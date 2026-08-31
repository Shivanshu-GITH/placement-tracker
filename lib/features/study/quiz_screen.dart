import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_palette.dart';
import '../../core/widgets/progress_ring.dart';
import '../../data/models/dtos.dart';
import '../../providers/providers.dart';
import '../ads/ad_service.dart';
import 'study_models.dart';
import 'widgets/note_view.dart';

/// A multiple-choice quiz for one topic: one question at a time, immediate
/// feedback with an explanation, then a scored results screen. Reached only
/// after the ad gate. Records the best score and logs a short study session.
class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({
    super.key,
    required this.entry,
    required this.row,
    required this.accent,
  });

  final StudyEntry entry;
  final LeafRow row;
  final Color accent;

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int _index = 0;
  int? _selected;
  bool _revealed = false;
  int _score = 0;
  bool _finished = false;
  bool _recorded = false;

  List<Mcq> get _mcqs => widget.entry.mcqs;
  Mcq get _current => _mcqs[_index];

  void _check() {
    if (_selected == null) return;
    setState(() {
      _revealed = true;
      if (_selected == _current.answer) _score++;
    });
  }

  void _next() {
    if (_index + 1 >= _mcqs.length) {
      setState(() => _finished = true);
      _recordOnce();
    } else {
      setState(() {
        _index++;
        _selected = null;
        _revealed = false;
      });
    }
  }

  Future<void> _recordOnce() async {
    if (_recorded) return;
    _recorded = true;
    await ref
        .read(quizResultsProvider.notifier)
        .record(widget.entry.canon, _score, _mcqs.length);
    // A finished quiz counts as study time, feeding streak / activity.
    await ref.read(prepRepositoryProvider).logSession(
          minutes: 5,
          category: widget.row.category,
          source: 'quiz',
          note: 'Quiz: ${widget.entry.title}',
        );
  }

  void _retake() {
    setState(() {
      _index = 0;
      _selected = null;
      _revealed = false;
      _score = 0;
      _finished = false;
      _recorded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.entry.title} · Quiz',
            overflow: TextOverflow.ellipsis),
        backgroundColor: widget.accent,
        foregroundColor: Colors.white,
      ),
      body: _finished ? _results(context) : _question(context),
    );
  }

  // ---- Question view -------------------------------------------------------

  Widget _question(BuildContext context) {
    final theme = Theme.of(context);
    final q = _current;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.screenH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Question ${_index + 1} of ${_mcqs.length}',
                      style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                  Text('Score $_score',
                      style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700, color: widget.accent)),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: LinearProgressIndicator(
                  value: (_index + (_revealed ? 1 : 0)) / _mcqs.length,
                  minHeight: 6,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation(widget.accent),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenH, 0, AppSpacing.screenH, AppSpacing.xl),
            children: [
              Text(q.question,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700, height: 1.4)),
              const SizedBox(height: AppSpacing.lg),
              for (var i = 0; i < q.options.length; i++)
                _OptionCard(
                  label: q.options[i],
                  state: _optionState(i),
                  onTap: _revealed ? null : () => setState(() => _selected = i),
                ),
              if (_revealed) ...[
                const SizedBox(height: AppSpacing.md),
                NoteView(blocks: [
                  NoteBlock(
                    type: BlockType.callout,
                    calloutStyle: _selected == q.answer
                        ? CalloutStyle.tip
                        : CalloutStyle.info,
                    title: _selected == q.answer ? 'Correct' : 'Explanation',
                    text: q.explain,
                  ),
                ]),
              ],
            ],
          ),
        ),
        _bottomBar(context),
      ],
    );
  }

  _OptionState _optionState(int i) {
    if (!_revealed) {
      return _selected == i ? _OptionState.selected : _OptionState.idle;
    }
    if (i == _current.answer) return _OptionState.correct;
    if (i == _selected) return _OptionState.wrong;
    return _OptionState.idle;
  }

  Widget _bottomBar(BuildContext context) {
    final last = _index + 1 >= _mcqs.length;
    return SafeArea(
      minimum: const EdgeInsets.all(AppSpacing.screenH),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: widget.accent,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          ),
          onPressed: _revealed
              ? _next
              : (_selected == null ? null : _check),
          child: Text(_revealed
              ? (last ? 'See results' : 'Next question')
              : 'Check answer'),
        ),
      ),
    );
  }

  // ---- Results view --------------------------------------------------------

  Widget _results(BuildContext context) {
    final theme = Theme.of(context);
    final pct = _mcqs.isEmpty ? 0.0 : _score / _mcqs.length;
    final passed = pct >= 0.6;
    final message = pct == 1
        ? 'Flawless. You own this topic.'
        : passed
            ? 'Solid — a few to polish.'
            : 'Worth another read, then retry.';

    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, AppSpacing.xxl,
          AppSpacing.screenH, AppSpacing.xl),
      children: [
        Center(
          child: ProgressRing(
            value: pct,
            size: 140,
            strokeWidth: 12,
            gradient: passed
                ? AppPalette.progressGradient
                : AppPalette.sunsetGradient,
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$_score/${_mcqs.length}',
                    style: theme.textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w800)),
                Text('${(pct * 100).round()}%',
                    style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(message,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: AppSpacing.xxl),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: AppPalette.success,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          ),
          onPressed: () {
            ref
                .read(prepRepositoryProvider)
                .setLeafStatus(widget.row.canon, 'done');
            Navigator.of(context).pop();
            // Show an interstitial on this natural break (frequency-capped).
            AdService.instance.interstitial.maybeShow();
          },
          icon: const Icon(Icons.check_circle_rounded),
          label: const Text('Mark topic as done'),
        ),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton.icon(
          onPressed: () {
            _retake();
            AdService.instance.interstitial.maybeShow();
          },
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Retake quiz'),
        ),
        const SizedBox(height: AppSpacing.md),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            AdService.instance.interstitial.maybeShow();
          },
          child: const Text('Back to topic'),
        ),
      ],
    );
  }
}

enum _OptionState { idle, selected, correct, wrong }

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.label,
    required this.state,
    required this.onTap,
  });
  final String label;
  final _OptionState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (Color border, Color bg, IconData? icon, Color iconColor) =
        switch (state) {
      _OptionState.idle => (
          theme.colorScheme.outline,
          theme.colorScheme.surface,
          null,
          Colors.transparent
        ),
      _OptionState.selected => (
          AppPalette.indigo,
          AppPalette.indigo.withValues(alpha: 0.08),
          Icons.radio_button_checked_rounded,
          AppPalette.indigo
        ),
      _OptionState.correct => (
          AppPalette.success,
          AppPalette.success.withValues(alpha: 0.12),
          Icons.check_circle_rounded,
          AppPalette.success
        ),
      _OptionState.wrong => (
          AppPalette.danger,
          AppPalette.danger.withValues(alpha: 0.12),
          Icons.cancel_rounded,
          AppPalette.danger
        ),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.md),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                  color: border,
                  width: state == _OptionState.idle ? 1 : 1.5),
            ),
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: Text(label,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(height: 1.35, fontWeight: FontWeight.w500)),
                ),
                if (icon != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Icon(icon, color: iconColor, size: 20),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
