import 'dart:async';

// import 'package:admob_flutter/admob_flutter.dart';
// import 'package:flutter/material.dart';
import 'package:firebase_admob/firebase_admob.dart';

int count = 0;
bool interestitialReady = false;
InterstitialAd myInterstitial;
BannerAd myBanner;
// AdmobInterstitial myInterstitial;

Future<void> showInterstitialAdIfNecessary() async {
  count = count + 1;

  if (interestitialReady) {
    myInterstitial.show();
    return;
  }

  if (count % 10 != 0) {
    return;
  }

  count = 0;
  myInterstitial = InterstitialAd(
    adUnitId: "ca-app-pub-3061718245955245/1972185702",
    listener: (MobileAdEvent event) {
      switch (event) {
        case MobileAdEvent.loaded:
          interestitialReady = true;
          break;
        case MobileAdEvent.closed:
        case MobileAdEvent.leftApplication:
        case MobileAdEvent.failedToLoad:
          interestitialReady = false;
          myInterstitial.dispose();
          break;
        default:
      }
      print("InterstitialAd event is $event");
    },
  );

  myInterstitial.load();
}

// Widget getBannerAd() {
  // return new Future(() async {
  //   var completer = new Completer();

    // AdmobBanner adBanner = AdmobBanner(
    //   adUnitId: 'ca-app-pub-3061718245955245/6882442044',
    //   adSize: AdmobBannerSize.MEDIUM_RECTANGLE,
    // );

    // return adBanner;

  //   return completer.future;
  // });
// }

void createAndShowBannerAd() {
  myBanner = BannerAd(
    adUnitId: 'ca-app-pub-3061718245955245/6882442044',
    size: AdSize.banner,
    listener: (MobileAdEvent event) {
      print(event);
      switch (event) {
        case MobileAdEvent.loaded:
          break;
        default:
      }
    },
  );
  myBanner..load()..show(
    anchorOffset: 70,
    anchorType: AnchorType.bottom,
  );
}

void disposeAllAds() {
  myInterstitial?.dispose();
  myBanner?.dispose();
}