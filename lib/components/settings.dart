import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:app_review/app_review.dart';

Widget getSettingsPage(BuildContext context) {
  return Container(
    // color: CupertinoColors.lightBackgroundGray,
    child: new ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        Divider(height: 15.0, color: Colors.transparent),
        // ListTile(
        //   title: Text("Remove ads"),
        //   subtitle: Text("Get rid of all ads for \$2/yr."),
        //   onTap: () {
        //     print("Tapped");
        //   },
        //   trailing: Icon(Icons.arrow_forward_ios, size: 15,),
        // ),
        // Divider(height: 15.0),
        // ListTile(
        //   title: Text("Contribute & Support"),
        //   subtitle: Text("Love the app? You can support the developer by making a contribution of \$5.\n\nBonus: Removes all ads forever"),
        //   onTap: () {
        //     print("Tapped");
        //   },
        //   trailing: Icon(Icons.arrow_forward_ios, size: 15,),
        // ),
        // Divider(height: 15.0),
        ListTile(
          title: Text("Rate & Review app"),
          subtitle: Text("Spread the word. Leave us a review on Store."),
          onTap: openReviewPage,
          trailing: Icon(Icons.arrow_forward_ios, size: 15,),
        ),
        Divider(height: 15.0),
        ListTile(
          title: Text("Privacy policy"),
          onTap: openPrivacyPolicyPage,
          trailing: Icon(Icons.arrow_forward_ios, size: 15,),
        ),
        Divider(height: 15.0),
        ListTile(
          title: Text("Content liability"),
          onTap: openContentLiabilityPage,
          trailing: Icon(Icons.arrow_forward_ios, size: 15,),
        ),
      ],
    ),
  );
}

void openReviewPage() async {
  const url = 'https://play.google.com/store/apps/details?id=com.kirukku.awwstagram';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
  // try {
  //   var value = await AppReview.requestReview;
  //   print(value);
  // } catch (e) {
  //   print(e);
  // }
}

void openPrivacyPolicyPage() async {
  const url = 'https://kirukku.com/awwstagram-privacy-policy/';
  if (await canLaunch(url)) {
    await launch(url, forceWebView: true);
  } else {
    throw 'Could not launch $url';
  }
}

void openContentLiabilityPage() async {
  const url = 'https://kirukku.com/awwstagram-content-liability/';
  if (await canLaunch(url)) {
    await launch(url, forceWebView: true);
  } else {
    throw 'Could not launch $url';
  }
}