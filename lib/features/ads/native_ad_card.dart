import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../core/theme/app_dimens.dart';
import 'ad_config.dart';

/// A compact native "small" template ad that blends into a content list. Renders
/// nothing until it loads (and nothing where ads are unavailable), so it never
/// leaves a gap. Insert it between real list items; hide it for premium users at
/// the call site.
class NativeAdCard extends StatefulWidget {
  const NativeAdCard({super.key});

  @override
  State<NativeAdCard> createState() => _NativeAdCardState();
}

class _NativeAdCardState extends State<NativeAdCard>
    with AutomaticKeepAliveClientMixin {
  NativeAd? _ad;
  bool _loaded = false;
  bool _requested = false;

  // Keep the ad alive while it scrolls off-screen so a new ad isn't requested
  // every time it re-enters view (wasteful, and it multiplied the validator
  // overlays on test ads).
  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_requested) {
      _requested = true;
      _load();
    }
  }

  void _load() {
    if (!AdConfig.enabled) return;
    final scheme = Theme.of(context).colorScheme;
    final ad = NativeAd(
      adUnitId: AdConfig.nativeAd,
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.small,
        mainBackgroundColor: scheme.surface,
        cornerRadius: AppRadius.md,
        primaryTextStyle: NativeTemplateTextStyle(
            textColor: scheme.onSurface, size: 14),
        secondaryTextStyle: NativeTemplateTextStyle(
            textColor: scheme.onSurfaceVariant, size: 12),
        tertiaryTextStyle: NativeTemplateTextStyle(
            textColor: scheme.onSurfaceVariant, size: 11),
      ),
      listener: NativeAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, err) => ad.dispose(),
      ),
    );
    _ad = ad;
    ad.load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // required by AutomaticKeepAliveClientMixin
    if (!_loaded || _ad == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      constraints: const BoxConstraints(minHeight: 90, maxHeight: 120),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: AdWidget(ad: _ad!),
    );
  }
}
