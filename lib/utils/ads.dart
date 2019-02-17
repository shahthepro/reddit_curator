import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/material.dart';

int count = 0;

Future<void> showInterstitialAdIfNecessary() async {
  count = count + 1;

  if (count % 20 != 0) {
    return;
  }

  count = 0;
  AdmobInterstitial myInterstitial;
  myInterstitial = AdmobInterstitial(
    adUnitId: "ca-app-pub-3061718245955245/1972185702",
    listener: (AdmobAdEvent event, _) {
      switch (event) {
        case AdmobAdEvent.loaded:
          myInterstitial.show();
          break;
        case AdmobAdEvent.closed:
        case AdmobAdEvent.completed:
        case AdmobAdEvent.failedToLoad:
          myInterstitial.dispose();
          break;
        default:
      }
      print("InterstitialAd event is $event");
    },
  );

  myInterstitial.load();

  // if (await myInterstitial.isLoaded) {
  //   myInterstitial.show();
  // }

  // myInterstitial.dispose();
}

Widget getBannerAd() {
  return AdmobBanner(
    adUnitId: 'ca-app-pub-3061718245955245/6882442044',
    adSize: AdmobBannerSize.MEDIUM_RECTANGLE,
  );
}