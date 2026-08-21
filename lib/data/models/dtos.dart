import '../../core/constants/enums.dart';
import '../database/database.dart';

/// A trackable leaf (problem or concept) joined with its sheet, top-level
/// section (for grouping) and the user's progress (shared by canonical key).
class LeafRow {
  LeafRow({
    required this.node,
    required this.sheet,
    required this.sectionId,
    required this.sectionTitle,
    this.progress,
  });

  final Node node;
  final Sheet sheet;
  final int sectionId;
  final String sectionTitle;
  final LeafProgressData? progress;

  bool get isConcept => node.leafType == 'concept';
  String get canon => node.canon;

  String get _statusName =>
      progress?.status ?? (isConcept ? 'notStarted' : 'todo');
  ProblemStatus get problemStatus => ProblemStatus.fromName(_statusName);
  ConceptStatus get conceptStatus => ConceptStatus.fromName(_statusName);

  Difficulty get difficulty => Difficulty.fromName(node.difficulty);
  PrepCategory get category => PrepCategory.fromName(sheet.category);

  bool get isDone => isConcept
      ? conceptStatus == ConceptStatus.done
      : problemStatus == ProblemStatus.solved;
  bool get needsRevisit => isConcept
      ? conceptStatus == ConceptStatus.revise
      : problemStatus == ProblemStatus.revisit;
  bool get isBookmarked => progress?.bookmarked ?? false;
}

/// Aggregate progress for one sheet (no cross-sheet dedup — a problem appears
/// once per sheet).
class SheetSummary {
  SheetSummary({
    required this.sheet,
    required this.total,
    required this.done,
    required this.revisit,
    required this.active,
  });

  final Sheet sheet;
  final int total;
  final int done;
  final int revisit;
  final bool active;

  double get progress => total == 0 ? 0 : done / total;
  PrepCategory get category => PrepCategory.fromName(sheet.category);
}

/// A node in a rendered sheet tree, with rolled-up completion counts.
class TreeNode {
  TreeNode.section(this.node, this.children, this.total, this.done)
      : leaf = null,
        isLeaf = false;
  TreeNode.leaf(this.node, this.leaf, this.total, this.done)
      : children = const [],
        isLeaf = true;

  final Node node;
  final List<TreeNode> children;
  final LeafRow? leaf;
  final bool isLeaf;
  final int total;
  final int done;

  double get progress => total == 0 ? 0 : done / total;
}

/// Progress rolled up per preparation category (deduped by canonical key).
class CategoryProgress {
  CategoryProgress({
    required this.category,
    required this.total,
    required this.done,
  });

  final PrepCategory category;
  final int total;
  final int done;

  double get progress => total == 0 ? 0 : done / total;
}

class StreakInfo {
  const StreakInfo({required this.current, required this.longest});
  final int current;
  final int longest;
  static const empty = StreakInfo(current: 0, longest: 0);
}

/// Top-level statistics over the user's ACTIVE sheets, deduped by canonical key.
class PrepStats {
  PrepStats({
    required this.totalItems,
    required this.totalDone,
    required this.byCategory,
    required this.doneByDifficulty,
    required this.totalByDifficulty,
    required this.bookmarked,
    required this.needsRevisit,
  });

  final int totalItems;
  final int totalDone;
  final List<CategoryProgress> byCategory;
  final Map<Difficulty, int> doneByDifficulty;
  final Map<Difficulty, int> totalByDifficulty;
  final int bookmarked;
  final int needsRevisit;

  double get overallProgress => totalItems == 0 ? 0 : totalDone / totalItems;
}
