import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _showDrawer() {
    print("Show Drawer");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: new IconButton(
          icon: const Icon(Icons.menu), 
          onPressed: _showDrawer,
        ),
        title: Text(widget.title),
      ),
      body: Center(
        child: Text("Hello World"),
      ),
    );
  }
}
