import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cachedrun/screens/search_video/bloc/search_video_bloc.dart';
import 'package:cachedrun/screens/search_video/search_video.dart';
import 'package:cachedrun/screens/select_video/bloc/select_video_bloc.dart';
import 'package:cachedrun/screens/select_video/video_preview.dart';
import 'package:cachedrun/screens/upload_screen/upload_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SelectVideos extends StatefulWidget {
  @override
  _SelectVideosState createState() => _SelectVideosState();
}

class _SelectVideosState extends State<SelectVideos> {
  bool title = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SelectVideoBloc, SelectVideoState>(
        builder: (context, state) {
      if (state is SelectVideoLoading) {
        return Scaffold(
          body: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60.0),
                  child: Container(
                    width: 70,
                    height: 70,
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.grey,
                      valueColor:
                          new AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Wait a Momment..",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        );
      } else if (state is SelectVideoLoaded) {
        return Scaffold(
            appBar: AppBar(
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.black),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(20),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: TextField(
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.blueAccent,
                          ),
                          hintText: "Search stock video..",
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                        ),
                        cursorColor: Colors.black,
                        onSubmitted: (String text) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  BlocProvider<SearchVideoBloc>(
                                create: (context) => SearchVideoBloc()
                                  ..add(LoadSearchVideos(text: text)),
                                child: SearchVideos(),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              backgroundColor: Colors.transparent,
            ),
            body: GridView(
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: 9 / 16,
                  crossAxisCount: 3,
                  mainAxisSpacing: 1.5,
                  crossAxisSpacing: 1.5),
              children: [
                InkWell(
                  onTap: () async {
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles(
                      type: FileType.video,
                      allowCompression: false,
                    );
                    if (result != null) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  UploadPage(video: result.files.single.path)));
                    }
                  },
                  child: Center(
                      child: Icon(Icons.video_collection, color: Colors.black)),
                ),
                ...state.videos.map(
                  (video) => InkWell(
                    onTap: () async {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              VideoPreview(url: video.files.link)));
                    },
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: CachedNetworkImageProvider(
                                video.thumbnail,
                              ),
                            ),
                          ),
                          foregroundDecoration: BoxDecoration(
                            gradient: LinearGradient(
                              end: Alignment.center,
                              begin: Alignment.bottomRight,
                              colors: [
                                Colors.black,
                                Colors.transparent,
                              ],
                            ),
                          ),
                          alignment: Alignment.bottomRight,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(Icons.movie_creation_rounded,
                                color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ));
      } else if (state is SelectVideoError) {
        return Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Column(
                children: [
                  Text(
                    state.error.code.toString(),
                    style: TextStyle(color: Colors.red, fontSize: 26),
                  ),
                  SizedBox(height: 10),
                  Text(
                    state.error.message,
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ],
              ),
            ));
      } else {
        return Scaffold();
      }
    });
  }
}
