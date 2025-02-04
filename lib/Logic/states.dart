import 'package:quran_flutter/models/surah.dart';

abstract class AppState {}

class InitialState extends AppState {
  final List<Surah> surahs;
  final Surah? lastReadSurah;
  final int lastReadVerse;

  InitialState({required this.surahs, this.lastReadSurah, required this.lastReadVerse});

  InitialState copyWith({
    List<Surah>? surahs,
    Surah? lastReadSurah,
    int? lastReadVerse,
  }) {
    return InitialState(
      surahs: surahs ?? this.surahs,
      lastReadSurah: lastReadSurah ?? this.lastReadSurah,
      lastReadVerse: lastReadVerse ?? this.lastReadVerse,
    );
  }

}

class SurahWithAudioState extends AppState {
  final Surah currentSurah;
  final bool isAudioPlaying;
  final int? currentSurahId;
  final String? currentUrl;
  final Duration position;
  final Duration duration;
  final Surah playingSurah;

  SurahWithAudioState({
    required this.currentSurah,
    this.isAudioPlaying = false,
    this.currentSurahId,
    this.currentUrl,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    required this.playingSurah,
  });

  SurahWithAudioState copyWith({
    Surah? currentSurah,
    bool? isAudioPlaying,
    int? currentSurahId,
    String? currentUrl,
    Duration? position,
    Duration? duration,
  }) {
    return SurahWithAudioState(
      currentSurah: currentSurah ?? this.currentSurah,
      isAudioPlaying: isAudioPlaying ?? this.isAudioPlaying,
      currentSurahId: currentSurahId ?? this.currentSurahId,
      currentUrl: currentUrl ?? this.currentUrl,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      playingSurah: playingSurah
    );
  }
}


class SurahLoadedState extends AppState {
  final Surah currentSurah;
  SurahLoadedState({required this.currentSurah});
}
class playingState extends AppState {
  final InitialState initState;
  final bool isPlaying;
  final int currentSurahId;
  final String currentUrl;
  final Duration position;
  final Duration duration;

  playingState({
    required this.initState,
    required this.isPlaying,
    required this.currentSurahId,
    required this.currentUrl,
    required this.position,
    required this.duration,
  });

  playingState copyWith({
    InitialState? initState,
    bool? isPlaying,
    int? currentSurahId,
    String? currentUrl,
    Duration? position,
    Duration? duration,
  }) {
    return playingState(
      initState: initState ?? this.initState,
      isPlaying: isPlaying ?? this.isPlaying,
      currentSurahId: currentSurahId ?? this.currentSurahId,
      currentUrl: currentUrl ?? this.currentUrl,
      position: position ?? this.position,
      duration: duration ?? this.duration,
    );
  }
}

class ErrorState extends AppState {
  final String message;
  ErrorState(this.message);
}