import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lottie/lottie.dart';

class CurrencyRecognitionScreen extends StatefulWidget {
  const CurrencyRecognitionScreen({Key? key}) : super(key: key);

  @override
  State<CurrencyRecognitionScreen> createState() => _CurrencyRecognitionScreenState();
}

class _CurrencyRecognitionScreenState extends State<CurrencyRecognitionScreen> {
  final FlutterTts flutterTts = FlutterTts();

  void speak()async{
    await flutterTts.awaitSpeakCompletion(true);
    await flutterTts.speak("Currency recognition screen. Swipe left for face recognition and right for object detection");
    //await flutterTts.speak("Swipe left for face recognition");
  }

  @override
  void initState() {
    
    super.initState();
    speak();
    
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Center(child: Lottie.asset('./assets/52975-under-construction.json',width: MediaQuery.of(context).size.width-40)),
    );
  }
}