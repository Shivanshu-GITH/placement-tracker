import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ads/ad_config.dart';
import '../ads/ad_service.dart';

/// The Play/App Store product id for the one-time "remove ads" unlock.
/// Create a matching **one-time (non-consumable) managed product** with this id
/// in the Google Play Console (and App Store Connect for iOS).
const String kPremiumProductId = 'preppilot_remove_ads';

/// Owns the "premium / remove ads" entitlement: a one-time, non-consumable
/// purchase tied to the user's Play account.
///
/// The entitlement is cached locally (so it works offline after purchase) and
/// restored from the store via [restore]. All ad surfaces read [premiumProvider]
/// and switch off when it's true.
class PremiumController extends Notifier<bool> {
  static const _prefsKey = 'premium_remove_ads_v1';
  StreamSubscription<List<PurchaseDetails>>? _sub;

  bool get _iapSupported {
    if (kIsWeb) return false;
    try {
      return Platform.isAndroid || Platform.isIOS;
    } catch (_) {
      return false;
    }
  }

  @override
  bool build() {
    _load();
    _listen();
    ref.onDispose(() => _sub?.cancel());
    return false;
  }

  Future<void> _load() async {
    try {
      final p = await SharedPreferences.getInstance();
      if (p.getBool(_prefsKey) ?? false) _apply(true);
    } catch (_) {}
  }

  void _listen() {
    if (!_iapSupported) return;
    try {
      _sub = InAppPurchase.instance.purchaseStream
          .listen(_onPurchases, onError: (_) {});
    } catch (_) {}
  }

  Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
    for (final pd in purchases) {
      if (pd.productID != kPremiumProductId) continue;
      if (pd.status == PurchaseStatus.purchased ||
          pd.status == PurchaseStatus.restored) {
        await _unlock();
      }
      if (pd.pendingCompletePurchase) {
        try {
          await InAppPurchase.instance.completePurchase(pd);
        } catch (_) {}
      }
    }
  }

  void _apply(bool value) {
    state = value;
    AdService.instance.premiumActive = value;
  }

  Future<void> _unlock() async {
    _apply(true);
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(_prefsKey, true);
    } catch (_) {}
  }

  /// Launches the purchase flow. Returns null once launched (the result arrives
  /// asynchronously via the purchase stream), or a human-readable error.
  Future<String?> buy() async {
    if (!_iapSupported) return 'In-app purchases aren\'t supported here.';
    final iap = InAppPurchase.instance;
    if (!await iap.isAvailable()) {
      return 'In-app purchases are unavailable. Make sure you\'re signed in to '
          'the Play Store.';
    }
    final resp = await iap.queryProductDetails({kPremiumProductId});
    if (resp.productDetails.isEmpty) {
      return 'This purchase isn\'t available yet. (Product "$kPremiumProductId" '
          'has not been set up in the store.)';
    }
    try {
      await iap.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: resp.productDetails.first),
      );
      return null;
    } catch (e) {
      return 'Could not start the purchase: $e';
    }
  }

  /// Restores a previous purchase (e.g. after a reinstall or new device).
  Future<void> restore() async {
    if (!_iapSupported) return;
    try {
      await InAppPurchase.instance.restorePurchases();
    } catch (_) {}
  }

  /// TEST-ONLY: unlock premium locally with no charge, so the ad-free
  /// experience can be verified before Play Billing is wired up. Available only
  /// while [AdConfig.useTestAds] is true; it disappears in a production build
  /// (real ad ids + `useTestAds = false`).
  Future<void> devUnlock() async {
    if (!AdConfig.useTestAds) return;
    await _unlock();
  }

  /// TEST-ONLY companion to [devUnlock]: clears the local unlock.
  Future<void> devReset() async {
    if (!AdConfig.useTestAds) return;
    _apply(false);
    try {
      final p = await SharedPreferences.getInstance();
      await p.remove(_prefsKey);
    } catch (_) {}
  }
}

final premiumProvider =
    NotifierProvider<PremiumController, bool>(PremiumController.new);

/// The store's product details for the premium unlock (for the localised
/// price), or null when unavailable / not yet configured.
final premiumProductProvider = FutureProvider<ProductDetails?>((ref) async {
  ref.watch(premiumProvider); // re-query after a purchase changes availability
  if (kIsWeb) return null;
  try {
    if (!(Platform.isAndroid || Platform.isIOS)) return null;
    final iap = InAppPurchase.instance;
    if (!await iap.isAvailable()) return null;
    final resp = await iap.queryProductDetails({kPremiumProductId});
    return resp.productDetails.isEmpty ? null : resp.productDetails.first;
  } catch (_) {
    return null;
  }
});
