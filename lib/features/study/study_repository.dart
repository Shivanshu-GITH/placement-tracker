import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import 'study_models.dart';

/// Loads the authored study packs (`assets/content/study/*.json`) and merges
/// them into a single [StudyContent] indexed by canonical key.
///
/// Packs are listed in `assets/content/study/index.json`:
/// `{ "packs": ["core_os.json"] }`. Adding a new subject is just a new pack
/// file plus one line in that index — no code changes.
class StudyRepository {
  const StudyRepository();

  static const _indexPath = 'assets/content/study/index.json';
  static const _dir = 'assets/content/study/';

  Future<StudyContent> load() async {
    final List<String> packs;
    try {
      final indexRaw = await rootBundle.loadString(_indexPath);
      packs = ((json.decode(indexRaw) as Map<String, dynamic>)['packs'] as List)
          .cast<String>();
    } catch (_) {
      // No index yet (or malformed) — behave as "no study content".
      return StudyContent.empty;
    }

    final merged = <String, StudyEntry>{};
    for (final pack in packs) {
      try {
        final raw = await rootBundle.loadString('$_dir$pack');
        final map = json.decode(raw) as Map<String, dynamic>;
        final topics = (map['topics'] ?? const {}) as Map<String, dynamic>;
        topics.forEach((canon, value) {
          merged[canon] =
              StudyEntry.fromJson(canon, value as Map<String, dynamic>);
        });
      } catch (_) {
        // Skip a broken pack rather than failing the whole load.
        continue;
      }
    }
    return StudyContent(merged);
  }
}
