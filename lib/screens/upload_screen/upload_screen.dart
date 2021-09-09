import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cached_video_player/cached_video_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'package:cachedrun/screens/add_audio/add_audio.dart';
import 'package:cachedrun/screens/add_audio/bloc/add_audio_bloc.dart';

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
  String? tempFile;
  Future<String> _uploadFile(String filePath, String folderName) async {
    var file = File(filePath);
    var basename = p.basename(filePath);

    final downloadUrl = await FirebaseStorage.instance
        .ref()
        .child(folderName)
        .child(basename)
        .putFile(file)
        .then((taskSnapshot) => taskSnapshot.ref.getDownloadURL());

    return downloadUrl;
  }

  Future<String> encodeVideo() async {
    var id = Uuid().v4();

    final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();
    final Directory _appDocDir = await getApplicationDocumentsDirectory();
    final dir = _appDocDir.path;
    final outPath = "$dir/$id.mp4";
    await _flutterFFmpeg
        .execute(
            "-i ${widget.video} -vf scale=480:-2,setsar=1:1 -c:v libx264 -c:a copy $outPath")
        .then((returnCode) => print("Return code $returnCode"));
    return outPath;
  }

  Future<String> encodeGif() async {
    var id = Uuid().v4();

    final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();
    final Directory _appDocDir = await getApplicationDocumentsDirectory();
    final dir = _appDocDir.path;
    final outPath = "$dir/$id.gif";
    await _flutterFFmpeg
        .execute('-i ${widget.video} -vf fps=5,scale=450:-1 -t 3 $outPath')
        .then((returnCode) => print("Return code $returnCode"));
    return outPath;
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
        brightness: Brightness.dark,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          FlatButton(
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

              var gif = await encodeGif();

              var outpath = await encodeVideo();
              var url = await _uploadFile(outpath, 'Videos');
              var gifUrl = await _uploadFile(gif, 'Gif');

              await FirebaseFirestore.instance.collection('Videos').doc().set({
                "id": "${Random().nextInt(1000)}",
                "comments": "${Random().nextInt(100)}",
                "likes": "${Random().nextInt(100)}K",
                "song_name":
                    "Song Title ${Random().nextInt(1000)} - Artist${Random().nextInt(1000)}",
                "url": url,
                "gif": gifUrl,
                "user": "user${Random().nextInt(1000)}",
                "user_pic":
                    "https://firebasestorage.googleapis.com/v0/b/testvideo-91d3a.appspot.com/o/profile_pics%2Fprofile6.jpeg?alt=media&token=e747af9e-4775-484e-9a27-94b2426f319c",
                "video_title": "Video${Random().nextInt(1000)}"
              });
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              "Post",
            ),
          )
        ],
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
