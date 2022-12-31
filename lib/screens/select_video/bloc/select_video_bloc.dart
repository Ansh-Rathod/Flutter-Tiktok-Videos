import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cachedrun/data/get_videos_api.dart';
import 'package:meta/meta.dart';

part 'select_video_event.dart';
part 'select_video_state.dart';

class SelectVideoBloc extends Bloc<SelectVideoEvent, SelectVideoState> {
  final repo = Api();

  SelectVideoBloc() : super(SelectVideoInitial()) {
    on<LoadVideos>((event, emit) async {
      try {
        emit(SelectVideoLoading());
        final getvideos = await repo.getVideos();
        emit(SelectVideoLoaded(videos: getvideos.videos));
      } on ErrorModel catch (e) {
        emit(SelectVideoError(error: e));
      } catch (e) {
        print(e.toString());
      }
    });
  }
}
