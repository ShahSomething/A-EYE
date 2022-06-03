import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:a_eye/ui/CurrencyRcg/currency_recognition.dart';
import 'package:a_eye/ui/FaceDtc/face_recognition_screen.dart';
import 'package:a_eye/ui/ObjDtc/object_detection_screen.dart';
import 'package:shake/shake.dart';
import 'package:telephony/telephony.dart';

class TabViewScreen extends StatefulWidget {
  const TabViewScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _TabViewScreenState();
  }
}

class _TabViewScreenState extends State<TabViewScreen>
    with TickerProviderStateMixin {
  var flutterTts = FlutterTts();
  TextEditingController? phoneNumber1;
  TextEditingController? phoneNumber2;
  Directory? tempDir;
  File? jsonFile;
  var data = {};

  // late TabController _tabController;
  // @override
  // void initState() {
  //   super.initState();
  //   _tabController = TabController(length: 3, vsync: this);
  //   _tabController.animateTo(2);
  // }

  static const List<Tab> _tabs = [
    Tab(icon: Icon(FontAwesomeIcons.shapes), child: Text('Object Detection')),
    Tab(icon: Icon(FontAwesomeIcons.moneyBills), text: 'Currency Recognition'),
    Tab(icon: Icon(FontAwesomeIcons.faceSmile), text: 'Face Recognition'),
  ];

  static const List<Widget> _views = [
    //ObjectDetection(),
    Obj(),
    CurrencyRecognitionScreen(),
    FaceRcg(),
    //FaceRecognition(),
  ];

  // ShakeDetector? detector;

  @override
  void initState() {
    asyncInit();

    super.initState();
  }

  void asyncInit() async {
    tempDir = await getApplicationDocumentsDirectory();
    String _numberPath = tempDir!.path + '/number.json';
    jsonFile = File(_numberPath);
    if (jsonFile!.existsSync()) {
      data = json.decode(jsonFile!.readAsStringSync());
    }
    phoneNumber1 =
        TextEditingController(text: data.isEmpty ? '' : data['number1']);
    phoneNumber2 =
        TextEditingController(text: data.isEmpty ? '' : data['number2']);
    ShakeDetector detector = ShakeDetector.waitForStart(
      onPhoneShake: () async {
        if (phoneNumber1!.text.isEmpty || phoneNumber2!.text.isEmpty) {
          await flutterTts.speak('Please provide an emergency contact');
          return;
        }
        final Telephony telephony = Telephony.instance;
        bool? permissionsGranted = await telephony.requestSmsPermissions;
        if (permissionsGranted == true) {
          telephony.sendSms(
            to: phoneNumber1!.text + ';' + phoneNumber2!.text,
            message: "Need your help!",
            statusListener: (status) async {
              switch (status) {
                case SendStatus.SENT:
                  await flutterTts.speak('Message sent successfully');
                  break;
                case SendStatus.DELIVERED:
                  await flutterTts.speak('Message delivered successfully');
                  break;
                default:
                  await flutterTts.speak('Failed to send message');
              }
            },
          );
        } else {
          await flutterTts.speak('Permission not granted');
        }
      },
      minimumShakeCount: 2,
    );

    detector.startListening();
  }

  @override
  void dispose() {
    phoneNumber1!.dispose();
    phoneNumber2!.dispose();
    //detector!.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () {
                  var alert = AlertDialog(
                    title: const Text("Edit Emergency contacts"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SizedBox(
                          width: double.infinity,
                          child: TextField(
                            controller: phoneNumber1,
                            autofocus: true,
                            decoration: InputDecoration(
                              labelText: "Phone Number 1",
                              icon: const Icon(Icons.phone),
                              hintText: phoneNumber1!.text.isEmpty
                                  ? null
                                  : phoneNumber1!.text,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: TextField(
                            controller: phoneNumber2,
                            autofocus: true,
                            decoration: InputDecoration(
                              labelText: "Phone Number 2",
                              icon: const Icon(Icons.phone),
                              hintText: phoneNumber2!.text.isEmpty
                                  ? null
                                  : phoneNumber2!.text,
                            ),
                          ),
                        )
                      ],
                    ),
                    actions: <Widget>[
                      TextButton(
                          child: const Text("Save"),
                          onPressed: () async {
                            if (phoneNumber1!.text.isEmpty ||
                                phoneNumber2!.text.isEmpty) {
                              await flutterTts.speak(
                                  'Please provide two emergency contacts');
                              return;
                            }
                            data['number1'] = phoneNumber1!.text;
                            data['number2'] = phoneNumber2!.text;
                            jsonFile!.writeAsStringSync(json.encode(data));
                            Navigator.pop(context);
                          }),
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
                    },
                  );
                },
                icon: const Icon(
                  Icons.settings,
                  color: Colors.white,
                ),
              )
            ],
            bottom: TabBar(
              labelColor: Colors.black,
              //labelColor: const Color.fromRGBO(255, 270, 270, 0.8),
              unselectedLabelColor: Colors.white,
              //labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              unselectedLabelStyle:
                  const TextStyle(fontStyle: FontStyle.italic),
              padding: const EdgeInsets.only(bottom: 2),

              indicator: BoxDecoration(
                border: Border.all(
                  color: const Color.fromARGB(255, 247, 191, 80),
                ),
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              isScrollable: true,
              physics: const BouncingScrollPhysics(),
              enableFeedback: true,

              tabs: _tabs,
            ),
            title: const Text(
              'A-EYE',
              textAlign: TextAlign.center,
              //style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            //backgroundColor: const Color.fromRGBO(255, 270, 270, 0.8),
            backgroundColor: const Color.fromARGB(255, 247, 191, 80),
          ),
          body: const TabBarView(
            physics: BouncingScrollPhysics(),
            children: _views,
          ),
        ),
      ),
    );
  }
}

class Obj extends StatefulWidget {
  const Obj({Key? key}) : super(key: key);

  @override
  State<Obj> createState() => _ObjState();
}

class _ObjState extends State<Obj> {
  final FlutterTts flutterTts = FlutterTts();

  void speak() async {
    await flutterTts.setLanguage("en-US");

    await flutterTts
        .setVoice({"name": "en-gb-x-gbb-network", "locale": "en-GB"});
    await flutterTts.awaitSpeakCompletion(false);
    await flutterTts.speak(
        "Object Detection Screen. Tap anywhere to start detection or swipe left for currency recognition.");
  }

  @override
  void initState() {
    super.initState();
    speak();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () {
          Navigator.of(context)
              .push(
            MaterialPageRoute(
              builder: (_) => const ObjectDetection(),
            ),
          )
              .then(
            (_) async {
              await flutterTts.awaitSpeakCompletion(false);
              await flutterTts.speak(
                "Object Detection Screen. Tap anywhere to start detection or swipe left for currency recognition.",
              );
            },
          );
        },
        child: SingleChildScrollView(
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding:
                    EdgeInsets.only(top: 80, left: 15, right: 15, bottom: 15),
                child: Text(
                  'Tap anywhere on the screen to start detection',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
              Lottie.asset('./assets/objectDtc.json'),
            ],
          ),
        ),
      ),
    );
  }
}

class FaceRcg extends StatefulWidget {
  const FaceRcg({Key? key}) : super(key: key);

  @override
  State<FaceRcg> createState() => _FaceRcgState();
}

class _FaceRcgState extends State<FaceRcg> {
  final FlutterTts flutterTts = FlutterTts();

  void speak() async {
    await flutterTts.setLanguage("en-US");

    await flutterTts
        .setVoice({"name": "en-gb-x-gbb-network", "locale": "en-GB"});
    await flutterTts.awaitSpeakCompletion(false);
    await flutterTts.speak(
        "Face recognition Screen. Tap anywhere to start recognizing or swipe right for currency recognition.");
  }

  @override
  void initState() {
    super.initState();
    speak();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () => Navigator.of(context)
            .push(
          MaterialPageRoute(
            builder: (_) => const FaceRecognition(),
          ),
        )
            .then(
          (_) async {
            await flutterTts.awaitSpeakCompletion(false);
            await flutterTts.speak(
                "Face recognition Screen. Tap anywhere to start recognizing or swipe right for currency recognition.");
          },
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Padding(
                padding:
                    EdgeInsets.only(top: 80, left: 15, right: 15, bottom: 30),
                child: Text(
                  'Tap anywhere on the screen to start recognizing',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
              Lottie.asset('./assets/faceRcg.json',
                  width: MediaQuery.of(context).size.width - 80)
            ],
          ),
        ),
      ),
    );
  }
}
