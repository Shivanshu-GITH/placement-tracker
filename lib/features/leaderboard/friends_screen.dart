import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_palette.dart';
import '../../core/widgets/empty_state.dart';
import '../../providers/providers.dart';
import 'leaderboard_models.dart';

Color _avatarColor(String seed) {
  const colors = [
    AppPalette.indigo, AppPalette.violet, AppPalette.mint, AppPalette.catSystem,
    AppPalette.catInterview, AppPalette.info, AppPalette.catAptitude,
  ];
  return colors[seed.hashCode.abs() % colors.length];
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty || parts.first.isEmpty) return '?';
  if (parts.length == 1) {
    return parts.first.characters.take(2).toString().toUpperCase();
  }
  return (parts.first.characters.first + parts.last.characters.first)
      .toUpperCase();
}

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  final _searchCtl = TextEditingController();
  Timer? _debounce;
  String _query = '';
  List<LeaderboardEntry> _results = const [];
  final Set<String> _followed = {};
  bool _loading = false;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _loadFollowing();
  }

  Future<void> _loadFollowing() async {
    final ids = await ref.read(leaderboardRepositoryProvider).followingIds();
    if (!mounted) return;
    setState(() {
      _followed
        ..clear()
        ..addAll(ids);
      _ready = true;
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtl.dispose();
    super.dispose();
  }

  void _onQuery(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => _search(q));
    setState(() => _query = q);
  }

  Future<void> _search(String q) async {
    if (q.trim().isEmpty) {
      setState(() => _results = const []);
      return;
    }
    setState(() => _loading = true);
    final res = await ref.read(leaderboardRepositoryProvider).searchUsers(q);
    if (!mounted) return;
    setState(() {
      _results = res;
      _loading = false;
    });
  }

  Future<void> _toggle(LeaderboardEntry e) async {
    final repo = ref.read(leaderboardRepositoryProvider);
    final wasFollowing = _followed.contains(e.userId);
    setState(() {
      wasFollowing ? _followed.remove(e.userId) : _followed.add(e.userId);
    });
    try {
      if (wasFollowing) {
        await repo.unfollow(e.userId);
      } else {
        await repo.follow(e.userId);
      }
      ref.invalidate(boardPoolProvider);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        wasFollowing ? _followed.add(e.userId) : _followed.remove(e.userId);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not update. Try again.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Current friends (from the Friends pool, excluding yourself).
    final friendsPool =
        ref.watch(boardPoolProvider(LeaderboardScope.friends)).valueOrNull ??
            const [];
    final following = friendsPool.where((e) => !e.isMe).toList();
    final searching = _query.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        titleTextStyle: theme.textTheme.headlineSmall,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, AppSpacing.sm,
                AppSpacing.screenH, AppSpacing.sm),
            child: TextField(
              controller: _searchCtl,
              onChanged: _onQuery,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search people by name…',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: searching
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _searchCtl.clear();
                          _onQuery('');
                        },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: searching
                ? _buildSearchResults(theme)
                : _buildFollowing(theme, following),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(ThemeData theme) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_results.isEmpty) {
      return const EmptyState(
        icon: Icons.person_search_rounded,
        title: 'No one found',
        message: 'Try a different name. People appear here once they\'ve '
            'joined the leaderboard.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, AppSpacing.sm,
          AppSpacing.screenH, AppSpacing.huge),
      itemCount: _results.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, i) => _PersonRow(
        entry: _results[i],
        following: _followed.contains(_results[i].userId),
        onToggle: () => _toggle(_results[i]),
      ),
    );
  }

  Widget _buildFollowing(ThemeData theme, List<LeaderboardEntry> following) {
    if (!_ready) {
      return const Center(child: CircularProgressIndicator());
    }
    if (following.isEmpty) {
      return const EmptyState(
        icon: Icons.group_add_rounded,
        title: 'No friends yet',
        message: 'Search for classmates and peers by name to follow them. '
            'Their progress shows up on your Friends leaderboard.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, AppSpacing.sm,
          AppSpacing.screenH, AppSpacing.huge),
      itemCount: following.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4, left: 4),
            child: Text('FOLLOWING (${following.length})',
                style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    letterSpacing: 1)),
          );
        }
        final e = following[i - 1];
        return _PersonRow(
          entry: e,
          following: true,
          onToggle: () => _toggle(e),
        );
      },
    );
  }
}

class _PersonRow extends StatelessWidget {
  const _PersonRow({
    required this.entry,
    required this.following,
    required this.onToggle,
  });
  final LeaderboardEntry entry;
  final bool following;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: scheme.outline),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: _avatarColor(entry.name).withValues(alpha: 0.9),
            child: Text(_initials(entry.name),
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(entry.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700)),
                    ),
                    if (entry.isVerified) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.verified_rounded,
                          size: 13, color: scheme.primary),
                    ],
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.emoji_events_rounded,
                        size: 12, color: AppPalette.warning),
                    const SizedBox(width: 2),
                    Text('${entry.prepScore} pts · ${entry.verifiedSolved} solved',
                        style: theme.textTheme.labelSmall
                            ?.copyWith(color: scheme.onSurfaceVariant)),
                    if (entry.college != null) ...[
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(entry.college!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall
                                ?.copyWith(color: scheme.onSurfaceVariant)),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          following
              ? OutlinedButton(
                  onPressed: onToggle,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  child: const Text('Following'),
                )
              : FilledButton(
                  onPressed: onToggle,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                  ),
                  child: const Text('Follow'),
                ),
        ],
      ),
    );
  }
}
