import 'package:flutter/material.dart';
import 'package:reddit_curator/screens/home.dart';
import 'package:reddit_curator/store/state.dart';
import 'package:reddit_curator/themes/index.dart';
// import 'package:firebase_admob/firebase_admob.dart';
// import 'package:admob_flutter/admob_flutter.dart';

void main() {
  // FirebaseAdMob.instance.initialize(appId: "ca-app-pub-3061718245955245~9017650793");
  // Admob.initialize("ca-app-pub-3061718245955245~9017650793");
  runApp(CuratorApp());
}

class CuratorApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new AppStateWidget(
      child: MaterialApp(
        theme: buildThemeData(),
        home: HomePage(),
        // builder: (BuildContext context, Widget child) {
        //   return new AppStateWidget(child: child);
        // },
      )
    );
  }
}
