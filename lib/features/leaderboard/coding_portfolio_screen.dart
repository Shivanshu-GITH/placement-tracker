import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_palette.dart';
import '../../core/widgets/app_card.dart';
import '../../providers/providers.dart';
import 'coding_profiles_screen.dart';
import 'leaderboard_models.dart';
import 'share_card_screen.dart';
import 'widgets/month_heatmap.dart';
import 'widgets/portfolio_charts.dart';

const _day = 86400;

/// Codolio-style unified portfolio: Problem Solving + Development tabs, with
/// verified stats, heatmap, contests, languages, projects and social links.
/// Pass [userId] to view someone else's profile (read-only); null = your own.
class CodingPortfolioScreen extends ConsumerStatefulWidget {
  const CodingPortfolioScreen({super.key, this.userId});
  final String? userId;

  @override
  ConsumerState<CodingPortfolioScreen> createState() => _PortfolioState();
}

class _PortfolioState extends ConsumerState<CodingPortfolioScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 2, vsync: this);
  LeaderboardEntry? _entry;
  List<PlatformInfo> _platforms = const [];
  List<ContestEntry> _contests = const [];
  List<SocialLink> _social = const [];
  List<ProjectItem> _projects = const [];
  bool _loading = true;
  String? _uid;

  bool get _isOwn => widget.userId == null;

  @override
  void initState() {
    super.initState();
    _load();
    if (!_isOwn) {
      ref
          .read(leaderboardRepositoryProvider)
          .incrementProfileView(widget.userId!);
    }
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final repo = ref.read(leaderboardRepositoryProvider);
    final uid = widget.userId ?? ref.read(authUserProvider).valueOrNull?.id;
    _uid = uid;
    if (uid == null) {
      setState(() => _loading = false);
      return;
    }
    final results = await Future.wait([
      repo.entryOf(uid),
      repo.platformsOf(uid),
      repo.contests(uid),
      repo.socialLinks(uid),
      repo.projects(uid),
    ]);
    if (!mounted) return;
    setState(() {
      _entry = results[0] as LeaderboardEntry?;
      _platforms = results[1] as List<PlatformInfo>;
      _contests = results[2] as List<ContestEntry>;
      _social = results[3] as List<SocialLink>;
      _projects = results[4] as List<ProjectItem>;
      _loading = false;
    });
  }

  // ---- Merged problem-solving activity (for heatmap + streaks) -------------
  Map<String, int> get _mergedDaily {
    final m = <String, int>{};
    for (final p in _platforms.where((p) => !p.isDev)) {
      p.daily.forEach((k, v) => m[k] = (m[k] ?? 0) + v);
    }
    return m;
  }

  ({int current, int max, int active}) _streaks(Map<String, int> daily) {
    final secs = <int>{};
    for (final e in daily.entries) {
      if (e.value > 0) {
        final d = DateTime.tryParse(e.key);
        if (d != null) secs.add((d.millisecondsSinceEpoch ~/ 1000 ~/ _day) * _day);
      }
    }
    final sorted = secs.toList()..sort();
    var max = 0, run = 0, prev = 0;
    for (final s in sorted) {
      run = (prev != 0 && s - prev == _day) ? run + 1 : 1;
      if (run > max) max = run;
      prev = s;
    }
    var current = 0;
    var cur = (DateTime.now().millisecondsSinceEpoch ~/ 1000 ~/ _day) * _day;
    if (!secs.contains(cur)) cur -= _day;
    while (secs.contains(cur)) {
      current++;
      cur -= _day;
    }
    return (current: current, max: max, active: secs.length);
  }

  Future<void> _openUrl(String url) async {
    var u = url.trim();
    if (!u.startsWith('http') && !u.contains('@')) u = 'https://$u';
    if (u.contains('@') && !u.startsWith('http')) u = 'mailto:$u';
    final uri = Uri.tryParse(u);
    if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _invite() async {
    final name = _entry?.name ?? 'me';
    final id = _uid ?? '';
    await SharePlus.instance.share(ShareParams(
      text: 'Follow $name on PrepPilot 🚀 and let\'s compete!\n'
          'Open: preppilot://follow/$id\n'
          '(Get PrepPilot and search "$name" in Friends.)',
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_isOwn ? 'My Portfolio' : (_entry?.name ?? 'Portfolio')),
        titleTextStyle: theme.textTheme.headlineSmall,
        actions: _isOwn
            ? [
                IconButton(
                  tooltip: 'Invite a friend',
                  icon: const Icon(Icons.person_add_alt_rounded),
                  onPressed: _invite,
                ),
                IconButton(
                  tooltip: 'Share card',
                  icon: const Icon(Icons.share_rounded),
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const ShareCardScreen())),
                ),
              ]
            : null,
        bottom: TabBar(
          controller: _tab,
          tabs: const [Tab(text: 'Problem Solving'), Tab(text: 'Development')],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tab,
              children: [_problemTab(theme), _devTab(theme)],
            ),
    );
  }

  /// The profile card. It lives *inside* each tab's list so it scrolls away
  /// with the content instead of staying pinned under the tab bar.
  Widget get _headerCard => _Header(
        entry: _entry,
        social: _social,
        isOwn: _isOwn,
        onOpenLink: _openUrl,
        onEditLinks: _isOwn ? _editSocialLinks : null,
      );

  // ---------------------------------------------------------------- PS tab
  Widget _problemTab(ThemeData theme) {
    final ps = _platforms.where((p) => !p.isDev).toList();
    final daily = _mergedDaily;
    final s = _streaks(daily);
    final solved = ps.fold<int>(0, (a, p) => a + p.solved);
    final maxStreak = [
      s.max,
      ...ps.map((p) => p.maxStreak),
    ].reduce((a, b) => a > b ? a : b);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenH, AppSpacing.md, AppSpacing.screenH, AppSpacing.huge),
      children: [
        _headerCard,
        Row(children: [
          Expanded(child: _Tile('Solved', '$solved', Icons.verified_rounded, AppPalette.success)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: _Tile('Active days', '${s.active}', Icons.calendar_month_rounded, AppPalette.indigo)),
        ]),
        const SizedBox(height: AppSpacing.sm),
        Row(children: [
          Expanded(child: _Tile('Current streak', '${s.current}d', Icons.local_fire_department_rounded, AppPalette.warning)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: _Tile('Max streak', '${maxStreak}d', Icons.whatshot_rounded, AppPalette.catInterview)),
        ]),
        const SizedBox(height: AppSpacing.lg),
        if (ps.isEmpty)
          _linkPrompt('Link LeetCode, Codeforces, AtCoder, GeeksforGeeks or CodeChef to see your solving stats.')
        else ...[
          if (ps.any((p) => p.rating > 0)) ...[
            _SectionTitle('Contest ratings'),
            const SizedBox(height: AppSpacing.sm),
            AppCard(
              child: Wrap(
                spacing: AppSpacing.lg,
                runSpacing: AppSpacing.md,
                children: [
                  for (final p in ps.where((p) => p.rating > 0))
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${p.rating}',
                            style: theme.textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800)),
                        Text(p.label,
                            style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          _SectionTitle('Submission activity'),
          const SizedBox(height: AppSpacing.sm),
          AppCard(child: MonthHeatmap(daily: daily)),
          const SizedBox(height: AppSpacing.lg),
          _SectionTitle('Platforms'),
          const SizedBox(height: AppSpacing.sm),
          for (final p in ps)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _PlatformRow(p),
            ),
          if (_contests.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            _SectionTitle('Contests', trailing: '${_contests.length}'),
            const SizedBox(height: AppSpacing.sm),
            AppCard(child: ContestRatingGraph(contests: _contests)),
            const SizedBox(height: AppSpacing.sm),
            for (final c in _contests.reversed.take(8))
              _ContestRow(c),
          ],
        ],
      ],
    );
  }

  // ---------------------------------------------------------------- Dev tab
  Widget _devTab(ThemeData theme) {
    PlatformInfo? gh;
    for (final p in _platforms) {
      if (p.isDev) gh = p;
    }
    if (gh == null) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, AppSpacing.md,
            AppSpacing.screenH, AppSpacing.huge),
        children: [
          _headerCard,
          _linkPrompt(
              'Link GitHub to show your development stats, languages and projects.'),
        ],
      );
    }
    final g = gh;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenH, AppSpacing.md, AppSpacing.screenH, AppSpacing.huge),
      children: [
        _headerCard,
        Row(children: [
          Expanded(child: _Tile('Contributions', '${g.contributions}', Icons.grid_view_rounded, AppPalette.success)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: _Tile('Active days', '${g.activeDays}', Icons.calendar_month_rounded, AppPalette.indigo)),
        ]),
        const SizedBox(height: AppSpacing.sm),
        Row(children: [
          Expanded(child: _Tile('Stars', '${g.stars}', Icons.star_rounded, AppPalette.warning)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: _Tile('Commits', '${g.commits}', Icons.commit_rounded, AppPalette.violet)),
        ]),
        const SizedBox(height: AppSpacing.sm),
        Row(children: [
          Expanded(child: _Tile('PRs', '${g.prs}', Icons.merge_rounded, AppPalette.info)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: _Tile('Issues', '${g.issues}', Icons.error_outline_rounded, AppPalette.catAptitude)),
        ]),
        if (g.daily.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          _SectionTitle('Contribution activity'),
          const SizedBox(height: AppSpacing.sm),
          AppCard(child: MonthHeatmap(daily: g.daily)),
        ],
        if (g.languages.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          _SectionTitle('Languages'),
          const SizedBox(height: AppSpacing.sm),
          AppCard(child: LanguagesChart(languages: g.languages)),
        ],
        const SizedBox(height: AppSpacing.lg),
        _SectionTitle('Projects',
            action: _isOwn ? 'Add' : null,
            onAction: _isOwn ? () => _addProject(g.handle) : null),
        const SizedBox(height: AppSpacing.sm),
        if (_projects.isEmpty)
          Text(_isOwn
              ? 'Add projects from your GitHub to showcase your work.'
              : 'No projects yet.',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant))
        else
          for (final p in _projects)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _ProjectCard(
                p,
                onEdit: _isOwn ? () => _editProject(g.handle, existing: p) : null,
                onOpen: _openUrl,
              ),
            ),
      ],
    );
  }

  Widget _linkPrompt(String msg) => AppCard(
        onTap: _isOwn
            ? () async {
                await Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const CodingProfilesScreen()));
                _load();
              }
            : null,
        child: Row(children: [
          const Icon(Icons.add_link_rounded, color: AppPalette.indigo),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(msg)),
          if (_isOwn)
            Icon(Icons.chevron_right_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
        ]),
      );

  // ---------------------------------------------------------------- editors
  Future<void> _editSocialLinks() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _SocialEditor(
        initial: {for (final s in _social) s.kind: s.url},
      ),
    );
    final repo = ref.read(leaderboardRepositoryProvider);
    ref.invalidate(mySocialLinksProvider);
    _social = await repo.socialLinks(_uid);
    if (mounted) setState(() {});
  }

  /// "Add" goes straight to the GitHub repo picker; the chosen repo pre-fills a
  /// new project editor. "Enter manually" (or an empty pick) opens a blank one.
  /// Dismissing the picker cancels the whole flow.
  Future<void> _addProject(String githubHandle) async {
    final picked = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _RepoPickerSheet(
        handle: githubHandle,
        onFetch: _fetchRepos,
        allowManual: true,
      ),
    );
    if (picked == null || !mounted) return; // dismissed → cancel
    final seed = picked.isEmpty
        ? null // "Enter manually"
        : ProjectItem(
            id: '',
            title: picked['name'] ?? '',
            description: picked['desc'] ?? '',
            repoUrl: picked['url'] ?? '',
            demoUrl: picked['homepage'] ?? '',
            tech: picked['lang'] ?? '',
          );
    await _editProject(githubHandle, seed: seed);
  }

  Future<void> _editProject(String githubHandle,
      {ProjectItem? existing, ProjectItem? seed}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ProjectEditor(
        existing: existing,
        seed: seed,
        githubHandle: githubHandle,
        onFetchRepos: _fetchRepos,
      ),
    );
    ref.invalidate(myProjectsProvider);
    _projects = await ref.read(leaderboardRepositoryProvider).projects(_uid);
    if (mounted) setState(() {});
  }

  /// Public GitHub repos for the "add from GitHub" picker (client-side).
  ///
  /// Returns an empty list only when the user genuinely has no public repos.
  /// On any failure it throws a [_RepoFetchException] with a user-readable
  /// reason so the picker can surface it instead of showing a silent blank.
  Future<List<Map<String, String>>> _fetchRepos(String handle) async {
    final user = handle.trim();
    if (user.isEmpty) {
      throw const _RepoFetchException(
          'Link your GitHub username first to import repositories.');
    }
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 15);
    try {
      final req = await client.getUrl(Uri.parse(
          'https://api.github.com/users/$user/repos?per_page=100&sort=updated'));
      req.headers.set(HttpHeaders.userAgentHeader, 'PrepPilot');
      req.headers.set(HttpHeaders.acceptHeader, 'application/vnd.github+json');
      final res = await req.close().timeout(const Duration(seconds: 20));
      final body = await res.transform(utf8.decoder).join();
      if (res.statusCode == 404) {
        throw _RepoFetchException('No GitHub user named "$user".');
      }
      if (res.statusCode == 403) {
        throw const _RepoFetchException(
            'GitHub is rate-limiting requests. Try again in a few minutes.');
      }
      if (res.statusCode != 200) {
        throw _RepoFetchException(
            'GitHub returned an error (${res.statusCode}). Please try again.');
      }
      final decoded = jsonDecode(body);
      if (decoded is! List) {
        // GitHub replies with an object (e.g. {"message": ...}) on errors.
        final msg = decoded is Map ? decoded['message'] : null;
        throw _RepoFetchException(msg is String && msg.isNotEmpty
            ? 'GitHub: $msg'
            : 'Could not read repositories from GitHub.');
      }
      decoded.sort((a, b) => ((b['stargazers_count'] ?? 0) as int)
          .compareTo((a['stargazers_count'] ?? 0) as int));
      return [
        for (final r in decoded)
          {
            'name': (r['name'] ?? '') as String,
            'url': (r['html_url'] ?? '') as String,
            'desc': (r['description'] ?? '') as String? ?? '',
            'lang': (r['language'] ?? '') as String? ?? '',
            'homepage': (r['homepage'] ?? '') as String? ?? '',
          },
      ];
    } on SocketException {
      throw const _RepoFetchException(
          'No internet connection. Check your network and try again.');
    } on TimeoutException {
      throw const _RepoFetchException(
          'GitHub took too long to respond. Please try again.');
    } finally {
      client.close();
    }
  }
}

/// A GitHub repo fetch failure carrying a message safe to show the user.
class _RepoFetchException implements Exception {
  const _RepoFetchException(this.message);
  final String message;
  @override
  String toString() => message;
}

// ============================================================ header
class _Header extends StatelessWidget {
  const _Header({
    required this.entry,
    required this.social,
    required this.isOwn,
    required this.onOpenLink,
    this.onEditLinks,
  });
  final LeaderboardEntry? entry;
  final List<SocialLink> social;
  final bool isOwn;
  final void Function(String) onOpenLink;
  final VoidCallback? onEditLinks;

  IconData _iconFor(String kind) => switch (kind) {
        'github' => Icons.code_rounded,
        'linkedin' => Icons.business_center_rounded,
        'x' => Icons.alternate_email_rounded,
        'website' => Icons.language_rounded,
        'email' => Icons.mail_outline_rounded,
        _ => Icons.link_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final name = entry?.name ?? 'Aspirant';
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: AppPalette.brandGradient,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: Colors.white.withValues(alpha: 0.25),
                child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'A',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w800)),
                    if (entry?.college != null && entry!.college!.isNotEmpty)
                      Text(entry!.college!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 11)),
                  ],
                ),
              ),
              Column(children: [
                Text('${entry?.prepScore ?? 0}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900)),
                const Text('Score',
                    style: TextStyle(color: Colors.white70, fontSize: 10)),
              ]),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Icon(Icons.visibility_rounded,
                  size: 14, color: Colors.white.withValues(alpha: 0.8)),
              const SizedBox(width: 4),
              Text('${entry?.profileViews ?? 0} views',
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
              const Spacer(),
              for (final s in social)
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: InkWell(
                    onTap: () => onOpenLink(s.url),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_iconFor(s.kind), size: 15, color: Colors.white),
                    ),
                  ),
                ),
              if (onEditLinks != null)
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: InkWell(
                    onTap: onEditLinks,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(social.isEmpty ? Icons.add_rounded : Icons.edit_rounded,
                          size: 15, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================ small pieces
class _Tile extends StatelessWidget {
  const _Tile(this.label, this.value, this.icon, this.color);
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md, horizontal: AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800)),
                Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, {this.trailing, this.action, this.onAction});
  final String title;
  final String? trailing;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(children: [
      Text(title,
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w800)),
      const Spacer(),
      if (trailing != null)
        Text(trailing!,
            style: theme.textTheme.labelMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      if (action != null && onAction != null)
        TextButton(onPressed: onAction, child: Text(action!)),
    ]);
  }
}

class _PlatformRow extends StatelessWidget {
  const _PlatformRow(this.p);
  final PlatformInfo p;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return AppCard(
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppPalette.indigo.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: const Icon(Icons.code_rounded, color: AppPalette.indigo),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Flexible(
                  child: Text(p.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                ),
                if (p.verified) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.verified_rounded, size: 14, color: scheme.primary),
                ],
              ]),
              Text('@${p.handle}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: scheme.onSurfaceVariant)),
            ],
          ),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${p.solved}',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800)),
          Text(p.rating > 0 ? '${p.rating} rating' : 'solved',
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: scheme.onSurfaceVariant)),
        ]),
      ]),
    );
  }
}

class _ContestRow extends StatelessWidget {
  const _ContestRow(this.c);
  final ContestEntry c;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(c.contest,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              Text(c.platformLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
        if (c.rank != null)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: Text('#${c.rank}',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
        if (c.rating != null)
          Text('${c.rating}',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w800)),
      ]),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard(this.p, {this.onEdit, required this.onOpen});
  final ProjectItem p;
  final VoidCallback? onEdit;
  final void Function(String) onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Text(p.title,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ),
            if (onEdit != null)
              InkWell(
                onTap: onEdit,
                child: Icon(Icons.edit_rounded,
                    size: 18, color: theme.colorScheme.onSurfaceVariant),
              ),
          ]),
          if (p.description != null && p.description!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(p.description!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
          if (p.techList.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final t in p.techList)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(t, style: theme.textTheme.labelSmall),
                  ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Row(children: [
            if (p.repoUrl != null && p.repoUrl!.isNotEmpty)
              TextButton.icon(
                onPressed: () => onOpen(p.repoUrl!),
                icon: const Icon(Icons.code_rounded, size: 16),
                label: const Text('Code'),
                style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8)),
              ),
            if (p.demoUrl != null && p.demoUrl!.isNotEmpty)
              TextButton.icon(
                onPressed: () => onOpen(p.demoUrl!),
                icon: const Icon(Icons.open_in_new_rounded, size: 16),
                label: const Text('Demo'),
                style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8)),
              ),
          ]),
        ],
      ),
    );
  }
}

// ============================================================ social editor
class _SocialEditor extends ConsumerStatefulWidget {
  const _SocialEditor({required this.initial});
  final Map<String, String> initial;

  @override
  ConsumerState<_SocialEditor> createState() => _SocialEditorState();
}

class _SocialEditorState extends ConsumerState<_SocialEditor> {
  static const _kinds = [
    ('github', 'GitHub'),
    ('linkedin', 'LinkedIn'),
    ('x', 'X (Twitter)'),
    ('website', 'Website'),
    ('email', 'Email'),
  ];
  late final Map<String, TextEditingController> _ctls = {
    for (final k in _kinds) k.$1: TextEditingController(text: widget.initial[k.$1] ?? ''),
  };
  bool _saving = false;

  @override
  void dispose() {
    for (final c in _ctls.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final repo = ref.read(leaderboardRepositoryProvider);
    for (final k in _kinds) {
      final v = _ctls[k.$1]!.text.trim();
      final had = widget.initial[k.$1]?.isNotEmpty ?? false;
      if (v.isNotEmpty) {
        await repo.setSocialLink(k.$1, v);
      } else if (had) {
        await repo.removeSocialLink(k.$1);
      }
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: media.size.height * 0.9),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: AppSpacing.xl,
            right: AppSpacing.xl,
            top: AppSpacing.lg,
            bottom: media.viewInsets.bottom + AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Profile links',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: AppSpacing.md),
              for (final k in _kinds)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: TextField(
                    controller: _ctls[k.$1],
                    keyboardType: k.$1 == 'email'
                        ? TextInputType.emailAddress
                        : TextInputType.url,
                    decoration: InputDecoration(labelText: k.$2),
                  ),
                ),
              const SizedBox(height: AppSpacing.sm),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: Text(_saving ? 'Saving…' : 'Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================ project editor
class _ProjectEditor extends ConsumerStatefulWidget {
  const _ProjectEditor({
    required this.githubHandle,
    required this.onFetchRepos,
    this.existing,
    this.seed,
  });
  final String githubHandle;
  final Future<List<Map<String, String>>> Function(String) onFetchRepos;
  final ProjectItem? existing;

  /// Pre-fill values for a brand-new project (e.g. picked from GitHub). Unlike
  /// [existing] it does not turn the sheet into an edit of a saved record.
  final ProjectItem? seed;

  @override
  ConsumerState<_ProjectEditor> createState() => _ProjectEditorState();
}

class _ProjectEditorState extends ConsumerState<_ProjectEditor> {
  ProjectItem? get _init => widget.existing ?? widget.seed;
  late final _title = TextEditingController(text: _init?.title ?? '');
  late final _desc = TextEditingController(text: _init?.description ?? '');
  late final _repo = TextEditingController(text: _init?.repoUrl ?? '');
  late final _demo = TextEditingController(text: _init?.demoUrl ?? '');
  late final _tech = TextEditingController(text: _init?.tech ?? '');
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_title, _desc, _repo, _demo, _tech]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickFromGithub() async {
    final picked = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _RepoPickerSheet(
        handle: widget.githubHandle,
        onFetch: widget.onFetchRepos,
      ),
    );
    if (picked != null && mounted) {
      setState(() {
        _title.text = picked['name'] ?? _title.text;
        if (_desc.text.isEmpty) _desc.text = picked['desc'] ?? '';
        _repo.text = picked['url'] ?? _repo.text;
        if ((picked['homepage'] ?? '').isNotEmpty) _demo.text = picked['homepage']!;
        if (_tech.text.isEmpty && (picked['lang'] ?? '').isNotEmpty) {
          _tech.text = picked['lang']!;
        }
      });
    }
  }

  void _toast(String m) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
    }
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty) {
      _toast('Give your project a title');
      return;
    }
    setState(() => _saving = true);
    final repo = ref.read(leaderboardRepositoryProvider);
    final p = ProjectItem(
      id: widget.existing?.id ?? '',
      title: _title.text.trim(),
      description: _desc.text.trim(),
      repoUrl: _repo.text.trim(),
      demoUrl: _demo.text.trim(),
      tech: _tech.text.trim(),
      orderIndex: widget.existing?.orderIndex ?? 0,
    );
    try {
      if (widget.existing == null) {
        await repo.addProject(p);
      } else {
        await repo.updateProject(p);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) setState(() => _saving = false);
      _toast('Could not save project: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    // Mirror _RepoPickerSheet's layout (which renders reliably in this sheet):
    // a min-height stretch column with a fixed header and a Flexible scroll body.
    // Everything sits under a maxHeight bound so the sheet never grows unbounded.
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: media.size.height * 0.9),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl, AppSpacing.lg, AppSpacing.sm, 0),
              child: Row(children: [
                Expanded(
                  child: Text(
                      widget.existing == null ? 'Add project' : 'Edit project',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800)),
                ),
                TextButton.icon(
                  onPressed: _pickFromGithub,
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: const Text('From GitHub'),
                ),
              ]),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: AppSpacing.xl,
                  right: AppSpacing.xl,
                  top: AppSpacing.sm,
                  bottom: media.viewInsets.bottom + AppSpacing.xl,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(controller: _title, decoration: const InputDecoration(labelText: 'Title')),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(controller: _desc, maxLines: 2, decoration: const InputDecoration(labelText: 'Description')),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(controller: _repo, decoration: const InputDecoration(labelText: 'Repo URL')),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(controller: _demo, decoration: const InputDecoration(labelText: 'Demo URL')),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(controller: _tech, decoration: const InputDecoration(labelText: 'Tech (comma-separated)')),
                    const SizedBox(height: AppSpacing.md),
                    // Full-width Save as a direct child of the stretch column.
                    // The app theme gives FilledButton minimumSize
                    // Size.fromHeight(54) — an *infinite* min width — so the
                    // button must always be laid out with a bounded width. A
                    // stretch column child gets a tight width; a plain Row child
                    // would get unbounded width and throw "infinite width".
                    FilledButton(
                      onPressed: _saving ? null : _save,
                      child: Text(_saving ? 'Saving…' : 'Save'),
                    ),
                    if (widget.existing != null)
                      TextButton(
                        onPressed: () async {
                          await ref
                              .read(leaderboardRepositoryProvider)
                              .deleteProject(widget.existing!.id);
                          if (context.mounted) Navigator.pop(context);
                        },
                        child: const Text('Delete'),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========================================================= repo picker sheet
/// Self-contained "import from GitHub" sheet. It owns its own load/error/empty
/// states so the sheet always shows content — a spinner, a readable error with
/// Retry, an empty note, or the tappable repo list — instead of a blank scrim.
class _RepoPickerSheet extends StatefulWidget {
  const _RepoPickerSheet({
    required this.handle,
    required this.onFetch,
    this.allowManual = false,
  });
  final String handle;
  final Future<List<Map<String, String>>> Function(String) onFetch;

  /// When true, offers an "Enter manually" action that pops an empty map so the
  /// caller can open a blank editor instead of importing a repo.
  final bool allowManual;

  @override
  State<_RepoPickerSheet> createState() => _RepoPickerSheetState();
}

class _RepoPickerSheetState extends State<_RepoPickerSheet> {
  late Future<List<Map<String, String>>> _future = widget.onFetch(widget.handle);

  void _retry() => setState(() => _future = widget.onFetch(widget.handle));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final media = MediaQuery.of(context);
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: media.size.height * 0.7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.md, AppSpacing.sm, AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Pick a repository',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800)),
                  ),
                  if (widget.allowManual)
                    TextButton(
                      onPressed: () => Navigator.pop(context, <String, String>{}),
                      child: const Text('Enter manually'),
                    ),
                ],
              ),
            ),
            Flexible(
              child: FutureBuilder<List<Map<String, String>>>(
                future: _future,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const Padding(
                      padding: EdgeInsets.all(AppSpacing.huge),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snap.hasError) {
                    return _message(theme,
                        icon: Icons.error_outline_rounded,
                        text: '${snap.error}',
                        onRetry: _retry);
                  }
                  final repos = snap.data ?? const [];
                  if (repos.isEmpty) {
                    return _message(theme,
                        icon: Icons.folder_off_rounded,
                        text: 'No public repositories found for '
                            '@${widget.handle}.',
                        onRetry: _retry);
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    itemCount: repos.length,
                    itemBuilder: (context, i) {
                      final r = repos[i];
                      final lang = r['lang'] ?? '';
                      final desc = r['desc'] ?? '';
                      final sub = [
                        if (lang.isNotEmpty) lang,
                        if (desc.isNotEmpty) desc,
                      ].join(' · ');
                      return ListTile(
                        dense: true,
                        title: Text(r['name'] ?? '',
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: sub.isEmpty
                            ? null
                            : Text(sub,
                                maxLines: 2, overflow: TextOverflow.ellipsis),
                        onTap: () => Navigator.pop(context, r),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _message(ThemeData theme,
      {required IconData icon, required String text, VoidCallback? onRetry}) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: AppSpacing.md),
          Text(text,
              textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
          if (onRetry != null) ...[
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}
