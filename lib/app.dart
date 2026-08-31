import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/services/app_update_service.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/leaderboard/invite_links.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/onboarding/welcome_auth_screen.dart';
import 'features/shell/app_shell.dart';
import 'features/shell/splash_screen.dart';
import 'providers/providers.dart';

/// Global navigator key so deep-link handlers can navigate / show snackbars.
final navigatorKey = GlobalKey<NavigatorState>();

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
      navigatorKey: navigatorKey,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      home: const _AppRoot(),
    );
  }
}

/// Decides the top-level screen: splash while loading, onboarding for new
/// users, otherwise the main app shell.
class _AppRoot extends ConsumerStatefulWidget {
  const _AppRoot();

  @override
  ConsumerState<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends ConsumerState<_AppRoot> {
  InviteLinks? _invites;
  bool _bgSynced = false;
  bool _contestSynced = false;
  bool _timetableSynced = false;

  @override
  void initState() {
    super.initState();
    _invites = InviteLinks(ref, navigatorKey)..init();
    // Once per launch: if a newer build is live on Play, show the immediate
    // (blocking) update flow so stale installs are brought up to date.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppUpdateService.maybePromptImmediateUpdate();
    });
  }

  /// Once per app open, silently refresh the signed-in user's platform stats.
  void _maybeBackgroundSync() {
    if (_bgSynced) return;
    if (ref.read(authUserProvider).valueOrNull == null) return;
    _bgSynced = true;
    backgroundSyncPlatforms(ref);
  }

  @override
  void dispose() {
    _invites?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bootstrap = ref.watch(bootstrapProvider);
    final profile = ref.watch(profileProvider);
    // Instantiate the premium controller at launch so the persisted "remove
    // ads" entitlement loads and every ad surface respects it from the start.
    ref.watch(premiumProvider);
    // Kick off a silent background sync once the user is known to be signed in.
    _maybeBackgroundSync();

    // Roll the contest-reminder window forward once per launch for opted-in
    // users (the schedule is a rolling next-7-days).
    if (ref.watch(contestPrepProvider) && !_contestSynced) {
      _contestSynced = true;
      final upcoming = ref.read(upcomingContestsProvider);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        NotificationService.instance.scheduleContestReminders(upcoming);
      });
    }

    // Re-arm the timetable reminders once per launch. Android drops scheduled
    // alarms on reboot (and after an app update), so rebuilding them from the
    // saved blocks is what keeps the reminders reliable.
    final blocks = ref.watch(timetableProvider).valueOrNull;
    if (blocks != null && blocks.isNotEmpty && !_timetableSynced) {
      _timetableSynced = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        NotificationService.instance.syncTimetableReminders(blocks);
      });
    }

    return bootstrap.when(
      loading: () => const SplashScreen(),
      error: (e, _) => SplashScreen(error: e.toString()),
      data: (_) => profile.when(
        loading: () => const SplashScreen(),
        error: (e, _) => SplashScreen(error: e.toString()),
        data: (p) {
          final session = ref.watch(sessionStateProvider);
          final onboarded = p?.onboarded ?? false;
          final Widget child;
          if (session == SessionState.needsAuth) {
            child = const WelcomeAuthScreen(key: ValueKey('welcome'));
          } else if (!onboarded) {
            child = const OnboardingScreen(key: ValueKey('onboarding'));
          } else {
            child = const AppShell(key: ValueKey('shell'));
          }
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: child,
          );
        },
      ),
    );
  }
}
