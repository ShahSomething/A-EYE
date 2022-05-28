import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import '../../tflite/currency recognition/classifier.dart';
import '../../tflite/currency recognition/classifier_float.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

class CurrencyRecognitionScreen extends StatefulWidget {
  const CurrencyRecognitionScreen({Key? key}) : super(key: key);

  @override
  _CurrencyRecognitionScreenState createState() =>
      _CurrencyRecognitionScreenState();
}

class _CurrencyRecognitionScreenState extends State<CurrencyRecognitionScreen> {
  final FlutterTts flutterTts = FlutterTts();

  void speak() async {
    await flutterTts.awaitSpeakCompletion(true);
    await flutterTts.speak(
        "Currency recognition screen. Tap anywhere on the screen to open camera");
    //await flutterTts.speak("Swipe left for face recognition");
  }

  late Classifier _classifier;

  File? _image;
  final picker = ImagePicker();

  Image? _imageWidget;

  img.Image? fox;

  Category? category;

  @override
  void initState() {
    super.initState();
    speak();
    _classifier = ClassifierFloat();
  }

  Future getImage() async {
    await flutterTts
        .speak("Opening Camera, use volume buttons to take a picture");
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      _image = File(pickedFile!.path);
      _imageWidget = Image.file(_image!);

      _predict();
    });
  }

  void _predict() async {
    img.Image imageInput = img.decodeImage(_image!.readAsBytesSync())!;
    var pred = _classifier.predict(imageInput);

    setState(() {
      category = pred;
    });
    await flutterTts.speak(category!.label);
    Future.delayed(
        const Duration(seconds: 2),
        () async => await flutterTts
            .speak('Tap to take another picture or Long press to hear again'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('TfLite Flutter Helper',
      //       style: TextStyle(color: Colors.white)),
      // ),
      backgroundColor: Colors.white,
      body: GestureDetector(
        onLongPress: () async => await flutterTts.speak(category!.label),
        onTap: () => getImage(),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: _image == null
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: <Widget>[
            Center(
              child: _image == null
                  ? Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(15.0),
                          child: Text(
                            'Tap anywhere on the screen to open camera',
                            style: TextStyle(fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Lottie.asset('./assets/55607-flying-wallet-money.json'),
                      ],
                    )
                  : Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Container(
                        constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height / 2),
                        decoration: BoxDecoration(
                          border: Border.all(),
                        ),
                        child: _imageWidget,
                      ),
                    ),
            ),
            const SizedBox(
              height: 36,
            ),
            Text(
              category != null ? category!.label : '',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              category != null
                  ? 'Confidence: ${category!.score.toStringAsFixed(3)}'
                  : '',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
