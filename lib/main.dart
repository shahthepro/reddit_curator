import 'package:flutter/material.dart';
import 'package:reddit_curator/screens/home.dart';
import 'package:reddit_curator/themes/index.dart';

void main() => runApp(CuratorApp());

class CuratorApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Curator',
      theme: buildThemeData(),
      home: HomePage(title: 'Curator'),
    );
  }
}
