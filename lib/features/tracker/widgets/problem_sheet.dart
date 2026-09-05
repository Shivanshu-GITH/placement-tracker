import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/enums.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/pill.dart';
import '../../../data/models/dtos.dart';
import '../../../data/repositories/prep_repository.dart';
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

  // Notes save on a short debounce rather than on every keystroke, so typing
  // doesn't fire a database write per character. The repository and canon are
  // captured during build so a pending edit can still be flushed from
  // dispose() without touching `ref` after the widget is deactivated.
  Timer? _noteDebounce;
  Timer? _savedFlash;
  PrepRepository? _repo;
  String? _noteCanon;
  bool _noteDirty = false;

  /// Drives the note box's "Saved" state: the border turns green and a tick
  /// appears for a moment after an auto-save, then it settles back.
  bool _noteSaved = false;

  /// Focus is tracked so the box can highlight while it's being written in.
  final _noteFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _noteFocus.addListener(() => setState(() {}));
  }

  void _onNoteChanged(String _) {
    _noteDirty = true;
    // A fresh keystroke clears the "Saved" tick — it belongs to the previous
    // save, not to what is being typed now.
    if (_noteSaved) {
      _savedFlash?.cancel();
      setState(() => _noteSaved = false);
    }
    _noteDebounce?.cancel();
    // Fires once typing pauses, so a save marks a finished thought.
    _noteDebounce = Timer(const Duration(milliseconds: 700), _flushNote);
  }

  /// Writes the pending note, if any. Safe to call repeatedly.
  void _flushNote({bool showFeedback = true}) {
    final canon = _noteCanon;
    if (!_noteDirty || canon == null) return;
    _noteDirty = false;
    // Store a whitespace-only note as genuinely empty so it doesn't linger as
    // invisible junk (and the placeholder comes back).
    final text = _noteController.text;
    _repo?.saveNote(canon, text.trim().isEmpty ? '' : text);
    if (!showFeedback || !mounted) return;
    setState(() => _noteSaved = true);
    _savedFlash?.cancel();
    _savedFlash = Timer(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _noteSaved = false);
    });
  }

  @override
  void dispose() {
    _noteDebounce?.cancel();
    _savedFlash?.cancel();
    // Don't lose what was typed just before closing. No feedback here — the
    // widget is going away.
    _flushNote(showFeedback: false);
    _noteFocus.dispose();
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
      final stored = row.progress?.note ?? '';
      // A note of nothing but whitespace carries no information, and it would
      // suppress the placeholder while looking identical to an empty box.
      _noteController.text = stored.trim().isEmpty ? '' : stored;
    }
    final repo = ref.read(prepRepositoryProvider);
    // Kept for the debounced save + the dispose-time flush.
    _repo = repo;
    _noteCanon = row.canon;

    // The sheet scrolls and is capped below full height: with the note box open
    // and the keyboard up, the content is easily taller than the screen.
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      child: SingleChildScrollView(
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
          // Wraps so a long section title (or a larger font scale) pushes onto
          // the next line instead of overflowing the sheet.
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (!row.isConcept)
                Pill(label: row.difficulty.label, color: row.difficulty.color),
              Pill(label: row.category.label, color: row.category.color),
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
          Row(
            children: [
              Text('Notes', style: theme.textTheme.titleSmall),
              const Spacer(),
              // Confirms the auto-save without needing a button.
              AnimatedOpacity(
                opacity: _noteSaved ? 1 : 0,
                duration: AppMotion.fast,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded,
                        size: 14, color: AppPalette.success),
                    const SizedBox(width: 4),
                    Text('Saved',
                        style: theme.textTheme.labelSmall?.copyWith(
                            color: AppPalette.success,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _NoteBox(
            controller: _noteController,
            focusNode: _noteFocus,
            saved: _noteSaved,
            hintText: _noteHint(row),
            onChanged: _onNoteChanged,
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

/// A prompt that fits what the user is actually studying — "edge cases and
/// complexity" is meaningless on an HR question or an aptitude formula.
String _noteHint(LeafRow row) {
  // Coding problems, whatever sheet they came from.
  if (!row.isConcept) {
    return 'Approach, edge cases, complexity…';
  }
  return switch (row.category) {
    PrepCategory.aptitude =>
      'Formula, shortcut, traps to avoid…',
    PrepCategory.interview =>
      'Your story, the STAR points, what to improve…',
    PrepCategory.system =>
      'Trade-offs, bottlenecks, how you\'d scale it…',
    PrepCategory.webdev =>
      'Syntax, gotchas, where you\'d use it…',
    PrepCategory.cp => 'Pattern, when it applies, template…',
    PrepCategory.dsa => 'Intuition, pattern, complexity…',
    PrepCategory.core => 'Definition, example, why it matters…',
  };
}

/// The personal-notes box.
///
/// Roomier than a plain field, with a border that reflects its state: neutral
/// at rest, brand-coloured while being written in, and green for a moment right
/// after an auto-save so the user can see their note was kept.
class _NoteBox extends StatelessWidget {
  const _NoteBox({
    required this.controller,
    required this.focusNode,
    required this.saved,
    required this.hintText,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool saved;

  /// Subject-appropriate prompt — see [_noteHint].
  final String hintText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final focused = focusNode.hasFocus;
    final borderColor = saved
        ? AppPalette.success
        : focused
            ? scheme.primary
            : scheme.outlineVariant;

    return AnimatedContainer(
      duration: AppMotion.fast,
      curve: AppMotion.enter,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: borderColor,
          width: (saved || focused) ? 1.6 : 1,
        ),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        minLines: 4,
        maxLines: 8,
        textCapitalization: TextCapitalization.sentences,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
        style: theme.textTheme.bodyMedium,
        decoration: InputDecoration(
          // The container draws the border and background, so the field itself
          // must be completely bare. The app theme sets filled + enabled/
          // focused borders, so EVERY state has to be cleared here or the
          // field paints a second border inside this one.
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          isCollapsed: true,
          hintText: hintText,
          hintStyle: theme.textTheme.bodySmall
              ?.copyWith(color: scheme.onSurfaceVariant),
        ),
        onChanged: onChanged,
      ),
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
