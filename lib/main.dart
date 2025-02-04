import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_app/Logic/Bloc.dart';
import 'package:quran_flutter/models/page_surah_verses.dart';
import 'package:quran_flutter/models/verse.dart';
import 'package:quran_flutter/quran.dart';
import 'Presentation/Screens/homeScreen.dart';
import 'Presentation/Screens/splashScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Quran.initialize();
  final AudioPlayer audioPlayer = AudioPlayer();

  runApp(
    BlocProvider(
      create: (context) => MainBloc(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "القرآن",
        home: SplashScreen(audioPlayer: audioPlayer),
      ),
    ),
  );
}
