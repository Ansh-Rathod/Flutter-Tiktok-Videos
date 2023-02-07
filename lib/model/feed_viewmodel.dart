import 'package:cachedrun/model/video.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';

import '../logger.dart';

class FeedViewModel extends BaseViewModel {
  // VideoPlayerController? controller;
  List<Video> videos = [];
  int prevIndex = 0;

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

  changeVideo(
    index,
  ) async {
    logger.d("$index, $prevIndex");
    bool isGoingUp = index == prevIndex;

    prevIndex = index - 1;

    if (videos[index].controller == null) {
      await videos[index].loadController();
    }

    await videos[index].controller!.play();

    if (!isGoingUp) {
      logger.wtf("Going down");

      if (videos[index - 1].controller != null) {
        await videos[index - 1].controller!.pause();
      }
      if (index + 1 < videos.length) {
        if (videos[index + 1].controller == null) {
          await videos[index + 1].loadController();
        }
      }

      if (index > 4) {
        for (var video in videos.sublist(0, index - 4)) {
          await video.dispose();
        }
      }
    } else {
      logger.wtf("Going up");

      if (videos[index + 1].controller != null) {
        await videos[index + 1].controller!.pause();
      }

      if (index - 1 != 0) {
        if (videos[index - 1].controller == null) {
          await videos[index - 1].loadController();
        }
      }

      for (var video in videos.sublist(index + 4, videos.length)) {
        await video.dispose();
      }
    }

    notifyListeners();
    print(index);
  }

  void loadVideo(int index) async {
    if (videos.length > index) {
      await videos[index].loadController();
      await videos[index].controller?.play();

      if (index + 1 < videos.length) {
        if (videos[index + 1].controller == null) {
          await videos[index + 1].loadController();
        }
      }
      notifyListeners();
    }
  }

  void setActualScreen(index) async {
    actualScreen = index;

    if (index == 0) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    } else {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    }
    await videos[prevIndex + 1].controller?.pause();
    notifyListeners();
  }
}
