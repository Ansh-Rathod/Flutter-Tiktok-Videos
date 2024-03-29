import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cachedrun/data/get_videos_api.dart';

part 'search_video_event.dart';
part 'search_video_state.dart';

class SearchVideoBloc extends Bloc<SearchVideoEvent, SearchVideoState> {
  final repo = Api();

  SearchVideoBloc() : super(SearchVideoInitial()) {
    on<LoadSearchVideos>(
      (event, emit) async {
        try {
          emit(SearchVideoLoading());
          final getvideos = await repo.getSearchedVideo(event.text);
          emit(SearchVideoLoaded(videos: getvideos.videos));
        } on ErrorModel catch (e) {
          emit(SearchVideoError(error: e));
        } catch (e) {
          emit(SearchVideoError(
              error: ErrorModel(code: 404, message: "No Match found.")));
          print(e.toString());
        }
      },
    );
  }
}
