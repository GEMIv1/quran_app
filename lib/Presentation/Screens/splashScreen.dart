import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'homeScreen.dart';
import 'package:quran_flutter/quran.dart';

class SplashScreen extends StatefulWidget {
  final AudioPlayer audioPlayer;
  const SplashScreen({required this.audioPlayer}) : super();

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => homeScreen(quran: Quran(), audioPlayer: widget.audioPlayer),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 20),
            const Text(
              Quran.bismillah,
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
