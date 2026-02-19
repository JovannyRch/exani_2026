import 'dart:async';
import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  static const bool _testAds = true; // TODO: Cambiar a false en producción

  // IDs de prueba de AdMob
  static const String _testBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';

  static const String _prodBannerAdUnitId =
      'ca-app-pub-4665787383933447/7025353869';
  static const String _prodInterstitialAdUnitId =
      'ca-app-pub-4665787383933447/9409633180';

  static String get bannerAdUnitId {
    if (_testAds) {
      return _testBannerAdUnitId;
    }
    if (Platform.isAndroid) {
      return _prodBannerAdUnitId;
    } else if (Platform.isIOS) {
      return _prodBannerAdUnitId; // Usar ID específico de iOS si es diferente
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get interstitialAdUnitId {
    if (_testAds) {
      return _testInterstitialAdUnitId;
    }
    if (Platform.isAndroid) {
      return _prodInterstitialAdUnitId;
    } else if (Platform.isIOS) {
      return _prodInterstitialAdUnitId; // Usar ID específico de iOS si es diferente
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  static BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) => print('BannerAd loaded.'),
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('BannerAd failed to load: $error');
          ad.dispose();
        },
        onAdOpened: (Ad ad) => print('BannerAd opened.'),
        onAdClosed: (Ad ad) => print('BannerAd closed.'),
      ),
    );
  }

  static Future<InterstitialAd?> createInterstitialAd() async {
    final Completer<InterstitialAd?> completer = Completer<InterstitialAd?>();

    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          print('InterstitialAd loaded.');
          completer.complete(ad);
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('InterstitialAd failed to load: $error');
          completer.complete(null);
        },
      ),
    );

    return completer.future;
  }

  static void showInterstitialAd(InterstitialAd? interstitialAd) {
    if (interstitialAd != null) {
      interstitialAd.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent:
            (InterstitialAd ad) =>
                print('InterstitialAd showed fullscreen content.'),
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          print('InterstitialAd dismissed fullscreen content.');
          ad.dispose();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          print('InterstitialAd failed to show fullscreen content: $error');
          ad.dispose();
        },
      );
      interstitialAd.show();
    }
  }
}
