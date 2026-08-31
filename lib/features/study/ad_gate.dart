import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_palette.dart';

/// Gates premium study actions (reading notes, taking a quiz) behind a
/// rewarded ad.
///
/// This is an ABSTRACTION on purpose: [PlaceholderAdGate] shows a simulated
/// rewarded-ad flow so the whole content experience is buildable and testable
/// today. Swapping in Google AdMob later means implementing [showRewardedAd]
/// with `RewardedAd` — nothing else in the app changes.
///
/// Unlocks are cached per [key] for the lifetime of the app process, so a
/// learner who watched an ad to open a topic's notes isn't asked again when
/// they reopen the quiz for the same topic in the same session.
abstract class AdGate {
  final Set<String> _unlocked = {};

  /// Keys whose ad is currently loading/showing, so a rapid double-tap doesn't
  /// start a second ad (and open the content twice).
  final Set<String> _inFlight = {};

  bool isUnlocked(String key) => _unlocked.contains(key);

  /// Ensures [key] is unlocked, showing a rewarded ad if needed. Returns true
  /// once unlocked (reward earned or already unlocked), false if the user
  /// backed out of the ad — or if an unlock for this key is already in progress
  /// (the concurrent tap is ignored so only one ad shows and content opens once).
  Future<bool> ensureUnlocked(
    BuildContext context, {
    required String key,
    required String rewardLabel,
  }) async {
    if (_unlocked.contains(key)) return true;
    if (_inFlight.contains(key)) return false; // already handling this tap
    _inFlight.add(key);
    try {
      final earned = await showRewardedAd(context, rewardLabel: rewardLabel);
      if (earned) _unlocked.add(key);
      return earned;
    } finally {
      _inFlight.remove(key);
    }
  }

  /// Shows a rewarded ad. Returns true when the reward is earned.
  Future<bool> showRewardedAd(BuildContext context,
      {required String rewardLabel});
}

/// Grants every unlock instantly with no ad — used for premium ("remove ads")
/// users, so notes and quizzes open straight away.
class NoAdsGate extends AdGate {
  @override
  Future<bool> showRewardedAd(BuildContext context,
          {required String rewardLabel}) async =>
      true;
}

/// A stand-in rewarded ad: a full-screen "sponsored" placeholder with a short
/// countdown, then a claim button. No network, no real ad SDK.
class PlaceholderAdGate extends AdGate {
  @override
  Future<bool> showRewardedAd(BuildContext context,
      {required String rewardLabel}) async {
    final result = await Navigator.of(context, rootNavigator: true).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _RewardedAdScreen(rewardLabel: rewardLabel),
      ),
    );
    return result ?? false;
  }
}

class _RewardedAdScreen extends StatefulWidget {
  const _RewardedAdScreen({required this.rewardLabel});
  final String rewardLabel;

  @override
  State<_RewardedAdScreen> createState() => _RewardedAdScreenState();
}

class _RewardedAdScreenState extends State<_RewardedAdScreen> {
  static const _seconds = 5;
  int _remaining = _seconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _remaining--);
      if (_remaining <= 0) t.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<bool> _confirmSkip() async {
    final skip = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Skip the ad?'),
        content: Text(
            'Watch the short ad to unlock ${widget.rewardLabel}. Ads keep '
            'PrepPilot free.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Keep watching')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Skip')),
        ],
      ),
    );
    return skip ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final done = _remaining <= 0;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final nav = Navigator.of(context);
        if (done || await _confirmSkip()) nav.pop(false);
      },
      child: Scaffold(
        backgroundColor: AppPalette.darkBg,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                      child: const Text('Sponsored',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        done ? Icons.close_rounded : Icons.timer_outlined,
                        color: Colors.white70,
                      ),
                      onPressed: () async {
                        final nav = Navigator.of(context);
                        if (done) {
                          nav.pop(false);
                        } else if (await _confirmSkip()) {
                          nav.pop(false);
                        }
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 92,
                          height: 92,
                          decoration: BoxDecoration(
                            gradient: AppPalette.brandGradient,
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                          ),
                          child: const Icon(Icons.play_circle_fill_rounded,
                              color: Colors.white, size: 52),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        const Text('Your ad is playing',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800)),
                        const SizedBox(height: AppSpacing.sm),
                        Text('Unlocking ${widget.rewardLabel}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.white60, fontSize: 14)),
                        const SizedBox(height: AppSpacing.xxl),
                        SizedBox(
                          width: 220,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            child: LinearProgressIndicator(
                              value: (_seconds - _remaining) / _seconds,
                              minHeight: 8,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation(
                                  AppPalette.mint),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed:
                        done ? () => Navigator.of(context).pop(true) : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppPalette.mint,
                      disabledBackgroundColor: Colors.white12,
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    ),
                    icon: Icon(done
                        ? Icons.lock_open_rounded
                        : Icons.hourglass_bottom_rounded),
                    label: Text(done
                        ? 'Continue'
                        : 'Reward in $_remaining s'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
