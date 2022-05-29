import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:see_ai/ui/FaceDtc/detector_painters.dart';
import 'package:see_ai/ui/FaceDtc/fr_utils.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'package:image/image.dart' as imglib;
import 'package:quiver/collection.dart';

class FaceRecognition extends StatefulWidget {
  const FaceRecognition({Key? key}) : super(key: key);

  @override
  State<FaceRecognition> createState() => _FaceRecognitionState();
}

class _FaceRecognitionState extends State<FaceRecognition> {
  final FlutterTts flutterTts = FlutterTts();

  void speak() async {
    await flutterTts.awaitSpeakCompletion(true);
    await flutterTts.speak(
        "Face recognition started. Press and hold anywhere to exit face recognition");
    //await flutterTts.speak("Swipe left for face recognition");
  }

  File? jsonFile;
  dynamic _scanResults;
  CameraController? _camera;
  // ignore: prefer_typing_uninitialized_variables
  var interpreter;
  bool _isDetecting = false;
  CameraLensDirection _direction = CameraLensDirection.front;
  dynamic data = {};
  double threshold = 1.0;
  Directory? tempDir;
  List? e1;
  bool _faceFound = false;
  final TextEditingController _name = TextEditingController();

  @override
  void initState() {
    super.initState();
    // SystemChrome.setPreferredOrientations(
    //     [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    _initializeCamera();
    speak();
  }

  Future loadModel() async {
    try {
      final gpuDelegateV2 = tfl.GpuDelegateV2(
          options: tfl.GpuDelegateOptionsV2(
        isPrecisionLossAllowed: false,
        inferencePreference: tfl.TfLiteGpuInferenceUsage.fastSingleAnswer,
        inferencePriority1: tfl.TfLiteGpuInferencePriority.minLatency,
        inferencePriority2: tfl.TfLiteGpuInferencePriority.auto,
        inferencePriority3: tfl.TfLiteGpuInferencePriority.auto,
      ));

      var interpreterOptions = tfl.InterpreterOptions()
        ..addDelegate(gpuDelegateV2);
      interpreter = await tfl.Interpreter.fromAsset('mobilefacenet.tflite',
          options: interpreterOptions);
    } on Exception {
      // ignore: avoid_print
      print('Failed to load model.');
    }
  }

  void _initializeCamera() async {
    CameraDescription description = await getCamera(_direction);

    InputImageRotation rotation = rotationIntToImageRotation(
      description.sensorOrientation,
    );

    _camera = CameraController(description, ResolutionPreset.ultraHigh,
        enableAudio: false);
    await _camera?.initialize();
    await loadModel();
    //await Future.delayed(const Duration(milliseconds: 500));
    tempDir = await getApplicationDocumentsDirectory();
    String _embPath = tempDir!.path + '/emb.json';
    jsonFile = File(_embPath);
    if (jsonFile!.existsSync()) {
      data = json.decode(jsonFile!.readAsStringSync());
    }

    _camera!.startImageStream((CameraImage image) async {
      if (_camera != null) {
        if (_isDetecting) {
          return;
        }
        _isDetecting = true;
        String res;
        dynamic finalResult = Multimap<String, Face>();
        List<Face> faces = await detect(image, rotation);

        if (faces.isEmpty) {
          _faceFound = false;
        } else {
          _faceFound = true;
        }
        Face _face;
        imglib.Image convertedImage = _convertCameraImage(image, _direction);
        for (_face in faces) {
          double x, y, w, h;
          x = (_face.boundingBox.left - 10);
          y = (_face.boundingBox.top - 10);
          w = (_face.boundingBox.width + 10);
          h = (_face.boundingBox.height + 10);
          imglib.Image croppedImage = imglib.copyCrop(
              convertedImage, x.round(), y.round(), w.round(), h.round());
          croppedImage = imglib.copyResizeCropSquare(croppedImage, 112);
          // int startTime = new DateTime.now().millisecondsSinceEpoch;
          res = _recog(croppedImage);
          // int endTime = new DateTime.now().millisecondsSinceEpoch;
          // print("Inference took ${endTime - startTime}ms");
          finalResult.add(res, _face);
        }
        setState(() {
          _scanResults = finalResult;
        });
        for (var result in _scanResults.keys) {
          await flutterTts.speak(result);
        }

        _isDetecting = false;
      }
    });
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    _camera?.stopImageStream();
    _camera?.dispose();
    _camera = null;
  }

  Future<List<Face>> detect(CameraImage image, InputImageRotation rotation) {
    final faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.fast,

        //mode: FaceDetectorMode.fast,
        //enableLandmarks: true,
      ),
    );
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize =
        Size(image.width.toDouble(), image.height.toDouble());
    final inputImageFormat =
        InputImageFormatValue.fromRawValue(image.format.raw) ??
            InputImageFormat.nv21;
    final planeData = image.planes.map(
      (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: rotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );

    return faceDetector.processImage(
      InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData),
    );
  }

  Widget _buildResults() {
    const Text noResultsText = Text('');
    if (_scanResults == null ||
        _camera == null ||
        !_camera!.value.isInitialized) {
      return noResultsText;
    }
    CustomPainter painter;

    final Size imageSize = Size(
      _camera!.value.previewSize!.height,
      _camera!.value.previewSize!.width,
    );
    painter = FaceDetectorPainter(imageSize, _scanResults);
    return CustomPaint(
      painter: painter,
    );
  }

  Widget _buildImage() {
    // if (_camera == null || !_camera!.value.isInitialized) {
    //   return const Center(
    //     child: CircularProgressIndicator(),
    //   );
    // }

    return Container(
      //constraints: const BoxConstraints.expand(),
      child: _camera == null
          ? const Center(child: null)
          : Stack(
              fit: StackFit.expand,
              children: <Widget>[
                CameraPreview(_camera!),
                _buildResults(),
                Positioned(
                  top: 40,
                  right: 5,
                  child: PopupMenuButton<Choice>(
                    color: const Color.fromARGB(255, 247, 191, 80),
                    onSelected: (Choice result) {
                      if (result == Choice.delete) {
                        _resetFile();
                      } else {
                        _viewLabels();
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<Choice>>[
                      const PopupMenuItem<Choice>(
                        child: Text('View Saved Faces'),
                        value: Choice.view,
                      ),
                      const PopupMenuItem<Choice>(
                        child: Text('Remove all faces'),
                        value: Choice.delete,
                      )
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  void _toggleCameraDirection() async {
    if (_direction == CameraLensDirection.back) {
      _direction = CameraLensDirection.front;
    } else {
      _direction = CameraLensDirection.back;
    }
    await _camera?.stopImageStream();
    await _camera?.dispose();

    setState(() {
      _camera = null;
    });
    _initializeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Face recognition'),
      //   actions: <Widget>[
      //     PopupMenuButton<Choice>(
      //       onSelected: (Choice result) {
      //         if (result == Choice.delete) {
      //           _resetFile();
      //         } else {
      //           _viewLabels();
      //         }
      //       },
      //       itemBuilder: (BuildContext context) => <PopupMenuEntry<Choice>>[
      //         const PopupMenuItem<Choice>(
      //           child: Text('View Saved Faces'),
      //           value: Choice.view,
      //         ),
      //         const PopupMenuItem<Choice>(
      //           child: Text('Remove all faces'),
      //           value: Choice.delete,
      //         )
      //       ],
      //     ),
      //   ],
      // ),
      body: GestureDetector(
        onLongPress: () => Navigator.of(context).pop(),
        child: _buildImage(),
      ),
      floatingActionButton:
          Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        FloatingActionButton(
          backgroundColor: (_faceFound)
              ? const Color.fromARGB(255, 247, 191, 80)
              : Colors.blueGrey,
          child: const Icon(Icons.add),
          onPressed: () {
            if (_faceFound) _addLabel();
          },
          heroTag: null,
        ),
        const SizedBox(
          height: 10,
        ),
        FloatingActionButton(
          backgroundColor: const Color.fromARGB(255, 247, 191, 80),
          onPressed: _toggleCameraDirection,
          heroTag: null,
          child: _direction == CameraLensDirection.back
              ? const Icon(Icons.camera_front)
              : const Icon(Icons.camera_rear),
        ),
      ]),
    );
  }

  imglib.Image _convertCameraImage(
      CameraImage image, CameraLensDirection _dir) {
    int width = image.width;
    int height = image.height;
    // imglib -> Image package from https://pub.dartlang.org/packages/image
    var img = imglib.Image(width, height); // Create Image buffer
    const int hexFF = 0xFF000000;
    final int uvyButtonStride = image.planes[1].bytesPerRow;
    final int? uvPixelStride = image.planes[1].bytesPerPixel;
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        final int uvIndex = uvPixelStride! * (x / 2).floor() +
            uvyButtonStride * (y / 2).floor();
        final int index = y * width + x;
        final yp = image.planes[0].bytes[index];
        final up = image.planes[1].bytes[uvIndex];
        final vp = image.planes[2].bytes[uvIndex];
        // Calculate pixel color
        int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
        int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
            .round()
            .clamp(0, 255);
        int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
        // color: 0x FF  FF  FF  FF
        //           A   B   G   R
        img.data[index] = hexFF | (b << 16) | (g << 8) | r;
      }
    }
    var img1 = (_dir == CameraLensDirection.front)
        ? imglib.copyRotate(img, -90)
        : imglib.copyRotate(img, 90);
    return img1;
  }

  String _recog(imglib.Image img) {
    List input = imageToByteListFloat32(img, 112, 128, 128);
    input = input.reshape([1, 112, 112, 3]);
    List output = List.filled(1 * 192, 0, growable: false).reshape([1, 192]);
    interpreter.run(input, output);
    output = output.reshape([192]);
    e1 = List.from(output);
    return compare(e1!).toUpperCase();
  }

  String compare(List currEmb) {
    if (data.length == 0) return "No Face saved";
    double minDist = 999;
    double currDist = 0.0;
    String predRes = "NOT RECOGNIZED";
    for (String label in data.keys) {
      currDist = euclideanDistance(data[label], currEmb);
      if (currDist <= threshold && currDist < minDist) {
        minDist = currDist;
        predRes = label;
      }
    }
    //print(minDist.toString() + " " + predRes);
    return predRes;
  }

  void _resetFile() {
    data = {};
    jsonFile!.deleteSync();
  }

  void _viewLabels() {
    // setState(() {
    //   _camera = null;
    // });
    String name;
    var alert = AlertDialog(
      title: const Text("Saved Faces"),
      content: ListView.builder(
          padding: const EdgeInsets.all(2),
          itemCount: data.length,
          itemBuilder: (BuildContext context, int index) {
            name = data.keys.elementAt(index);
            return Column(
              children: <Widget>[
                ListTile(
                  title: Text(
                    name,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(2),
                ),
                const Divider(),
              ],
            );
          }),
      // actions: <Widget>[
      //   TextButton(
      //     child: const Text("OK"),
      //     onPressed: () {
      //       _initializeCamera();
      //       Navigator.pop(context);
      //     },
      //   )
      // ],
    );
    showDialog(
        context: context,
        builder: (context) {
          return alert;
        });
  }

  void _addLabel() {
    // setState(() {
    //   _camera = null;
    // });
    //print("Adding new face");
    var alert = AlertDialog(
      title: const Text("Add Face"),
      content: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _name,
              autofocus: true,
              decoration: const InputDecoration(
                  labelText: "Name", icon: Icon(Icons.face)),
            ),
          )
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: const Text("Save"),
          onPressed: () {
            _handle(_name.text.toUpperCase());
            _name.clear();
            //Navigator.pop(context);
          },
        ),
        // TextButton(
        //   child: const Text("Cancel"),
        //   onPressed: () {
        //     // _initializeCamera();
        //     // Navigator.of(context).pop();
        //   },
        // )
      ],
    );
    showDialog(
        context: context,
        builder: (context) {
          return alert;
        });
  }

  void _handle(String text) {
    data[text] = e1;
    jsonFile!.writeAsStringSync(json.encode(data));
    // _initializeCamera();
  }
}
