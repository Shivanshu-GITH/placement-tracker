import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';

/// Metrics that drive achievement unlocks (all derived from existing data).
class AchStats {
  const AchStats({
    required this.solved,
    required this.hardSolved,
    required this.categoriesCovered,
    required this.longestStreak,
    required this.goalDays,
    required this.totalMinutes,
  });

  final int solved;
  final int hardSolved;
  final int categoriesCovered;
  final int longestStreak;
  final int goalDays;
  final int totalMinutes;
}

class Achievement {
  const Achievement({
    required this.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.target,
    required this.value,
  });

  final String key;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final int target;
  final int Function(AchStats s) value;

  int current(AchStats s) => value(s).clamp(0, target);
  bool earned(AchStats s) => value(s) >= target;
  double progress(AchStats s) => (value(s) / target).clamp(0.0, 1.0);
}

/// Badges, grouped by the metric they track and ordered by difficulty so the
/// grid reads as a progression. Every badge has a distinct icon + colour.
const List<Achievement> kAchievements = [
  // ---- Problems solved --------------------------------------------------
  Achievement(
    key: 'first-solve', title: 'First Blood',
    description: 'Solve your first problem', icon: Icons.bolt_rounded,
    color: AppPalette.mint, target: 1, value: _solved,
  ),
  Achievement(
    key: 'solve-10', title: 'Warming Up',
    description: 'Solve 10 problems', icon: Icons.local_fire_department_rounded,
    color: AppPalette.warning, target: 10, value: _solved,
  ),
  Achievement(
    key: 'solve-25', title: 'Quarter Century',
    description: 'Solve 25 problems', icon: Icons.trending_up_rounded,
    color: AppPalette.info, target: 25, value: _solved,
  ),
  Achievement(
    key: 'solve-50', title: 'Half Century',
    description: 'Solve 50 problems', icon: Icons.military_tech_rounded,
    color: AppPalette.indigo, target: 50, value: _solved,
  ),
  Achievement(
    key: 'solve-100', title: 'Centurion',
    description: 'Solve 100 problems', icon: Icons.workspace_premium_rounded,
    color: AppPalette.violet, target: 100, value: _solved,
  ),
  Achievement(
    key: 'solve-250', title: '250 Club',
    description: 'Solve 250 problems', icon: Icons.diamond_rounded,
    color: AppPalette.catSystem, target: 250, value: _solved,
  ),
  Achievement(
    key: 'solve-500', title: 'Grandmaster',
    description: 'Solve 500 problems', icon: Icons.shield_rounded,
    color: AppPalette.catCp, target: 500, value: _solved,
  ),
  // ---- Hard problems ----------------------------------------------------
  Achievement(
    key: 'hard-10', title: 'Hard Hitter',
    description: 'Solve 10 hard problems', icon: Icons.whatshot_rounded,
    color: AppPalette.danger, target: 10, value: _hard,
  ),
  Achievement(
    key: 'hard-25', title: 'Fearless',
    description: 'Solve 25 hard problems', icon: Icons.flash_on_rounded,
    color: AppPalette.catInterview, target: 25, value: _hard,
  ),
  Achievement(
    key: 'hard-50', title: 'Nightmare Mode',
    description: 'Solve 50 hard problems', icon: Icons.psychology_alt_rounded,
    color: AppPalette.violet, target: 50, value: _hard,
  ),
  // ---- Streak -----------------------------------------------------------
  Achievement(
    key: 'streak-3', title: 'On a Roll',
    description: 'Reach a 3-day streak', icon: Icons.bolt_rounded,
    color: AppPalette.warning, target: 3, value: _streak,
  ),
  Achievement(
    key: 'streak-7', title: 'Week Warrior',
    description: 'Reach a 7-day streak', icon: Icons.local_fire_department_rounded,
    color: AppPalette.catInterview, target: 7, value: _streak,
  ),
  Achievement(
    key: 'streak-14', title: 'Fortnight',
    description: 'Reach a 14-day streak', icon: Icons.date_range_rounded,
    color: AppPalette.mint, target: 14, value: _streak,
  ),
  Achievement(
    key: 'streak-30', title: 'Unstoppable',
    description: 'Reach a 30-day streak', icon: Icons.rocket_launch_rounded,
    color: AppPalette.indigo, target: 30, value: _streak,
  ),
  Achievement(
    key: 'streak-100', title: 'Century Streak',
    description: 'Reach a 100-day streak', icon: Icons.auto_awesome_rounded,
    color: AppPalette.danger, target: 100, value: _streak,
  ),
  // ---- Consistency (days the daily goal was met) ------------------------
  Achievement(
    key: 'consistent-7', title: 'Consistent',
    description: 'Hit your daily goal on 7 days',
    icon: Icons.event_available_rounded,
    color: AppPalette.mint, target: 7, value: _goalDays,
  ),
  Achievement(
    key: 'goal-30', title: 'Habit Formed',
    description: 'Hit your daily goal on 30 days', icon: Icons.task_alt_rounded,
    color: AppPalette.info, target: 30, value: _goalDays,
  ),
  Achievement(
    key: 'goal-75', title: 'Iron Will',
    description: 'Hit your daily goal on 75 days', icon: Icons.verified_rounded,
    color: AppPalette.catSystem, target: 75, value: _goalDays,
  ),
  // ---- Study time -------------------------------------------------------
  Achievement(
    key: 'deep-work', title: 'Deep Work',
    description: 'Study for 10 total hours', icon: Icons.timer_rounded,
    color: AppPalette.info, target: 600, value: _minutes,
  ),
  Achievement(
    key: 'marathon', title: 'Marathoner',
    description: 'Study for 50 total hours', icon: Icons.emoji_events_rounded,
    color: AppPalette.warning, target: 3000, value: _minutes,
  ),
  Achievement(
    key: 'century-hours', title: '100 Hours Deep',
    description: 'Study for 100 total hours',
    icon: Icons.hourglass_bottom_rounded,
    color: AppPalette.violet, target: 6000, value: _minutes,
  ),
  // ---- Breadth ----------------------------------------------------------
  Achievement(
    key: 'all-rounder', title: 'All-Rounder',
    description: 'Make progress in all 7 categories',
    icon: Icons.hexagon_rounded,
    color: AppPalette.catAptitude, target: 7, value: _cats,
  ),
];

int _solved(AchStats s) => s.solved;
int _hard(AchStats s) => s.hardSolved;
int _cats(AchStats s) => s.categoriesCovered;
int _streak(AchStats s) => s.longestStreak;
int _goalDays(AchStats s) => s.goalDays;
int _minutes(AchStats s) => s.totalMinutes;
