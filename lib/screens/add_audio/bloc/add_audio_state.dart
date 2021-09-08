part of 'add_audio_bloc.dart';

@immutable
abstract class AddAudioState {}

class AddAudioInitial extends AddAudioState {}

class AddAudioLoading extends AddAudioState {}

class AddAudioError extends AddAudioState {}

class AddAudioLoaded extends AddAudioState {
  final List<Audio> audio;
  AddAudioLoaded({
    required this.audio,
  });
}
