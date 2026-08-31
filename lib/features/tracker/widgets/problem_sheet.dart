import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/enums.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/pill.dart';
import '../../../data/models/dtos.dart';
import '../../../providers/providers.dart';
import '../../study/study_actions.dart';
import '../../study/study_links.dart';
import '../../study/study_models.dart';

Future<void> showLeafSheet(BuildContext context, WidgetRef ref, LeafRow row) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => _LeafSheet(slug: row.node.slug),
  );
}

class _LeafSheet extends ConsumerStatefulWidget {
  const _LeafSheet({required this.slug});
  final String slug;

  @override
  ConsumerState<_LeafSheet> createState() => _LeafSheetState();
}

class _LeafSheetState extends ConsumerState<_LeafSheet> {
  final _noteController = TextEditingController();
  bool _noteInit = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final row = ref
        .watch(leafRowsProvider)
        .where((r) => r.node.slug == widget.slug)
        .firstOrNull;
    if (row == null) return const SizedBox.shrink();

    if (!_noteInit) {
      _noteInit = true;
      _noteController.text = row.progress?.note ?? '';
    }
    final repo = ref.read(prepRepositoryProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        top: AppSpacing.sm,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(row.node.title,
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700)),
              ),
              IconButton(
                onPressed: () => repo.toggleBookmark(row.canon),
                icon: Icon(
                  row.isBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_outline_rounded,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              if (!row.isConcept)
                Pill(label: row.difficulty.label, color: row.difficulty.color),
              const SizedBox(width: 8),
              Pill(label: row.category.label, color: row.category.color),
              const SizedBox(width: 8),
              Text(row.sectionTitle,
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          _StudySection(row: row),
          Text('Status', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: row.isConcept
                ? [
                    for (final s in ConceptStatus.values)
                      _StatusChip(
                        label: s.label,
                        icon: s.icon,
                        color: s.color(context),
                        selected: row.conceptStatus == s,
                        onTap: () => repo.setLeafStatus(row.canon, s.name),
                      ),
                  ]
                : [
                    for (final s in ProblemStatus.values)
                      _StatusChip(
                        label: s.label,
                        icon: s.icon,
                        color: s.color(context),
                        selected: row.problemStatus == s,
                        onTap: () => repo.setLeafStatus(row.canon, s.name),
                      ),
                  ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Notes', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _noteController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Approach, edge cases, complexity…',
            ),
            onChanged: (v) => repo.saveNote(row.canon, v),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (row.progress?.nextReviewAt != null)
            Row(
              children: [
                Icon(Icons.event_repeat_rounded,
                    size: 16, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Text('Next revision scheduled',
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
        ],
      ),
    );
  }
}

/// The "Study" block inside the leaf detail sheet: ad-gated Notes + Quiz
/// actions when authored content exists, plus always-available Google/ChatGPT
/// study links.
class _StudySection extends ConsumerWidget {
  const _StudySection({required this.row});
  final LeafRow row;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final accent = row.category.color;
    final StudyEntry? entry = ref.watch(studyByCanonProvider).entry(row.canon);
    final result = ref.watch(quizResultsProvider)[row.canon];
    final gate = ref.watch(adGateProvider);
    final locked = entry != null &&
        (!gate.isUnlocked('note:${row.canon}') ||
            !gate.isUnlocked('quiz:${row.canon}'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Study', style: theme.textTheme.titleSmall),
            if (entry != null && locked) ...[
              const SizedBox(width: AppSpacing.sm),
              Icon(Icons.play_circle_outline_rounded,
                  size: 14, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 3),
              Text('unlock with a short ad',
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (entry != null && (entry.hasNote || entry.hasQuiz)) ...[
          Row(
            children: [
              if (entry.hasNote)
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: accent,
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    ),
                    onPressed: () =>
                        openStudyNotes(context, ref, row, entry, accent),
                    icon: const Icon(Icons.menu_book_rounded, size: 18),
                    label: const Text('Read notes'),
                  ),
                ),
              if (entry.hasNote && entry.hasQuiz)
                const SizedBox(width: AppSpacing.md),
              if (entry.hasQuiz)
                Expanded(
                  child: FilledButton.tonalIcon(
                    style: FilledButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    ),
                    onPressed: () =>
                        openStudyQuiz(context, ref, row, entry, accent),
                    icon: const Icon(Icons.quiz_rounded, size: 18),
                    label: Text(result == null
                        ? 'Quiz'
                        : 'Quiz ${result.best}/${result.total}'),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
        ] else
          const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            _LinkChip(
              icon: Icons.search_rounded,
              label: 'Google',
              onTap: () => StudyLinks.open(context,
                  StudyLinks.google(row.node.title, subject: row.category.label)),
            ),
            const SizedBox(width: AppSpacing.sm),
            _LinkChip(
              icon: Icons.auto_awesome_rounded,
              label: 'Ask ChatGPT',
              onTap: () => StudyLinks.open(context,
                  StudyLinks.chatgpt(row.node.title, subject: row.category.label)),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

class _LinkChip extends StatelessWidget {
  const _LinkChip(
      {required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: scheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: selected ? color : scheme.surfaceContainer,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: selected ? color : scheme.outline),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: selected ? Colors.white : color),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : scheme.onSurface)),
          ],
        ),
      ),
    );
  }
}
