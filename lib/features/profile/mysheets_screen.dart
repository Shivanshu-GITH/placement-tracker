import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/enums.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/widgets/app_card.dart';
import '../../data/models/dtos.dart';
import '../../providers/providers.dart';

/// Lets the user choose which sheets are active and which DSA sheet is primary.
class MySheetsScreen extends ConsumerWidget {
  const MySheetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaries = ref.watch(sheetSummariesProvider);
    final userSheets = ref.watch(userSheetsProvider).valueOrNull ?? const [];
    final primaryId =
        userSheets.where((u) => u.isPrimary).map((u) => u.sheetId).firstOrNull;
    final repo = ref.read(prepRepositoryProvider);

    // Group by category, in enum order.
    final byCat = <PrepCategory, List<SheetSummary>>{};
    for (final s in summaries) {
      byCat.putIfAbsent(s.category, () => []).add(s);
    }
    final cats = PrepCategory.values.where(byCat.containsKey).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('My Sheets')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, AppSpacing.md,
            AppSpacing.screenH, AppSpacing.huge),
        children: [
          Text(
            'Pick the sheets you\'ll actually work on. Your progress, dashboard and roadmap only count active sheets.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final cat in cats) ...[
            Padding(
              padding: const EdgeInsets.only(
                  left: 4, bottom: AppSpacing.sm, top: AppSpacing.sm),
              child: Row(
                children: [
                  Icon(cat.icon, size: 18, color: cat.color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(cat.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (final s in byCat[cat]!)
                    _SheetRow(
                      summary: s,
                      isPrimary: s.sheet.id == primaryId,
                      isDsa: cat == PrepCategory.dsa,
                      onToggle: (v) => repo.setSheetActive(s.sheet.id, v),
                      onSetPrimary: () => repo.setPrimarySheet(s.sheet.id),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}

class _SheetRow extends StatelessWidget {
  const _SheetRow({
    required this.summary,
    required this.isPrimary,
    required this.isDsa,
    required this.onToggle,
    required this.onSetPrimary,
  });
  final SheetSummary summary;
  final bool isPrimary;
  final bool isDsa;
  final ValueChanged<bool> onToggle;
  final VoidCallback onSetPrimary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(summary.sheet.title,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    Text('${summary.total} items',
                        style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              Switch(value: summary.active, onChanged: onToggle),
            ],
          ),
          // Primary selector for active DSA sheets.
          if (isDsa && summary.active)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: isPrimary ? null : onSetPrimary,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
                icon: Icon(
                  isPrimary
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  size: 18,
                  color: isPrimary
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                label: Text(isPrimary ? 'Primary (drives roadmap)' : 'Set as primary',
                    style: theme.textTheme.labelMedium?.copyWith(
                        color: isPrimary
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant)),
              ),
            ),
        ],
      ),
    );
  }
}
