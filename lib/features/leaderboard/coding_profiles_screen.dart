import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_palette.dart';
import '../../core/widgets/app_card.dart';
import '../../providers/providers.dart';
import 'leaderboard_models.dart';

const _supported = [
  ('leetcode', 'LeetCode', 'name or summary'),
  ('codeforces', 'Codeforces', 'first name or organization'),
  ('atcoder', 'AtCoder', 'affiliation'),
  ('geeksforgeeks', 'GeeksforGeeks', 'display name'),
  ('codechef', 'CodeChef', 'name'),
];

// Development platforms (GitHub) — separate section, dev stats not solved counts.
const _devSupported = [
  ('github', 'GitHub', 'bio'),
];

class CodingProfilesScreen extends ConsumerStatefulWidget {
  const CodingProfilesScreen({super.key});

  @override
  ConsumerState<CodingProfilesScreen> createState() =>
      _CodingProfilesScreenState();
}

class _CodingProfilesScreenState extends ConsumerState<CodingProfilesScreen> {
  List<PlatformInfo> _platforms = const [];
  final Map<String, String> _tokens = {}; // platform -> just-generated token
  bool _loading = true;
  String? _busyPlatform;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await ref.read(leaderboardRepositoryProvider).myPlatforms();
    if (!mounted) return;
    setState(() {
      _platforms = p;
      _loading = false;
    });
  }

  PlatformInfo? _infoFor(String platform) {
    for (final p in _platforms) {
      if (p.platform == platform) return p;
    }
    return null;
  }

  Future<void> _link(String platform, String label) async {
    final handle = await _askHandle(label);
    if (handle == null || handle.trim().isEmpty) return;
    setState(() => _busyPlatform = platform);
    try {
      final token = await ref
          .read(leaderboardRepositoryProvider)
          .linkPlatform(platform, handle.trim());
      _tokens[platform] = token;
      // Store the handle locally by reloading (link row now exists).
      await _load();
    } catch (e) {
      _toast('Could not link: $e');
    } finally {
      if (mounted) setState(() => _busyPlatform = null);
    }
  }

  Future<void> _verify(String platform, String handle) async {
    setState(() => _busyPlatform = platform);
    try {
      final res = await ref
          .read(leaderboardRepositoryProvider)
          .verifyPlatform(platform, handle);
      if (res.verified) {
        _toast(platform == 'github'
            ? 'Verified! GitHub synced 🎉'
            : 'Verified! ${res.solved} solved synced 🎉');
        ref.invalidate(boardPoolProvider);
        await _load();
      } else {
        _toast(res.error ?? 'Not verified yet — add the token and retry.');
      }
    } finally {
      if (mounted) setState(() => _busyPlatform = null);
    }
  }

  Future<void> _unlink(String platform) async {
    setState(() => _busyPlatform = platform);
    try {
      await ref.read(leaderboardRepositoryProvider).unlinkPlatform(platform);
      _tokens.remove(platform);
      ref.invalidate(boardPoolProvider);
      await _load();
    } finally {
      if (mounted) setState(() => _busyPlatform = null);
    }
  }

  Future<String?> _askHandle(String label) => showDialog<String>(
        context: context,
        builder: (_) => _HandleDialog(label: label),
      );

  void _toast(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final signedIn = ref.watch(authUserProvider).valueOrNull != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Coding profiles'),
        titleTextStyle: theme.textTheme.headlineSmall,
      ),
      body: !signedIn
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Text('Sign up to link your coding profiles.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge),
              ),
            )
          : _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.screenH,
                      AppSpacing.md, AppSpacing.screenH, AppSpacing.huge),
                  children: [
                    Text(
                      'Link your coding accounts to appear on the verified '
                      'leaderboard. We pull your real solved count & rating — '
                      'not self-reported numbers.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _SectionLabel('PROBLEM SOLVING'),
                    for (final (id, label, field) in _supported) ...[
                      _PlatformCard(
                        id: id,
                        label: label,
                        field: field,
                        info: _infoFor(id),
                        token: _tokens[id],
                        busy: _busyPlatform == id,
                        onLink: () => _link(id, label),
                        onVerify: (h) => _verify(id, h),
                        onUnlink: () => _unlink(id),
                        onCopyToken: (t) {
                          Clipboard.setData(ClipboardData(text: t));
                          _toast('Token copied');
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    _SectionLabel('DEVELOPMENT'),
                    for (final (id, label, field) in _devSupported) ...[
                      _PlatformCard(
                        id: id,
                        label: label,
                        field: field,
                        info: _infoFor(id),
                        token: _tokens[id],
                        busy: _busyPlatform == id,
                        onLink: () => _link(id, label),
                        onVerify: (h) => _verify(id, h),
                        onUnlink: () => _unlink(id),
                        onCopyToken: (t) {
                          Clipboard.setData(ClipboardData(text: t));
                          _toast('Token copied');
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                  ],
                ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: AppSpacing.sm),
      child: Text(text,
          style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant, letterSpacing: 1)),
    );
  }
}

class _PlatformCard extends StatelessWidget {
  const _PlatformCard({
    required this.id,
    required this.label,
    required this.field,
    required this.info,
    required this.token,
    required this.busy,
    required this.onLink,
    required this.onVerify,
    required this.onUnlink,
    required this.onCopyToken,
  });
  final String id;
  final String label;
  final String field;
  final PlatformInfo? info;
  final String? token;
  final bool busy;
  final VoidCallback onLink;
  final void Function(String handle) onVerify;
  final VoidCallback onUnlink;
  final void Function(String token) onCopyToken;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final linked = info != null;
    final verified = info?.verified ?? false;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.code_rounded, color: scheme.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(label,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800)),
              const Spacer(),
              if (verified)
                Row(children: [
                  Icon(Icons.verified_rounded,
                      size: 18, color: scheme.primary),
                  const SizedBox(width: 4),
                  Text('Verified',
                      style: theme.textTheme.labelMedium?.copyWith(
                          color: scheme.primary, fontWeight: FontWeight.w700)),
                ]),
            ],
          ),
          if (!linked) ...[
            const SizedBox(height: AppSpacing.sm),
            Text('Not linked',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: scheme.onSurfaceVariant)),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: busy ? null : onLink,
                child: busy
                    ? const _Spin()
                    : Text('Link $label'),
              ),
            ),
          ] else ...[
            const SizedBox(height: AppSpacing.sm),
            Text('@${info!.handle}',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600)),
            if (verified) ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                children: info!.isDev
                    ? [
                        _Stat(label: 'Repos', value: '${info!.repos}'),
                        _Stat(label: 'Stars', value: '${info!.stars}'),
                        _Stat(
                            label: 'Commits',
                            value: '${info!.contributions}'),
                        if (info!.streak > 0)
                          _Stat(label: 'Streak', value: '${info!.streak}d'),
                      ]
                    : [
                        _Stat(label: 'Solved', value: '${info!.solved}'),
                        if (info!.rating > 0)
                          _Stat(label: 'Rating', value: '${info!.rating}'),
                        if (info!.streak > 0)
                          _Stat(label: 'Streak', value: '${info!.streak}d'),
                      ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: busy ? null : () => onVerify(info!.handle),
                      icon: busy
                          ? const _Spin()
                          : const Icon(Icons.sync_rounded, size: 18),
                      label: const Text('Re-sync'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  IconButton(
                    onPressed: busy ? null : onUnlink,
                    icon: const Icon(Icons.link_off_rounded),
                    tooltip: 'Unlink',
                  ),
                ],
              ),
            ] else ...[
              // Linked, awaiting verification.
              const SizedBox(height: AppSpacing.md),
              if (token != null) ...[
                Text('1. Temporarily set your $label $field to this exact '
                    'token (replace what\'s there):',
                    style: theme.textTheme.bodySmall),
                const SizedBox(height: 6),
                InkWell(
                  onTap: () => onCopyToken(token!),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(token!,
                              style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'monospace')),
                        ),
                        Icon(Icons.copy_rounded,
                            size: 18, color: scheme.onSurfaceVariant),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text('2. Save your profile, then tap Verify. Once verified you '
                    'can restore your $field — you stay verified.',
                    style: theme.textTheme.bodySmall),
              ] else
                Text(
                    'Tap "Get token" to receive a verification code to place in '
                    'your $label profile.',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant)),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: busy
                          ? null
                          : (token != null
                              ? () => onVerify(info!.handle)
                              : onLink),
                      child: busy
                          ? const _Spin()
                          : Text(token != null ? 'Verify' : 'Get token'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  IconButton(
                    onPressed: busy ? null : onUnlink,
                    icon: const Icon(Icons.link_off_rounded),
                    tooltip: 'Unlink',
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800, color: AppPalette.indigo)),
          Text(label,
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _Spin extends StatelessWidget {
  const _Spin();
  @override
  Widget build(BuildContext context) => const SizedBox(
      width: 18,
      height: 18,
      child: CircularProgressIndicator(strokeWidth: 2.3, color: Colors.white));
}


/// Owns its own controller so it is disposed when the dialog route actually
/// leaves the tree. Disposing in a `finally` around `showDialog` is too early:
/// that future completes when the pop *starts*, while the dialog is still
/// animating out and rebuilding against the controller.
class _HandleDialog extends StatefulWidget {
  const _HandleDialog({required this.label});
  final String label;

  @override
  State<_HandleDialog> createState() => _HandleDialogState();
}

class _HandleDialogState extends State<_HandleDialog> {
  final _ctl = TextEditingController();

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Link ${widget.label}'),
      content: TextField(
        controller: _ctl,
        autofocus: true,
        decoration: InputDecoration(hintText: 'Your ${widget.label} username'),
        onSubmitted: (v) => Navigator.pop(context, v),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
            onPressed: () => Navigator.pop(context, _ctl.text),
            child: const Text('Continue')),
      ],
    );
  }
}
