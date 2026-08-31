import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/dtos.dart';
import '../../providers/providers.dart';
import 'notes_screen.dart';
import 'quiz_screen.dart';
import 'study_models.dart';

/// Opens the notes reader for [entry], showing a rewarded ad first (unless the
/// topic's notes were already unlocked this session).
Future<void> openStudyNotes(
  BuildContext context,
  WidgetRef ref,
  LeafRow row,
  StudyEntry entry,
  Color accent,
) async {
  final ok = await ref.read(adGateProvider).ensureUnlocked(
        context,
        key: 'note:${entry.canon}',
        rewardLabel: 'these notes',
      );
  if (!ok || !context.mounted) return;
  await Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute(
      builder: (_) => NotesScreen(entry: entry, row: row, accent: accent),
    ),
  );
}

/// Opens the topic quiz, showing a rewarded ad first (unless the topic's quiz
/// was already unlocked this session).
Future<void> openStudyQuiz(
  BuildContext context,
  WidgetRef ref,
  LeafRow row,
  StudyEntry entry,
  Color accent,
) async {
  final ok = await ref.read(adGateProvider).ensureUnlocked(
        context,
        key: 'quiz:${entry.canon}',
        rewardLabel: 'this quiz',
      );
  if (!ok || !context.mounted) return;
  await Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute(
      builder: (_) => QuizScreen(entry: entry, row: row, accent: accent),
    ),
  );
}
