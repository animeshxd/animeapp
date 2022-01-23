import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'config.dart';
import 'package:http/http.dart' as http;

class SearchAnime extends SearchDelegate<String> {
  bool _usingservice = false;
  bool errorlock = false;

  @override
  List<Widget>? buildActions(BuildContext context) {
    // TODO: implement buildActions
    return [];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    return null;
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder(
        future: getFutureResult(query),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }
          if (snapshot.hasData) {
            return snapshot.data as Widget;
          } else {
            return const LinearProgressIndicator(
              color: Colors.grey,
            );
          }
        });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: implement buildSuggestions
    return Container();
  }

  Future<Widget> getFutureResult(String search) async {
    List<SearchResault> anime = [];
    bool valid = false;
    if (_usingservice) return Container();
    _usingservice = true;
    try {
      http.Response res =
          await http.get(Uri.http(baseServer, "/search", {"query": search}));
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
        logger.d("Old length: ${anime.length}");
        for (var i in jsondata['data']) {
          anime.add(SearchResault(int.parse(i['total']), i['name'], i['href']));
        }
        logger.d("new length: ${anime.length}");
        valid = jsondata['status'];
      }

      _usingservice = false;
    } on SocketException {
      _usingservice = false;
      return const Center(child: Text("Error: No Internet Connections!"));
    } on HttpException {
      _usingservice = false;
      return const Center(child: Text("Error: Unexpected Connection Error!"));
    } on FormatException {
      _usingservice = false;
      return const Center(child: Text("Error: Unexpected ServerSide Error!"));
    } catch (e) {
      _usingservice = false;
      return Center(child: Text("Error: ${e.toString()}"));
    }

    if (!valid) return const Center(child: Text("No Result Found"));
    return ListView.builder(
      itemCount: anime.length,
      itemBuilder: (context, index) {
        return ListTile(
          subtitle: Text("Total: ${anime[index].total}"),
          title: Text(anime[index].name),
          onTap: () {
            Navigator.popUntil(context, ModalRoute.withName('/home'));
            Navigator.of(context)
                .pushNamed('/anime', arguments: anime[index].href);
          },
        );
      },
    );
  }
}

class SearchResault {
  //{"total": total if total.isdigit() else 1, "name": list_.text, "href": result}
  final int total;
  final String name;
  final String href;

  SearchResault(this.total, this.name, this.href);
}
