import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/enums.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/entrance.dart';
import '../../core/widgets/filter_bar.dart';
import '../../core/widgets/pill.dart';
import '../../core/widgets/progress_ring.dart';
import '../../data/models/dtos.dart';
import '../../providers/providers.dart';
import 'companies_screen.dart';
import 'sheet_detail_screen.dart';

class TrackerScreen extends ConsumerStatefulWidget {
  const TrackerScreen({super.key});

  @override
  ConsumerState<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends ConsumerState<TrackerScreen> {
  PrepCategory? _filter;
  bool _activeOnly = true;

  /// True once the sheet list has scrolled under the filter header, which then
  /// grows a hairline so the cards don't look joined to it.
  bool _scrolled = false;

  @override
  Widget build(BuildContext context) {
    final summaries = ref.watch(sheetSummariesProvider);
    final scoped =
        _activeOnly ? summaries.where((s) => s.active).toList() : summaries;
    final filtered = _filter == null
        ? scoped
        : scoped.where((s) => s.category == _filter).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracker'),
        titleTextStyle: Theme.of(context).textTheme.headlineSmall,
        actions: [
          IconButton(
            tooltip: 'By company',
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const CompaniesScreen())),
            icon: const Icon(Icons.business_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          ScrolledUnderHeader(
            scrolled: _scrolled,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenH, 0, AppSpacing.screenH, AppSpacing.sm),
                  child: SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: true, label: Text('My sheets')),
                      ButtonSegment(value: false, label: Text('All sheets')),
                    ],
                    selected: {_activeOnly},
                    onSelectionChanged: (s) =>
                        setState(() => _activeOnly = s.first),
                    showSelectedIcon: false,
                  ),
                ),
                _CategoryFilter(
                  selected: _filter,
                  onSelect: (c) => setState(() => _filter = c),
                ),
              ],
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? _EmptyTracker(activeOnly: _activeOnly)
                : ScrollAwareHeaderController(
                    scrolled: _scrolled,
                    onChanged: (v) => setState(() => _scrolled = v),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.screenH,
                          AppSpacing.md, AppSpacing.screenH, AppSpacing.huge),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, i) =>
                          _SheetCard(summary: filtered[i]).entrance(index: i),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _EmptyTracker extends StatelessWidget {
  const _EmptyTracker({required this.activeOnly});
  final bool activeOnly;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Text(
          activeOnly
              ? 'No active sheets in this category.\nSwitch to "All sheets" or add some in Profile → My Sheets.'
              : 'Loading…',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  const _CategoryFilter({required this.selected, required this.onSelect});
  final PrepCategory? selected;
  final ValueChanged<PrepCategory?> onSelect;

  @override
  Widget build(BuildContext context) {
    return FilterChipBar(
      children: [
        _Chip(
          label: 'All',
          selected: selected == null,
          onTap: () => onSelect(null),
        ),
        for (final c in PrepCategory.values)
          _Chip(
            label: c.label,
            icon: c.icon,
            color: c.color,
            selected: selected == c,
            onTap: () => onSelect(c),
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.color,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final c = color ?? scheme.primary;
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppMotion.fast,
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: selected ? c : scheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: selected ? c : scheme.outline),
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon,
                    size: 16,
                    color: selected ? Colors.white : scheme.onSurfaceVariant),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : scheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetCard extends StatelessWidget {
  const _SheetCard({required this.summary});
  final SheetSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cat = summary.category;
    return AppCard(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => SheetDetailScreen(sheetId: summary.sheet.id),
      )),
      child: Row(
        children: [
          ProgressRing(
            value: summary.progress,
            size: 62,
            strokeWidth: 7,
            gradient: LinearGradient(
                colors: [cat.color, cat.color.withValues(alpha: 0.6)]),
            center: Text(
              '${(summary.progress * 100).round()}%',
              style: theme.textTheme.labelMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(summary.sheet.title,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(summary.sheet.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: AppSpacing.sm),
                // Wrap, not Row: at larger font scales two pills no longer fit
                // side by side on a narrow phone and would overflow.
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    Pill(
                        label: '${summary.done}/${summary.total} done',
                        color: cat.color,
                        dense: true),
                    if (summary.revisit > 0)
                      Pill(
                          label: '${summary.revisit} revisit',
                          color: theme.colorScheme.tertiary,
                          dense: true),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              color: theme.colorScheme.onSurfaceVariant),
        ],
      ),
    );
  }
}
