import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cachedrun/data/get_videos_api.dart';

part 'search_video_event.dart';
part 'search_video_state.dart';

class SearchVideoBloc extends Bloc<SearchVideoEvent, SearchVideoState> {
  SearchVideoBloc() : super(SearchVideoInitial());
  final repo = Api();

  @override
  Stream<SearchVideoState> mapEventToState(
    SearchVideoEvent event,
  ) async* {
    if (event is LoadSearchVideos) {
      try {
        yield SearchVideoLoading();
        final getvideos = await repo.getSearchedVideo(event.text);
        yield SearchVideoLoaded(videos: getvideos.videos);
      } on ErrorModel catch (e) {
        yield SearchVideoError(error: e);
      } catch (e) {
        yield SearchVideoError(
            error: ErrorModel(code: 404, message: "No Match found."));

        print(e.toString());
      }
    }
  }
}
