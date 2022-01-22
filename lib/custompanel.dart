import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/material.dart';

class CustomFijkPanel extends StatefulWidget {
  final FijkPlayer player;
  final BuildContext buildContext;
  final Size viewSize;
  final Rect texturePos;
  final String title;

  const CustomFijkPanel({
    Key? key,
    required this.player,
    required this.buildContext,
    required this.viewSize,
    required this.texturePos,
    required this.title,
  }) : super(key: key);

  @override
  _CustomFijkPanelState createState() => _CustomFijkPanelState();
}

class _CustomFijkPanelState extends State<CustomFijkPanel> {
  FijkPlayer get player => widget.player;
  bool _hideshow = true;

  @override
  void initState() {
    super.initState();
    widget.player.addListener(_playerValueChanged);
  }

  void _playerValueChanged() {
    FijkValue value = player.value;

    bool started =
        (value.state == FijkState.prepared || value.state == FijkState.started);

    if (started) {
      // print(_loading);
      setState(() {});
    }

    if (value.state == FijkState.error) {
      setState(() {});
    }

    if (value.completed && value.fullScreen) {
      player.exitFullScreen();
      // player.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    /*Rect rect = Rect.fromLTRB(
        max(0.0, widget.texturePos.left),
        max(0.0, widget.texturePos.top),
        min(widget.viewSize.width, widget.texturePos.right),
        min(widget.viewSize.height, widget.texturePos.bottom));*/

    return Builder(builder: (context) {
      FijkValue value = player.value;
      // print(value.state);
      if (value.state == FijkState.error) {
        return Container(
          color: Theme.of(context).backgroundColor,
          child: const Center(
            child: Text("An Error Occured"),
          ),
        );
      }
      if (value.state == FijkState.asyncPreparing) {
        return const Center(
          child: CircularProgressIndicator(
            color: Colors.amber,
          ),
        );
      }

      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          // print(_hideshow);
          setState(() {
            _hideshow = !_hideshow;
          });
        },
        onDoubleTap: () async {
          if (player.value.state == FijkState.paused) {
            await player.start();
          } else {
            await player.pause();
          }
        },
        onPanUpdate: (details) async {
          // Swiping in right direction.
          if (details.delta.dx > 0) {
            await player.seekTo(player.currentPos.inMilliseconds + 10000);
          }

          // Swiping in left direction.
          if (details.delta.dx < 0) {
            await player.seekTo(player.currentPos.inMilliseconds - 10000);
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Visibility(
              visible: player.value.fullScreen ? _hideshow : true,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 15, 0, 0),
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 15,
                    letterSpacing: 1.6,
                    backgroundColor: Colors.black,
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onDoubleTap: () async {
                    if(player.currentPos.inMilliseconds - 10000 > 0) {
                      await player.seekTo(player.currentPos.inMilliseconds - 10000);
                    }
                  },
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width / 3.1,
                    // color: Colors.green,
                    height: MediaQuery.of(context).size.height * 0.50,
                  ),
                ),
                GestureDetector(
                  onDoubleTap: () async {
                    if (player.value.state == FijkState.paused) {
                      await player.start();
                    } else {
                      await player.pause();
                    }
                  },
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width / 3.1,
                    // color: Colors.blue,
                    height: MediaQuery.of(context).size.height * 0.60,
                  ),
                ),
                GestureDetector(
                  onDoubleTap: () async {
                     await player.seekTo(player.currentPos.inMilliseconds + 10000);
                  },
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width / 3.1,
                    // color: Colors.red,
                    height: MediaQuery.of(context).size.height * 0.50,
                  ),
                ),
              ],
            ),
            Visibility(
              visible: _hideshow,
              child: Container(
                alignment: Alignment.bottomLeft,
                margin: const EdgeInsets.all(10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      // width: 250,
                      child: StreamBuilder(
                        stream: player.onCurrentPosUpdate,
                        // initialData: const Duration(seconds: 0),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return ProgressBar(
                              // thumbGlowColor: Colors.amber,
                              thumbRadius: 6,
                              barHeight: 2,
                              thumbColor: Colors.grey,
                              baseBarColor: Colors.grey,
                              progressBarColor: Colors.red,
                              buffered: player.bufferPos,
                              progress: player.currentPos,
                              total: player.value.duration,
                              onSeek: (value) {
                                player.seekTo(value.inMilliseconds);
                              },
                            );
                          } else {
                            return const Center(
                                child: LinearProgressIndicator());
                          }
                        },
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          setState(() {
                            player.value.state == FijkState.paused
                                ? player.start()
                                : player.pause();
                          });
                        },
                        icon: player.value.state == FijkState.paused
                            ? const Icon(Icons.play_arrow)
                            : const Icon(Icons.pause)),
                    IconButton(
                        onPressed: () {
                          setState(() {
                            if (player.value.fullScreen) {
                              player.exitFullScreen();
                            } else {
                              player.enterFullScreen();
                            }
                          });
                        },
                        icon: player.value.fullScreen
                            ? const Icon(Icons.fullscreen)
                            : const Icon(Icons.fullscreen_exit)),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
    player.removeListener(_playerValueChanged);
  }
}
/*
alignment: Alignment.bottomLeft,
margin: const EdgeInsets.all(10),

Positioned.fromRect(
              rect: rect,
              child: Visibility(
                visible: _hideshow,
                child: Row(
                  children: [
                    IconButton(onPressed: () {}, icon: const Icon(Icons.pause)),
                    Container(
                      alignment: Alignment.bottomLeft,
                      width: rect.width,
                      child: ,
                    ),
                  ],
                ),
              ),
            ),

behavior: HitTestBehavior.translucent,
onTap: () {
  setState(() {
    _hideshow = !_hideshow;
  });
},
onDoubleTap: () async {
  if (player.value.state == FijkState.paused) {
    await player.start();
  } else {
    await player.pause();
  }
},

*/
