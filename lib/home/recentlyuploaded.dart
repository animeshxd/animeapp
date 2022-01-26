import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import '../config.dart';
import '../model/anime_min.dart' show Anime;
import 'package:http/http.dart' as http;

class RecentlyUploaded extends StatefulWidget {
  const RecentlyUploaded({ Key? key }) : super(key: key);

  @override
  _RecentlyUploadedState createState() => _RecentlyUploadedState();
}

class _RecentlyUploadedState extends State<RecentlyUploaded> {

  List<Anime> anime = [];
  final ScrollController _controller = ScrollController();
  final SinkStream _sinkStream = SinkStream();

  int _nextPage = 1;
  bool _usingService = false;
  bool _hasAnime = true;
  bool _errorLock = false;
  
  @override
  void initState() {
    _controller.addListener(
      () {
        double maxscroll = _controller.position.maxScrollExtent;
        double currentPixel = _controller.position.pixels;
        // double delta = MediaQuery.of(context).size.height * 0.25;
        if (maxscroll == currentPixel) {
          // current_page += 1;
          logger.d("adding...");
          _getanime();
        }
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getanime(),
      builder: (context, future) {
        return StreamBuilder(
            stream: _sinkStream.stream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return RefreshIndicator(
                  onRefresh: () async {
                    _nextPage = 1;
                    anime.clear();
                    await _getanime();
                    showsnack(context, "Refresh Done");
                  },
                  child: ListView.separated(
                    separatorBuilder: (context, index) {
                      return const SizedBox();
                    },
                    // itemExtent: 10,
                    itemCount: anime.length + 1,
                    controller: _controller,
                    itemBuilder: (context, index) {
                      if (index == anime.length) {
                        return const LinearProgressIndicator(
                          color: Colors.grey,
                        );
                      }
                      return ListTile(
                        // leading: Image(image: CachedNetworkImageProvider(anime[index].image)),
                        title: Text(anime[index].name),
                        subtitle: Text(anime[index].date),
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed('/anime', arguments: anime[index].href);
                        },
                      );
                    },
                  ),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          );
      }
    );
  }

  Future<void> _getanime() async {
    if (!_hasAnime) return;
    if (_usingService) return;
    _usingService = true;

    try {
      http.Response res = await http
          .get(Uri.http(baseServer, "/home", {"page": _nextPage.toString()}));
      var jsondata = json.decode(res.body);
      logger.d("Received Status Code: ${res.statusCode}");

      if (200 > res.statusCode && res.statusCode > 299) {
        if (res.statusCode > 499) {
          showsnack(
            context,
            "Unexpected ServerSide Error!",
            label: 'Exit',
            func: () => exit(0),
          );
        } else {
          showsnack(
            context,
            jsondata['error'],
            label: 'Exit',
            func: () => exit(0),
          );
        }
      } else {
        bool valid = jsondata['status'];
        if (!valid) {
          showsnack(
            context,
            jsondata['error'],
            label: 'Exit',
            func: () => exit(0),
          );
          return;
        }
        // logger.d("Old length: ${anime.length}");
        for (var i in jsondata['data']) {
          anime.add(Anime(i['name'], i['href'], i['date'], i['image']));
        }
        // logger.d("new length: ${anime.length}");
        int _next = int.parse(jsondata['next']);
        if (_next == _nextPage) {
          _hasAnime = false;
        } else {
          _nextPage = _next;
        }
        _sinkStream.sink.add(true);
      }

      _usingService = false;
      _errorLock = false;
    } on SocketException {
      showsnack(
        context,
        "Error: No Internet Connections!",
        label: "Exit",
        func: () => exit(0),
      );

      return;
    } on HttpException {
      showsnack(
        context,
        "Error: Unexpected Connection Error!",
        label: "Exit App",
      );
      return;
    } on FormatException {
      showsnack(context, "Error: Unexpected ServerSide Error!");
      return;
    } catch (e) {
      logger.e(e);
      showsnack(context, "Error: $e");
      return;
    }

    if (anime.isEmpty) return;
    
  }

   void showsnack(BuildContext context, Object message,
      {String? label, Function()? func}) {
    _usingService = false;
    if (_errorLock) return;
    _errorLock = true;
    SnackBarAction? action;
    if (label != null) {
      func ??= () {
        exit(0);
      };
      action = SnackBarAction(label: label, onPressed: func);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message.toString()),
        action: action,
      ),
    );
    _errorLock = false;
  }

}

class SinkStream {
  final _streamcontrolller = StreamController<bool>();
  StreamSink<bool> get sink => _streamcontrolller.sink;
  Stream<bool> get stream => _streamcontrolller.stream;
}