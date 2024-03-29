import 'package:cached_network_image/cached_network_image.dart';
import 'package:cachedrun/bottom_nav_bar/bottom_nav_bar.dart';
import 'package:cachedrun/model/feed_viewmodel.dart';
import 'package:cachedrun/screens/select_video/bloc/select_video_bloc.dart';
import 'package:cachedrun/screens/select_video/select_video.dart';
import 'package:cachedrun/widgets/action_toolbar.dart';
import 'package:cachedrun/widgets/description.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:stacked/stacked.dart';
import 'package:video_player/video_player.dart';

import '../model/video.dart';
import 'all_video/all_video.dart';

class FeedScreen extends StatefulWidget {
  FeedScreen({Key? key}) : super(key: key);

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final locator = GetIt.instance;
  final feedViewModel = GetIt.instance<FeedViewModel>();

  @override
  void initState() {
    feedViewModel.loadVideo(0);

    feedViewModel.setInitialised(true);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<FeedViewModel>.reactive(
      disposeViewModel: false,
      builder: (context, model, child) => videoScreen(),
      viewModelBuilder: () => feedViewModel,
    );
  }

  Widget videoScreen() {
    return Scaffold(
      backgroundColor: GetIt.instance<FeedViewModel>().actualScreen == 0
          ? Colors.black
          : Colors.white,
      body: scrollFeed(),
    );
  }

  Widget currentScreen() {
    switch (feedViewModel.actualScreen) {
      case 0:
        return feedVideos();
      case 1:
        return BlocProvider(
          create: (context) => SelectVideoBloc()..add(LoadVideos()),
          child: SelectVideos(),
        );
      case 2:
        return AllVideoPage();
      default:
        return feedVideos();
    }
  }

  Widget scrollFeed() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(child: currentScreen()),
        BottomBar(),
      ],
    );
  }

  Widget feedVideos() {
    return Stack(
      children: [
        PageView.builder(
          controller: PageController(
            initialPage: 0,
            viewportFraction: 1,
          ),
          itemCount: feedViewModel.videos.length,
          onPageChanged: (index) {
            feedViewModel.changeVideo(index);
          },
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) {
            return videoCard(feedViewModel.videos[index]);
          },
        ),
      ],
    );
  }

  checkVideoRatio(double width, double height) {
    if (width > height) {
      return BoxFit.contain;
    } else if (width < height) {
      return BoxFit.cover;
    } else {
      return BoxFit.contain;
    }
  }

  Widget videoCard(Video video) {
    return SafeArea(
      child: Stack(
        children: [
          video.controller != null
              ? SizedBox.expand(
                  child: FittedBox(
                  fit: checkVideoRatio(video.controller?.value.size.width ?? 0,
                      video.controller?.value.size.height ?? 0),
                  child: SizedBox(
                    width: video.controller?.value.size.width ?? 0,
                    height: video.controller?.value.size.height ?? 0,
                    child: VideoPlayer(video.controller!),
                  ),
                ))
              : Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Center(
                    child: Container(
                      height: 70,
                      width: 70,
                      color: Colors.black,
                      child: Center(
                          child: CircularProgressIndicator(
                        backgroundColor: Colors.grey,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                      )),
                    ),
                  ),
                ),
          GestureDetector(
            onTap: () {
              if (video.controller != null) {
                if (video.controller!.value.isPlaying) {
                  video.controller?.pause();
                } else {
                  video.controller?.play();
                }
              }
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.black.withOpacity(0.2),
                      Colors.black.withOpacity(0.2)
                    ]),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      VideoDescription(
                          video.user, video.videoTitle, video.songName),
                      ActionsToolbar(video.likes, video.comments,
                          "https://www.andersonsobelcosmetic.com/wp-content/uploads/2018/09/chin-implant-vs-fillers-best-for-improving-profile-bellevue-washington-chin-surgery.jpg"),
                    ],
                  ),
                  SizedBox(height: 20)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // feedViewModel.controller?.dispose();
    super.dispose();
  }
}

class AllVideoPage extends StatefulWidget {
  AllVideoPage({Key? key}) : super(key: key);

  @override
  _AllVideoPageState createState() => _AllVideoPageState();
}

class _AllVideoPageState extends State<AllVideoPage> {
  final locator = GetIt.instance;

  final feedViewModel = GetIt.instance<FeedViewModel>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            "All Videos",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        body: ViewModelBuilder<FeedViewModel>.reactive(
          disposeViewModel: false,
          fireOnModelReadyOnce: true,
          initialiseSpecialViewModelsOnce: true,
          builder: (context, model, child) => videoScreen(),
          viewModelBuilder: () => feedViewModel,
        ));
  }

  Widget videoScreen() {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 9 / 16,
        crossAxisSpacing: 1.5,
        mainAxisSpacing: 1.5,
      ),
      itemCount: feedViewModel.videos.length,
      itemBuilder: (context, i) {
        return InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ViewVideo(
                          index: i,
                        )));
          },
          child: Container(
            color: Colors.grey.shade300,
            child: CachedNetworkImage(
                imageUrl: feedViewModel.videos[i].gif, fit: BoxFit.cover),
          ),
        );
      },
    );
  }
}
