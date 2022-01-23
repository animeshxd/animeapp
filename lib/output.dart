import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
// import 'package:better_player/better_player.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:http/http.dart' as http;
import 'package:wakelock/wakelock.dart';
import 'config.dart';
import 'custompanel.dart';
import 'package:url_launcher/url_launcher.dart';

class OutputAnime extends StatefulWidget {
  const OutputAnime({Key? key}) : super(key: key);

  @override
  State<OutputAnime> createState() => _OutputAnimeState();
}

class _OutputAnimeState extends State<OutputAnime> {
  final FijkPlayer _player = FijkPlayer();
  List _anime = [];
  String _currentUrl = "";
  String _currentRef = '';
  final sinkStream = SinkStream();
  final _broadcast = SinkStreamBroadCast();
  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    // _getdemo('');
    //
  }

  Future<void> initVideo(String url, String referer) async {
    FijkLog.setLevel(FijkLogLevel.Error);
    if (_player.value.state != FijkState.end) {
      await _player.reset();
    }

    _player.enterFullScreen();
    await _player.setOption(
        FijkOption.formatCategory, "headers", "Referer: $referer");
    await _player.setOption(FijkOption.playerCategory, 'start-on-prepared', 1);
    await _player.setOption(FijkOption.playerCategory, "packet-buffering", 0);
    await _player.setDataSource(url, autoPlay: true).catchError((error) {});
  }

  Future<Widget> getSources(String data) async {
    try {
      Uri url = Uri.http(baseServer, '/stream' + data);
      http.Response res = await http.get(url);
      // print(res.body);
      if ((200 >= res.statusCode && 299 <= res.statusCode)) {
        return Center(
            child:
                Text("ServerSide Unexpected Error: Status ${res.statusCode}"));
      }
      Map _data = json.decode(res.body);
      if (!_data['status']) {
        return Center(
            child: Text(
                "ServerSide Unexpected Error: Status ${res.statusCode} ${_data['error']}"));
      }
      _anime = _data['data'];
      if (_anime.isEmpty) {
        return const Center(child: Text("Error: Can't Find Playable Sources"));
      }
      for (var i in _anime) {
        if (i['quality'] == 'HIGH') {
          _currentUrl = i['stream_url'].toString();
          _currentRef = i['referer'].toString();
          break;
        }
      }
      if (_currentUrl.isNotEmpty) initVideo(_currentUrl, _currentRef);
      var sinkdata = {
        "download":
            _data['iframe'].toString().replaceAll("streaming.php", "download"),
        "name": _data['name'],
        "next": _data['next'],
        "previous": _data['previous'],
      };
      _broadcast.sink.add(sinkdata);

      return FijkView(
        player: _player,
        color: Colors.black,
        // fs: false,
        panelBuilder: (player, data, context, viewSize, texturePos) {
          return CustomFijkPanel(
              title: _data['name'].toString(),
              player: player,
              buildContext: context,
              viewSize: viewSize,
              texturePos: texturePos);
        },
      );
    } on SocketException {
      return const Center(child: Text("No Internet Connections"));
    } catch (e) {
      return Center(
          child: Text("ServerSide Unexpected Error: ${e.toString()}"));
    }
  }

  /*
  Future<Widget> _getdemo(String data) async {
    List _data = [
      {
        "stream_url":
            "https://vidstreamingcdn.com/cdn25/e420acfb2abc9b10377f59c58eb8d84e/EP.1.v1.1639316347.360p.mp4?mac=tTBd%2F6VePMVXC%2BVt4csYXvigilqoi5f%2FCqj9jj5DZXs%3D&vip=117.226.148.182&expiry=1642680973387",
        "quality": 360,
        "referer": "https://gogoplay.io/"
      },
      {
        "stream_url":
            "https://vidstreamingcdn.com/cdn25/e420acfb2abc9b10377f59c58eb8d84e/EP.1.v1.1639316347.480p.mp4?mac=bxVvyY9Ndw9kYcQ3zOQjpSKABtROUnwVrzgDOgRiKs8%3D&vip=117.226.148.182&expiry=1642680973460",
        "quality": 480,
        "referer": "https://gogoplay.io/"
      },
      {
        "stream_url":
            "https://vidstreamingcdn.com/cdn25/e420acfb2abc9b10377f59c58eb8d84e/EP.1.v1.1639316347.720p.mp4?mac=HwVxVIvisrSwajpqytW2S%2FS8rDbrt7aGbrA7ijQGqX8%3D&vip=117.226.148.182&expiry=1642680973523",
        "quality": 720,
        "referer": "https://gogoplay.io/"
      },
      {
        "stream_url":
            "https://vidstreamingcdn.com/cdn25/e420acfb2abc9b10377f59c58eb8d84e/EP.1.v1.1639316347.1080p.mp4?mac=W80SQ22K%2Flei%2Fk%2FDcOIGDtvWuynI2NL%2BjkC2uZfFmfk%3D&vip=117.226.148.182&expiry=1642680973626",
        "quality": 1080,
        "referer": "https://gogoplay.io/"
      },
      {
        "stream_url":
            "https://vidstreamingcdn.com/cdn25/e420acfb2abc9b10377f59c58eb8d84e/EP.1.v1.1639316347.720p.mp4?mac=HwVxVIvisrSwajpqytW2S%2FS8rDbrt7aGbrA7ijQGqX8%3D&vip=117.226.148.182&expiry=1642680973523",
        "quality": "HIGH",
        "referer": "https://gogoplay.io/"
      },
      {
        "stream_url":
            "https://gogo-cdn.com/download.php?url=aHR0cHM6LyAdrefsdsdfwerFrefdsfrersfdsrfer363435349AdeqwrwedffryretgsdFrsftrsvfsfsrjZG4yNS5hbmljZG4uc3RyZWFtL3VzZXIxMzQyL2U0MjBhY2ZiMmFiYzliMTAzNzdmNTljNThlYjhkODRlL0VQLjEudjEuMTYzOTMxNjM0Ny4zNjBwLm1wND90b2tlbj1NT2kyTS1PdFRvS0o0RHFjaG8xaG5nJmV4cGlyZXM9MTY0MjY4ODE3MyZpZD0yOTgyOA==?token=HQxz45YgncUr-IFce7MMUw&expires=1642688349&id=29828",
        "quality": 360,
        "referer": "https://gogoplay.io/"
      },
      {
        "stream_url":
            "https://gogo-cdn.com/download.php?url=aHR0cHM6LyURASDGHUSRFSJGYfdsffsderFStewthsfSFtrfteAdrefsdsdfwerFrefdsfrersfdsrfer36343534sdf9jZG4yNS5hbmljZG4uc3RyZWFtL3VzZXIxMzQyL2U0MjBhY2ZiMmFiYzliMTAzNzdmNTljNThlYjhkODRlL0VQLjEudjEuMTYzOTMxNjM0Ny40ODBwLm1wND90b2tlbj1PaTY1NW5fZ29vMkZVNDd1X3ZNbDRBJmV4cGlyZXM9MTY0MjY4ODE3MyZpZD0yOTgyOA==?token=HQxz45YgncUr-IFce7MMUw&expires=1642688349&id=29828",
        "quality": 480,
        "referer": "https://gogoplay.io/"
      },
      {
        "stream_url":
            "https://gogo-cdn.com/download.php?url=aHR0cHM6LyAawehyfcghysfdsDGDYdgdsfsdfwstdgdsgtert9AdeqwrwedffryretgsdFrsftrsvfsfsrjZG4yNS5hbmljZG4uc3RyZWFtL3VzZXIxMzQyL2U0MjBhY2ZiMmFiYzliMTAzNzdmNTljNThlYjhkODRlL0VQLjEudjEuMTYzOTMxNjM0Ny43MjBwLm1wND90b2tlbj1kV293MEQ5b1IxNmF1ZWItMHIzNTZRJmV4cGlyZXM9MTY0MjY4ODE3MyZpZD0yOTgyOA==?token=HQxz45YgncUr-IFce7MMUw&expires=1642688349&id=29828",
        "quality": 720,
        "referer": "https://gogoplay.io/"
      },
      {
        "stream_url":
            "https://gogo-cdn.com/download.php?url=aHR0cHM6LyAawehyfcghysfdsDGDYdgdsfsdfwstdgdsgtert9AdrefsdsdfwerFrefdsfrersfdsrfer36343534jZG4yNS5hbmljZG4uc3RyZWFtL3VzZXIxMzQyL2U0MjBhY2ZiMmFiYzliMTAzNzdmNTljNThlYjhkODRlL0VQLjEudjEuMTYzOTMxNjM0Ny4xMDgwcC5tcDQ/dG9rZW49a0NuazFwSlNydTdHbzQ4SFVuQjVtZyZleHBpcmVzPTE2NDI2ODgxNzMmaWQ9Mjk4Mjg=?token=HQxz45YgncUr-IFce7MMUw&expires=1642688349&id=29828",
        "quality": 1080,
        "referer": "https://gogoplay.io/"
      },
      {
        "stream_url":
            "https://gogo-cdn.com/download.php?url=aHR0cHM6LyAawehyfcghysfdsDGDYdgdsfsdfwstdgdsgtert9AdeqwrwedffryretgsdFrsftrsvfsfsrjZG4yNS5hbmljZG4uc3RyZWFtL3VzZXIxMzQyL2U0MjBhY2ZiMmFiYzliMTAzNzdmNTljNThlYjhkODRlL0VQLjEudjEuMTYzOTMxNjM0Ny43MjBwLm1wND90b2tlbj1kV293MEQ5b1IxNmF1ZWItMHIzNTZRJmV4cGlyZXM9MTY0MjY4ODE3MyZpZD0yOTgyOA==?token=HQxz45YgncUr-IFce7MMUw&expires=1642688349&id=29828",
        "quality": "HIGH",
        "referer": "https://gogoplay.io/"
      }
    ];

    _anime = _data;
    return ListView.separated(
      separatorBuilder: (context, index) {
        return const SizedBox(
          width: 5,
        );
      },
      scrollDirection: Axis.horizontal,
      itemCount: _data.length,
      itemBuilder: (context, index) {
        String label = _data[index]['quality'].toString();
        // String url = _data[index]['stream_url'].toString();
        // String referer = _data[index]['referer'].toString();
        return ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.play_arrow),
            label: Text(label));
      },
    );
  }
*/
  @override
  void dispose() {
    super.dispose();
    _player.release();
    Wakelock.disable();
  }

  @override
  Widget build(BuildContext context) {
    String _todata = ModalRoute.of(context)?.settings.arguments as String;
    return Scaffold(
        appBar: AppBar(
          // title: Text(_todata[1]),
          actions: [
            // previous
            StreamBuilder<Map>(
                stream: _broadcast.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!['previous'] != null) {
                      return IconButton(
                          tooltip: "Previous Episode",
                          onPressed: () {
                            Navigator.of(context).popAndPushNamed(
                              '/output',
                              arguments: snapshot.data!['previous'],
                            );
                          },
                          icon: const Icon(Icons.navigate_before));
                    } else {
                      return Container();
                    }
                  } else {
                    return Container();
                  }
                }),
            // next
            StreamBuilder<Map>(
                stream: _broadcast.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!['next'] != null) {
                      return IconButton(
                          tooltip: "Next Episode",
                          onPressed: () {
                            Navigator.of(context).popAndPushNamed(
                              '/output',
                              arguments: snapshot.data!['next'],
                            );
                          },
                          icon: const Icon(Icons.navigate_next));
                    } else {
                      return Container();
                    }
                  } else {
                    return Container();
                  }
                }),
            IconButton(
                onPressed: () {
                  if (_player.value.fullScreen) {
                    _player.exitFullScreen();
                  } else {
                    _player.enterFullScreen();
                  }
                },
                icon: _player.value.fullScreen
                    ? const Icon(Icons.fullscreen)
                    : const Icon(Icons.fullscreen_exit)),

            //download
            StreamBuilder<Map>(
              stream: _broadcast.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!['download'] != null) {
                    return IconButton(
                        onPressed: () async {
                          if (snapshot.hasData) {
                            if (await canLaunch(
                                snapshot.data!['download'] as String)) {
                              await launch(
                                  snapshot.data!['download'] as String);
                            }
                          }
                        },
                        icon: const Icon(Icons.download));
                  } else {
                    return Container();
                  }
                } else {
                  return Container();
                }
              },
            ),
            PopupMenuButton(
              tooltip: "Select Quality",
              icon: const Icon(Icons.high_quality),
              itemBuilder: (context) {
                return _anime.map((e) => fixQuality(e)).toList();
              },
            )
          ],
        ),
        body: FutureBuilder(
          future: getSources(_todata),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return snapshot.data as Widget;
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ));
  }

  PopupMenuItem fixQuality(data) {
    String label = data['quality'].toString();
    String url = data['stream_url'].toString();
    String referer = data['referer'].toString();
    return PopupMenuItem(
      onTap: () {
        _player.reset().then((value) => initVideo(url, referer));
      },
      child: Text(label),
    );
  }
}

class Quality {
  final String url;
  final String quality;

  Quality(this.url, this.quality);
}

class QualityItems {}

class SinkStream {
  final _streamcontrolller = StreamController<String>.broadcast();
  StreamSink<String> get sink => _streamcontrolller.sink;
  Stream<String> get stream => _streamcontrolller.stream;
}

class SinkStreamBroadCast {
  final _streamcontrolller = StreamController<Map>.broadcast();
  StreamSink<Map> get sink => _streamcontrolller.sink;
  Stream<Map> get stream => _streamcontrolller.stream;
}
