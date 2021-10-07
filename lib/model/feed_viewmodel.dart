import 'package:cached_video_player/cached_video_player.dart';
import 'package:cachedrun/data/get_data.dart';
import 'package:cachedrun/model/video.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';

class FeedViewModel extends BaseViewModel {
  // VideoPlayerController? controller;
  List<Video> videos = [];

  int prevVideo = 0;
  int actualScreen = 0;

  FeedViewModel() {
    load();
    notifyListeners();
  }

  void load() async {
    videos = await getVideoList();
    await videos[0].loadController();
    videos[0].controller!.play();
    notifyListeners();
  }

  Future<List<Video>> getVideoList() async {
    var videoList = <Video>[];
    var videos;

    videos = (await FirebaseFirestore.instance.collection("Videos").get());

    videos.docs.forEach((element) {
      Video video = Video.fromJson(element.data());
      videoList.add(video);
    });
    notifyListeners();
    return videoList;
  }

  changeVideo(index) async {
    if (videos[prevVideo].controller != null)
      videos[prevVideo].controller!.pause();

    if (videos[index].controller == null) {
      await videos[index].loadController();
    }
    videos[index].controller!.play();
    prevVideo = index;
    if (prevVideo + 1 < videos.length) {
      await videos[prevVideo + 1].loadController();
    }
    notifyListeners();

    print(index);
  }

  void loadVideo(int index) async {
    if (videos.length > index) {
      await videos[index].loadController();
      videos[index].controller?.play();

      notifyListeners();
    }
  }

  void setActualScreen(index) {
    actualScreen = index;
    if (index == 0) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    } else {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    }
    notifyListeners();
  }
}
