import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/entrance.dart';
import '../../providers/providers.dart';
import 'achievements.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final s = ref.watch(achStatsProvider);
    final earned = kAchievements.where((a) => a.earned(s)).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenH,
                  AppSpacing.md, AppSpacing.screenH, AppSpacing.lg),
              child: Text('$earned of ${kAchievements.length} unlocked',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, 0,
                AppSpacing.screenH, AppSpacing.huge),
            sliver: SliverGrid(
              // Adaptive: the column count follows the available width (2 on a
              // phone, more on a tablet/landscape) instead of being pinned to
              // 2, and tiles grow taller as the user's font scale grows so the
              // badge text never overflows its cell.
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                childAspectRatio:
                    0.82 / MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.6),
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) =>
                    _BadgeCard(achievement: kAchievements[i], stats: s)
                        .entrance(index: i),
                childCount: kAchievements.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({required this.achievement, required this.stats});
  final Achievement achievement;
  final AchStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final earned = achievement.earned(stats);
    final color = earned ? achievement.color : theme.colorScheme.onSurfaceVariant;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withValues(alpha: earned ? 0.18 : 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(achievement.icon,
                color: earned
                    ? achievement.color
                    : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                size: 30),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(achievement.title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: earned ? null : theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 2),
          Expanded(
            child: Text(achievement.description,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant)),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (earned)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_rounded,
                    size: 15, color: achievement.color),
                const SizedBox(width: 4),
                Text('Unlocked',
                    style: theme.textTheme.labelSmall?.copyWith(
                        color: achievement.color, fontWeight: FontWeight.w700)),
              ],
            )
          else
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: LinearProgressIndicator(
                    value: achievement.progress(stats),
                    minHeight: 5,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    valueColor:
                        AlwaysStoppedAnimation(theme.colorScheme.primary),
                  ),
                ),
                const SizedBox(height: 3),
                Text('${achievement.current(stats)}/${achievement.target}',
                    style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
        ],
      ),
    );
  }
}
