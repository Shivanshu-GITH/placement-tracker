import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_config.dart';

/// Owns SDK initialisation and the app's non-rewarded ad managers
/// (interstitial + app-open). Everything here is a safe no-op when ads are
/// disabled or unavailable, so it never blocks the UI or breaks tests.
class AdService {
  AdService._();
  static final AdService instance = AdService._();

  bool _initialized = false;
  final InterstitialAdManager interstitial = InterstitialAdManager();
  final AppOpenAdManager appOpen = AppOpenAdManager();

  /// True once the user buys the "remove ads" unlock. When set, interstitial and
  /// app-open ads become no-ops (banners/native/rewarded are switched off at
  /// their own call sites / providers).
  bool premiumActive = false;

  /// When any full-screen ad (rewarded / interstitial / app-open) was last
  /// shown. Used to stop an app-open ad from stacking right after another ad,
  /// since showing a full-screen ad pauses→resumes the app.
  DateTime lastFullScreenShownAt = DateTime.fromMillisecondsSinceEpoch(0);
  void markFullScreenShown() => lastFullScreenShownAt = DateTime.now();

  Future<void> init() async {
    if (!AdConfig.enabled || _initialized) return;
    try {
      await MobileAds.instance.initialize();
      _initialized = true;
      interstitial.preload();
      appOpen.preload();
    } catch (_) {
      // SDK unavailable — leave everything as a no-op.
    }
  }
}

/// Preloads a single interstitial and shows it at most once per [_minGap],
/// so natural breaks (e.g. finishing a quiz) can monetise without nagging.
class InterstitialAdManager {
  InterstitialAd? _ad;
  bool _loading = false;
  DateTime _lastShown = DateTime.fromMillisecondsSinceEpoch(0);
  static const _minGap = Duration(seconds: 90);

  void preload() {
    if (!AdConfig.enabled || _loading || _ad != null) return;
    _loading = true;
    InterstitialAd.load(
      adUnitId: AdConfig.interstitial,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _loading = false;
        },
        onAdFailedToLoad: (err) {
          _ad = null;
          _loading = false;
        },
      ),
    );
  }

  /// Shows the interstitial if one is ready and the cooldown has elapsed.
  /// Always returns immediately; never blocks the caller.
  void maybeShow() {
    if (!AdConfig.enabled || AdService.instance.premiumActive) return;
    final ad = _ad;
    if (ad == null) {
      preload();
      return;
    }
    if (DateTime.now().difference(_lastShown) < _minGap) return;
    _lastShown = DateTime.now();
    _ad = null;
    AdService.instance.markFullScreenShown();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        preload();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        ad.dispose();
        preload();
      },
    );
    ad.show();
  }
}

/// Shows an app-open ad when the user returns from the background, capped by
/// [_minGap] and only while a fresh ad is cached.
class AppOpenAdManager {
  AppOpenAd? _ad;
  bool _showing = false;
  DateTime _loadedAt = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastShown = DateTime.fromMillisecondsSinceEpoch(0);
  static const _minGap = Duration(minutes: 4);
  static const _maxCacheAge = Duration(hours: 4);

  bool get _isFresh =>
      _ad != null && DateTime.now().difference(_loadedAt) < _maxCacheAge;

  void preload() {
    if (!AdConfig.enabled || _ad != null) return;
    AppOpenAd.load(
      adUnitId: AdConfig.appOpen,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _loadedAt = DateTime.now();
        },
        onAdFailedToLoad: (err) => _ad = null,
      ),
    );
  }

  /// Shows the app-open ad if one is ready and the cooldown has elapsed.
  void maybeShow() {
    if (!AdConfig.enabled || _showing || AdService.instance.premiumActive) {
      return;
    }
    // Don't stack right after another full-screen ad's resume.
    if (DateTime.now().difference(AdService.instance.lastFullScreenShownAt) <
        const Duration(seconds: 20)) {
      return;
    }
    if (!_isFresh) {
      preload();
      return;
    }
    if (DateTime.now().difference(_lastShown) < _minGap) return;
    final ad = _ad!;
    _ad = null;
    _showing = true;
    _lastShown = DateTime.now();
    AdService.instance.markFullScreenShown();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _showing = false;
        ad.dispose();
        preload();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        _showing = false;
        ad.dispose();
        preload();
      },
    );
    ad.show();
  }
}
