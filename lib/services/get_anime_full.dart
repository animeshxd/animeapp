import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/anime_full.dart';
import '../config.dart';

Future<AnimeFull> getFullAnimeData(BuildContext context) async {
  var data = ModalRoute.of(context)?.settings.arguments as String;
  Uri url = Uri.http(baseServer, data);
  bool valid = false;

  try {
    http.Response res = await http.get(url);
    var jsondata = json.decode(res.body);
    logger.d("Received Status Code: ${res.statusCode}");

    if (200 > res.statusCode && res.statusCode > 299) {
      if (res.statusCode > 499) {
        throw "Unexpected ServerSide Error!";
      } else {
        throw jsondata['error'].toString();
      }
    } else {
      valid = jsondata['status'];
      if (!valid) throw jsondata['error'].toString();
      return AnimeFull.fromJson(jsondata);
    }
  } on SocketException {
    throw "Error: No Internet Connections!";
  } on HttpException {
    throw "Error: Unexpected Connection Error!";
  } on FormatException {
    throw "Error: Unexpected ServerSide Error!";
  } on http.ClientException catch (e) {
    throw "ClientSideError: ${e.message}";
  } on Exception catch (e) {
    throw "Error: ${e.toString()}";
  }
}
