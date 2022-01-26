import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'config.dart';

class Loading extends StatefulWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  Widget _child = const CircularProgressIndicator(color: Colors.green,);

  void prehome() async {
    Uri url = Uri.http(baseServer, '/');

    try {
      await http.get(url);
    } on SocketException {

      setState(() {
        _child = const Text("Connection Error");
      });
    } catch (C) {
      
      logger.e(C);
      setState(() {
        _child = Text("Error $C");
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('No Connection!'),
        action: SnackBarAction(
          label: 'Exit',
          onPressed: () {
            exit(0);
          },
        ),
      ));
      Future.delayed(const Duration(seconds: 10), () {
        exit(0);
      });
      return;
    }
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  void initState() {
    super.initState();
    prehome();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _child),
    );
  }
}
