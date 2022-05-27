import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
        "Currency recognition screen. Swipe right for currency recognition");
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('TfLite Flutter Helper',
      //       style: TextStyle(color: Colors.white)),
      // ),
      body: Column(
        children: <Widget>[
          Center(
            child: _image == null
                ? const Text('No image selected.')
                : Container(
                    constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height / 2),
                    decoration: BoxDecoration(
                      border: Border.all(),
                    ),
                    child: _imageWidget,
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
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Pick Image',
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
}
