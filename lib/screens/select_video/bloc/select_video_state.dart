part of 'select_video_bloc.dart';

@immutable
abstract class SelectVideoState {}

class SelectVideoInitial extends SelectVideoState {}

class SelectVideoLoading extends SelectVideoState {}

class SelectVideoError extends SelectVideoState {
  final ErrorModel error;
  SelectVideoError({
    required this.error,
  });
}

class SelectVideoLoaded extends SelectVideoState {
  final List<Video> videos;
  SelectVideoLoaded({
    required this.videos,
  });
}
