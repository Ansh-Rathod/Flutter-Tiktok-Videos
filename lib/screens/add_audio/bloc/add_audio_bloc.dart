import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cachedrun/model/audio_model.dart';
import 'package:meta/meta.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
part 'add_audio_event.dart';
part 'add_audio_state.dart';

class AudioRepo {
  Future<AudioList> getAudios() async {
    final docs = await FirebaseFirestore.instance.collection('Songs').get();
    return AudioList.fromDoc(docs);
  }
}

class AddAudioBloc extends Bloc<AddAudioEvent, AddAudioState> {
  AddAudioBloc() : super(AddAudioInitial());
  final repo = AudioRepo();
  @override
  Stream<AddAudioState> mapEventToState(
    AddAudioEvent event,
  ) async* {
    if (event is LoadAudio) {
      try {
        yield AddAudioLoading();
        final audios = await repo.getAudios();
        yield AddAudioLoaded(audio: audios.audioList);
      } catch (e) {
        print(e.toString());

        yield AddAudioError();
      }
    }
  }
}
