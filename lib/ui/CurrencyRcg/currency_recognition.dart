import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../tflite/currency recognition/classifier.dart';
import '../../tflite/currency recognition/classifier_float.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:tflite_flutter_helper/tflite_flutter_helper.dart' as tfh;

File? _image;
Image? _imageWidget;

class CurrencyRecognitionScreen extends StatefulWidget {
  const CurrencyRecognitionScreen({Key? key}) : super(key: key);

  @override
  _CurrencyRecognitionScreenState createState() =>
      _CurrencyRecognitionScreenState();
}

class _CurrencyRecognitionScreenState extends State<CurrencyRecognitionScreen> {
  final FlutterTts flutterTts = FlutterTts();

  void speak() async {
    await flutterTts
        .setVoice({"name": "en-gb-x-gbb-network", "locale": "en-GB"});
    await flutterTts.awaitSpeakCompletion(false);
    await flutterTts.speak(
        "Currency recognition screen. Tap anywhere on the screen to open camera or swipe left for Face recognition");
    //await flutterTts.speak("Swipe left for face recognition");
  }

  late Classifier _classifier;

  tfh.Category? category;
  CameraDescription? firstCamera;

  @override
  void initState() {
    super.initState();
    Future.delayed(
      Duration.zero,
      () async {
        final cameras = await availableCameras();
        firstCamera = cameras.first;
      },
    );
    if (_image == null) {
      speak();
    }

    _classifier = ClassifierFloat();
  }

  @override
  void dispose() {
    _image = null;
    _imageWidget = null;
    super.dispose();
  }

  void _predict() async {
    img.Image imageInput = img.decodeImage(_image!.readAsBytesSync())!;
    var pred = _classifier.predict(imageInput);

    setState(() {
      category = pred;
    });
    await flutterTts.speak(category!.label);
    Future.delayed(
        const Duration(seconds: 3),
        () async => await flutterTts
            .speak('Tap to take another picture or Long press to hear again'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onLongPress: () async => await flutterTts.speak(category!.label),
        onTap: () {
          Navigator.of(context)
              .push(
            MaterialPageRoute(
              builder: (_) => TakePictureScreen(camera: firstCamera!),
            ),
          )
              .then((_) {
            _predict();
            setState(() {});
          });
        },
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

/// A widget showing a live camera preview.
class CameraPreview extends StatelessWidget {
  /// Creates a preview widget for the given camera controller.
  const CameraPreview(this.controller, {Key? key, this.child})
      : super(key: key);

  /// The controller for the camera that the preview is shown for.
  final CameraController controller;

  /// A widget to overlay on top of the camera preview
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return controller.value.isInitialized
        ? ValueListenableBuilder<CameraValue>(
            valueListenable: controller,
            builder: (BuildContext context, Object? value, Widget? child) {
              return AspectRatio(
                aspectRatio: MediaQuery.of(context).size.width /
                    MediaQuery.of(context).size.height,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    _wrapInRotatedBox(child: controller.buildPreview()),
                    child ?? Container(),
                  ],
                ),
              );
            },
            child: child,
          )
        : Container();
  }

  Widget _wrapInRotatedBox({required Widget child}) {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return child;
    }

    return RotatedBox(
      quarterTurns: _getQuarterTurns(),
      child: child,
    );
  }

  int _getQuarterTurns() {
    final Map<DeviceOrientation, int> turns = <DeviceOrientation, int>{
      DeviceOrientation.portraitUp: 0,
      DeviceOrientation.landscapeRight: 1,
      DeviceOrientation.portraitDown: 2,
      DeviceOrientation.landscapeLeft: 3,
    };
    return turns[_getApplicableOrientation()]!;
  }

  DeviceOrientation _getApplicableOrientation() {
    return controller.value.isRecordingVideo
        ? controller.value.recordingOrientation!
        : (controller.value.previewPauseOrientation ??
            controller.value.lockedCaptureOrientation ??
            controller.value.deviceOrientation);
  }
}

class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;
  const TakePictureScreen({
    Key? key,
    required this.camera,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _TakePictureScreenState createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends State<TakePictureScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  final FlutterTts flutterTts = FlutterTts();

  void speak() async {
    await flutterTts
        .setVoice({"name": "en-gb-x-gbb-network", "locale": "en-GB"});
    await flutterTts.awaitSpeakCompletion(false);
    await flutterTts.speak("Tap anywhere to take a picture");
  }

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.high,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller!.initialize();
    speak();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner
      // until the controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return GestureDetector(
              onTap: () async {
                // Take the Picture in a try / catch block. If anything goes wrong,
                // catch the error.
                try {
                  // Ensure that the camera is initialized.
                  await _initializeControllerFuture;

                  await _controller!.setFlashMode(FlashMode.torch);
                  await _controller!.setFocusMode(FocusMode.auto);

                  // Attempt to take a picture and log where it's been saved.
                  final pickedFile = await _controller!.takePicture();

                  _image = File(pickedFile.path);
                  _imageWidget = Image.file(_image!);

                  Navigator.of(context).pop();
                } catch (e) {
                  // If an error occurs, log the error to the console.
                  // print(e);
                }
              },
              child: CameraPreview(_controller!),
            );
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
