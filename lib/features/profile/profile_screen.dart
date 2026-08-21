import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/enums.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_palette.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/entrance.dart';
import '../../providers/providers.dart';
import '../achievements/achievements_screen.dart';
import '../focus/focus_timer_screen.dart';
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
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(icon, color: theme.colorScheme.primary, size: 20),
      ),
      title: Text(title,
          style: theme.textTheme.titleSmall
              ?.copyWith(fontWeight: FontWeight.w600)),
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
        segments: const [
          ButtonSegment(value: 0, label: Text('System'), icon: Icon(Icons.brightness_auto_rounded)),
          ButtonSegment(value: 1, label: Text('Light'), icon: Icon(Icons.light_mode_rounded)),
          ButtonSegment(value: 2, label: Text('Dark'), icon: Icon(Icons.dark_mode_rounded)),
        ],
        selected: {selected},
        onSelectionChanged: (s) => onSelect(s.first),
        showSelectedIcon: false,
      ),
    );
  }
}
