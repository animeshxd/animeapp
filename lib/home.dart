import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'search.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _nextPage = 1;
  List<Anime> anime = [];
  Widget? body;
  bool _usingService = false;
  bool _hasAnime = true;
  bool _errorLock = false;

  final ScrollController _controller = ScrollController();
  final SinkStream _sinkStream = SinkStream();



  Future<void> _getanime() async {
    if (!_hasAnime) return;
    if (_usingService) return;
    _usingService = true;

    try {
      http.Response res = await http
          .get(Uri.http(baseServer, "/home", {"page": _nextPage.toString()}));
      var jsondata = jsonDecode(res.body);
      logger.d("Received Status Code: ${res.statusCode}");

      if (200 > res.statusCode && res.statusCode > 299) {
        if (res.statusCode > 499) {
          showsnack("Unexpected ServerSide Error!",
              label: 'Exit', func: () => exit(0));
        } else {
          showsnack(jsondata['error'], label: 'Exit', func: () => exit(0));
        }
      } else {
        bool valid = jsondata['status'];
        if (!valid) {
          showsnack(jsondata['error'], label: 'Exit', func: () => exit(0));
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
      showsnack("Error: No Internet Connections!",
          label: "Exit", func: () => exit(0));

      return;
    } on HttpException {
      showsnack("Error: Unexpected Connection Error!");
      return;
    } on FormatException {
      showsnack("Error: Unexpected ServerSide Error!");
      return;
    } catch (e) {
      logger.e(e);
      showsnack("Error: $e");
      return;
    }

    if (anime.isEmpty) return;
    /*
    setState(() {
      body = RefreshIndicator(
        onRefresh: () async {
          _nextPage = 1;
          anime.clear();
          await _getanime();
          showsnack("Refresh Done");
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
    });*/
  }

  void showsnack(Object message, {String? label, Function()? func}) {
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message.toString()),
      action: action,
    ));
    _errorLock = false;
  }

  @override
  void initState() {
    super.initState();
    _getanime();
    _controller.addListener(() {
      double maxscroll = _controller.position.maxScrollExtent;
      double currentPixel = _controller.position.pixels;
      // double delta = MediaQuery.of(context).size.height * 0.25;
      if (maxscroll == currentPixel) {
        // current_page += 1;
        logger.d("adding...");
        _getanime();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder(
          stream: _sinkStream.stream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return RefreshIndicator(
                onRefresh: () async {
                  _nextPage = 1;
                  anime.clear();
                  await _getanime();
                  showsnack("Refresh Done");
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
        ),
        bottomNavigationBar: BottomNavigationBar(
            currentIndex: 0,
            // type: BottomNav igationBarType.shifting,
            // selectedIconTheme: IconThemeData(color: Colors.grey),
            onTap: (value) {
              switch (value) {
                case 1:
                  showSearch(context: context, delegate: SearchAnime());
                  break;
                default:
              }
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'search',
              )
            ]));
  }
}

class Anime {
  final String name;
  final String href;
  final String date;
  final String image;
  Anime(this.name, this.href, this.date, this.image);
}

class SinkStream {
  final _streamcontrolller = StreamController<bool>();
  StreamSink<bool> get sink => _streamcontrolller.sink;
  Stream<bool> get stream => _streamcontrolller.stream;
}
