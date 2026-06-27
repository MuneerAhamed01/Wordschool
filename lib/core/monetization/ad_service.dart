import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:wordshool/core/monetization/ad_config.dart';
import 'package:wordshool/core/monetization/story_entitlements.dart';

class AdService {
  AdService({required StoryEntitlementsService entitlements})
      : _entitlements = entitlements;

  final StoryEntitlementsService _entitlements;
  bool _initialized = false;
  InterstitialAd? _interstitialAd;

  Future<void> initialize() async {
    if (_initialized) return;
    await MobileAds.instance.initialize();
    _initialized = true;
    await loadInterstitial();
  }

  String get bannerAdUnitId {
    if (Platform.isAndroid) return AdConfig.androidBannerId;
    if (Platform.isIOS) return AdConfig.iosBannerId;
    return AdConfig.androidBannerId;
  }

  bool get shouldShowAds => !_entitlements.shouldHideAds;

  Future<void> loadInterstitial() async {
    if (!shouldShowAds) return;

    await InterstitialAd.load(
      adUnitId: Platform.isIOS
          ? AdConfig.iosInterstitialId
          : AdConfig.androidInterstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial load failed: $error');
        },
      ),
    );
  }

  Future<void> showInterstitialIfAllowed() async {
    if (!shouldShowAds) return;
    final ad = _interstitialAd;
    if (ad == null) {
      await loadInterstitial();
      return;
    }
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        loadInterstitial();
      },
    );
    await ad.show();
  }

  Future<bool> showRewardedForHint() async {
    if (_entitlements.isDetectivePro) {
      return true;
    }

    final completer = Completer<bool>();

    await RewardedAd.load(
      adUnitId: Platform.isIOS
          ? AdConfig.iosRewardedId
          : AdConfig.androidRewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) => ad.dispose(),
          );
          ad.show(onUserEarnedReward: (_, __) {
            if (!completer.isCompleted) completer.complete(true);
          });
        },
        onAdFailedToLoad: (error) {
          debugPrint('Rewarded load failed: $error');
          if (!completer.isCompleted) completer.complete(false);
        },
      ),
    );

    return completer.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () => false,
    );
  }

  void dispose() {
    _interstitialAd?.dispose();
  }
}
