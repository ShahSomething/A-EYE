// ignore_for_file: unnecessary_null_comparison, constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:see_ai/tflite/ObjectDetection/recognition.dart';
import 'package:see_ai/ui/ObjDtc/box_widget.dart';

import 'camera_view.dart';

/// [ObjectDetection] stacks [CameraView] and [BoxWidget]s with bottom sheet for stats
class ObjectDetection extends StatefulWidget {
  const ObjectDetection({Key? key}) : super(key: key);

  @override
  _ObjectDetectionState createState() => _ObjectDetectionState();
}

class _ObjectDetectionState extends State<ObjectDetection> {
  final FlutterTts flutterTts = FlutterTts();

  void speak() async {
    await flutterTts.setLanguage("en-US");
    //await flutterTts.setPitch(1);
    //print(await flutterTts.getVoices);
    //await flutterTts.setSpeechRate(0);
    await flutterTts
        .setVoice({"name": "en-gb-x-gbb-network", "locale": "en-GB"});
    await flutterTts.awaitSpeakCompletion(true);
    await flutterTts.speak(
        "Object Detection Started. Press and hold anywhere to exit Object Detection.");
    //await flutterTts.speak("Swipe left for face recognition");
  }

  @override
  void initState() {
    super.initState();
    speak();
  }

  /// Results to draw bounding boxes
  List<Recognition> results = [];

  /// Scaffold Key
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.black,
      // appBar: AppBar(
      //   title: const Text('A-EYE'),
      // ),
      body: GestureDetector(
        onLongPress: () => Navigator.of(context).pop(),
        child: Stack(
          children: <Widget>[
            // Camera View
            SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.height,
              child: CameraView(resultsCallback),
            ),

            // Bounding boxes
            boundingBoxes(results),

            // Heading
            // Align(
            //   alignment: Alignment.topLeft,
            //   child: Container(
            //     padding: const EdgeInsets.only(top: 20),
            //     child: Text(
            //       'Object Detection Flutter',
            //       textAlign: TextAlign.left,
            //       style: TextStyle(
            //         fontSize: 28,
            //         fontWeight: FontWeight.bold,
            //         color: Colors.deepOrangeAccent.withOpacity(0.6),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  /// Returns Stack of bounding boxes
  Widget boundingBoxes(List<Recognition>? results) {
    if (results == null) {
      return Container();
    }
    return Stack(
      children: results
          .map((e) => BoxWidget(
                result: e,
              ))
          .toList(),
    );
  }

  /// Callback to get inference results from [CameraView]
  void resultsCallback(List<Recognition> results) async {
    setState(() {
      this.results = results;
    });
    for (var result in results) {
      await flutterTts.speak(result.label);
    }
  }
}
