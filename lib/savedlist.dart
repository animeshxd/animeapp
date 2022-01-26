import 'dart:async';

import 'package:flutter/material.dart';
import 'database/anime.dart' show Anime, DataBaseHelper;

class SavedList extends StatefulWidget {
  const SavedList({Key? key}) : super(key: key);

  @override
  _SavedListState createState() => _SavedListState();
}

class _SavedListState extends State<SavedList> {
  final StreamController<bool> _streamController =
      StreamController<bool>.broadcast();

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            ScaffoldMessenger.of(context).clearSnackBars();
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: FutureBuilder<List<Anime>>(
        future: DataBaseHelper.instance.likedList(),
        builder: (context, future) {
          if (!future.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (future.data!.isEmpty) {
            return const Center(child: Text("Empty List"));
          }

          return StreamBuilder<bool>(
            stream: _streamController.stream,
            initialData: true,
            builder: (context, stream) {
              if (future.data!.isEmpty) {
                return const Center(child: Text("Empty List"));
              }
              return ListView.builder(
                itemCount: future.data?.length,
                itemBuilder: (context, index) {
                  var anime = future.data![index];
                  return Dismissible(
                    key: Key(anime.id),
                    direction: DismissDirection.startToEnd,
                    onDismissed: (direction) async {
                      future.data?.removeAt(index);
                      await DataBaseHelper.instance.remove(anime.id);
                      _streamController.sink.add(true);
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Successfully Removed ${anime.name}"),
                          action: SnackBarAction(
                            label: "UNDO",
                            onPressed: () async {
                              await DataBaseHelper.instance.add(anime);
                              future.data?.insert(index, anime);
                              _streamController.sink.add(true);
                            },
                          ),
                          dismissDirection: DismissDirection.horizontal,
                        ),
                      );
                    },
                    child: Card(
                      color: Colors.grey[900]?.withOpacity(.5),
                      child: ListTile(
                        title: Text(anime.name),
                        subtitle: Text(anime.time.toString()),
                        // subtitle: Text(snapshot.data?[index]['date']),
                        trailing: const Icon(Icons.download),
                        onTap: () {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            '/anime',
                            ModalRoute.withName('/home'),
                            arguments: anime.id,
                          );
                        },
                      ),
                    ),
                    background: Container(
                      alignment: Alignment.centerLeft,
                      color: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: const [
                          Icon(Icons.delete_forever),
                          SizedBox(width: 10),
                          Text("Remove", style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
