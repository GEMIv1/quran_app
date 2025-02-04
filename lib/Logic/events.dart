import 'package:quran_flutter/models/surah.dart';

abstract class AppEvent {}

class OpenSurahEvent extends AppEvent {
  final int surahId;
  OpenSurahEvent({required this.surahId});
}

class UpdateLastReadEvent extends AppEvent {
  final Surah surah;
  final int lastReadVerse;
  UpdateLastReadEvent({required this.surah, required this.lastReadVerse});
}

class PlayAudioEvent extends AppEvent {
  final int surahId;
  final String url;

  PlayAudioEvent({required this.surahId, required this.url});
}

class UpdateAudioPositionEvent extends AppEvent {
  final Duration position;
  UpdateAudioPositionEvent(this.position);
}

class UpdateAudioDurationEvent extends AppEvent {
  final Duration duration;
  UpdateAudioDurationEvent(this.duration);
}

class SeekAudioEvent extends AppEvent {
  final Duration position;
  SeekAudioEvent(this.position);
}

class AudioCompletedEvent extends AppEvent {}

class OpenSurahWithAudioEvent extends AppEvent{
  final Surah surah;
  final String? audioUrl;
  final bool pauseCurrent;
  final position;
  final duration;
  final Surah playingSurah;

  OpenSurahWithAudioEvent({
    required this.surah,
    this.audioUrl,
    this.pauseCurrent = false,
    required this.position,
    required this.duration,
    required this.playingSurah
  });
}

class PauseAudioEvent extends AppEvent {}

class NavigateBackEvent extends AppEvent {}