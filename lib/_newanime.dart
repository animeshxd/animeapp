import 'dart:async';

import 'package:flutter/material.dart';
import 'database/anime.dart' show Anime, DataBaseHelper;
import 'model/anime_full.dart' show AnimeFull;
import 'savedlist.dart';
import 'search.dart';
import 'services/get_anime_full.dart' show getFullAnimeData;
import 'widgets/widget.dart';

class AnimeEpisode extends StatefulWidget {
  const AnimeEpisode({Key? key}) : super(key: key);

  @override
  _AnimeEpisodeState createState() => _AnimeEpisodeState();
}

class _AnimeEpisodeState extends State<AnimeEpisode> {
  final ScrollController _scrollController = ScrollController();
  final _streamSinkList = SinkStreamList();
  final _streamSinkString = SinkStreamString();
  final _likeunlike = SinkStreamAnime();

  @override
  void dispose() {
    _scrollController.dispose();
    _streamSinkList.dispose();
    _streamSinkString.dispose();
    super.dispose();
  }

  // final items = ['One', 'Two', 'Three', 'Four'];
  // String selectedValue = 'Four';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<AnimeFull>(
        future: getFullAnimeData(context),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
              ),
            );
          }
          if (snapshot.hasData) {
            AnimeFull anime = snapshot.data!;
            bool isSingle = anime.data.length <= 1;
            if (anime.data.isNotEmpty) {
              _streamSinkList.sink.add(anime.data.first);
              _streamSinkString.sink.add(
                "${anime.data.first.first['number']} - ${anime.data.first.last['number']}",
              );
            }

            return CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  pinned: !false,
                  // floating: true,
                  expandedHeight: MediaQuery.of(context).size.height * 0.39,
                  flexibleSpace: FlexibleSpaceBar(
                    background: SingleChildScrollView(
                      child: Image.network(
                        anime.image,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  actions: [
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return const SavedList();
                            },
                          ),
                        ).then(
                          (value) {
                            _likeunlike.sink.add(false);
                          },
                        );
                      },
                      icon: const Icon(Icons.bookmark),
                      tooltip: "search",
                    ),
                    StreamBuilder<bool>(
                      stream: _likeunlike.stream,
                      builder: (context, stream) {
                        return FutureBuilder<bool>(
                          future: DataBaseHelper.instance.isLiked(
                            anime.data.first.first['href'],
                          ),
                          builder: (context, future) {
                            return IconButton(
                              onPressed: () async {
                                future.data ?? false
                                    ? await DataBaseHelper.instance.remove(
                                        anime.data.first.first['href'],
                                      )
                                    : await DataBaseHelper.instance.add(
                                        Anime(
                                          id: anime.data.first.first['href'],
                                          name: anime.name,
                                        ),
                                      );
                                _likeunlike.sink.add(
                                  await DataBaseHelper.instance.isLiked(
                                    anime.data.first.first['href'],
                                  ),
                                );
                              },
                              icon: Icon(
                                future.data ?? false
                                    ? Icons.playlist_add_check
                                    : Icons.playlist_add,
                              ),
                              tooltip: "Add to list",
                            );
                          },
                        );
                      },
                    ),
                    IconButton(
                      onPressed: () {
                        showSearch(
                          context: context,
                          delegate: SearchAnime(),
                        );
                      },
                      icon: const Icon(Icons.search),
                      tooltip: "search",
                    )
                  ],
                ),
                SliverSafeArea(
                  sliver: SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 13),
                      // sliver: SliverList(
                      //     delegate: SliverChildListDelegate([
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              anime.name,
                              style: Theme.of(context).textTheme.headline6,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Divider(
                              height: 10,
                              thickness: 1.3,
                            ),
                            TextDropdown(
                              text: anime.description,
                              toSplit: 80,
                              style:
                                  Theme.of(context).textTheme.caption?.copyWith(
                                        fontSize: 15,
                                        letterSpacing: .25,
                                      ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Divider(
                              height: 10,
                              thickness: 1.3,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Total ${anime.total}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      ?.copyWith(
                                          fontSize: 17, letterSpacing: 1),
                                ),
                                if (!isSingle)
                                  StreamBuilder<String>(
                                    stream: _streamSinkString.stream,
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return Container();
                                      }

                                      return DropdownButton<String>(
                                        value: snapshot.data,
                                        onChanged: (value) {},
                                        items: anime.data
                                            .map<DropdownMenuItem<String>>(
                                          (value) {
                                            String key =
                                                "${value.first['number']} - ${value.last['number']}";
                                            return DropdownMenuItem(
                                              onTap: () {
                                                _streamSinkList.sink.add(value);
                                                _streamSinkString.sink.add(key);
                                              },
                                              value: key,
                                              child: Text(key),
                                            );
                                          },
                                        ).toList(),
                                        icon: const Icon(Icons.arrow_drop_down),
                                        iconSize: 30,
                                        underline: const SizedBox(),
                                      );
                                    },
                                  ),
                              ],
                            ),
                            const Divider(
                              height: 10,
                              thickness: 1.3,
                            ),
                            const SizedBox(
                              height: 1,
                            ),
                          ],
                        ),
                      )
                      // ])
                      // )
                      ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  sliver: StreamBuilder<List>(
                    stream: _streamSinkList.stream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return Card(
                                child: ListTile(
                                  title: Text(snapshot.data?[index]['name']),
                                  subtitle: Text(snapshot.data?[index]['date']),
                                  trailing: const Icon(Icons.download),
                                  onTap: () {
                                    Navigator.of(context).pushNamed(
                                      '/output',
                                      arguments: snapshot.data?[index]['href'],
                                    );
                                  },
                                ),
                              );
                            },
                            childCount: snapshot.data?.length,
                          ),
                        );
                      } else {
                        return const SliverToBoxAdapter(
                          child: LinearProgressIndicator(),
                        );
                      }
                    },
                  ),
                ),
                const SliverFillRemaining()
              ],
            );
          } else {
            return const LinearProgressIndicator();
          }
        },
      ),
    );
  }
}



class SinkStreamList {
  final _streamcontrolller = StreamController<List>();
  StreamSink<List> get sink => _streamcontrolller.sink;
  Stream<List> get stream => _streamcontrolller.stream;

  void dispose() {
    _streamcontrolller.close();
  }
}

class SinkStreamString {
  final _streamcontrolller = StreamController<String>();
  StreamSink<String> get sink => _streamcontrolller.sink;
  Stream<String> get stream => _streamcontrolller.stream;
  void dispose() {
    _streamcontrolller.close();
  }
}

class SinkStreamAnime {
  final _streamcontrolller = StreamController<bool>.broadcast();
  StreamSink<bool> get sink => _streamcontrolller.sink;
  Stream<bool> get stream => _streamcontrolller.stream;
  void dispose() {
    _streamcontrolller.close();
  }
}
