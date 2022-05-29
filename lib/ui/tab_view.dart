import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:see_ai/ui/CurrencyRcg/currency_recognition.dart';
import 'package:see_ai/ui/FaceDtc/face_recognition_screen.dart';
import 'package:see_ai/ui/ObjDtc/object_detection_screen.dart';
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
  TextEditingController phoneNumber = TextEditingController(text: '');
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
    ShakeDetector detector = ShakeDetector.waitForStart(
        onPhoneShake: () async {
          if (phoneNumber.text.isEmpty) {
            await flutterTts.speak('Please provide an emergency contact');
            return;
          }
          final Telephony telephony = Telephony.instance;
          bool? permissionsGranted = await telephony.requestSmsPermissions;
          if (permissionsGranted == true) {
            telephony.sendSms(
                to: phoneNumber.text,
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
                });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Permission not granted')));
            await flutterTts.speak('Permission not granted');
          }
        },
        minimumShakeCount: 2);

    detector.startListening();
    super.initState();
  }

  @override
  void dispose() {
    phoneNumber.dispose();
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
                    title: const Text("Edit Emergency contact"),
                    content: Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: phoneNumber,
                            autofocus: true,
                            decoration: InputDecoration(
                                labelText: "Phone Number",
                                icon: const Icon(Icons.phone),
                                hintText: phoneNumber.text.isEmpty
                                    ? null
                                    : phoneNumber.text),
                          ),
                        )
                      ],
                    ),
                    actions: <Widget>[
                      TextButton(
                          child: const Text("Save"),
                          onPressed: () {
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
              // overlayColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
              //   if (states.contains(MaterialState.pressed)) {
              //     return Colors.white;
              //   } if (states.contains(MaterialState.focused)) {
              //     return Colors.orange;
              //   } else if (states.contains(MaterialState.hovered)) {
              //     return Colors.pinkAccent;
              //   }
              //   return Colors.transparent;
              // }),
              //indicatorWeight: 10,
              // indicatorColor: Colors.red,
              // indicatorSize: TabBarIndicatorSize.tab,
              // indicatorPadding: const EdgeInsets.all(5),
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

              // Uncomment the line below and remove DefaultTabController if you want to use a custom TabController

              // controller: _tabController,

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

            // Uncomment the line below and remove DefaultTabController if you want to use a custom TabController

            // controller: _tabController,

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
    //await flutterTts.setPitch(1);
    //print(await flutterTts.getVoices);
    //await flutterTts.setSpeechRate(0);
    await flutterTts
        .setVoice({"name": "en-gb-x-gbb-network", "locale": "en-GB"});
    await flutterTts.awaitSpeakCompletion(false);
    await flutterTts.speak(
        "Object Detection Screen. Tap anywhere to start detection or swipe left for currency recognition.");
    //await flutterTts.speak("Swipe left for face recognition");
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
              .push(MaterialPageRoute(builder: (_) => const ObjectDetection()));
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
    //await flutterTts.setPitch(1);
    //print(await flutterTts.getVoices);
    //await flutterTts.setSpeechRate(0);
    await flutterTts
        .setVoice({"name": "en-gb-x-gbb-network", "locale": "en-GB"});
    await flutterTts.awaitSpeakCompletion(false);
    await flutterTts.speak(
        "Face recognition Screen. Tap anywhere to start recognizing or swipe right for currency recognition.");
    //await flutterTts.speak("Swipe left for face recognition");
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
            .push(MaterialPageRoute(builder: (_) => const FaceRecognition())),
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
