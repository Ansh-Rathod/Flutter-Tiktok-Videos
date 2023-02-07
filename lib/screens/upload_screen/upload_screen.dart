import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cachedrun/cloudinary.dart';
import 'package:cachedrun/logger.dart';
import 'package:cachedrun/screens/add_audio/add_audio.dart';
import 'package:cachedrun/screens/add_audio/bloc/add_audio_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

class UploadPage extends StatefulWidget {
  final String? video;
  UploadPage({
    Key? key,
    this.video,
  }) : super(key: key);

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  // String? tempFile;

  Future<String?> encodeVideo(String videoId) async {
    final Directory _appDocDir = await getTemporaryDirectory();
    final dir = _appDocDir.path;
    final outPath = "$dir/$videoId-video.mp4";
    try {
      await FFmpegKit.execute(
          "-i ${widget.video} -vf scale=trunc(iw/4)*2:trunc(ih/4)*2 -c:v libx264 -crf 18 $outPath");
      return await uploadFile(File(outPath), "$videoId-video");
    } catch (e) {
      logger.wtf(e.toString());
      print(e.toString());
    }
    return null;
  }

  Future<String?> encodeGif(String videoid) async {
    final Directory _appDocDir = await getApplicationDocumentsDirectory();
    final dir = _appDocDir.path;
    final outPath = "$dir/$videoid.gif";
    try {
      await FFmpegKit.execute(
          '-ss 00:00:01 -t 3 -i ${widget.video} -filter_complex "fps=8,scale=480:-1:flags=lanczos,split[s0][s1];[s0]palettegen=max_colors=32[p];[s1][p]paletteuse=dither=bayer" $outPath');

      return await uploadFile(File(outPath), videoid);
    } catch (e) {
      logger.wtf(e);
      print(e.toString());
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: widget.video == null
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.video_collection,
                          size: 100, color: Colors.grey),
                      SizedBox(height: 10),
                      Text(
                        "Add Your Video file here.",
                        style: TextStyle(color: Colors.grey),
                      )
                    ],
                  ),
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: VideoPreviewWideget(
                url: widget.video!,
              ),
            ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          MaterialButton(
            textColor: Colors.white,
            onPressed: () async {
              showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      backgroundColor: Colors.white,
                      title: Center(
                          child: Container(
                        width: 70,
                        height: 70,
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.grey,
                          valueColor: new AlwaysStoppedAnimation<Color>(
                              Colors.blueAccent),
                        ),
                      )),
                      content: Text(
                        "Wait a Momment..",
                        style: TextStyle(color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    );
                  });

              final id = Uuid().v4();
              var gif = await encodeGif(id);
              var outpath = await encodeVideo(id);

              await FirebaseFirestore.instance
                  .collection('Videos')
                  .doc(id)
                  .set({
                "id": id,
                "comments": "${Random().nextInt(1000)}",
                "likes": "${Random().nextInt(100)}K",
                "song_name":
                    "Song Title ${Random().nextInt(1000)} - Artist${Random().nextInt(1000)}",
                "url": outpath,
                "gif": gif,
                "user": "user${Random().nextInt(1000)}",
                "user_pic":
                    "https://firebasxestorage.googleapis.com/v0/b/testvideo-91d3a.appspot.com/o/profile_pics%2Fprofile6.jpeg?alt=media&token=e747af9e-4775-484e-9a27-94b2426f319c",
                "video_title": "Video-${Random().nextInt(1000)}"
              });
              Navigator.pop(context);
              // Navigator.pushReplacement(
              //     context,
              //     MaterialPageRoute(
              //         builder: (context) => Scaffold(
              //               body: VideoPreviewWideget(url: outpath),
              //             )));
              Navigator.pop(context);
            },
            child: Text(
              "Post",
            ),
          )
        ],
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            child: Icon(Icons.audiotrack),
            onPressed: () async {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider(
                    create: (context) => AddAudioBloc()..add(LoadAudio()),
                    child: AudioFiles(
                      video: widget.video!,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class VideoPreviewWideget extends StatefulWidget {
  final String url;
  const VideoPreviewWideget({Key? key, required this.url}) : super(key: key);

  @override
  _VideoPreviewWidegetState createState() => _VideoPreviewWidegetState();
}

class _VideoPreviewWidegetState extends State<VideoPreviewWideget> {
  late VideoPlayerController controller;
  late Future<void> _initVideoPlaybackFuture;
  late bool loading = false;

  @override
  void initState() {
    controller = VideoPlayerController.file(File(widget.url));
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
    return Container(
      child: GestureDetector(
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
                              Colors.blueAccent)),
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
