import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'search.dart';
import 'config.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentPage = 1;
  bool _usingService = false;
  bool _errorLock = false;
  bool _hasAnime = true;
  final List<Anime> _list = [];

  final ScrollController _controller = ScrollController();
  final http.Client client = http.Client();
  Widget? body;
  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      double maxscroll = _controller.position.maxScrollExtent;
      double currentPixel = _controller.position.pixels;
      if (maxscroll == currentPixel) {
        // current_page += 1;
        logger.d("adding...");
        setState(() {
          
        });
        // _getMore().then((value) {
        //   setState(() {});
        // });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0,
          onTap: (value) {
            switch (value) {
              case 1:
                showSearch(context: context, delegate: SearchAnime());
                break;
              default:
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.subtitles), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'search',
            )
          ]),
      body: FutureBuilder(
        future: _initHome(),
        builder: (context, snapshot) {
          if (snapshot.hasData) return snapshot.data as Widget;
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.grey,
            ),
          );
        },
      ),
    );
  }

  Future<Widget?> _initHome() async {
    // if (_usingService) return null;
    _usingService = true;
    try {
      http.Response res = await client
          .get(Uri.http(baseServer, "/home", {"page": "$_currentPage"}));
      Map json = jsonDecode(res.body);
      if (res.statusCode >= 200 && res.statusCode < 299) {
        bool status = json['status'];
        if (!status) {
          
          return Center(
            child: Text("Error!: " + json['error'].toString()),
          );
        } else {
          for (var i in json['data']) {
            _list.add(Anime(i['name'], i['href'], i['date'], i['image']));
          }
          return RefreshIndicator(
            onRefresh: _refreshHome,
            child: ListView.separated(
                controller: _controller,
                itemBuilder: (context, index) {
                  if (index == _list.length) {
                    return const LinearProgressIndicator(
                      color: Colors.grey,
                    );
                  }
                  return ListTile(
                    // leading: Image(image: CachedNetworkImageProvider(anime[index].image)),
                    title: Text(_list[index].name),
                    subtitle: Text(_list[index].date),
                    onTap: () {
                      Navigator.of(context)
                          .pushNamed('/anime', arguments: _list[index].href);
                    },
                  );
                },
                separatorBuilder: (context, index) {
                  return const SizedBox(
                    height: 2,
                  );
                },
                itemCount: _list.length + 1),
          );
        }
      } else {
        return Center(
          child: Text("Error!: " + json['error'].toString()),
        );
      }
    } on SocketException {
      return const Center(
        child: Text("Error!: No Internet Connections!"),
      );
    } on HttpException {
      return const Center(
        child: Text("Error!: HttpException"),
      );
    } on FormatException {
      return const Center(
        child: Text("Error(FormatException): Failed to format data"),
      );
    } catch (e) {
      return Center(
        child: Text("Error!: " + e.toString()),
      );
    }
  }

  Future<void> _refreshHome() async {
    _currentPage = 1;
    _list.clear();
    await _getMore();
    return;
    // setState(() {});
  }

  Future<void> _getMore() async {
    if (_usingService) return;
    if (!_hasAnime) return;
    _usingService = true;
    try {
      http.Response res = await client
          .get(Uri.http(baseServer, "/home", {"page": "$_currentPage"}));
      Map json = jsonDecode(res.body);
      if (res.statusCode >= 200 && res.statusCode < 299) {
        bool status = json['status'];
        if (!status) {
          showsnack("Error!: " + json['error'].toString());
          return;
        } else {
          int next = int.parse(json['next']);
          if (_currentPage == next) {
            _hasAnime = false;
            return;
          }
          _currentPage = next;

          for (var i in json['data']) {
            _list.add(Anime(i['name'], i['href'], i['date'], i['image']));
          }
          _usingService = false;
        }
      } else {
        showsnack("Error!: " + json['error'].toString());
        return;
      }
    } on SocketException {
      showsnack("Error(SocketException): No Internet Connections!");
    } on HttpException {
      showsnack("Error!: HttpException");
      return;
    } on FormatException {
      showsnack("Error(FormatException): Failed to format data");
      return;
    } catch (e) {
      showsnack("Error!: " + e.toString());
      return;
    }
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
}

class Anime {
  final String name;
  final String href;
  final String date;
  final String image;
  Anime(this.name, this.href, this.date, this.image);
}
