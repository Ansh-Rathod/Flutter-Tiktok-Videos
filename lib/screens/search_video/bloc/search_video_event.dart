part of 'search_video_bloc.dart';

abstract class SearchVideoEvent {
  const SearchVideoEvent();
}

class LoadSearchVideos extends SearchVideoEvent {
  final String text;
  LoadSearchVideos({
    required this.text,
  });
}
