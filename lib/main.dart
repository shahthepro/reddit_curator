import 'package:flutter/material.dart';
import 'package:reddit_curator/screens/home.dart';
import 'package:reddit_curator/store/state.dart';
import 'package:reddit_curator/themes/index.dart';

void main() => runApp(CuratorApp());

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
