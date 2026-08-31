import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/services/notification_service.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_palette.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/entrance.dart';
import '../../core/widgets/section_header.dart';
import '../../providers/providers.dart';
import 'contest_models.dart';
import 'contest_schedule.dart';

Color _platformColor(String platform) => switch (platform) {
      'LeetCode' => const Color(0xFFF59E0B),
      'Codeforces' => const Color(0xFF3B82F6),
      'CodeChef' => const Color(0xFF8B5CF6),
      'AtCoder' => const Color(0xFF10B981),
      _ => AppPalette.catCp,
    };

/// Lists today's and upcoming competitive-programming contests and lets the
/// user opt into pre-contest reminders.
class ContestsScreen extends ConsumerWidget {
  const ContestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todaysContestsProvider);
    final upcoming = ref.watch(upcomingContestsProvider);
    // Upcoming excluding today's, so the two sections don't repeat.
    final todayKeys = today.map((o) => o.startIst).toSet();
    final later = upcoming.where((o) => !todayKeys.contains(o.startIst)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contests'),
        titleTextStyle: Theme.of(context).textTheme.headlineSmall,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, AppSpacing.md,
            AppSpacing.screenH, AppSpacing.huge),
        children: [
          const _ContestPrepCard().entrance(index: 0),
          const SizedBox(height: AppSpacing.xl),
          SectionHeader(
            title: 'Today',
            subtitle: today.isEmpty ? 'No contests scheduled today' : null,
            icon: Icons.today_rounded,
          ).entrance(index: 1),
          const SizedBox(height: AppSpacing.md),
          if (today.isEmpty)
            const _EmptyToday().entrance(index: 1)
          else
            for (final o in today)
              _ContestTile(occurrence: o, highlight: true).entrance(index: 1),
          const SizedBox(height: AppSpacing.xl),
          SectionHeader(
            title: 'This week',
            subtitle: '${later.length} scheduled',
            icon: Icons.event_rounded,
          ).entrance(index: 2),
          const SizedBox(height: AppSpacing.md),
          for (final o in later)
            _ContestTile(occurrence: o, highlight: false).entrance(index: 2),
          const SizedBox(height: AppSpacing.xl),
          SectionHeader(
            title: 'Irregular — check the schedule',
            subtitle: 'Codeforces rounds vary week to week',
            icon: Icons.link_rounded,
          ).entrance(index: 3),
          const SizedBox(height: AppSpacing.md),
          for (final s in ContestSchedule.irregularSeries())
            _SeriesLinkTile(series: s).entrance(index: 3),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Times are typical weekly slots in IST and can change — always confirm on the platform.',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

/// The opt-in toggle for contest prep + reminders.
class _ContestPrepCard extends ConsumerWidget {
  const _ContestPrepCard();

  Future<void> _toggle(BuildContext context, WidgetRef ref, bool value) async {
    if (value) {
      final granted = await NotificationService.instance.requestPermission();
      if (!granted) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                  'Allow notifications to get contest reminders.')));
        }
        return;
      }
      await ref.read(contestPrepProvider.notifier).setEnabled(true);
      await NotificationService.instance
          .scheduleContestReminders(ref.read(upcomingContestsProvider));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Contest prep on — you\'ll be reminded ~1h before.')));
      }
    } else {
      await ref.read(contestPrepProvider.notifier).setEnabled(false);
      await NotificationService.instance.cancelContestReminders();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final enabled = ref.watch(contestPrepProvider);
    return AppCard(
      padding: EdgeInsets.zero,
      child: SwitchListTile(
        value: enabled,
        onChanged: (v) => _toggle(context, ref, v),
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppPalette.catCp.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: const Icon(Icons.emoji_events_rounded,
              color: AppPalette.catCp, size: 20),
        ),
        title: Text('Contest prep & reminders',
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w700)),
        subtitle: Text('Remind me ~1 hour before each contest',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ),
    );
  }
}

class _ContestTile extends StatelessWidget {
  const _ContestTile({required this.occurrence, required this.highlight});
  final ContestOccurrence occurrence;
  final bool highlight;

  Future<void> _open(BuildContext context) async {
    final uri = Uri.parse(occurrence.url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        await Clipboard.setData(ClipboardData(text: occurrence.url));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Link copied to clipboard')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _platformColor(occurrence.platform);
    final dayLabel = DateFormat('EEE, d MMM').format(occurrence.startIst);
    final timeLabel = DateFormat('h:mm a').format(occurrence.startIst);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        borderColor: highlight ? color : null,
        onTap: () => _open(context),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              alignment: Alignment.center,
              child: Text(occurrence.platform[0],
                  style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w800,
                      fontSize: 20)),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${occurrence.platform} · ${occurrence.name}',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text('$dayLabel · $timeLabel IST · ${occurrence.durationMins} min',
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            if (highlight)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: const Text('TODAY',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800)),
              )
            else
              Icon(Icons.open_in_new_rounded,
                  size: 18, color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _SeriesLinkTile extends StatelessWidget {
  const _SeriesLinkTile({required this.series});
  final ContestSeries series;

  Future<void> _open(BuildContext context) async {
    final uri = Uri.parse(series.url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        await Clipboard.setData(ClipboardData(text: series.url));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _platformColor(series.platform);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.md),
        onTap: () => _open(context),
        child: Row(
          children: [
            Icon(Icons.bolt_rounded, color: color, size: 20),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${series.platform} · ${series.name}',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  if (series.note.isNotEmpty)
                    Text(series.note,
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            Icon(Icons.open_in_new_rounded,
                size: 18, color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _EmptyToday extends StatelessWidget {
  const _EmptyToday();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Row(
        children: [
          Icon(Icons.free_breakfast_rounded,
              color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
                'Nothing today — use the time to upsolve last week\'s problems.',
                style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
