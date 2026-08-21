import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_palette.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/entrance.dart';
import '../../providers/providers.dart';
import 'sheet_detail_screen.dart' show LeafTile;

String _titleCase(String s) => s
    .split(' ')
    .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
    .join(' ');

/// Lists companies (from tagged problems in active sheets) with counts.
class CompaniesScreen extends ConsumerWidget {
  const CompaniesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counts = ref.watch(companyCountsProvider);
    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(title: const Text('By Company')),
      body: entries.isEmpty
          ? const EmptyState(
              icon: Icons.business_rounded,
              title: 'No company tags yet',
              message:
                  'Activate a company-tagged sheet (Arsh Goyal or Apna College) in My Sheets to prep by company.',
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenH,
                  AppSpacing.md, AppSpacing.screenH, AppSpacing.huge),
              itemCount: entries.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, i) {
                final e = entries[i];
                return AppCard(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => CompanyProblemsScreen(company: e.key))),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppPalette.indigo.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: const Icon(Icons.business_rounded,
                            color: AppPalette.indigo),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(_titleCase(e.key),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700)),
                      ),
                      Text('${e.value}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(width: 4),
                      Icon(Icons.chevron_right_rounded,
                          color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ],
                  ),
                ).entrance(index: i);
              },
            ),
    );
  }
}

/// Shows the problems tagged with a given company (from active sheets).
class CompanyProblemsScreen extends ConsumerWidget {
  const CompanyProblemsScreen({super.key, required this.company});
  final String company;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rows = ref.watch(activeLeafRowsProvider).where((r) {
      final c = r.node.companies;
      if (c.isEmpty) return false;
      return c.split(',').map((e) => e.trim()).contains(company);
    }).toList();
    final done = rows.where((r) => r.isDone).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(_titleCase(company)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(28),
          child: Padding(
            padding: const EdgeInsets.only(
                left: AppSpacing.lg, bottom: AppSpacing.sm),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('$done / ${rows.length} done',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ),
          ),
        ),
      ),
      body: rows.isEmpty
          ? const EmptyState(
              icon: Icons.business_rounded, title: 'No problems found')
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenH,
                  AppSpacing.md, AppSpacing.screenH, AppSpacing.huge),
              itemCount: rows.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, i) => LeafTile(row: rows[i]),
            ),
    );
  }
}
