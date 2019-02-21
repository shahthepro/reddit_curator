import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget getSettingsPage() {
  return Container(
    // color: CupertinoColors.lightBackgroundGray,
    child: new ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        Divider(height: 15.0, color: Colors.transparent),
        ListTile(
          title: Text('Remove ads'),
          onTap: () {
            print("Tapped");
          },
          trailing: Icon(Icons.arrow_forward_ios, size: 15,),
        ),
        Divider(height: 15.0),
        ListTile(
          title: Text('Give feedback'),
          onTap: () {
            print("Tapped");
          },
          trailing: Icon(Icons.arrow_forward_ios, size: 15,),
        ),
        Divider(height: 15.0),
        ListTile(
          title: Text('Privacy policy'),
          onTap: () {
            print("Tapped");
          },
          trailing: Icon(Icons.arrow_forward_ios, size: 15,),
        ),
        Divider(height: 15.0),
        ListTile(
          title: Text('Disclaimer'),
          onTap: () {
            print("Tapped");
          },
          trailing: Icon(Icons.arrow_forward_ios, size: 15,),
        ),
      ],
    )
    //   children: <Widget>[
    //     // new ListTile(
    //     //   title: Text("Personalization", style: TextStyle(fontWeight: FontWeight.bold),),
    //     // )
    //     new ListTile(
    //       contentPadding: EdgeInsets.only(top: 5, left: 15, bottom: 0, right: 5),
    //       title: Text("Personalization"),
    //       dense: true,
    //     ),
    //     Container(
    //       // decoration: BoxDecoration(
    //       //   color: CupertinoColors.white,
    //       //   border: Border(
    //       //     top: const BorderSide(
    //       //       color: CupertinoColors.inactiveGray,
    //       //       width: 0.0,
    //       //     ),
    //       //     bottom: const BorderSide(
    //       //       color: CupertinoColors.inactiveGray,
    //       //       width: 0.0,
    //       //     ),
    //       //   ),
    //       // ),
    //       child: new ListTile(
    //         title: Text("Remove ads"),
    //         enabled: true,
    //         onTap: () {
    //           print("Hello");
    //         },
    //       ),
    //     )
    //   ],
    // ),
    // // child: Column(
    // //   children: <Widget>[
    // //     Container(
    // //       decoration: BoxDecoration(
    // //         color: CupertinoColors.white,
    // //         border: Border(
    // //           top: const BorderSide(
    // //             color: CupertinoColors.inactiveGray,
    // //             width: 0.0,
    // //           ),
    // //           bottom: const BorderSide(
    // //             color: CupertinoColors.inactiveGray,
    // //             width: 0.0,
    // //           ),
    // //         ),
    // //       ),
    // //       child: Column(
    // //         crossAxisAlignment: CrossAxisAlignment.stretch,
    // //         children: <Widget>[
    // //           Text("Remove ads"),
    // //           Text("Remove ads"),
    // //         ],
    // //       ),
    // //     ),
    // //   ],
    // // ),
  );

}