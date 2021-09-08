import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:uuid/uuid.dart';

import 'methods/audio_cutter.dart';
import 'methods/hidden_thumb_component_shape.dart';
import 'widgets/controll_button.dart';
import 'widgets/seek_bar.dart';

class BottomSheetWidget extends StatefulWidget {
  final String file;
  final String title;
  final String vidpath;

  BottomSheetWidget({
    Key? key,
    required this.file,
    required this.title,
    required this.vidpath,
  }) : super(key: key);
  @override
  _BottomSheetWidgetState createState() => _BottomSheetWidgetState();
}

class _BottomSheetWidgetState extends State<BottomSheetWidget> {
  late AudioPlayer _player;
  int _addedCount = 0;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _init();
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.speech());
    // Listen to errors during playback.
    _player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      print('A stream error occurred: $e');
    });
    try {
      await _player.setAudioSource(
        AudioSource.uri(Uri.file(widget.file)),
      );
    } catch (e) {
      print("Error loading playlist: $e");
    }
  }

  @override
  void dispose() {
    if (_player.playing) {
      _player.pause();
    }

    _player.dispose();
    super.dispose();
  }

  var start = 0.0;
  var end = 20.0;
  Future<String> createFolderInAppDocDir(String folderName) async {
    final Directory _appDocDir = await getApplicationDocumentsDirectory();
    final Directory _appDocDirFolder =
        Directory('${_appDocDir.path}/$folderName');

    if (await _appDocDirFolder.exists()) {
      return _appDocDirFolder.path;
    } else {
      final Directory _appDocDirNewFolder =
          await _appDocDirFolder.create(recursive: true);
      return _appDocDirNewFolder.path;
    }
  }

  cutaudio() async {
    setState(() {
      isCut = !isCut;
    });
  }

  bool isCut = false;
  SfRangeValues _values = SfRangeValues(0.0, 10.0);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ListView(
        shrinkWrap: true,
        children: [
          SizedBox(
            height: 10,
          ),
          ListTile(
            leading: ControlButtons(_player),
            title: Text(widget.title, style: TextStyle(color: Colors.black)),
            trailing: IconButton(
              icon: Icon(
                Icons.cut_outlined,
                color: !isCut ? Colors.black : Colors.blue,
              ),
              onPressed: cutaudio,
            ),
          ),
          StreamBuilder<Duration?>(
            stream: _player.durationStream,
            builder: (context, snapshot) {
              final duration = snapshot.data ?? Duration.zero;
              return StreamBuilder<PositionData>(
                stream: Rx.combineLatest2<Duration, Duration, PositionData>(
                    _player.positionStream,
                    _player.bufferedPositionStream,
                    (position, bufferedPosition) =>
                        PositionData(position, bufferedPosition)),
                builder: (context, snapshot) {
                  final positionData = snapshot.data ??
                      PositionData(Duration.zero, Duration.zero);
                  var position = positionData.position;
                  if (position > duration) {
                    position = duration;
                  }
                  var bufferedPosition = positionData.bufferedPosition;
                  if (bufferedPosition > duration) {
                    bufferedPosition = duration;
                  }
                  return SeekBar(
                    duration: duration,
                    position: position,
                    bufferedPosition: bufferedPosition,
                    onChangeEnd: (newPosition) {
                      _player.seek(newPosition);
                    },
                  );
                },
              );
            },
          ),
          SizedBox(height: 8.0),
          if (isCut)
            StreamBuilder<Duration?>(
                stream: _player.durationStream,
                builder: (context, snapshot) {
                  final duration = snapshot.data ?? Duration.zero;
                  var totalduration = duration.inSeconds.toDouble();
                  if (snapshot.hasData) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SfRangeSlider(
                          min: 0.0,
                          max: totalduration,
                          stepSize: 1,
                          values: _values,
                          interval: 20,
                          showTicks: true,
                          activeColor: Colors.blue,
                          inactiveColor: Colors.black,
                          showLabels: true,
                          enableTooltip: true,
                          minorTicksPerInterval: 1,
                          onChanged: (SfRangeValues values) {
                            setState(() {
                              end = values.end;
                              start = values.start;

                              print(values.start);
                              print(values.end);
                              _values = values;
                              _player.seek(
                                  Duration(seconds: values.start.toInt()));
                            });
                          }),
                    );
                  } else if (!snapshot.hasData) {
                    return Center(
                        child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: LinearProgressIndicator(),
                    ));
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error"));
                  } else {
                    return Container();
                  }
                }),
          SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: MaterialButton(
              color: Colors.blue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              elevation: 0.0,
              textColor: Colors.white,
              onPressed: () async {
                if (!isCut) {
                  final path = await createFolderInAppDocDir('video');
                  final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();
                  final Directory _appDocDir =
                      await getApplicationDocumentsDirectory();
                  final dir = Directory('${_appDocDir.path}/video');
                  final id = Uuid().v4();
                  final outPath = "${dir.path}/$id.mp4";
                  await _flutterFFmpeg
                      .execute(
                          "-i ${widget.vidpath} -i ${widget.file} -c:v copy -c:a aac -map 0:v:0 -map 1:a:0 -shortest ${dir.path}/$id.mp4")
                      .then((return_code) => print("Return code $return_code"));

                  Navigator.pop(context, outPath);
                } else {
                  var outputFilePath =
                      await AudioCutter.cutAudio(widget.file, start, end);

                  final path = await createFolderInAppDocDir('video');
                  final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();
                  final Directory _appDocDir =
                      await getApplicationDocumentsDirectory();
                  final dir = Directory('${_appDocDir.path}/video');
                  final id = Uuid().v4();
                  final outPath = "${dir.path}/$id.mp4";
                  await _flutterFFmpeg
                      .execute(
                          "-i ${widget.vidpath} -i ${outputFilePath} -c:v copy -c:a aac -map 0:v:0 -map 1:a:0 -shortest ${dir.path}/$id.mp4")
                      .then((return_code) => print("Return code $return_code"));
                  Navigator.pop(context, outPath);
                }
              },
              child: Text(!isCut ? "Add audio" : "Cut and add"),
            ),
          ),
        ],
      ),
    );
  }
}
