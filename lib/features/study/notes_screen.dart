import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_dimens.dart';
import '../../data/models/dtos.dart';
import '../../providers/providers.dart';
import 'study_actions.dart';
import 'study_links.dart';
import 'study_models.dart';
import 'widgets/note_view.dart';

/// Full-screen reader for a topic's authored notes, with "study elsewhere"
/// links and a jump into the topic quiz. Reached only after the ad gate.
class NotesScreen extends ConsumerWidget {
  const NotesScreen({
    super.key,
    required this.entry,
    required this.row,
    required this.accent,
  });

  final StudyEntry entry;
  final LeafRow row;
  final Color accent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final subject = row.category.label;

    return Scaffold(
      appBar: AppBar(
        title: Text(entry.title, overflow: TextOverflow.ellipsis),
        backgroundColor: accent,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, AppSpacing.lg,
            AppSpacing.screenH, AppSpacing.huge),
        children: [
          Row(
            children: [
              Icon(Icons.menu_book_rounded,
                  size: 15, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Text('${entry.minutes} min read · $subject',
                  style: theme.textTheme.labelMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
          if (entry.summary.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(entry.summary,
                  style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600, height: 1.4)),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          NoteView(blocks: entry.blocks),
          const SizedBox(height: AppSpacing.xl),
          Divider(color: theme.colorScheme.outline),
          const SizedBox(height: AppSpacing.md),
          Text('Study further', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => StudyLinks.open(
                      context, StudyLinks.google(entry.title, subject: subject)),
                  icon: const Icon(Icons.search_rounded, size: 18),
                  label: const Text('Google'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => StudyLinks.open(context,
                      StudyLinks.chatgpt(entry.title, subject: subject)),
                  icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                  label: const Text('Ask ChatGPT'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          if (entry.hasQuiz)
            _QuizCta(entry: entry, row: row, accent: accent),
        ],
      ),
    );
  }
}

class _QuizCta extends ConsumerWidget {
  const _QuizCta({required this.entry, required this.row, required this.accent});
  final StudyEntry entry;
  final LeafRow row;
  final Color accent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(quizResultsProvider)[entry.canon];
    final gated =
        !ref.watch(adGateProvider).isUnlocked('quiz:${entry.canon}');
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        ),
        onPressed: () => openStudyQuiz(context, ref, row, entry, accent),
        icon: Icon(gated ? Icons.play_circle_outline_rounded : Icons.quiz_rounded),
        label: Text(result == null
            ? (gated ? 'Take the quiz  (watch a short ad)' : 'Take the quiz')
            : 'Retake quiz · best ${result.best}/${result.total}'),
      ),
    );
  }
}
