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
  final repo = AudioRepo();
  AddAudioBloc() : super(AddAudioInitial()) {
    on<LoadAudio>((event, emit) {
      emit(AddAudioLoading());
      final repo = AudioRepo();
      repo.getAudios().then((value) {
        emit(AddAudioLoaded(audio: value.audioList));
      }).catchError((e) {
        print(e.toString());
        emit(AddAudioError());
      });
    });
  }
}
