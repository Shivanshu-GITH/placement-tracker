/// Data model for the in-app study content: richly-formatted notes + MCQs that
/// attach to an existing content leaf by its canonical key ([StudyEntry.canon]).
///
/// Content is authored as JSON in `assets/content/study/*.json` and loaded by
/// [StudyRepository]. Notes are a list of typed [NoteBlock]s (not raw markdown)
/// so they render as fully themed, consistent widgets — see `widgets/note_view`.
library;

/// One authored study unit for a single topic (one content leaf).
class StudyEntry {
  const StudyEntry({
    required this.canon,
    required this.title,
    required this.summary,
    required this.minutes,
    required this.blocks,
    required this.mcqs,
  });

  /// Canonical key of the leaf this attaches to (e.g. `u:core-os-5-...`).
  final String canon;
  final String title;

  /// One-line hook shown above the note.
  final String summary;

  /// Estimated read time in minutes.
  final int minutes;
  final List<NoteBlock> blocks;
  final List<Mcq> mcqs;

  bool get hasNote => blocks.isNotEmpty;
  bool get hasQuiz => mcqs.isNotEmpty;

  factory StudyEntry.fromJson(String canon, Map<String, dynamic> j) {
    return StudyEntry(
      canon: canon,
      title: (j['title'] ?? '') as String,
      summary: (j['summary'] ?? '') as String,
      minutes: (j['minutes'] ?? 4) as int,
      blocks: ((j['blocks'] ?? const []) as List)
          .map((b) => NoteBlock.fromJson(b as Map<String, dynamic>))
          .toList(),
      mcqs: ((j['mcqs'] ?? const []) as List)
          .map((m) => Mcq.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// The kind of a [NoteBlock]. Unknown types render as a plain paragraph.
enum BlockType { heading, paragraph, points, steps, code, table, callout }

BlockType _blockType(String? t) {
  switch (t) {
    case 'h':
      return BlockType.heading;
    case 'points':
      return BlockType.points;
    case 'steps':
      return BlockType.steps;
    case 'code':
      return BlockType.code;
    case 'table':
      return BlockType.table;
    case 'callout':
      return BlockType.callout;
    case 'p':
    default:
      return BlockType.paragraph;
  }
}

/// Visual accent for a [BlockType.callout].
enum CalloutStyle { tip, warn, info, key }

CalloutStyle _calloutStyle(String? s) {
  switch (s) {
    case 'warn':
      return CalloutStyle.warn;
    case 'info':
      return CalloutStyle.info;
    case 'key':
      return CalloutStyle.key;
    case 'tip':
    default:
      return CalloutStyle.tip;
  }
}

/// A single renderable block of a note. Text fields may contain the lightweight
/// inline markup the renderer understands: `**bold**` and `` `code` ``.
class NoteBlock {
  const NoteBlock({
    required this.type,
    this.text = '',
    this.lang = '',
    this.title = '',
    this.calloutStyle = CalloutStyle.tip,
    this.items = const [],
    this.headers = const [],
    this.rows = const [],
  });

  final BlockType type;
  final String text;

  /// For [BlockType.code]: the language label (display only).
  final String lang;

  /// For [BlockType.callout]: the bold lead-in.
  final String title;
  final CalloutStyle calloutStyle;

  /// For [BlockType.points] / [BlockType.steps].
  final List<String> items;

  /// For [BlockType.table].
  final List<String> headers;
  final List<List<String>> rows;

  factory NoteBlock.fromJson(Map<String, dynamic> j) {
    return NoteBlock(
      type: _blockType(j['t'] as String?),
      text: (j['text'] ?? '') as String,
      lang: (j['lang'] ?? '') as String,
      title: (j['title'] ?? '') as String,
      calloutStyle: _calloutStyle(j['style'] as String?),
      items: ((j['items'] ?? const []) as List).map((e) => e as String).toList(),
      headers:
          ((j['headers'] ?? const []) as List).map((e) => e as String).toList(),
      rows: ((j['rows'] ?? const []) as List)
          .map((r) => (r as List).map((e) => e as String).toList())
          .toList(),
    );
  }
}

/// A single multiple-choice question with a 0-based correct-[answer] index.
class Mcq {
  const Mcq({
    required this.question,
    required this.options,
    required this.answer,
    required this.explain,
  });

  final String question;
  final List<String> options;
  final int answer;
  final String explain;

  factory Mcq.fromJson(Map<String, dynamic> j) {
    return Mcq(
      question: (j['q'] ?? '') as String,
      options: ((j['options'] ?? const []) as List)
          .map((e) => e as String)
          .toList(),
      answer: (j['answer'] ?? 0) as int,
      explain: (j['explain'] ?? '') as String,
    );
  }
}

/// All loaded study entries, indexed by canonical key.
class StudyContent {
  const StudyContent(this.byCanon);
  final Map<String, StudyEntry> byCanon;

  static const StudyContent empty = StudyContent({});

  StudyEntry? entry(String canon) => byCanon[canon];
  bool has(String canon) => byCanon.containsKey(canon);
}
