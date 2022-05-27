import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:see_ai/ui/CurrencyRcg/currency_recognition.dart';
import 'package:see_ai/ui/FaceDtc/face_recognition_screen.dart';
import 'package:see_ai/ui/ObjDtc/object_detection_screen.dart';

class TabViewScreen extends StatefulWidget {
  const TabViewScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _TabViewScreenState();
  }
}

class _TabViewScreenState extends State<TabViewScreen>
    with TickerProviderStateMixin {
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
    CurrencyRecognitionScreen(),
    ObjectDetection(),
    FaceRecognition(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            bottom: TabBar(
              labelColor: const Color.fromRGBO(255, 270, 270, 0.8),
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
                border: Border.all(color: Colors.red),
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
            ),
            backgroundColor: const Color.fromRGBO(255, 270, 270, 0.8),
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
