import 'package:flutter/material.dart';

import '../theme/app_palette.dart';

/// Preparation categories. Stored in the DB as the enum `name`.
enum PrepCategory {
  dsa('DSA', 'Data Structures & Algorithms', Icons.data_object_rounded, AppPalette.catDsa),
  core('Core CS', 'OS, DBMS, CN, OOP', Icons.memory_rounded, AppPalette.catCore),
  aptitude('Aptitude', 'Quant, Logical, Verbal', Icons.calculate_rounded, AppPalette.catAptitude),
  system('System Design', 'HLD & LLD', Icons.account_tree_rounded, AppPalette.catSystem),
  interview('Interview', 'HR & Behavioural', Icons.record_voice_over_rounded, AppPalette.catInterview);

  const PrepCategory(this.label, this.description, this.icon, this.color);

  final String label;
  final String description;
  final IconData icon;
  final Color color;

  static PrepCategory fromName(String name) =>
      PrepCategory.values.firstWhere((e) => e.name == name, orElse: () => PrepCategory.dsa);
}

/// Non-binary progress states — the "revisit" state is what powers spaced
/// revision and honest analytics.
enum ProblemStatus {
  todo('To do', Icons.circle_outlined),
  attempted('Attempted', Icons.timelapse_rounded),
  solved('Solved', Icons.check_circle_rounded),
  revisit('Revisit', Icons.refresh_rounded);

  const ProblemStatus(this.label, this.icon);
  final String label;
  final IconData icon;

  bool get isDone => this == ProblemStatus.solved;

  static ProblemStatus fromName(String name) =>
      ProblemStatus.values.firstWhere((e) => e.name == name, orElse: () => ProblemStatus.todo);

  Color color(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (this) {
      case ProblemStatus.todo:
        return scheme.onSurfaceVariant;
      case ProblemStatus.attempted:
        return AppPalette.warning;
      case ProblemStatus.solved:
        return AppPalette.success;
      case ProblemStatus.revisit:
        return AppPalette.info;
    }
  }
}

/// Status for concept leaves (theory subtopics, aptitude question-types) — a
/// lighter model than coding problems.
enum ConceptStatus {
  notStarted('Not started', Icons.circle_outlined),
  learning('Learning', Icons.menu_book_rounded),
  done('Done', Icons.check_circle_rounded),
  revise('Revise', Icons.refresh_rounded);

  const ConceptStatus(this.label, this.icon);
  final String label;
  final IconData icon;

  bool get isDone => this == ConceptStatus.done;

  static ConceptStatus fromName(String name) => ConceptStatus.values
      .firstWhere((e) => e.name == name, orElse: () => ConceptStatus.notStarted);

  Color color(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (this) {
      case ConceptStatus.notStarted:
        return scheme.onSurfaceVariant;
      case ConceptStatus.learning:
        return AppPalette.warning;
      case ConceptStatus.done:
        return AppPalette.success;
      case ConceptStatus.revise:
        return AppPalette.info;
    }
  }
}

enum Difficulty {
  easy('Easy', AppPalette.easy),
  medium('Medium', AppPalette.medium),
  hard('Hard', AppPalette.hard);

  const Difficulty(this.label, this.color);
  final String label;
  final Color color;

  static Difficulty fromName(String name) =>
      Difficulty.values.firstWhere((e) => e.name == name, orElse: () => Difficulty.medium);
}

/// Target role influences the generated roadmap weighting.
enum TargetRole {
  product('Product-based (SDE)', 'FAANG, unicorns — heavy DSA + system design'),
  service('Service-based', 'TCS, Infosys, Wipro — aptitude + core + basic DSA'),
  startup('Startup / Full-stack', 'Projects + DSA + practical skills'),
  core('Core / Non-CS', 'Domain + aptitude + basic programming');

  const TargetRole(this.label, this.description);
  final String label;
  final String description;

  static TargetRole fromName(String name) =>
      TargetRole.values.firstWhere((e) => e.name == name, orElse: () => TargetRole.product);
}

enum SkillLevel {
  beginner('Beginner', 'New to coding / just starting prep'),
  intermediate('Intermediate', 'Know basics, solved some problems'),
  advanced('Advanced', 'Comfortable, polishing for interviews');

  const SkillLevel(this.label, this.description);
  final String label;
  final String description;

  static SkillLevel fromName(String name) =>
      SkillLevel.values.firstWhere((e) => e.name == name, orElse: () => SkillLevel.beginner);
}
