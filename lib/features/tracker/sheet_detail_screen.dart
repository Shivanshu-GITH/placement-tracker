import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/enums.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/widgets/pill.dart';
import '../../data/models/dtos.dart';
import '../../data/repositories/prep_repository.dart';
import '../../providers/providers.dart';
import 'widgets/problem_sheet.dart';

/// Shows one sheet as an expandable tree: Section → Sub-section → Leaf, with
/// rolled-up completion on every section.
class SheetDetailScreen extends ConsumerWidget {
  const SheetDetailScreen({super.key, required this.sheetId});
  final int sheetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sheet = ref.watch(sheetsByIdProvider)[sheetId];
    final nodes =
        ref.watch(nodesProvider).where((n) => n.sheetId == sheetId).toList();
    final progress = ref.watch(progressByCanonProvider);

    if (sheet == null || nodes.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final cat = PrepCategory.fromName(sheet.category);
    final tree = PrepRepository.buildSheetTree(nodes, sheet, progress);
    final total = tree.fold<int>(0, (s, t) => s + t.total);
    final done = tree.fold<int>(0, (s, t) => s + t.done);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 150,
            backgroundColor: cat.color,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              title: Text(sheet.title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [cat.color, cat.color.withValues(alpha: 0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg, 60, AppSpacing.lg, 44),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text('$done / $total',
                        style: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w800,
                            fontSize: 15)),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.screenH,
                AppSpacing.md, AppSpacing.screenH, AppSpacing.huge),
            sliver: SliverList.separated(
              itemCount: tree.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, i) => tree[i].isLeaf
                  ? LeafTile(row: tree[i].leaf!)
                  : TreeSection(node: tree[i], depth: 0, accent: cat.color),
            ),
          ),
        ],
      ),
    );
  }
}

/// An expandable section with a roll-up progress bar; lazily builds children.
class TreeSection extends StatefulWidget {
  const TreeSection({
    super.key,
    required this.node,
    required this.depth,
    required this.accent,
  });
  final TreeNode node;
  final int depth;
  final Color accent;

  @override
  State<TreeSection> createState() => _TreeSectionState();
}

class _TreeSectionState extends State<TreeSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final n = widget.node;
    final complete = n.total > 0 && n.done == n.total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                    color: complete
                        ? widget.accent.withValues(alpha: 0.5)
                        : theme.colorScheme.outline),
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.md),
              child: Row(
                children: [
                  AnimatedRotation(
                    turns: _expanded ? 0.25 : 0,
                    duration: AppMotion.fast,
                    child: Icon(Icons.chevron_right_rounded,
                        color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(n.node.title,
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          child: LinearProgressIndicator(
                            value: n.progress,
                            minHeight: 5,
                            backgroundColor:
                                theme.colorScheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation(widget.accent),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text('${n.done}/${n.total}',
                      style: theme.textTheme.labelMedium?.copyWith(
                          color: complete
                              ? widget.accent
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: AppMotion.fast,
          curve: AppMotion.enter,
          alignment: Alignment.topCenter,
          child: _expanded
              ? Padding(
                  padding: const EdgeInsets.only(
                      left: AppSpacing.md, top: AppSpacing.sm),
                  child: Column(
                    children: [
                      for (final child in n.children) ...[
                        child.isLeaf
                            ? LeafTile(row: child.leaf!)
                            : TreeSection(
                                node: child,
                                depth: widget.depth + 1,
                                accent: widget.accent),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                    ],
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

/// A single leaf: coding problem (4-state + link) or concept (Learning/Done/…).
class LeafTile extends ConsumerWidget {
  const LeafTile({super.key, required this.row});
  final LeafRow row;

  Future<void> _openUrl(BuildContext context) async {
    final url = row.node.url;
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        await Clipboard.setData(ClipboardData(text: url));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Link copied to clipboard')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final repo = ref.read(prepRepositoryProvider);
    final hasStudy = ref.watch(studyByCanonProvider).has(row.canon);

    final IconData icon;
    final Color color;
    final VoidCallback onCycle;
    if (row.isConcept) {
      final s = row.conceptStatus;
      icon = s.icon;
      color = s.color(context);
      onCycle = () => repo.setLeafStatus(row.canon, _nextConcept(s).name);
    } else {
      final s = row.problemStatus;
      icon = s.icon;
      color = s.color(context);
      onCycle = () => repo.setLeafStatus(row.canon, _nextProblem(s).name);
    }

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppRadius.md),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => showLeafSheet(context, ref, row),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: theme.colorScheme.outline),
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Row(
            children: [
              GestureDetector(
                onTap: onCycle,
                child: Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.node.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration:
                            row.isDone ? TextDecoration.lineThrough : null,
                        color: row.isDone
                            ? theme.colorScheme.onSurfaceVariant
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Wraps so a long platform name or a larger font scale
                    // reflows instead of overflowing the row.
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (!row.isConcept)
                          Pill(
                              label: row.difficulty.label,
                              color: row.difficulty.color,
                              dense: true),
                        if (row.node.platform.isNotEmpty)
                          Text(row.node.platform,
                              style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant)),
                        if (row.isBookmarked)
                          Icon(Icons.bookmark_rounded,
                              size: 14, color: theme.colorScheme.primary),
                      ],
                    ),
                  ],
                ),
              ),
              if (hasStudy)
                Tooltip(
                  message: 'In-app notes & quiz',
                  child: Icon(Icons.menu_book_rounded,
                      size: 17, color: theme.colorScheme.primary),
                ),
              if (row.node.url.isNotEmpty)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _openUrl(context),
                  icon: Icon(Icons.open_in_new_rounded,
                      size: 18, color: theme.colorScheme.onSurfaceVariant),
                ),
            ],
          ),
        ),
      ),
    );
  }

  ProblemStatus _nextProblem(ProblemStatus s) => switch (s) {
        ProblemStatus.todo => ProblemStatus.attempted,
        ProblemStatus.attempted => ProblemStatus.solved,
        ProblemStatus.solved => ProblemStatus.revisit,
        ProblemStatus.revisit => ProblemStatus.todo,
      };

  ConceptStatus _nextConcept(ConceptStatus s) => switch (s) {
        ConceptStatus.notStarted => ConceptStatus.learning,
        ConceptStatus.learning => ConceptStatus.done,
        ConceptStatus.done => ConceptStatus.revise,
        ConceptStatus.revise => ConceptStatus.notStarted,
      };
}
