import 'dart:async';
import 'dart:io';

import 'package:cached_video_player/cached_video_player.dart';
import 'package:cachedrun/screens/upload_screen/upload_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class VideoPreview extends StatefulWidget {
  final String url;
  const VideoPreview({Key? key, required this.url}) : super(key: key);

  @override
  _VideoPreviewState createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  late VideoPlayerController controller;
  late Future<void> _initVideoPlaybackFuture;
  late bool loading = false;

  @override
  void initState() {
    controller = VideoPlayerController.network(widget.url);
    _initVideoPlaybackFuture = controller.initialize();
    controller.setLooping(true);
    controller.setVolume(1.0);
    super.initState();
  }

  @override
  void dispose() {
    if (controller.value.isPlaying) {
      controller.pause();
    }
    controller.dispose();
    super.dispose();
  }

  bool isShow = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        brightness: Brightness.dark,
        elevation: 0.0,
        actions: [
          FlatButton(
            onPressed: () async {
              if (controller.value.isPlaying) {
                controller.pause();
              }
              setState(() {
                loading = true;
              });
              var fetchedFile =
                  await DefaultCacheManager().getSingleFile(widget.url);
              setState(() {
                loading = false;
              });
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          UploadPage(video: fetchedFile.path)));
            },
            child: !loading
                ? Text("Add ",
                    style: TextStyle(
                      color: Colors.white,
                    ))
                : Container(
                    width: 30,
                    height: 30,
                    child: Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.grey,
                        strokeWidth: 2,
                        valueColor: new AlwaysStoppedAnimation<Color>(
                            Colors.blueAccent),
                      ),
                    )),
          )
        ],
      ),
      body: GestureDetector(
        onTap: () {
          if (isShow) {
            setState(() {
              isShow = true;
              Timer(const Duration(milliseconds: 400), () {
                isShow = false;
              });
            });
          } else {
            setState(() {
              isShow = false;
              Timer(const Duration(milliseconds: 400), () {
                isShow = true;
              });
            });
          }
        },
        child: Stack(
          children: [
            FutureBuilder(
              future: _initVideoPlaybackFuture,
              builder: (context, snapShot) {
                if (snapShot.connectionState == ConnectionState.done) {
                  return Center(
                    child: AspectRatio(
                      aspectRatio: controller.value.aspectRatio,
                      child: VideoPlayer(controller),
                    ),
                  );
                } else {
                  return Center(
                    child: Container(
                      width: 70,
                      height: 70,
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.grey,
                        valueColor: new AlwaysStoppedAnimation<Color>(
                            Colors.blueAccent),
                      ),
                    ),
                  );
                }
              },
            ),
            isShow
                ? Center(
                    child: FloatingActionButton(
                      backgroundColor: Colors.white,
                      onPressed: () {
                        setState(() {
                          if (controller.value.isPlaying) {
                            controller.pause();
                            isShow = true;
                          } else {
                            controller.play();
                            isShow = false;
                          }
                        });
                      },
                      child: Icon(
                          controller.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: Colors.black),
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}
