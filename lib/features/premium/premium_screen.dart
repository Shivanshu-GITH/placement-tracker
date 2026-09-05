import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_palette.dart';
import '../../core/widgets/app_card.dart';
import '../ads/ad_config.dart';
import '../../providers/providers.dart';

/// The "PrepPilot Premium" paywall: a one-time purchase that removes every ad
/// and opens notes/quizzes with no ad wall.
class PremiumScreen extends ConsumerStatefulWidget {
  const PremiumScreen({super.key});

  @override
  ConsumerState<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends ConsumerState<PremiumScreen> {
  bool _busy = false;

  static const _perks = [
    (Icons.block_rounded, 'Remove all ads', 'No banners, interstitials or app-open ads.'),
    (Icons.menu_book_rounded, 'Ad-free notes & quizzes',
        'Open every topic\'s notes and quiz instantly — no rewarded ad.'),
    (Icons.favorite_rounded, 'Support PrepPilot', 'A one-time purchase keeps the app growing.'),
  ];

  Future<void> _buy() async {
    setState(() => _busy = true);
    final err = await ref.read(premiumProvider.notifier).buy();
    if (!mounted) return;
    setState(() => _busy = false);
    if (err != null) _toast(err);
  }

  Future<void> _restore() async {
    setState(() => _busy = true);
    await ref.read(premiumProvider.notifier).restore();
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _busy = false);
    if (!ref.read(premiumProvider)) {
      _toast('No previous purchase found to restore.');
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPremium = ref.watch(premiumProvider);
    final product = ref.watch(premiumProductProvider).valueOrNull;
    final priceLabel = product?.price;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PrepPilot Premium'),
        titleTextStyle: theme.textTheme.headlineSmall,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, AppSpacing.lg,
            AppSpacing.screenH, AppSpacing.huge),
        children: [
          GradientHeroCard(
            gradient: AppPalette.brandGradient,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.workspace_premium_rounded,
                        color: Colors.white, size: 30),
                    const SizedBox(width: AppSpacing.sm),
                    Text(isPremium ? 'You\'re Premium' : 'Go ad-free',
                        style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white, fontWeight: FontWeight.w900)),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  isPremium
                      ? 'Thanks for supporting PrepPilot. Ads are off and all '
                          'notes & quizzes open instantly.'
                      : 'One purchase, forever. Remove every ad and study '
                          'without interruptions.',
                  style:
                      theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          for (final (icon, title, body) in _perks)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: AppCard(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer
                            .withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(icon,
                          color: theme.colorScheme.primary, size: 22),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              style: theme.textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                          Text(body,
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          if (isPremium)
            AppCard(
              color: AppPalette.success.withValues(alpha: 0.12),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: AppPalette.success),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text('Premium is active on this device.',
                        style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppPalette.success)),
                  ),
                ],
              ),
            )
          else ...[
            FilledButton.icon(
              onPressed: _busy ? null : _buy,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              ),
              icon: _busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.4, color: Colors.white))
                  : const Icon(Icons.lock_open_rounded),
              label: Text(priceLabel == null
                  ? 'Remove ads'
                  : 'Remove ads — $priceLabel'),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: _busy ? null : _restore,
              child: const Text('Restore purchase'),
            ),
            if (product == null)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(
                  'Pricing loads once the "$kPremiumProductId" product is live '
                  'in the store.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
            // Test-only: preview the ad-free experience before Play Billing is
            // configured. Disappears in production (real ids + useTestAds=false).
            if (kDebugMode && AdConfig.useTestAds) ...[
              const SizedBox(height: AppSpacing.xl),
              const Divider(),
              const SizedBox(height: AppSpacing.sm),
              Text('Testing tools',
                  style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      letterSpacing: 1)),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: () async {
                  await ref.read(premiumProvider.notifier).devUnlock();
                  if (mounted) _toast('Premium unlocked for testing.');
                },
                icon: const Icon(Icons.science_rounded, size: 18),
                label: const Text('Unlock premium for testing (no charge)'),
              ),
            ],
          ],
          if (isPremium && kDebugMode && AdConfig.useTestAds) ...[
            const SizedBox(height: AppSpacing.lg),
            TextButton(
              onPressed: () async {
                await ref.read(premiumProvider.notifier).devReset();
                if (mounted) _toast('Test premium cleared.');
              },
              child: const Text('Clear test premium'),
            ),
          ],
        ],
      ),
    );
  }
}
