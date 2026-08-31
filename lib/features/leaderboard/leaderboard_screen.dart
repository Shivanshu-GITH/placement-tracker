import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_palette.dart';
import '../../core/widgets/animated_counter.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/entrance.dart';
import '../../providers/providers.dart';
import 'coding_portfolio_screen.dart';
import 'friends_screen.dart';
import 'leaderboard_models.dart';
import 'leaderboard_repository.dart';

/// Opens a user's portfolio — own (userId null) when it's you, else public.
void openPortfolio(BuildContext context, LeaderboardEntry e) {
  // Skip sample/stub rows (their ids aren't real user uuids).
  if (!e.isMe && !e.userId.contains('-')) return;
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => CodingPortfolioScreen(userId: e.isMe ? null : e.userId),
  ));
}

String _shortPlatform(String p) => switch (p) {
      'leetcode' => 'LC',
      'codeforces' => 'CF',
      'codechef' => 'CC',
      'atcoder' => 'AC',
      _ => p,
    };

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
  LeaderboardMetric _metric = LeaderboardMetric.prepScore;
  bool _synced = false;
  Timer? _syncDebounce;

  @override
  void dispose() {
    _syncDebounce?.cancel();
    super.dispose();
  }

  /// Pushes the latest in-app stats to the backend (debounced) so the PrepPilot
  /// Score and streak/XP stay current as the user solves problems.
  void _scheduleSync() {
    if (ref.read(authUserProvider).valueOrNull == null) return;
    if (!ref.read(leaderboardRepositoryProvider).isLive) return;
    _syncDebounce?.cancel();
    _syncDebounce = Timer(const Duration(milliseconds: 600), () async {
      final repo = ref.read(leaderboardRepositoryProvider);
      final id = await ref.read(lbIdentityProvider.future);
      await repo.syncMyStats(ref.read(myStatsProvider),
          name: id.name, college: id.college);
      if (mounted) ref.invalidate(boardPoolProvider);
    });
  }

  Future<void> _join() async {
    // Guests join by signing in with Google directly; name & college are then
    // collected in onboarding for the new account.
    final err = await signInWithGoogleFlow(ref);
    if (!mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(err)));
    } else {
      // Mark synced so the post-open auto-sync doesn't double-fire right after.
      _synced = true;
    }
  }

  Future<void> _openFriends() async {
    final signedIn = ref.read(authUserProvider).valueOrNull != null;
    if (!signedIn) {
      await _join();
      return;
    }
    if (!mounted) return;
    await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const FriendsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final repo = ref.watch(leaderboardRepositoryProvider);
    final live = repo.isLive;
    final signedIn = ref.watch(authUserProvider).valueOrNull != null;
    final async = ref.watch(boardPoolProvider(_scope));

    // Re-sync whenever in-app stats change (solving problems, streak, XP) or the
    // user signs in — so the PrepPilot Score / streak move without a restart.
    ref.listen<MyStats>(myStatsProvider, (_, _) => _scheduleSync());
    ref.listen(authUserProvider, (_, next) {
      if (next.valueOrNull != null) _scheduleSync();
    });

    // Initial sync on first open (listeners only fire on change).
    if (live && signedIn && !_synced) {
      _synced = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final id = await ref.read(lbIdentityProvider.future);
        await repo.syncMyStats(ref.read(myStatsProvider),
            name: id.name, college: id.college);
        ref.invalidate(boardPoolProvider);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        titleTextStyle: theme.textTheme.headlineSmall,
        actions: [
          IconButton(
            tooltip: 'Friends',
            icon: const Icon(Icons.group_add_rounded),
            onPressed: _openFriends,
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: AppSpacing.xs),
          _ChipRow(
            values: LeaderboardScope.values.map((e) => e.label).toList(),
            selected: _scope.index,
            onSelect: (i) => setState(() => _scope = LeaderboardScope.values[i]),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ChipRow(
            values: LeaderboardMetric.values.map((e) => e.label).toList(),
            selected: _metric.index,
            small: true,
            onSelect: (i) =>
                setState(() => _metric = LeaderboardMetric.values[i]),
          ),
          const SizedBox(height: AppSpacing.sm),
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
              child: Text('Preview — connect the backend to go live',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant)),
            )
          else if (!signedIn)
            Container(
              margin: const EdgeInsets.fromLTRB(AppSpacing.screenH, 4,
                  AppSpacing.screenH, 0),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                gradient: AppPalette.brandGradient,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Join to appear on the board and compete with peers.',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  FilledButton(
                    onPressed: _join,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppPalette.indigo,
                      minimumSize: const Size(0, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: const Text('Join'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Could not load: $e')),
              data: (pool) {
                // Friends board with no one followed yet → prompt to add.
                if (_scope == LeaderboardScope.friends &&
                    !pool.any((e) => !e.isMe)) {
                  return EmptyState(
                    icon: Icons.group_add_rounded,
                    title: signedIn ? 'No friends yet' : 'Follow your friends',
                    message: signedIn
                        ? 'Add classmates and peers to see how you stack up '
                            'against them each week.'
                        : 'Sign up and follow classmates to compete on a '
                            'private board.',
                    actionLabel: signedIn ? 'Find friends' : 'Sign up',
                    onAction: _openFriends,
                  );
                }
                final ranked = rankPool(pool, _metric);
                final top3 = ranked.take(3).toList();
                final rest = ranked.skip(3).toList();
                LeaderboardEntry? me;
                for (final e in ranked) {
                  if (e.isMe) {
                    me = e;
                    break;
                  }
                }
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
                              itemBuilder: (context, i) => GestureDetector(
                                onTap: () => openPortfolio(context, rest[i]),
                                child: _RankRow(entry: rest[i], metric: _metric),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (me != null)
                      _YourRankBar(me: me, metric: _metric)
                    else
                      _GuestRankBar(onSignUp: _join),
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
    // Equal-width chips that fill the row — no horizontal scrolling.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
      child: Row(
        children: [
          for (var i = 0; i < values.length; i++)
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                    right: i == values.length - 1 ? 0 : AppSpacing.sm),
                child: GestureDetector(
                  onTap: () => onSelect(i),
                  child: AnimatedContainer(
                    duration: AppMotion.fast,
                    height: small ? 38 : 44,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: i == selected ? scheme.primary : scheme.surface,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(
                          color:
                              i == selected ? scheme.primary : scheme.outline),
                    ),
                    child: Text(
                      values[i],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: small ? 12.5 : 13.5,
                          color: i == selected ? Colors.white : scheme.onSurface),
                    ),
                  ),
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
          for (final spot in [(at(1), 2), (at(0), 1), (at(2), 3)])
            Expanded(
              child: GestureDetector(
                onTap: spot.$1 == null
                    ? null
                    : () => openPortfolio(context, spot.$1!),
                child: _PodiumSpot(
                    entry: spot.$1, place: spot.$2, metric: metric),
              ),
            ),
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
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(entry!.name.split(' ').first,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ),
            if (entry!.isVerified) ...[
              const SizedBox(width: 3),
              Icon(Icons.verified_rounded,
                  size: 13, color: theme.colorScheme.primary),
            ],
          ],
        ),
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
          // A minimum width keeps the ranks aligned, but four-digit ranks (and
          // larger font scales) are allowed to widen instead of clipping.
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 28),
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
                Row(
                  children: [
                    Flexible(
                      child: Text(entry.isMe ? '${entry.name} (You)' : entry.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700)),
                    ),
                    if (entry.isVerified) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.verified_rounded,
                          size: 14, color: theme.colorScheme.primary),
                    ],
                  ],
                ),
                if (metric == LeaderboardMetric.rating &&
                    entry.platformRatings.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final e in entry.platformRatings.entries)
                        Text('${_shortPlatform(e.key)} ${e.value}',
                            style: theme.textTheme.labelSmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600)),
                    ],
                  )
                else
                  Row(
                    children: [
                      Icon(Icons.local_fire_department_rounded,
                          size: 12, color: AppPalette.warning),
                      const SizedBox(width: 2),
                      Text('${entry.extStreak}d',
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

/// Shown instead of the rank bar for guests — they can browse but must sign up
/// to appear on the board.
class _GuestRankBar extends StatelessWidget {
  const _GuestRankBar({required this.onSignUp});
  final VoidCallback onSignUp;

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
              Icon(Icons.visibility_rounded,
                  size: 20, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text('You\'re browsing as a guest',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
              ),
              FilledButton(
                onPressed: onSignUp,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 38),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text('Sign up'),
              ),
            ],
          ),
        ),
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
