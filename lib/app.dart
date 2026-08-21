import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/shell/app_shell.dart';
import 'features/shell/splash_screen.dart';
import 'providers/providers.dart';

class PrepPilotApp extends ConsumerWidget {
  const PrepPilotApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeModeIndex = ref.watch(themeModeProvider);
    final themeMode = switch (themeModeIndex) {
      1 => ThemeMode.light,
      2 => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    return MaterialApp(
      title: 'PrepPilot',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      home: const _AppRoot(),
    );
  }
}

/// Decides the top-level screen: splash while loading, onboarding for new
/// users, otherwise the main app shell.
class _AppRoot extends ConsumerWidget {
  const _AppRoot();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bootstrap = ref.watch(bootstrapProvider);
    final profile = ref.watch(profileProvider);

    return bootstrap.when(
      loading: () => const SplashScreen(),
      error: (e, _) => SplashScreen(error: e.toString()),
      data: (_) => profile.when(
        loading: () => const SplashScreen(),
        error: (e, _) => SplashScreen(error: e.toString()),
        data: (p) {
          final onboarded = p?.onboarded ?? false;
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: onboarded
                ? const AppShell(key: ValueKey('shell'))
                : const OnboardingScreen(key: ValueKey('onboarding')),
          );
        },
      ),
    );
  }
}
