import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_palette.dart';
import '../../core/widgets/animated_counter.dart';
import '../../core/widgets/entrance.dart';
import '../../providers/providers.dart';
import 'leaderboard_models.dart';
import 'leaderboard_repository.dart';

Color _avatarColor(String seed) {
  const colors = [
    AppPalette.indigo, AppPalette.violet, AppPalette.mint, AppPalette.catSystem,
    AppPalette.catInterview, AppPalette.info, AppPalette.catAptitude,
  ];
  return colors[seed.hashCode.abs() % colors.length];
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first.characters.take(2).toString().toUpperCase();
  return (parts.first.characters.first + parts.last.characters.first).toUpperCase();
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, this.size = 44, this.me = false});
  final String name;
  final double size;
  final bool me;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _avatarColor(name).withValues(alpha: 0.9),
        shape: BoxShape.circle,
        border: me
            ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2.5)
            : null,
      ),
      alignment: Alignment.center,
      child: Text(_initials(name),
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: size * 0.36)),
    );
  }
}

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  LeaderboardScope _scope = LeaderboardScope.global;
  LeaderboardMetric _metric = LeaderboardMetric.solved;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final live = ref.watch(leaderboardRepositoryProvider).isLive;
    final async = ref.watch(boardPoolProvider(_scope));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        titleTextStyle: theme.textTheme.headlineSmall,
      ),
      body: Column(
        children: [
          _ChipRow(
            values: LeaderboardScope.values.map((e) => e.label).toList(),
            selected: _scope.index,
            onSelect: (i) => setState(() => _scope = LeaderboardScope.values[i]),
          ),
          _ChipRow(
            values: LeaderboardMetric.values.map((e) => e.label).toList(),
            selected: _metric.index,
            small: true,
            onSelect: (i) =>
                setState(() => _metric = LeaderboardMetric.values[i]),
          ),
          if (!live)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(AppSpacing.screenH, 4,
                  AppSpacing.screenH, 0),
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text('Preview — sign in to join real leaderboards',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant)),
            ),
          Expanded(
            child: async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Could not load: $e')),
              data: (pool) {
                final ranked = rankPool(pool, _metric);
                final top3 = ranked.take(3).toList();
                final rest = ranked.skip(3).toList();
                final me = ranked.firstWhere((e) => e.isMe,
                    orElse: () => ranked.isNotEmpty
                        ? ranked.first
                        : throw StateError('empty'));
                return Column(
                  children: [
                    Expanded(
                      child: CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: _Podium(top3: top3, metric: _metric)
                                .entrance(),
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(AppSpacing.screenH,
                                AppSpacing.sm, AppSpacing.screenH, AppSpacing.huge),
                            sliver: SliverList.separated(
                              itemCount: rest.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: AppSpacing.sm),
                              itemBuilder: (context, i) =>
                                  _RankRow(entry: rest[i], metric: _metric),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _YourRankBar(me: me, metric: _metric),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipRow extends StatelessWidget {
  const _ChipRow({
    required this.values,
    required this.selected,
    required this.onSelect,
    this.small = false,
  });
  final List<String> values;
  final int selected;
  final ValueChanged<int> onSelect;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: small ? 40 : 46,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
        children: [
          for (var i = 0; i < values.length; i++)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: GestureDetector(
                onTap: () => onSelect(i),
                child: AnimatedContainer(
                  duration: AppMotion.fast,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(
                      horizontal: small ? AppSpacing.md : AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: i == selected ? scheme.primary : scheme.surface,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(
                        color: i == selected ? scheme.primary : scheme.outline),
                  ),
                  child: Text(values[i],
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: small ? 13 : 14,
                          color:
                              i == selected ? Colors.white : scheme.onSurface)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Podium extends StatelessWidget {
  const _Podium({required this.top3, required this.metric});
  final List<LeaderboardEntry> top3;
  final LeaderboardMetric metric;

  @override
  Widget build(BuildContext context) {
    if (top3.isEmpty) return const SizedBox.shrink();
    LeaderboardEntry? at(int i) => i < top3.length ? top3[i] : null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenH, AppSpacing.lg, AppSpacing.screenH, AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: _PodiumSpot(entry: at(1), place: 2, metric: metric)),
          Expanded(child: _PodiumSpot(entry: at(0), place: 1, metric: metric)),
          Expanded(child: _PodiumSpot(entry: at(2), place: 3, metric: metric)),
        ],
      ),
    );
  }
}

class _PodiumSpot extends StatelessWidget {
  const _PodiumSpot(
      {required this.entry, required this.place, required this.metric});
  final LeaderboardEntry? entry;
  final int place;
  final LeaderboardMetric metric;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (entry == null) return const SizedBox.shrink();
    final medal = switch (place) {
      1 => const Color(0xFFFFD24A),
      2 => const Color(0xFFC7CCD6),
      _ => const Color(0xFFE29A5B),
    };
    final avatarSize = place == 1 ? 66.0 : 52.0;
    final barHeight = place == 1 ? 90.0 : (place == 2 ? 66.0 : 52.0);

    return Column(
      children: [
        if (place == 1)
          const Icon(Icons.emoji_events_rounded,
              color: Color(0xFFFFD24A), size: 26),
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            _Avatar(name: entry!.name, size: avatarSize, me: entry!.isMe),
            Positioned(
              bottom: -6,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(color: medal, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text('$place',
                    style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w800,
                        fontSize: 12)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(entry!.name.split(' ').first,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelLarge
                ?.copyWith(fontWeight: FontWeight.w700)),
        AnimatedCounter(
          value: entry!.metricValue(metric),
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w800, color: medal),
        ),
        const SizedBox(height: 6),
        Container(
          height: barHeight,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [medal.withValues(alpha: 0.5), medal.withValues(alpha: 0.15)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(AppRadius.sm)),
          ),
        ),
      ],
    );
  }
}

class _RankRow extends StatelessWidget {
  const _RankRow({required this.entry, required this.metric});
  final LeaderboardEntry entry;
  final LeaderboardMetric metric;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: entry.isMe
            ? scheme.primaryContainer.withValues(alpha: 0.5)
            : scheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
            color: entry.isMe ? scheme.primary : scheme.outline),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text('${entry.rank}',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurfaceVariant)),
          ),
          const SizedBox(width: AppSpacing.sm),
          _Avatar(name: entry.name, size: 40, me: entry.isMe),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.isMe ? '${entry.name} (You)' : entry.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
                Row(
                  children: [
                    Icon(Icons.local_fire_department_rounded,
                        size: 12, color: AppPalette.warning),
                    const SizedBox(width: 2),
                    Text('${entry.streak}d',
                        style: theme.textTheme.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant)),
                    if (entry.college != null) ...[
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(entry.college!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                                color: scheme.onSurfaceVariant)),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${entry.metricValue(metric)}',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800)),
              Text(metric.unit,
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: scheme.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }
}

class _YourRankBar extends StatelessWidget {
  const _YourRankBar({required this.me, required this.metric});
  final LeaderboardEntry me;
  final LeaderboardMetric metric;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.colorScheme.outline)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenH, vertical: AppSpacing.sm),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: AppPalette.brandGradient,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text('#${me.rank}',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: AppSpacing.md),
              _Avatar(name: me.name, size: 34, me: true),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text('Your rank',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
              ),
              Text('${me.metricValue(metric)} ${metric.unit}',
                  style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ),
    );
  }
}
