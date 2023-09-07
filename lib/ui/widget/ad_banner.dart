import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nagn_2/utils/ad_helper.dart';

class AdBanner extends StatefulWidget {
  const AdBanner({super.key});

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  BannerAd? _bannerAd;
  @override
  void initState() {
    super.initState();
    BannerAd(
            size: AdSize.banner,
            adUnitId: AdHelper.bannerAdUnitId,
            listener: BannerAdListener(
              onAdLoaded: (ad) {
                setState(() {
                  _bannerAd = ad as BannerAd;
                });
              },
              onAdFailedToLoad: (ad, err) {
                print('Failed to load a banner ad: ${err.message}');
                ad.dispose();
              },
            ),
            request: const AdRequest())
        .load();
  }

  @override
  Widget build(BuildContext context) {
    return _bannerAd != null
        ? SizedBox(
            width: _bannerAd!.size.width.toDouble(),
            height: _bannerAd!.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd!),
          )
        : Container();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
}
