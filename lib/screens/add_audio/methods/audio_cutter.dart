import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

class AudioCutter {
  static const MethodChannel _channel = const MethodChannel('audiocutter');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<String> cutAudio(String? path, double start, double end) async {
    if (start < 0.0 || end < 0.0) {
      throw ArgumentError('Cannot pass negative values.');
    }

    if (start > end) {
      throw ArgumentError('Cannot have start time after end.');
    }
    final Directory _appDocDir = await getApplicationDocumentsDirectory();

    final id = Uuid().v4();
    final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();
    final dir = Directory('${_appDocDir.path}/video');

    final outPath = "${dir.path}/$id.mp3";
    var cmd = "-i $path -ss $start -to $end -c copy ${dir.path}/$id.mp3";
    int rc = await _flutterFFmpeg.execute(cmd);

    if (rc != 0) {
      throw ("[FFmpeg] process exited with rc $rc");
    }

    return outPath;
  }
}
