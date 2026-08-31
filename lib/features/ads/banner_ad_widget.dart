import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_config.dart';

/// A full-width, short inline adaptive banner (height capped to [_maxHeight])
/// pinned above the bottom nav. Renders nothing until an ad loads (and nothing
/// at all where ads are unavailable), so it never leaves an empty gap or breaks
/// layout.
class BottomBannerAd extends StatefulWidget {
  const BottomBannerAd({super.key});

  @override
  State<BottomBannerAd> createState() => _BottomBannerAdState();
}

class _BottomBannerAdState extends State<BottomBannerAd> {
  static const int _maxHeight = 50; // keep the strip short

  BannerAd? _ad;
  bool _loaded = false;
  bool _requested = false;
  double _height = _maxHeight.toDouble();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_requested) {
      _requested = true;
      _load();
    }
  }

  Future<void> _load() async {
    if (!AdConfig.enabled) return;
    // Inline adaptive: spans the full screen width but is capped to a short
    // height, so it fills the width without a tall strip.
    final width = MediaQuery.of(context).size.width.truncate();
    final ad = BannerAd(
      adUnitId: AdConfig.banner,
      size: AdSize.getInlineAdaptiveBannerAdSize(width, _maxHeight),
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) async {
          final size = await (ad as BannerAd).getPlatformAdSize();
          if (!mounted) return;
          setState(() {
            _loaded = true;
            if (size != null) _height = size.height.toDouble();
          });
        },
        onAdFailedToLoad: (ad, err) => ad.dispose(),
      ),
    );
    _ad = ad;
    await ad.load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (!_loaded || ad == null) return const SizedBox.shrink();
    return SafeArea(
      top: false,
      child: SizedBox(
        width: double.infinity,
        height: _height,
        child: AdWidget(ad: ad),
      ),
    );
  }
}
