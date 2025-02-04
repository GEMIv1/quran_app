import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'events.dart';
import 'states.dart';
import 'package:quran_flutter/quran_flutter.dart';
import '';
class MainBloc extends Bloc<AppEvent, AppState> {
  MainBloc() : super(InitialState(
    surahs: Quran.getSurahAsList(),
    lastReadSurah: null,
    lastReadVerse: 0,
  )) {
    on<OpenSurahEvent>(_handleOpenSurah);
    on<UpdateLastReadEvent>(_handleUpdateLastRead);
    on<NavigateBackEvent>(_handleNavigateBack);
    on<PlayAudioEvent>(_handlePlayAudio);
    on<PauseAudioEvent>(_handlePauseAudio);
    on<UpdateAudioPositionEvent>(_handleUpdatePosition);
    on<UpdateAudioDurationEvent>(_handleUpdateDuration);
    on<SeekAudioEvent>(_handleSeek);
    on<OpenSurahWithAudioEvent>(_handleOpenSurahWithAudio);
    on<AudioCompletedEvent>(_handelAudioCompleted);

    _loadInitialData();
  }

  Future<void> _handelAudioCompleted(AudioCompletedEvent event, Emitter<AppState> emit) async {
      final lastReadSurah = state is playingState
        ? (state as playingState).initState.lastReadSurah
        : (state as InitialState).lastReadSurah;
      final lastReadVerse = state is playingState
        ? (state as playingState).initState.lastReadVerse
        : (state as InitialState).lastReadVerse;
      final surahs = state is playingState
        ? (state as playingState).initState.surahs
        : (state as InitialState).surahs;

      emit(InitialState(
        surahs: surahs,
        lastReadSurah: lastReadSurah,
        lastReadVerse: lastReadVerse,
      ));
  }

  Future<void> _handleOpenSurahWithAudio(OpenSurahWithAudioEvent event, Emitter<AppState>emit) async {
      emit(SurahWithAudioState(currentSurah: event.surah, playingSurah:event.playingSurah ,isAudioPlaying: event.pauseCurrent, duration:event.duration, position: event.position, currentUrl: event.audioUrl));
}

  Future<void> _handlePlayAudio(PlayAudioEvent event, Emitter<AppState> emit) async {
    try {
      final currentState = state;
      int SurahId = 0;
      if (currentState is InitialState || currentState is playingState) {
        final initState = currentState is InitialState ? currentState : (currentState as playingState).initState;
        SurahId = event.surahId;
        emit(playingState(
          initState: initState,
          isPlaying: true,
          currentSurahId: event.surahId,
          currentUrl: event.url,
          position: Duration.zero,
          duration: currentState is playingState ? currentState.duration : Duration.zero,
        ));
      }
      else if(currentState is SurahWithAudioState){
        emit(currentState.copyWith(
          isAudioPlaying: true,
          currentSurahId: SurahId,
          currentUrl: event.url,
          position: Duration.zero,
        ));
      }
    } catch (e) {
      emit(ErrorState('Failed to play audio: ${e.toString()}'));
    }
  }

  Future<void> _handlePauseAudio(PauseAudioEvent event, Emitter<AppState> emit) async {
    try {
      if (state is playingState) {
        final currentState = state as playingState;
        emit(currentState.copyWith(isPlaying: false));
      }
    } catch (e) {
      emit(ErrorState('Failed to pause audio: ${e.toString()}'));
    }
  }

  Future<void> _handleUpdatePosition(UpdateAudioPositionEvent event, Emitter<AppState> emit) async {
    try {
      if (state is playingState) {
        final currentState = state as playingState;
        emit(currentState.copyWith(position: event.position));
      }
    } catch (e) {
      emit(ErrorState('Failed to update position: ${e.toString()}'));
    }
  }

  Future<void> _handleUpdateDuration(UpdateAudioDurationEvent event, Emitter<AppState> emit) async {
    try {
      if (state is playingState) {
        final currentState = state as playingState;
        emit(currentState.copyWith(duration: event.duration));
      }
    } catch (e) {
      emit(ErrorState('Failed to update duration: ${e.toString()}'));
    }
  }

  Future<void> _handleSeek(SeekAudioEvent event, Emitter<AppState> emit) async {
    try {
      if (state is playingState) {
        final currentState = state as playingState;
        emit(currentState.copyWith(position: event.position));
      }
    } catch (e) {
      emit(ErrorState('Failed to seek audio: ${e.toString()}'));
    }
  }

  Future<void> _handleOpenSurah(OpenSurahEvent event, Emitter<AppState> emit) async {
    try {
      final surah = Quran.getSurah(event.surahId);
      if (state is playingState) {
        final currentState = state as playingState;
        emit(SurahWithAudioState(
          currentSurah: surah,
          isAudioPlaying: currentState.isPlaying,
          currentSurahId: currentState.currentSurahId,
          currentUrl: currentState.currentUrl,
          position: currentState.position,
          duration: currentState.duration,
          playingSurah: surah
        ));
      } else {
        emit(SurahLoadedState(currentSurah: surah));
      }
    } catch (e) {
      emit(ErrorState('Failed to open Surah: ${e.toString()}'));
    }
  }

  Future<void> _handleUpdateLastRead(UpdateLastReadEvent event, Emitter<AppState> emit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('lastSurahNumber', event.surah.number);
      await prefs.setString('lastSurahName', event.surah.name);
      await prefs.setInt('verseNumber', event.lastReadVerse);

      if (state is InitialState) {
        final currentState = state as InitialState;
        emit(currentState.copyWith(
          lastReadSurah: event.surah,
          lastReadVerse: event.lastReadVerse,
        ));
      } else if (state is playingState) {
        final currentState = state as playingState;
        emit(currentState.copyWith(
          initState: currentState.initState.copyWith(
            lastReadSurah: event.surah,
            lastReadVerse: event.lastReadVerse,
          ),
        ));
      }
      else if (state is SurahWithAudioState) {
        final surahs = Quran.getSurahAsList();
        final currentState = state as SurahWithAudioState;
        final initState = InitialState(
          surahs: surahs,
          lastReadSurah: event.surah,
          lastReadVerse: event.lastReadVerse,
        );
        emit(playingState(
          initState: initState,
          isPlaying: currentState.isAudioPlaying,
          currentSurahId: currentState.playingSurah.number,
          currentUrl: currentState.currentUrl ?? "",
          position: currentState.position,
          duration: currentState.duration,
        ));
    }
      else if (state is SurahLoadedState) {
        final surahs = Quran.getSurahAsList();
        emit(InitialState(surahs:surahs,lastReadSurah: event.surah, lastReadVerse: event.lastReadVerse));

      }
    } catch (e) {
      emit(ErrorState('Failed to update last read: ${e.toString()}'));
    }
  }

  Future<void> _handleNavigateBack(NavigateBackEvent event, Emitter<AppState> emit) async {
    emit(InitialState(
      surahs: Quran.getSurahAsList(),
      lastReadSurah: (state as SurahLoadedState).currentSurah,
      lastReadVerse: 0,
    ));
  }

  Future<void> _loadInitialData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastNumber = prefs.getInt('lastSurahNumber');
      final lastName = prefs.getString('lastSurahName');
      final lastVerse = prefs.getInt('verseNumber') ?? 0;

      if (lastNumber != null && lastName != null) {
        final lastSurah = Quran.getSurah(lastNumber);
        emit(InitialState(
          surahs: Quran.getSurahAsList(),
          lastReadSurah: lastSurah,
          lastReadVerse: lastVerse,
        ));
      }
    } catch (e) {
      emit(ErrorState('Failed to load initial data: ${e.toString()}'));
    }
  }
}