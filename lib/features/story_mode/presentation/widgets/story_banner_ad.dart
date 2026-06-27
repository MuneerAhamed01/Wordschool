import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:wordshool/core/config/monetization_config.dart';
import 'package:wordshool/core/monetization/ad_service.dart';
import 'package:wordshool/core/monetization/story_entitlements.dart';
import 'package:wordshool/di.dart';

class StoryBannerAd extends StatefulWidget {
  const StoryBannerAd({super.key});

  @override
  State<StoryBannerAd> createState() => _StoryBannerAdState();
}

class _StoryBannerAdState extends State<StoryBannerAd> {
  BannerAd? _bannerAd;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bannerAd == null) {
      _loadBanner();
    }
  }

  Future<void> _loadBanner() async {
    if (!getIt<MonetizationConfig>().isMonetizationAndPurchasesEnabled) {
      return;
    }
    if (!getIt.isRegistered<AdService>() ||
        !getIt.isRegistered<StoryEntitlementsService>()) {
      return;
    }

    final entitlements = getIt<StoryEntitlementsService>();
    if (entitlements.shouldHideAds) return;

    final adService = getIt<AdService>();
    final width = MediaQuery.sizeOf(context).width.truncate();
    final size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);
    if (size == null || !mounted) return;

    final banner = BannerAd(
      adUnitId: adService.bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _bannerAd = ad as BannerAd;
              _loaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );

    await banner.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!getIt<MonetizationConfig>().isMonetizationAndPurchasesEnabled) {
      return const SizedBox.shrink();
    }
    if (!_loaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
