import 'dart:async';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/material.dart';


class CustomFijkPanel extends StatefulWidget {
  final FijkPlayer player;
  final BuildContext buildContext;
  final Size viewSize;
  final Rect texturePos;
  final String title;
  final String id;

  const CustomFijkPanel({
    Key? key,
    required this.player,
    required this.buildContext,
    required this.viewSize,
    required this.texturePos,
    required this.title,
    required this.id,
  }) : super(key: key);

  @override
  _CustomFijkPanelState createState() => _CustomFijkPanelState();
}

class _CustomFijkPanelState extends State<CustomFijkPanel> {
  FijkPlayer get player => widget.player;
  bool _hideshow = true;
  final _fijkStream = FijkStream();

  @override
  void initState() {
    
    super.initState();
    player.addListener(_playerValueChanged);
  }

  void _playerValueChanged() {
    _fijkStream.sinkValue.add(player.value);
  }

  @override
  void dispose() {
    player.removeListener(_playerValueChanged);
    _fijkStream.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // print("build called");
    return StreamBuilder<FijkValue>(
      stream: _fijkStream.streamValue,
      builder: (context, snapshot) {


        FijkValue value = player.value;
        if (value.state == FijkState.error) {
          String? error = "Error";
          if (value.exception.code == -2004) {
            error = "No Internet Connections!";
          } else {
            error = value.exception.message;
          }
          return Container(
            color: Theme.of(context).backgroundColor,
            child: Center(
              child: Text("Error! $error"),
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
            _hideshow = !_hideshow;
            _fijkStream.sinkhideshow.add(true);
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
              StreamBuilder<bool>(
                stream: _fijkStream.streamhideshow,
                builder: (context, snapshot) {
                  return Visibility(
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
                  );
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onDoubleTap: () async {
                      if (player.currentPos.inMilliseconds - 10000 > 0) {
                        await player
                            .seekTo(player.currentPos.inMilliseconds - 10000);
                      }
                    },
                    child: xController(context),
                  ),
                  GestureDetector(
                      onDoubleTap: () async {
                        if (player.value.state == FijkState.paused) {
                          await player.start();
                        } else {
                          await player.pause();
                        }
                      },
                      child: xController(context)),
                  GestureDetector(
                      onDoubleTap: () async {
                        await player
                            .seekTo(player.currentPos.inMilliseconds + 10000);
                      },
                      child: xController(context)),
                ],
              ),
              StreamBuilder<bool>(
                stream: _fijkStream.streamhideshow,
                builder: (context, snapshot) {
                  return Visibility(
                    visible: _hideshow,
                    child: Container(
                      alignment: Alignment.bottomLeft,
                      margin: const EdgeInsets.all(10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            // width: 250,
                            child: StreamBuilder<Duration>(
                              stream: player.onCurrentPosUpdate,
                              // initialData: const Duration(seconds: 0),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  // print(snapshot.data);
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
                                    child: LinearProgressIndicator(),
                                  );
                                }
                              },
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              player.value.state == FijkState.paused
                                  ? player.start()
                                  : player.pause();
                            },
                            icon: player.value.state == FijkState.paused
                                ? const Icon(Icons.play_arrow)
                                : const Icon(Icons.pause),
                          ),
                          IconButton(
                            onPressed: () {
                              if (player.value.fullScreen) {
                                player.exitFullScreen();
                              } else {
                                player.enterFullScreen();
                              }
                            },
                            icon: !player.value.fullScreen
                                ? const Icon(Icons.fullscreen)
                                : const Icon(Icons.fullscreen_exit),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );

    /*Rect rect = Rect.fromLTRB(
        max(0.0, widget.texturePos.left),
        max(0.0, widget.texturePos.top),
        min(widget.viewSize.width, widget.texturePos.right),
        min(widget.viewSize.height, widget.texturePos.bottom));*/
  }

  Container xController(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 3.1,
      color: Colors.transparent,
      height: MediaQuery.of(context).size.height * 0.50,
    );
  }
}

class FijkStream {
  final __streamFijkValue = StreamController<FijkValue>.broadcast();
  final __streamHideShow = StreamController<bool>.broadcast();
  final __streamFijkState = StreamController<FijkState>.broadcast();

  StreamSink<FijkValue> get sinkValue => __streamFijkValue.sink;
  Stream<FijkValue> get streamValue => __streamFijkValue.stream;

  StreamSink<FijkState> get sinkState => __streamFijkState.sink;
  Stream<FijkState> get streamState => __streamFijkState.stream;

  StreamSink<bool> get sinkhideshow => __streamHideShow.sink;
  Stream<bool> get streamhideshow => __streamHideShow.stream;

  void dispose() {
    __streamFijkState.close();
    __streamFijkState.close();
    __streamHideShow.close();
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
