import 'package:flutter/material.dart';
import 'search.dart' show SearchAnime;
import 'home/recentlyuploaded.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    // _getanime();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // leading: IconButton(onPressed: () {}, icon: const Icon(Icons.done)),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(context: context, delegate: SearchAnime());
            },
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () async {
              await Navigator.of(context).pushNamed('/saved');
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
            icon: const Icon(Icons.bookmark),
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) {
              return <PopupMenuItem>[
                PopupMenuItem(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      Icon(Icons.settings),
                      Text("settings"),
                    ],
                  ),
                ),
              ];
            },
          )
        ],
      ),
      body: const RecentlyUploaded(),
    );
  }
}
