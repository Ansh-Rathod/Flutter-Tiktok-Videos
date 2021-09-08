import 'dart:io';

import 'package:cachedrun/screens/upload_screen/upload_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'audio_editor.dart';
import 'bloc/add_audio_bloc.dart';

class AudioFiles extends StatelessWidget {
  final String video;
  const AudioFiles({Key? key, required this.video}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddAudioBloc, AddAudioState>(builder: (context, state) {
      if (state is AddAudioLoading) {
        return Scaffold(
          body: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 70,
                  width: 70,
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.grey,
                    valueColor:
                        new AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Wait a momment..",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        );
      } else if (state is AddAudioLoaded) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
            appBar: AppBar(
              elevation: 0.0,
              title: Text(
                "Add Audio",
                style: TextStyle(color: Colors.black),
              ),
              actions: [
                IconButton(
                  onPressed: () async {
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowMultiple: false,
                      allowedExtensions: ['mp3'],
                    );
                    var path = result!.paths.first;
                    final videoPath = await showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return BottomSheetWidget(
                            file: path!,
                            title: 'Unknown',
                            vidpath: video,
                          );
                        });
                    if (videoPath != null) {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UploadPage(
                                    video: videoPath,
                                  )));
                    }
                  },
                  icon:
                      Icon(Icons.local_hospital_outlined, color: Colors.black),
                )
              ],
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UploadPage(video: video),
                    ),
                  );
                },
              ),
              backgroundColor: Colors.transparent,
            ),
            body: ListView(
              children: [
                ...state.audio.map((audio) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14.0, vertical: 4),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: ListTile(
                        onTap: () async {
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
                                      valueColor:
                                          new AlwaysStoppedAnimation<Color>(
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
                          var fetchedFile = await DefaultCacheManager()
                              .getSingleFile(audio.downloadurl);
                          Navigator.pop(context);
                          final videoPath = await showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return BottomSheetWidget(
                                  file: fetchedFile.path,
                                  title: audio.name,
                                  vidpath: video,
                                );
                              });
                          if (videoPath != null) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    UploadPage(video: videoPath),
                              ),
                            );
                          }
                        },
                        leading: Icon(Icons.play_circle_fill_outlined,
                            size: 50, color: Colors.black),
                        title: Text(
                          audio.name,
                          style: TextStyle(color: Colors.black),
                        ),
                        subtitle: Text(
                          audio.duration.toString(),
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      } else if (state is AddAudioError) {
        return Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Column(
                children: [
                  Text(
                    "503",
                    style: TextStyle(color: Colors.red, fontSize: 26),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Service not available",
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ],
              ),
            ));
      } else {
        return Scaffold(
          backgroundColor: Colors.black,
        );
      }
    });
  }
}
