import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/entrance.dart';
import '../../providers/providers.dart';
import 'prep_tracks.dart';

/// One-tap preparation tracks: applying one sets the role, daily goal, active
/// sheets + primary, and regenerates the roadmap.
class TracksScreen extends ConsumerWidget {
  const TracksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final sheets = ref.watch(sheetsProvider).valueOrNull ?? const [];
    final userSheets = ref.watch(userSheetsProvider).valueOrNull ?? const [];
    final primaryId =
        userSheets.where((u) => u.isPrimary).map((u) => u.sheetId).firstOrNull;
    final primarySlug =
        sheets.where((s) => s.id == primaryId).map((s) => s.slug).firstOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Prep Tracks')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, AppSpacing.md,
            AppSpacing.screenH, AppSpacing.huge),
        children: [
          Text(
            'Pick a track to instantly set your sheets, daily goal and roadmap for that path. You can fine-tune everything afterwards in My Sheets.',
            style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (var i = 0; i < kPrepTracks.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _TrackCard(
                track: kPrepTracks[i],
                isCurrent: kPrepTracks[i].primarySlug == primarySlug,
                onApply: () => _confirmAndApply(context, ref, kPrepTracks[i]),
              ).entrance(index: i),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmAndApply(
      BuildContext context, WidgetRef ref, PrepTrack track) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Switch to ${track.name}?'),
        content: Text(
            'This sets your active sheets, primary sheet and daily goal for this track, and regenerates your roadmap. Your problem progress is kept.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Apply')),
        ],
      ),
    );
    if (ok != true) return;

    final sheets = ref.read(sheetsProvider).valueOrNull ?? const [];
    final bySlug = {for (final s in sheets) s.slug: s.id};
    final prep = ref.read(prepRepositoryProvider);
    final profileRepo = ref.read(profileRepositoryProvider);

    await profileRepo.applyTrackPlan(
      role: track.role.name,
      minutes: track.dailyMinutes,
      problems: track.dailyProblems,
    );
    for (final s in sheets) {
      await prep.setSheetActive(s.id, track.activeSlugs.contains(s.slug));
    }
    final primaryId = bySlug[track.primarySlug];
    if (primaryId != null) await prep.setPrimarySheet(primaryId);
    final profile = await profileRepo.get();
    await ref.read(roadmapRepositoryProvider).generate(profile);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${track.name} track applied — roadmap updated')),
      );
      Navigator.of(context).pop();
    }
  }
}

class _TrackCard extends StatelessWidget {
  const _TrackCard({
    required this.track,
    required this.isCurrent,
    required this.onApply,
  });
  final PrepTrack track;
  final bool isCurrent;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      onTap: onApply,
      borderColor: isCurrent ? track.color : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: track.color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(track.icon, color: track.color),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(track.name,
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800)),
                        if (isCurrent) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: track.color,
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                            ),
                            child: const Text('CURRENT',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800)),
                          ),
                        ],
                      ],
                    ),
                    Text(track.tagline,
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(track.description, style: theme.textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _pill(context, Icons.flag_rounded,
                  '${track.dailyProblems}/day · ${track.dailyMinutes}m'),
              const SizedBox(width: AppSpacing.sm),
              _pill(context, Icons.star_rounded, _primaryName(track.primarySlug)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pill(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(label,
              style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  String _primaryName(String slug) => switch (slug) {
        'striver-a2z' => 'A2Z',
        'striver-sde' => 'SDE Sheet',
        'striver-sde79' => 'SDE-79',
        'striver-cp' => 'CP Sheet',
        'apna-college' => 'Apna College',
        'love-babbar' => 'Love Babbar',
        'arsh-goyal' => 'Arsh Goyal',
        _ => slug,
      };
}
