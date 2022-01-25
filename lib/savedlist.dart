import 'package:flutter/material.dart';
import 'database/anime.dart' show Anime, DataBaseHelper;

class SavedList extends StatelessWidget {
  const SavedList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
      ),
      body: FutureBuilder<List<Anime>>(
        future: DataBaseHelper.instance.likedList(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return StatefulBuilder(
            builder: (context, setState) {
              return ListView.builder(
                itemCount: snapshot.data?.length,
                itemBuilder: (context, index) {
                  var anime = snapshot.data![index];
                  return Dismissible(
                    key: UniqueKey(),
                    direction: DismissDirection.startToEnd,
                    background: Container(
                      alignment: Alignment.centerLeft,
                      color: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: const Text(
                        "Remove from List",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    onDismissed: (direction) {
                      DataBaseHelper.instance.remove(anime.id).then(
                        (value) {
                          setState(
                            () {
                              snapshot.data?.removeAt(
                                index,
                              );
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Successfully Removed ${anime.name}",
                                  ),
                                  action: SnackBarAction(
                                    label: "UNDO",
                                    onPressed: () async {
                                      DataBaseHelper.instance
                                          .add(
                                        anime,
                                      )
                                          .then(
                                        (value) {
                                          setState(
                                            () {
                                              snapshot.data?.insert(
                                                index,
                                                anime,
                                              );
                                            },
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  dismissDirection: DismissDirection.horizontal,
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                    child: Card(
                      color: Colors.grey[900]?.withOpacity(.5),
                      child: ListTile(
                        title: Text(
                          anime.name,
                        ),
                        // subtitle: Text(snapshot.data?[index]['date']),
                        trailing: const Icon(
                          Icons.download,
                        ),
                        onTap: () {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            '/anime',
                            ModalRoute.withName('/home'),
                            arguments: anime.id,
                          );
                        },
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
