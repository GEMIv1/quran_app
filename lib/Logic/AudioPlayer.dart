import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_flutter/quran.dart';
import 'Bloc.dart';
import 'events.dart';
import 'states.dart';

class AudioPlayerWidget extends StatefulWidget {
  final AudioPlayer audioPlayer;

  const AudioPlayerWidget({required this.audioPlayer}) : super();

  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late final StreamSubscription<Duration> _positionSubscription;
  late final StreamSubscription<Duration> _durationSubscription;
  late final StreamSubscription<PlayerState> _playerStateSubscription;

  @override
  void initState() {
    super.initState();

    _positionSubscription = widget.audioPlayer.onPositionChanged.listen((position) {
      context.read<MainBloc>().add(UpdateAudioPositionEvent(position));
    });

    _durationSubscription = widget.audioPlayer.onDurationChanged.listen((duration) {
      context.read<MainBloc>().add(UpdateAudioDurationEvent(duration));
    });

    _playerStateSubscription = widget.audioPlayer.onPlayerStateChanged.listen((playerState) {
    });
  }

  @override
  void dispose() {
    _positionSubscription.cancel();
    _durationSubscription.cancel();
    _playerStateSubscription.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final twoDigits = (int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainBloc, AppState>(
      builder: (context, state) {
        Duration currentPosition = Duration.zero;
        Duration totalDuration = Duration.zero;
        bool isPlaying = false;
        int playingSurahId = 0;
        String currentUrl = "";
        String surahName = "";
        if (state is playingState) {
          currentPosition = state.position;
          totalDuration = state.duration;
          isPlaying = state.isPlaying;
          playingSurahId = state.currentSurahId;
          currentUrl = state.currentUrl;
          surahName = Quran.getSurahName(playingSurahId);
        } else if (state is SurahWithAudioState) {
          currentPosition = state.position;
          totalDuration = state.duration;
          isPlaying = state.isAudioPlaying;
          playingSurahId = (state.playingSurah.number);
          currentUrl = state.currentUrl ?? "";
          surahName = Quran.getSurahName(playingSurahId);
        }

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, -3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                surahName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Amiri',
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      color: const Color(0xFF9C7C5F),
                    ),
                    onPressed: () async {
                      if (isPlaying) {
                        await widget.audioPlayer.pause();
                        context.read<MainBloc>().add(PauseAudioEvent());
                      } else {
                        await widget.audioPlayer.resume();
                        context.read<MainBloc>().add(PlayAudioEvent(
                          surahId: playingSurahId,
                          url: currentUrl,
                        ));
                      }
                    },
                  ),
                  Expanded(
                    child: totalDuration.inSeconds > 0
                        ? Slider(
                      value: currentPosition.inSeconds.toDouble().clamp(
                          0.0, totalDuration.inSeconds.toDouble()),
                      min: 0,
                      max: totalDuration.inSeconds.toDouble(),
                      onChanged: (value) {
                        final newPosition = Duration(seconds: value.toInt());
                        widget.audioPlayer.seek(newPosition);
                        context.read<MainBloc>().add(UpdateAudioPositionEvent(newPosition));
                      },
                      activeColor: const Color(0xFF9C7C5F),
                      inactiveColor: Colors.grey[300],
                    )
                        : Container(),
                  ),
                  Text(
                    _formatDuration(currentPosition),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
