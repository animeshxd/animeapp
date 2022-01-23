import 'dart:convert';
import 'dart:io';

import 'config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AnimeEpisode extends StatefulWidget {
  const AnimeEpisode({Key? key}) : super(key: key);

  @override
  _AnimeEpisodeState createState() => _AnimeEpisodeState();
}

class _AnimeEpisodeState extends State<AnimeEpisode> {
  bool errorlock = false;
  final ScrollController _controller = ScrollController();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String data = ModalRoute.of(context)?.settings.arguments as String;
    return Scaffold(
      body: FutureBuilder(
        future: _getData(data, _controller),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }
          if (snapshot.hasData) {
            return snapshot.data as Widget;
          } else {
            return const SafeArea(
              child: LinearProgressIndicator(
                color: Colors.grey,
                // backgroundColor: Colors.grey,
              ),
            );
          }
        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Colors.grey,
      //   onPressed: () {
      //     Navigator.of(context).pop();
      //   },
      //   child: const Icon(Icons.arrow_back),
      //   tooltip: "Go Back",
      // ),
    );
  }

  Future<Widget> _getData(String data, ScrollController _controller) async {
    Uri url = Uri.http(baseServer, data);
    bool valid = false;
    AnimeFull anime;
    try {
      http.Response res = await http.get(url);
      var jsondata = jsonDecode(res.body);
      logger.d("Received Status Code: ${res.statusCode}");

      if (200 > res.statusCode && res.statusCode > 299) {
        if (res.statusCode > 499) {
          return const Center(
            child: Text("Unexpected ServerSide Error!"),
          );
        } else {
          return Center(
            child: Text(jsondata['error']),
          );
        }
      } else {
        valid = jsondata['status'];
        if (!valid) return Center(child: Text(jsondata['error'] as String));
        anime = AnimeFull(
          name: jsondata['name'],
          image: jsondata['image'],
          description: jsondata['description'],
          data: jsondata['data'],
          controller: _controller,
        );
      }
    } on SocketException {
      return const Center(child: Text("Error: No Internet Connections!"));
    } on HttpException {
      return const Center(child: Text("Error: Unexpected Connection Error!"));
    } on FormatException {
      return const Center(child: Text("Error: Unexpected ServerSide Error!"));
    } catch (e) {
      return Center(child: Text("Error: ${e.toString()}"));
    }

    if (!valid) return const Center(child: Text("No Result Found"));
    return anime;
  }
}

class AnimeFull extends StatefulWidget {
  final String name;
  final String image;
  final String description;
  final List data;
  final ScrollController controller;
  const AnimeFull(
      {Key? key,
      required this.name,
      required this.image,
      required this.description,
      required this.data,
      required this.controller})
      : super(key: key);

  @override
  _AnimeFullState createState() =>
      // ignore: no_logic_in_create_state
      _AnimeFullState(name, image, description, data, controller);
}

class _AnimeFullState extends State<AnimeFull> {
  final String name;
  final String image;
  final String description;
  final ScrollController controller;
  List data;
  int total = 0;
  bool showDownloads = false;
  bool showDescription = false;
  final Map<String, List> _temp = {};

  List<DropdownMenuItem<String>> items = [];
  Widget? _sliver;
  String? _dropdown;
  _AnimeFullState(
      this.name, this.image, this.description, this.data, this.controller)
      : total = data.length;

  String getValidEpisodeNumber(Object? raw) {
    String _temp = raw.toString();
    String no = _temp.split('-').last;
    RegExp _numeric = RegExp(r'^-?[0-9]+$');
    return _numeric.hasMatch(no) ? no : "~";
  }

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < data.length; i += 25) {
      List __temp =
          data.sublist(i, i + 25 > data.length ? data.length : i + 25);

      String _episodeNumber =
          "${getValidEpisodeNumber(__temp.first['href'])} - ${getValidEpisodeNumber(__temp.last['href'])}";
      _dropdown ??= _episodeNumber;
      _temp[_episodeNumber] = __temp;

      items.add(DropdownMenuItem(
        // enabled: false,
        value: _episodeNumber,
        child: Text(_episodeNumber),
      ));
      // print(_dropdown);
      // print(items);

      // _temp.add();
    }
    data = [];
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(controller: controller, slivers: [
      SliverAppBar(
        pinned: true,
        expandedHeight: 252,
        flexibleSpace: FlexibleSpaceBar(
          background: SingleChildScrollView(
              child: Image.network(
            image,
            errorBuilder: (context, error, stackTrace) {
              return Container();
            },
            fit: BoxFit.cover,
          )),
        ),
      ),
      SliverSafeArea(
          sliver: SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 13),
        sliver: SliverList(
            delegate: SliverChildListDelegate([
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const SizedBox(
              height: 3,
            ),
            Text(
              name,
              style: const TextStyle(
                  // color: Colors.white,
                  letterSpacing: 1.5,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 10,
            ),
            const Divider(
              height: 1,
              // color: Colors.grey,
            ),
            ListTile(
              style: ListTileStyle.drawer,
              leading: const Text(
                "DESCRIPTION",
                style: TextStyle(
                    // color: Colors.grey,
                    letterSpacing: 1,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
              trailing: showDescription
                  ? const Icon(Icons.arrow_drop_up)
                  : const Icon(Icons.arrow_drop_down),
              onTap: () {
                setState(() {
                  showDescription = !showDescription;
                  if (showDownloads) showDownloads = false;
                });
              },
            ),
            Visibility(
              visible: showDescription,
              child: Text(
                description,
                style: const TextStyle(
                  // color: Colors.grey,
                  letterSpacing: 1,
                  fontSize: 15,
                ),
              ),
            ),
            const Divider(
              height: 1,
              // color: Colors.grey,
            ),
            ListTile(
              title: Text(
                "Total: $total",
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  letterSpacing: 1,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: DropdownButton<String>(
                icon: const Icon(Icons.arrow_drop_down),
                value: _dropdown,
                items: items,
                // elevation: 0,
                onChanged: (value) {
                  setState(() {
                    _dropdown = value!;
                    showDownloads = true;
                    _sliver = SliverList(
                      // gridDelegate:
                      //     const SliverGridDelegateWithFixedCrossAxisCount(
                      //   crossAxisSpacing: 4,
                      //   mainAxisSpacing: 4,
                      //   crossAxisCount: 8,
                      // ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        String _no = _temp[value]![index]['name'];
                        String _url = _temp[value]![index]['href'];
                        return Card(
                          child: ListTile(
                            title: Text(
                              _no, /*style: TextStyle(fontSize: 14.5),*/
                            ),
                            trailing: const Icon(Icons.download),
                            onTap: () {
                              Navigator.of(context).pushNamed('/output', arguments: [_url, _no]);
                            },
                          ),
                        );
                      },
                          childCount: showDownloads ? _temp[value]?.length : 0,
                          addAutomaticKeepAlives: false
                          // controller: controller,
                          ),
                    );
                  });
                },
              ),
              onTap: () {
                setState(() {
                  if (showDescription) showDescription = false;
                  showDownloads = !showDownloads;
                });
              },
            ),
            const Divider(
              height: 0.1,
              // color: Colors.grey,
            ),
            const SizedBox(
              height: 10,
            )
          ])
        ], addAutomaticKeepAlives: false)),
      )),
      SliverVisibility(
        // visible: showDownloads,
        sliver: SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 13),
            sliver: _sliver),
      ),
      const SliverFillRemaining()
    ]);
  }
}
