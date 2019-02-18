import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/material.dart';

int count = 0;
bool interestitialReady = false;
AdmobInterstitial myInterstitial;

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
  myInterstitial = AdmobInterstitial(
    adUnitId: "ca-app-pub-3061718245955245/1972185702",
    listener: (AdmobAdEvent event, _) {
      switch (event) {
        case AdmobAdEvent.loaded:
          // myInterstitial.show();
          interestitialReady = true;
          break;
        case AdmobAdEvent.closed:
        case AdmobAdEvent.completed:
        case AdmobAdEvent.failedToLoad:
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

Widget getBannerAd() {
  return AdmobBanner(
    adUnitId: 'ca-app-pub-3061718245955245/6882442044',
    adSize: AdmobBannerSize.MEDIUM_RECTANGLE,
  );
}