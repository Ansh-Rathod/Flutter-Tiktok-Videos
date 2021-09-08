part of 'search_video_bloc.dart';

abstract class SearchVideoState {}

class SearchVideoInitial extends SearchVideoState {}

class SearchVideoLoading extends SearchVideoState {}

class SearchVideoError extends SearchVideoState {
  final ErrorModel error;
  SearchVideoError({
    required this.error,
  });
}

class SearchVideoLoaded extends SearchVideoState {
  final List<Video> videos;
  SearchVideoLoaded({
    required this.videos,
  });
}
