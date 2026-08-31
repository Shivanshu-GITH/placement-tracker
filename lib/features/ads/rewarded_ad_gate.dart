import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../study/ad_gate.dart';
import 'ad_config.dart';
import 'ad_service.dart';

/// Real AdMob-backed [AdGate]: loads and shows a rewarded ad to unlock a topic's
/// notes / quiz.
///
/// If ads can't run (unsupported platform) or an ad fails to load or show, the
/// reward is granted anyway — a monetisation hiccup must never lock a learner
/// out of content. Only an explicit user dismissal *before* earning the reward
/// leaves it locked (they can simply tap again to retry).
class RewardedAdGate extends AdGate {
  @override
  Future<bool> showRewardedAd(BuildContext context,
      {required String rewardLabel}) async {
    if (!AdConfig.enabled) return true; // no ads here — don't block content

    final completer = Completer<bool>();
    var earned = false;

    void grant() {
      if (!completer.isCompleted) completer.complete(true);
    }

    void finish() {
      if (!completer.isCompleted) completer.complete(earned);
    }

    try {
      await RewardedAd.load(
        adUnitId: AdConfig.rewarded,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
                finish(); // earned reflects whether the reward fired
              },
              onAdFailedToShowFullScreenContent: (ad, err) {
                ad.dispose();
                grant(); // couldn't show → don't punish the user
              },
            );
            AdService.instance.markFullScreenShown();
            ad.show(onUserEarnedReward: (ad, reward) => earned = true);
          },
          onAdFailedToLoad: (err) => grant(), // no fill → grant anyway
        ),
      );
    } catch (_) {
      grant();
    }
    return completer.future;
  }
}
