import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_palette.dart';
import '../../providers/providers.dart';
import 'leaderboard_models.dart';

/// A shareable image card of the user's PrepPilot profile (score + verified
/// platforms) — exportable to WhatsApp / LinkedIn / Instagram for growth.
class ShareCardScreen extends ConsumerStatefulWidget {
  const ShareCardScreen({super.key});

  @override
  ConsumerState<ShareCardScreen> createState() => _ShareCardScreenState();
}

class _ShareCardScreenState extends ConsumerState<ShareCardScreen> {
  final _cardKey = GlobalKey();
  bool _sharing = false;

  Future<void> _share() async {
    setState(() => _sharing = true);
    try {
      final boundary =
          _cardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) throw 'Could not render card';
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/preppilot_card.png');
      await file.writeAsBytes(bytes.buffer.asUint8List());
      await SharePlus.instance.share(ShareParams(
        files: [XFile(file.path)],
        text: 'My coding prep on PrepPilot 🚀',
      ));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not share: $e')));
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = ref.watch(profileProvider).valueOrNull;
    final lbId = ref.watch(lbIdentityProvider).valueOrNull;
    final meAsync = ref.watch(myEntryProvider);
    final platformsAsync = ref.watch(myPlatformsProvider);

    // On a cold start these are still in flight. Rendering the card early shows
    // a problem-only layout that visibly re-flows into the full card a second
    // later, so hold the placeholder until the real numbers are in.
    final loading = meAsync.isLoading || platformsAsync.isLoading;

    final me = meAsync.valueOrNull;
    final platforms = platformsAsync.valueOrNull ?? const <PlatformInfo>[];
    final verified = platforms.where((p) => p.verified).toList();

    final name = lbId?.name ?? profile?.name ?? 'Aspirant';
    final college = lbId?.college;
    final score = me?.prepScore ?? 0;
    final solved =
        me?.verifiedSolved ?? platforms.fold<int>(0, (s, p) => s + p.solved);
    final rating = me?.rating ??
        platforms.fold<int>(0, (s, p) => p.rating > s ? p.rating : s);
    final streak = me?.extStreak ??
        platforms.fold<int>(0, (s, p) => p.streak > s ? p.streak : s);
    PlatformInfo? gh;
    for (final p in platforms) {
      if (p.isDev) gh = p;
    }
    final contributions = gh?.contributions ?? 0;
    final stars = gh?.stars ?? 0;
    final repos = gh?.repos ?? 0;
    final hasDev = gh != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Share card'),
        titleTextStyle: theme.textTheme.headlineSmall,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: loading
                  ? const CircularProgressIndicator()
                  : Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: RepaintBoundary(
                        key: _cardKey,
                        child: _Card(
                          name: name,
                          college: college,
                          score: score,
                          solved: solved,
                          rating: rating,
                          streak: streak,
                          hasDev: hasDev,
                          contributions: contributions,
                          stars: stars,
                          repos: repos,
                          platforms: [for (final p in verified) p.label],
                        ),
                      ),
                    ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl,
                  AppSpacing.lg),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  // Can't capture a card that hasn't rendered yet.
                  onPressed: (_sharing || loading) ? null : _share,
                  icon: _sharing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.4, color: Colors.white))
                      : const Icon(Icons.share_rounded),
                  label: const Text('Share my card'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.name,
    required this.college,
    required this.score,
    required this.solved,
    required this.rating,
    required this.streak,
    required this.hasDev,
    required this.contributions,
    required this.stars,
    required this.repos,
    required this.platforms,
  });
  final String name;
  final String? college;
  final int score;
  final int solved;
  final int rating;
  final int streak;
  final bool hasDev;
  final int contributions;
  final int stars;
  final int repos;
  final List<String> platforms;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: AppPalette.brandGradient,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🚀', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 6),
              Text('PrepPilot',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: const Text('Verified',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800)),
          if (college != null && college!.isNotEmpty)
            Text(college!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: AppSpacing.xl),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$score',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 52,
                      fontWeight: FontWeight.w900,
                      height: 1)),
              const SizedBox(width: 6),
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text('PrepPilot\nScore',
                    style: TextStyle(color: Colors.white70, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Text('PROBLEM SOLVING',
              style: TextStyle(
                  color: Colors.white60, fontSize: 9, letterSpacing: 1.2)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Stat(value: '$solved', label: 'Solved'),
              _Stat(value: rating > 0 ? '$rating' : '—', label: 'Rating'),
              _Stat(value: streak > 0 ? '${streak}d' : '—', label: 'Streak'),
            ],
          ),
          if (hasDev) ...[
            const SizedBox(height: AppSpacing.md),
            const Text('DEVELOPMENT',
                style: TextStyle(
                    color: Colors.white60, fontSize: 9, letterSpacing: 1.2)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Stat(value: '$contributions', label: 'Contribs'),
                _Stat(value: '$stars', label: 'Stars'),
                _Stat(value: '$repos', label: 'Repos'),
              ],
            ),
          ],
          if (platforms.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final p in platforms)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(p,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: AppSpacing.sm),
          const Text('Track your placement prep on PrepPilot',
              style: TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800)),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}
