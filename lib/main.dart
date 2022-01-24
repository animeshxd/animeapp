import 'package:flutter/material.dart';
import 'loading.dart';
import 'home.dart';
import '_newanime.dart';
import 'output.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      
      theme: ThemeData(
        primarySwatch: Colors.amber,
        primaryColor: Colors.grey,
        backgroundColor: Colors.black,
        scaffoldBackgroundColor: const Color(0x561F1C1C),
        appBarTheme: const AppBarTheme(backgroundColor: Colors.black54),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(backgroundColor: Colors.black, selectedItemColor: Colors.white),
        highlightColor: Colors.black54,
        canvasColor: Colors.grey[900],
        cardColor: const Color(0x561F1C1C),
        dividerColor: Colors.grey,
        textSelectionTheme: const TextSelectionThemeData(cursorColor: Colors.grey, selectionColor: Colors.grey, selectionHandleColor: Colors.grey),
        brightness: Brightness.dark,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const Loading(),
        '/home': (context) => const Home(),
        '/anime': (context) => const AnimeEpisode(),
        '/output': (context) => const OutputAnime()
      },
      // home: OutputAnime(),
    );
  }
}