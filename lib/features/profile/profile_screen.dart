import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/enums.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_palette.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/entrance.dart';
import '../../providers/providers.dart';
import '../ads/ad_config.dart';
import '../achievements/achievements_screen.dart';
import '../focus/focus_timer_screen.dart';
import '../contests/contests_screen.dart';
import '../leaderboard/coding_portfolio_screen.dart';
import '../leaderboard/coding_profiles_screen.dart';
import '../leaderboard/signup_flow.dart';
import '../premium/premium_screen.dart';
import '../timetable/timetable_screen.dart';
import '../tracks/tracks_screen.dart';
import 'mysheets_screen.dart';
import 'widgets/reminder_tile.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profile = ref.watch(profileProvider).valueOrNull;
    final stats = ref.watch(statsProvider);
    final themeMode = ref.watch(themeModeProvider);
    final authUser = ref.watch(authUserProvider).valueOrNull;
    final signedIn = authUser != null;
    final lbId = ref.watch(lbIdentityProvider).valueOrNull;
    final isPremium = ref.watch(premiumProvider);

    final xp = profile?.xp ?? 0;
    final level = (xp ~/ 100) + 1;
    final xpIntoLevel = xp % 100;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        titleTextStyle: theme.textTheme.headlineSmall,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, AppSpacing.md,
            AppSpacing.screenH, AppSpacing.huge),
        children: [
          _ProfileHeader(
            name: profile?.name ?? 'Aspirant',
            role: TargetRole.fromName(profile?.targetRole ?? 'product'),
            level: level,
            xp: xp,
            xpIntoLevel: xpIntoLevel,
          ).entrance(index: 0),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                  child: _QuickStat(
                      label: 'Total XP',
                      value: '$xp',
                      icon: Icons.bolt_rounded,
                      color: AppPalette.warning)),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                  child: _QuickStat(
                      label: 'Solved',
                      value: '${stats.totalDone}',
                      icon: Icons.check_circle_rounded,
                      color: AppPalette.success)),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                  child: _QuickStat(
                      label: 'Bookmarks',
                      value: '${stats.bookmarked}',
                      icon: Icons.bookmark_rounded,
                      color: AppPalette.indigo)),
            ],
          ).entrance(index: 1),
          const SizedBox(height: AppSpacing.xl),
          // The "remove ads" upgrade only makes sense once ads are switched on.
          if (AdConfig.enabled) ...[
            _SettingsGroup(
              title: 'Premium',
              children: [
                _SettingTile(
                  icon: isPremium
                      ? Icons.workspace_premium_rounded
                      : Icons.block_rounded,
                  title: isPremium ? 'Premium active' : 'Remove ads',
                  subtitle: isPremium
                      ? 'Ads are off · notes & quizzes open instantly'
                      : 'One-time unlock — go fully ad-free',
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const PremiumScreen())),
                ),
              ],
            ).entrance(index: 1),
            const SizedBox(height: AppSpacing.lg),
          ],
          _SettingsGroup(
            title: 'Account',
            children: [
              _SettingTile(
                icon: Icons.dashboard_customize_rounded,
                title: 'My Portfolio',
                subtitle: 'Verified profiles, PrepPilot Score & badges',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const CodingPortfolioScreen())),
              ),
              ...(signedIn
                ? [
                    _SettingTile(
                      icon: Icons.account_circle_rounded,
                      title: lbId?.name ?? profile?.name ?? 'Signed in',
                      subtitle: [
                        if (authUser.email != null) authUser.email!,
                        if (lbId?.college != null) lbId!.college!,
                      ].join('\n').trim().isEmpty
                          ? 'Signed in with Google'
                          : [
                              if (authUser.email != null) authUser.email!,
                              if (lbId?.college != null) lbId!.college!,
                            ].join(' · '),
                      onTap: () => showSignUpFlow(context, ref),
                    ),
                    _SettingTile(
                      icon: Icons.code_rounded,
                      title: 'Coding profiles',
                      subtitle: 'Link LeetCode / Codeforces for a verified rank',
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const CodingProfilesScreen())),
                    ),
                    _SettingTile(
                      icon: Icons.logout_rounded,
                      title: 'Log out',
                      subtitle: 'Sign out of your leaderboard account',
                      onTap: () => _logout(context, ref),
                    ),
                    _SettingTile(
                      icon: Icons.delete_forever_rounded,
                      title: 'Delete account & data',
                      subtitle: 'Permanently erase your account and all data',
                      destructive: true,
                      onTap: () => _deleteAccount(context, ref),
                    ),
                  ]
                : [
                    _SettingTile(
                      icon: Icons.login_rounded,
                      title: 'Sign in with Google',
                      subtitle: 'Save progress per account & join leaderboards',
                      onTap: () => _signInWithGoogle(context, ref),
                    ),
                    _SettingTile(
                      icon: Icons.swap_horiz_rounded,
                      title: 'Back to welcome',
                      subtitle: 'Return to choose a different sign-in option',
                      onTap: () => _exitGuest(context, ref),
                    ),
                    _SettingTile(
                      icon: Icons.delete_forever_rounded,
                      title: 'Delete all my data',
                      subtitle: 'Erase your on-device progress and start over',
                      destructive: true,
                      onTap: () => _deleteGuestData(context, ref),
                    ),
                  ]),
            ],
          ).entrance(index: 2),
          const SizedBox(height: AppSpacing.lg),
          _SettingsGroup(
            title: 'Progress',
            children: [
              _SettingTile(
                icon: Icons.emoji_events_rounded,
                title: 'Achievements',
                subtitle: 'Badges you\'ve unlocked and what\'s next',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const AchievementsScreen())),
              ),
            ],
          ).entrance(index: 2),
          const SizedBox(height: AppSpacing.lg),
          _SettingsGroup(
            title: 'Study',
            children: [
              _SettingTile(
                icon: Icons.explore_rounded,
                title: 'Prep Tracks',
                subtitle: 'One-tap presets for product, service, CP & more',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const TracksScreen())),
              ),
              _SettingTile(
                icon: Icons.library_books_rounded,
                title: 'My Sheets',
                subtitle: 'Choose active sheets & your primary DSA sheet',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const MySheetsScreen())),
              ),
              _SettingTile(
                icon: Icons.emoji_events_rounded,
                title: 'Contests',
                subtitle: 'Today\'s & upcoming contests + reminders',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const ContestsScreen())),
              ),
              _SettingTile(
                icon: Icons.schedule_rounded,
                title: 'My timetable',
                subtitle: 'Plan your day & get reminders per subject',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const TimetableScreen())),
              ),
              _SettingTile(
                icon: Icons.timer_rounded,
                title: 'Focus timer',
                subtitle: 'Pomodoro sessions that log automatically',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const FocusTimerScreen())),
              ),
              _SettingTile(
                icon: Icons.flag_rounded,
                title: 'Daily goal',
                subtitle:
                    '${profile?.dailyGoalProblems ?? 4} problems · ${profile?.dailyGoalMinutes ?? 120} min',
                onTap: () => _editGoals(context, ref),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              const ReminderTile(),
            ],
          ).entrance(index: 2),
          const SizedBox(height: AppSpacing.lg),
          _SettingsGroup(
            title: 'Appearance',
            children: [
              _ThemeTile(
                selected: themeMode,
                onSelect: (v) =>
                    ref.read(themeModeProvider.notifier).state = v,
              ),
            ],
          ).entrance(index: 3),
          const SizedBox(height: AppSpacing.lg),
          _SettingsGroup(
            title: 'About',
            children: [
              const _SettingTile(
                icon: Icons.info_outline_rounded,
                title: 'PrepPilot',
                subtitle: 'Version 1.0.0 · Local-first, private by design',
              ),
            ],
          ).entrance(index: 4),
        ],
      ),
    );
  }

  /// Guest → Google: signs in directly (name/college are collected in
  /// onboarding for the new account).
  Future<void> _signInWithGoogle(BuildContext context, WidgetRef ref) async {
    final err = await signInWithGoogleFlow(ref);
    if (err != null && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(err)));
    }
  }

  /// Leaves guest mode and returns to the welcome screen so the user can pick a
  /// different sign-in option. Local guest progress stays saved in its bucket.
  Future<void> _exitGuest(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Back to welcome?'),
        content: const Text(
            'You\'ll return to the welcome screen to choose a sign-in option. '
            'Your guest progress stays saved on this device.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Continue')),
        ],
      ),
    );
    if (confirmed != true) return;
    await setGuestMode(ref, false);
    // sessionStateProvider → needsAuth → the router shows WelcomeAuthScreen.
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text(
            'You\'ll be signed out and returned to the welcome screen. Your '
            'progress stays saved on this device.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Log out')),
        ],
      ),
    );
    if (confirmed != true) return;
    final auth = ref.read(leaderboardAuthProvider);
    await auth?.signOut();
    await setGuestMode(ref, false);
    ref.invalidate(lbIdentityProvider);
    ref.invalidate(boardPoolProvider);
    // authUserProvider flips to null → the router shows the welcome screen.
  }

  /// Permanently deletes the signed-in account and all data (cloud + local),
  /// gated by a type-to-confirm dialog. Play requires an in-app deletion path.
  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    final ok = await _confirmDeletion(
      context,
      title: 'Delete account & data?',
      body: 'This permanently deletes your PrepPilot account and ALL associated '
          'data: your cloud profile, leaderboard entry, linked coding profiles, '
          'portfolio, and on-device progress. This cannot be undone.',
      confirmLabel: 'Delete account',
    );
    if (!ok || !context.mounted) return;

    // Root navigator survives the auth-driven body swap, so a spinner pushed
    // here can still be dismissed after deletion completes.
    final rootNav = Navigator.of(context, rootNavigator: true);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => const PopScope(
        canPop: false,
        child: Center(child: CircularProgressIndicator()),
      ),
    );

    final err = await deleteAccountAndData(ref);

    if (rootNav.canPop()) rootNav.pop(); // dismiss the spinner
    if (err != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
    // On success, authUser → null routes to the welcome screen automatically.
  }

  /// Wipes all on-device data for a guest and returns to the welcome screen.
  Future<void> _deleteGuestData(BuildContext context, WidgetRef ref) async {
    final ok = await _confirmDeletion(
      context,
      title: 'Delete all my data?',
      body: 'This erases all your on-device progress, notes, and stats and '
          'returns you to the welcome screen. This cannot be undone.',
      confirmLabel: 'Delete data',
    );
    if (!ok) return;
    await deleteGuestData(ref);
    // guestMode → false routes to the welcome screen automatically.
  }

  /// Destructive confirmation requiring the user to type DELETE. Returns true
  /// only on an explicit, typed confirmation.
  Future<bool> _confirmDeletion(
    BuildContext context, {
    required String title,
    required String body,
    required String confirmLabel,
  }) async {
    final controller = TextEditingController();
    try {
      final res = await showDialog<bool>(
        context: context,
        builder: (ctx) => StatefulBuilder(
          builder: (ctx, setState) {
            final canDelete =
                controller.text.trim().toUpperCase() == 'DELETE';
            final scheme = Theme.of(ctx).colorScheme;
            return AlertDialog(
              title: Text(title),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(body),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Type DELETE to confirm',
                      style: Theme.of(ctx).textTheme.labelMedium),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'DELETE',
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancel')),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: scheme.error,
                    foregroundColor: scheme.onError,
                  ),
                  onPressed:
                      canDelete ? () => Navigator.pop(ctx, true) : null,
                  child: Text(confirmLabel),
                ),
              ],
            );
          },
        ),
      );
      return res ?? false;
    } finally {
      controller.dispose();
    }
  }

  Future<void> _editGoals(BuildContext context, WidgetRef ref) async {
    final profile = await ref.read(profileRepositoryProvider).get();
    var problems = profile.dailyGoalProblems;
    var minutes = profile.dailyGoalMinutes;
    if (!context.mounted) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.xl,
            right: AppSpacing.xl,
            top: AppSpacing.lg,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Daily goal',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.lg),
              Text('Problems per day: $problems'),
              Slider(
                value: problems.toDouble(),
                min: 1,
                max: 15,
                divisions: 14,
                onChanged: (v) => setState(() => problems = v.round()),
              ),
              Text('Minutes per day: $minutes'),
              Slider(
                value: minutes.toDouble(),
                min: 30,
                max: 600,
                divisions: 19,
                onChanged: (v) =>
                    setState(() => minutes = (v / 30).round() * 30),
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: () async {
                  await ref
                      .read(profileRepositoryProvider)
                      .updateGoals(minutes: minutes, problems: problems);
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.name,
    required this.role,
    required this.level,
    required this.xp,
    required this.xpIntoLevel,
  });
  final String name;
  final TargetRole role;
  final int level;
  final int xp;
  final int xpIntoLevel;

  @override
  Widget build(BuildContext context) {
    return GradientHeroCard(
      gradient: AppPalette.brandGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white.withValues(alpha: 0.25),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'A',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800)),
                    Text(role.label,
                        style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text('Lv $level',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: xpIntoLevel / 100,
              minHeight: 8,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          const SizedBox(height: 6),
          Text('$xpIntoLevel / 100 XP to level ${level + 1}',
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  const _QuickStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md, horizontal: AppSpacing.sm),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 6),
          Text(value,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800)),
          Text(label,
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: AppSpacing.sm),
          child: Text(title.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 1)),
        ),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.destructive = false,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  /// Renders the tile in the theme's error color (for irreversible actions).
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent =
        destructive ? theme.colorScheme.error : theme.colorScheme.primary;
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (destructive
                  ? theme.colorScheme.errorContainer
                  : theme.colorScheme.primaryContainer)
              .withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(icon, color: accent, size: 20),
      ),
      title: Text(title,
          style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: destructive ? accent : null)),
      subtitle: Text(subtitle,
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      trailing: onTap == null
          ? null
          : Icon(Icons.chevron_right_rounded,
              color: theme.colorScheme.onSurfaceVariant),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  const _ThemeTile({required this.selected, required this.onSelect});
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: SegmentedButton<int>(
        // Labels must not wrap ("Syste/m") when the icon + text are tight or
        // the user has scaled their font up.
        segments: const [
          ButtonSegment(
              value: 0,
              label: Text('System', maxLines: 1, softWrap: false),
              icon: Icon(Icons.brightness_auto_rounded)),
          ButtonSegment(
              value: 1,
              label: Text('Light', maxLines: 1, softWrap: false),
              icon: Icon(Icons.light_mode_rounded)),
          ButtonSegment(
              value: 2,
              label: Text('Dark', maxLines: 1, softWrap: false),
              icon: Icon(Icons.dark_mode_rounded)),
        ],
        selected: {selected},
        onSelectionChanged: (s) => onSelect(s.first),
        showSelectedIcon: false,
      ),
    );
  }
}
