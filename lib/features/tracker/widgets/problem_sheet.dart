import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/enums.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/pill.dart';
import '../../../data/models/dtos.dart';
import '../../../providers/providers.dart';

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
