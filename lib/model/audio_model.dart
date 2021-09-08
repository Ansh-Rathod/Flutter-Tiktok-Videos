import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:core';

class Audio {
  final String duration;
  final String url;
  final String name;
  final String downloadurl;
  Audio({
    required this.duration,
    required this.url,
    required this.downloadurl,
    required this.name,
  });
  // ignore: non_constant_identifier_names
  factory Audio.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return Audio(
      duration: data['duration'].toString(),
      url: data['url'] ?? '',
      downloadurl: data['downloadurl'] ?? '',
      name: data['name'] ?? "",
    );
  }
}

class AudioList {
  final List<Audio> audioList;
  AudioList({
    required this.audioList,
  });
  factory AudioList.fromDoc(QuerySnapshot<Map<String, dynamic>> docs) {
    return AudioList(
        audioList: docs.docs.map((audio) => Audio.fromDoc(audio)).toList());
  }
}
