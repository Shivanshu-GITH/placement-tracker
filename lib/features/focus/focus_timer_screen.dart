import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/enums.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_palette.dart';
import '../../core/widgets/progress_ring.dart';
import '../../providers/providers.dart';

class FocusTimerScreen extends ConsumerStatefulWidget {
  const FocusTimerScreen({super.key});

  @override
  ConsumerState<FocusTimerScreen> createState() => _FocusTimerScreenState();
}

class _FocusTimerScreenState extends ConsumerState<FocusTimerScreen> {
  static const _presets = [15, 25, 45, 60];
  int _selectedMinutes = 25;
  int _remaining = 25 * 60;
  Timer? _timer;
  bool _running = false;
  PrepCategory _category = PrepCategory.dsa;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _setPreset(int minutes) {
    if (_running) return;
    setState(() {
      _selectedMinutes = minutes;
      _remaining = minutes * 60;
    });
  }

  void _toggle() {
    if (_running) {
      _timer?.cancel();
      setState(() => _running = false);
    } else {
      setState(() => _running = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (_remaining <= 1) {
          t.cancel();
          _complete();
        } else {
          setState(() => _remaining--);
        }
      });
    }
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _running = false;
      _remaining = _selectedMinutes * 60;
    });
  }

  Future<void> _complete() async {
    setState(() {
      _running = false;
      _remaining = 0;
    });
    await ref.read(prepRepositoryProvider).logSession(
          minutes: _selectedMinutes,
          category: _category,
          source: 'pomodoro',
        );
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        icon: const Icon(Icons.celebration_rounded,
            color: AppPalette.mint, size: 40),
        title: const Text('Session complete!'),
        content: Text(
            'Logged $_selectedMinutes minutes of ${_category.label}. Great focus 💪'),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _reset();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  String get _display {
    final m = (_remaining ~/ 60).toString().padLeft(2, '0');
    final s = (_remaining % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = _selectedMinutes * 60;
    final progress = total == 0 ? 0.0 : 1 - (_remaining / total);

    return Scaffold(
      appBar: AppBar(title: const Text('Focus timer')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              const Spacer(),
              ProgressRing(
                value: progress,
                size: 260,
                strokeWidth: 16,
                gradient: AppPalette.brandGradient,
                duration: AppMotion.fast,
                center: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_display,
                        style: theme.textTheme.displaySmall
                            ?.copyWith(fontWeight: FontWeight.w800)),
                    Text(_running ? 'Stay focused' : 'Ready',
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Wrap(
                spacing: AppSpacing.sm,
                children: [
                  for (final p in _presets)
                    ChoiceChip(
                      label: Text('$p min'),
                      selected: _selectedMinutes == p,
                      onSelected: _running ? null : (_) => _setPreset(p),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                children: [
                  for (final c in PrepCategory.values)
                    ChoiceChip(
                      label: Text(c.label),
                      selected: _category == c,
                      onSelected:
                          _running ? null : (_) => setState(() => _category = c),
                    ),
                ],
              ),
              const Spacer(),
              // Reset gets a fair share of the row and its label is pinned to a
              // single line — at flex 1 it was too narrow and wrapped to
              // "Rese/t".
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: OutlinedButton.icon(
                      onPressed: _reset,
                      icon: const Icon(Icons.stop_rounded),
                      label: const Text('Reset',
                          maxLines: 1, softWrap: false),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 4,
                    child: FilledButton.icon(
                      onPressed: _toggle,
                      icon: Icon(_running
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded),
                      label: Text(_running ? 'Pause' : 'Start',
                          maxLines: 1, softWrap: false),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
