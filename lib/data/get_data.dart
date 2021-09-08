import 'package:cachedrun/model/video.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

var data = [
  {
    "id": "2",
    "comments": "21",
    "likes": "3.2k",
    "song_name": "Song Title 1 - Artist 1",
    "url":
        "https://firebasestorage.googleapis.com/v0/b/video-9ecef.appspot.com/o/video1920%2Fmaster.m3u8?alt=media&token=b2e3e560-a92f-492c-9984-cbaf601c8e74",
    "user": "user1",
    "user_pic":
        "https://firebasestorage.googleapis.com/v0/b/testvideo-91d3a.appspot.com/o/profile_pics%2Fprofile1.jpg?alt=media&token=567ea332-04e8-4c64-afb0-8152c6f12fec",
    "video_title": "Video 1"
  },
  {
    "id": "2",
    "comments": "11",
    "likes": "35k",
    "song_name": "Song Title 2 - Artist 2",
    "url":
        "https://firebasestorage.googleapis.com/v0/b/testvideo-91d3a.appspot.com/o/1.mp4?alt=media&token=36032747-7815-473d-beef-061098f08c18",
    "user": "user2",
    "user_pic":
        "https://firebasestorage.googleapis.com/v0/b/testvideo-91d3a.appspot.com/o/profile_pics%2Fprofile2.jpeg?alt=media&token=b1fdd00d-5d6e-4705-980d-4ef3e70ff6c5",
    "video_title": "Video 2"
  },
  {
    "id": "2",
    "comments": "434",
    "likes": "21.4k",
    "song_name": "Song Title 3 - Artist 3",
    "url":
        "https://firebasestorage.googleapis.com/v0/b/testvideo-91d3a.appspot.com/o/3.mp4?alt=media&token=a7ccda22-7264-4c64-9328-86a4c2ec31cd",
    "user": "user3",
    "user_pic":
        "https://firebasestorage.googleapis.com/v0/b/testvideo-91d3a.appspot.com/o/profile_pics%2Fprofile3.jpg?alt=media&token=d65b2ed7-4164-4149-a5c7-8620201e8411",
    "video_title": "Video 3"
  },
  {
    "id": "2",
    "comments": "66",
    "likes": "3m",
    "song_name": "Song Title 4 - Artist 4",
    "url":
        "https://firebasestorage.googleapis.com/v0/b/testvideo-91d3a.appspot.com/o/2.mp4?alt=media&token=b6218221-6699-402b-8b89-7e3354ac32dc",
    "user": "user4",
    "user_pic":
        "https://firebasestorage.googleapis.com/v0/b/testvideo-91d3a.appspot.com/o/profile_pics%2Fprofile4.jpg?alt=media&token=399ca1f4-2017-4f48-af21-0aa6a7b17550",
    "video_title": "Video 4"
  },
  {
    "id": "2",
    "comments": "54",
    "likes": "1.1k",
    "song_name": "Song Title 6 - Artist 6",
    "url":
        "https://firebasestorage.googleapis.com/v0/b/testvideo-91d3a.appspot.com/o/5.mp4?alt=media&token=965a0494-7aaf-4248-85c5-fefac581ee7f",
    "user": "user5",
    "user_pic":
        "https://firebasestorage.googleapis.com/v0/b/testvideo-91d3a.appspot.com/o/profile_pics%2Fprofile5.jpeg?alt=media&token=7fbe5118-c2e9-4550-a468-3eb8a4d34d6a",
    "video_title": "Video 5"
  },
  {
    "id": "2",
    "comments": "43",
    "likes": "5.2k",
    "song_name": "Song Title 6 - Artist 6",
    "url":
        "https://firebasestorage.googleapis.com/v0/b/testvideo-91d3a.appspot.com/o/7.mp4?alt=media&token=2f6a3c9b-bfc4-483e-ad5b-bb7d539ee765",
    "user": "user6",
    "user_pic":
        "https://firebasestorage.googleapis.com/v0/b/testvideo-91d3a.appspot.com/o/profile_pics%2Fprofile6.jpeg?alt=media&token=e747af9e-4775-484e-9a27-94b2426f319c",
    "video_title": "Video 6"
  },
  {
    "id": "2",
    "comments": "43",
    "likes": "5.2k",
    "song_name": "Song Title 6 - Artist 6",
    "url":
        "https://firebasestorage.googleapis.com/v0/b/testvideo-91d3a.appspot.com/o/8.mp4?alt=media&token=87e20ffd-2b5c-422a-ad85-33b90b4e2169",
    "user": "user6",
    "user_pic":
        "https://firebasestorage.googleapis.com/v0/b/testvideo-91d3a.appspot.com/o/profile_pics%2Fprofile6.jpeg?alt=media&token=e747af9e-4775-484e-9a27-94b2426f319c",
    "video_title": "Video 7"
  },
  {
    "id": "2",
    "comments": "43",
    "likes": "5.2k",
    "song_name": "Song Title 6 - Artist 6",
    "url":
        "https://firebasestorage.googleapis.com/v0/b/testvideo-91d3a.appspot.com/o/9.mp4?alt=media&token=83911bd2-6083-43d1-824e-2049f1fb11e7",
    "user": "user6",
    "user_pic":
        "https://firebasestorage.googleapis.com/v0/b/testvideo-91d3a.appspot.com/o/profile_pics%2Fprofile6.jpeg?alt=media&token=e747af9e-4775-484e-9a27-94b2426f319c",
    "video_title": "Video 8"
  }
];

class VideosAPI extends ChangeNotifier {
  List<Video> listVideos = <Video>[];

  VideosAPI() {
    load();
  }

  void load() async {
    listVideos = await getVideoList();
  }

  Future<List<Video>> getVideoList() async {
    var videoList = <Video>[];
    var videos;

    videos = (await FirebaseFirestore.instance.collection("Videos").get());

    videos.docs.forEach((element) {
      Video video = Video.fromJson(element.data());
      videoList.add(video);
    });

    return videoList;
  }
}
