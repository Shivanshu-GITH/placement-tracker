import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

/// Central AdMob configuration.
///
/// **Ads are OFF by default** ([adsEnabled] = `false`): there are no ads and no
/// ad space anywhere in the app, and notes/quizzes open with no ad wall. This is
/// the state to ship the first release in (build users first, monetise later).
///
/// To turn ads ON later — without touching any other code:
///  1. Put your real AdMob **App ID** in `AndroidManifest.xml`.
///  2. Paste your real **unit IDs** into the `_real*` constants below.
///  3. Set [useTestAds] to `false`.
///  4. Set [adsEnabled] to `true`.
/// (During development you can set [adsEnabled] = `true` while keeping
/// [useTestAds] = `true` to preview Google's test ads.)
///
/// Ad formats and where they're used (chosen for a good revenue/UX balance):
/// - **Rewarded** — unlock a topic's notes & quiz (opt-in, highest eCPM).
/// - **Interstitial** — after finishing a quiz (a natural break), frequency-capped.
/// - **Inline adaptive banner** — pinned above the bottom nav on the main tabs.
/// - **Native** — blended into the Resources list.
/// - **App open** — on returning to the app from the background, capped.
class AdConfig {
  AdConfig._();

  /// The single master switch. `false` = no ads and no ad space at all.
  /// Flip to `true` (with real IDs / test ads) to start showing ads.
  static const bool adsEnabled = false;

  /// Use Google's test units. Keep `true` until you wire your real AdMob IDs.
  static const bool useTestAds = true;

  /// True only when ads are switched on AND we're on a real mobile device (not
  /// web, desktop, or the test VM), so nothing ever calls the ad SDK — or
  /// reserves ad space — where ads shouldn't run.
  static bool get enabled {
    if (!adsEnabled || kIsWeb) return false;
    try {
      return Platform.isAndroid || Platform.isIOS;
    } catch (_) {
      return false;
    }
  }

  static bool get _isAndroid {
    try {
      return Platform.isAndroid;
    } catch (_) {
      return false;
    }
  }

  // ---- Google's official TEST unit IDs -------------------------------------
  static const _testRewardedAndroid = 'ca-app-pub-3940256099942544/5224354917';
  static const _testInterstitialAndroid =
      'ca-app-pub-3940256099942544/1033173712';
  static const _testBannerAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const _testAppOpenAndroid = 'ca-app-pub-3940256099942544/9257395921';
  static const _testNativeAndroid = 'ca-app-pub-3940256099942544/2247696110';

  static const _testRewardedIos = 'ca-app-pub-3940256099942544/1712485313';
  static const _testInterstitialIos = 'ca-app-pub-3940256099942544/4411468910';
  static const _testBannerIos = 'ca-app-pub-3940256099942544/2934735716';
  static const _testAppOpenIos = 'ca-app-pub-3940256099942544/5575463023';
  static const _testNativeIos = 'ca-app-pub-3940256099942544/3986624511';

  // ---- YOUR REAL unit IDs (leave blank to keep using the test units) -------
  static const _realRewardedAndroid = '';
  static const _realInterstitialAndroid = '';
  static const _realBannerAndroid = '';
  static const _realAppOpenAndroid = '';
  static const _realNativeAndroid = '';

  static const _realRewardedIos = '';
  static const _realInterstitialIos = '';
  static const _realBannerIos = '';
  static const _realAppOpenIos = '';
  static const _realNativeIos = '';

  static String _pick(String test, String real) =>
      (useTestAds || real.isEmpty) ? test : real;

  static String get rewarded => _isAndroid
      ? _pick(_testRewardedAndroid, _realRewardedAndroid)
      : _pick(_testRewardedIos, _realRewardedIos);

  static String get interstitial => _isAndroid
      ? _pick(_testInterstitialAndroid, _realInterstitialAndroid)
      : _pick(_testInterstitialIos, _realInterstitialIos);

  static String get banner => _isAndroid
      ? _pick(_testBannerAndroid, _realBannerAndroid)
      : _pick(_testBannerIos, _realBannerIos);

  static String get appOpen => _isAndroid
      ? _pick(_testAppOpenAndroid, _realAppOpenAndroid)
      : _pick(_testAppOpenIos, _realAppOpenIos);

  static String get nativeAd => _isAndroid
      ? _pick(_testNativeAndroid, _realNativeAndroid)
      : _pick(_testNativeIos, _realNativeIos);
}
