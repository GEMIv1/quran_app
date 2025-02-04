import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_app/Logic/Bloc.dart';
import 'package:quran_app/Logic/events.dart';
import 'package:quran_flutter/models/surah.dart';
import 'package:quran_flutter/quran_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Logic/states.dart';
import '../../Logic/AudioPlayer.dart';

class SurahScreen extends StatelessWidget {
  final Surah surah;
  final AudioPlayer audioPlayer;
  SurahScreen({required this.surah, required this.audioPlayer, Key? key})
      : super(key: key);

  Future<void> _updateLastRead(int verseNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastSurahNumber', surah.number);
    await prefs.setInt('verseNumber', verseNumber);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainBloc, AppState>(
      builder: (context, state) {
        print("Current state in SurahScreen: $state");
        bool isAudioPlaying = state is playingState;
        print("isAudioPlaying: $isAudioPlaying");

        return WillPopScope(
          onWillPop: () async {
            final controller = TextEditingController();
            final verseNumber = await showDialog<int>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text(
                    "أدخل رقم الآية",
                    style: TextStyle(fontFamily: "Amiri"),
                  ),
                  content: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: "رقم الآية"),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        if (controller.text.isNotEmpty) {
                          int enteredData = int.parse(controller.text);
                          if (enteredData >= 1 && enteredData <= surah.verseCount) {
                            Navigator.pop(context, int.tryParse(controller.text));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "خطأ في الإدخال",
                                  style: TextStyle(
                                      fontFamily: 'Amiri', fontSize: 18),
                                ),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          }
                        }
                      },
                      child: const Text(
                        "حفظ",
                        style: TextStyle(fontFamily: 'Amiri'),
                      ),
                    )
                  ],
                );
              },
            );

            if (verseNumber != null) {
              await _updateLastRead(verseNumber);
              context.read<MainBloc>().add(
                UpdateLastReadEvent(
                  surah: surah,
                  lastReadVerse: verseNumber,
                ),
              );
            }
            return true;
          },
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: const Color(0xFFF5EDE3),
              elevation: 0,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    surah.name,
                    style: const TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 16,
                      color: Colors.brown,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/images/sura_name_frame.png"),
                          fit: BoxFit.contain,
                        ),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 40),
                          Text(
                            "${surah.verseCount}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              fontFamily: 'Amiri',
                            ),
                          ),
                          const SizedBox(width: 95),
                          Text(
                            surah.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              fontFamily: 'Amiri',
                            ),
                          ),
                          const SizedBox(width: 95),
                          Text(
                            "${surah.number}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              fontFamily: 'Amiri',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (surah.number != 1 && surah.number != 9)
                      const Center(
                        child: Text(
                          Quran.bismillah,
                          style: TextStyle(
                            fontFamily: 'AmiriQuran',
                            color: Colors.black,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Builder(
                        builder: (context) {
                          final verses =
                          Quran.getSurahVersesAsList(surah.number);
                          final Map<int, List> groupedVerses = {};
                          for (final verse in verses) {
                            final page = Quran.getPageNumber(surahNumber: surah.number, verseNumber: verse.verseNumber,);
                            if (!groupedVerses.containsKey(page)) {
                              groupedVerses[page] = [];
                            }
                            groupedVerses[page]!.add(verse);
                          }
                          final sortedPages = groupedVerses.keys.toList()..sort();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: sortedPages.map((page) {
                              final pageVerses = groupedVerses[page]!;
                              final juz = Quran.getJuzNumber(surahNumber: surah.number, verseNumber: pageVerses.first.verseNumber,);
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pageVerses.map((verse) => '${verse.text} \u06DD${verse.verseNumber}').join(' '),
                                    style: const TextStyle(fontFamily: 'AmiriQuran', fontSize: 22, height: 2.2,),
                                    textDirection: TextDirection.rtl,
                                    textAlign: TextAlign.justify,
                                    strutStyle: const StrutStyle(fontSize: 22, height: 2.2, forceStrutHeight: true,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF5EDE3),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      "Page $page - Juz $juz",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontFamily: 'Amiri',
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: isAudioPlaying
                ? Container(
              color: Colors.white,
              child: AudioPlayerWidget(
                audioPlayer: audioPlayer,
              ),
            )
                : null,
          ),
        );
      },
    );
  }
}
