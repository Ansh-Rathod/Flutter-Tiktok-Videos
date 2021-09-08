import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'package:flutter/foundation.dart';

class Api {
  Future<VideosList> getVideos() async {
    List data = [];
    Random random = new Random();
    int randomNumber = random.nextInt(50);
    final response = await http.get(
      Uri.parse(
          'https://api.pexels.com/videos/popular?per_page=80&page=${randomNumber}&max_duration=20&orientation=portrait'),
      headers: {
        HttpHeaders.authorizationHeader:
            "563492ad6f917000010000019051457aa9424d0db0e0b17147886a9e"
      },
    );
    if (response.statusCode == 200) {
      var jsonBody = json.decode(response.body);
      data.addAll(jsonBody['videos']);
    } else {
      throw ErrorModel(
          code: response.statusCode, message: "Something wents wrong.");
    }

    return VideosList.fromJson(data);
  }

  Future<VideosList> getVideolimited() async {
    Random random = new Random();
    int randomNumber = random.nextInt(50);
    final response = await http.get(
      Uri.parse(
          'https://api.pexels.com/videos/popular?per_page=25&page=$randomNumber&max_duration=20'),
      headers: {
        HttpHeaders.authorizationHeader:
            "563492ad6f917000010000019051457aa9424d0db0e0b17147886a9e"
      },
    );
    if (response.statusCode == 200) {
      var jsonBody = json.decode(response.body);
      return VideosList.fromJson(jsonBody['videos']);
    } else {
      throw ErrorModel(
          code: response.statusCode, message: "Something wents wrong.");
    }
  }

  Future<VideosList> getSearchedVideo(String searchtext) async {
    List data = [];
    String search = searchtext.replaceAll(" ", "+");
    for (int i = 1; i <= 10; i++) {
      final response = await http.get(
        Uri.parse(
          'https://api.pexels.com/videos/search?query=$search?per_page=25&page=$i&max_duration=20',
        ),
        headers: {
          HttpHeaders.authorizationHeader:
              "563492ad6f917000010000019051457aa9424d0db0e0b17147886a9e"
        },
      );
      if (response.statusCode == 200) {
        var jsonBody = json.decode(response.body);
        data.addAll(jsonBody['videos']);
      } else {
        throw ErrorModel(
            code: response.statusCode, message: "Something wents wrong.");
      }
    }

    return VideosList.fromJson(data);
  }
}

class Video {
  final String id;
  final int duration;
  final String thumbnail;
  final VideoFile files;
  Video({
    required this.id,
    required this.duration,
    required this.thumbnail,
    required this.files,
  });
  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'].toString(),
      duration: json['duration'],
      thumbnail: json['image'],
      files: VideoFile.fromJson(json['video_files'][2]),
    );
  }
}

class VideoFile {
  final String filetype;
  final String link;
  VideoFile({
    required this.filetype,
    required this.link,
  });
  factory VideoFile.fromJson(Map<String, dynamic> json) {
    return VideoFile(
      filetype: json['file_type'],
      link: json['link'],
    );
  }
}

class VideosList {
  final List<Video> videos;
  VideosList({
    required this.videos,
  });
  factory VideosList.fromJson(List<dynamic> jsonList) {
    return VideosList(
      videos: jsonList.map((video) => Video.fromJson(video)).toList(),
    );
  }
}

class ErrorModel {
  final int code;
  final String message;
  ErrorModel({
    required this.code,
    required this.message,
  });
}
