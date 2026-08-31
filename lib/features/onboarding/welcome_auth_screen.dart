import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_palette.dart';
import '../../providers/providers.dart';

/// First-launch screen: sign in with Google (then set up your plan), or continue
/// as a guest. Details like name and college are collected in onboarding, so
/// both paths lead into the same setup flow.
class WelcomeAuthScreen extends ConsumerStatefulWidget {
  const WelcomeAuthScreen({super.key});

  @override
  ConsumerState<WelcomeAuthScreen> createState() => _WelcomeAuthScreenState();
}

class _WelcomeAuthScreenState extends ConsumerState<WelcomeAuthScreen> {
  bool _busy = false;

  Future<void> _google() async {
    setState(() => _busy = true);
    // authUserProvider flips on success → the account's database loads and the
    // router shows onboarding (new account) or the app (returning account).
    final err = await signInWithGoogleFlow(ref);
    if (mounted) {
      setState(() => _busy = false);
      if (err != null) _toast(err);
    }
  }

  Future<void> _guest() async {
    setState(() => _busy = true);
    await setGuestMode(ref, true);
    // Normally the router has already swapped this screen out; reset anyway so
    // the buttons can't stay stuck disabled if it hasn't.
    if (mounted) setState(() => _busy = false);
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        // Spacers keep the airy layout when there's room, but the content can
        // exceed the screen on small devices or at large accessibility text
        // sizes — so it scrolls instead of overflowing.
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const Spacer(flex: 2),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  gradient: AppPalette.brandGradient,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                alignment: Alignment.center,
                child: const Text('🚀', style: TextStyle(fontSize: 48)),
              ).animate().scaleXY(begin: 0.7, end: 1, duration: 500.ms, curve: Curves.easeOutBack),
              const SizedBox(height: AppSpacing.xl),
              Text('PrepPilot',
                      style: theme.textTheme.displaySmall
                          ?.copyWith(fontWeight: FontWeight.w900))
                  .animate()
                  .fadeIn(delay: 150.ms),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Stay consistent. Climb the ranks.\nCompete with peers across India.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ).animate().fadeIn(delay: 300.ms),
              const Spacer(flex: 3),
              // Highlights of what an account unlocks.
              _Highlight(
                icon: Icons.leaderboard_rounded,
                text: 'Global, weekly, friends & college leaderboards',
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: AppSpacing.md),
              _Highlight(
                icon: Icons.local_fire_department_rounded,
                text: 'Streaks & XP that keep you showing up daily',
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),
              const Spacer(flex: 3),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _busy ? null : _google,
                  icon: _busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.4, color: Colors.white))
                      : const Icon(Icons.login_rounded),
                  label: const Text('Continue with Google'),
                ),
              ).animate().fadeIn(delay: 600.ms),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: _busy ? null : _guest,
                child: const Text('Continue as guest'),
              ).animate().fadeIn(delay: 700.ms),
              Text(
                'Guests can browse leaderboards. Sign in anytime to appear on them.',
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Highlight extends StatelessWidget {
  const _Highlight({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 22),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(text,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
