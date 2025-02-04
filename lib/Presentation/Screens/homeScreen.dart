import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_app/Logic/Bloc.dart';
import 'package:quran_app/Logic/events.dart';
import 'package:quran_app/Logic/states.dart';
import 'package:quran_app/Presentation/Screens/SurahScreen.dart';
import 'package:quran_flutter/models/surah.dart';
import 'package:quran_flutter/quran.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../Logic/AudioPlayer.dart';

class homeScreen extends StatefulWidget {
  final Quran quran;
  final AudioPlayer audioPlayer;
  homeScreen({required this.quran, required this.audioPlayer}) : super();

  @override
  State<homeScreen> createState() => _homeScreenState();
}

class _homeScreenState extends State<homeScreen> {

  @override
  void dispose() {
    widget.audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playAudio(String url, int surahId) async {
    try {
      await widget.audioPlayer.stop();
      print(surahId);
      context.read<MainBloc>().add(PlayAudioEvent(surahId: surahId, url: url));
      await widget.audioPlayer.play(UrlSource(url));
      await widget.audioPlayer.onPlayerComplete.listen((_) {
        context.read<MainBloc>().add(AudioCompletedEvent());
      });
    } catch (e) {
      print("Audio error: $e");
    }
  }

  void _showReciterSelection(BuildContext context, int surahId) {
    String tmpId = surahId.toString().padLeft(3, '0');
    print(tmpId);
    List<Map<String, String>> reciters = [
      {"name": "Ali Jaber", "url": "https://download.quranicaudio.com/quran/ali_jaber//$tmpId.mp3"},
      {"name": "Mohamed Siddiq al-Minshawi", "url": "https://download.quranicaudio.com/qdc/siddiq_minshawi/murattal/$surahId.mp3"},
      {"name": "AbdulBaset AbdulSamad", "url": "https://download.quranicaudio.com/qdc/abdul_baset/murattal/$surahId.mp3"},
    ];

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: reciters.map((reciter) {
              return ListTile(
                title: Text(
                  reciter["name"]!,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  _playAudio(reciter["url"]!, surahId);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildSurahList(List<Surah> surahs, AppState state) {
    return ListView.builder(
      itemCount: surahs.length,
      itemBuilder: (context, index) {
        final surah = surahs[index];
        final isPlaying = state is playingState &&
            state.currentSurahId == surah.number &&
            state.isPlaying;

        return Card(
          color: const Color(0xFFF5EDE3),
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: InkWell(
            onTap: () {
              final currentState = context.read<MainBloc>().state;
              final initState = currentState is InitialState ? currentState : (currentState as playingState).initState;

              context.read<MainBloc>().add(UpdateLastReadEvent(surah: surah, lastReadVerse: initState.lastReadVerse,));
              if(state is playingState){
                Surah curr = Quran.getSurah(state.currentSurahId);
                context.read<MainBloc>().add(OpenSurahWithAudioEvent(surah: surah, playingSurah:curr ,audioUrl: state.currentUrl, position: state.position, duration: state.duration, pauseCurrent: true));}
              else context.read<MainBloc>().add(OpenSurahEvent(surahId: surah.number));
            },
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => _showReciterSelection(context, surah.number),
                    icon: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      color: const Color(0xFF9C7C5F),
                      size: 30,
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          surah.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Amiri',
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          "${surah.nameEnglish} (${surah.verseCount}) - ${surah.type.value}",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontFamily: 'Poppins',
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/sura_frame.png"),
                        fit: BoxFit.fill,
                      ),
                    ),
                    child: Text(
                      "${surah.number}",
                      style: const TextStyle(
                        color: Color(0xFF9C7C5F),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLastReadBar(Surah? lastReadSurah, int lastReadVerse) {
    final displayText = lastReadSurah != null ? "${lastReadSurah.name} (آية ${lastReadVerse})" : "لا يوجد قراءة سابقة";

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF9C7C5F),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            displayText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Amiri',
            ),
          ),
          const Text(
            "آخر ما تم قراءته",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Amiri',
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "القرآن الكريم",
          textAlign: TextAlign.right,
          style: TextStyle(
            fontFamily: 'Amiri',
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF5EDE3),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/homebackground.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: BlocBuilder<MainBloc, AppState>(
          builder: (context, state) {
            return Column(
              children: [
                if (state is InitialState) _buildLastReadBar(state.lastReadSurah, state.lastReadVerse),
                if (state is playingState) _buildLastReadBar(state.initState.lastReadSurah, state.initState.lastReadVerse),
                Expanded(
                  child: BlocConsumer<MainBloc, AppState>(
                    listener: (context, state) {
                      if (state is SurahWithAudioState) {
                        print("Navigating to SurahScreen with audio");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SurahScreen(
                              surah: state.currentSurah,
                              audioPlayer: widget.audioPlayer,
                            ),
                          ),
                        );
                      } else if (state is SurahLoadedState) {
                        print("Navigating to SurahScreen without audio");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SurahScreen(
                              surah: state.currentSurah,
                              audioPlayer: widget.audioPlayer,
                            ),
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      if (state is InitialState) {
                        return _buildSurahList(state.surahs, state);
                      }
                      if (state is playingState) {
                        return _buildSurahList(state.initState.surahs, state);
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
                if (state is playingState) AudioPlayerWidget(audioPlayer: widget.audioPlayer,),
              ],
            );
          },
        ),
      ),
    );
  }
}