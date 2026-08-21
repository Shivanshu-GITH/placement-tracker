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

const List<Achievement> kAchievements = [
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
    key: 'hard-10', title: 'Hard Hitter',
    description: 'Solve 10 hard problems', icon: Icons.whatshot_rounded,
    color: AppPalette.danger, target: 10, value: _hard,
  ),
  Achievement(
    key: 'all-rounder', title: 'All-Rounder',
    description: 'Make progress in all 5 categories', icon: Icons.hexagon_rounded,
    color: AppPalette.catAptitude, target: 5, value: _cats,
  ),
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
    key: 'streak-30', title: 'Unstoppable',
    description: 'Reach a 30-day streak', icon: Icons.rocket_launch_rounded,
    color: AppPalette.indigo, target: 30, value: _streak,
  ),
  Achievement(
    key: 'consistent-7', title: 'Consistent',
    description: 'Hit your daily goal on 7 days', icon: Icons.event_available_rounded,
    color: AppPalette.mint, target: 7, value: _goalDays,
  ),
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
];

int _solved(AchStats s) => s.solved;
int _hard(AchStats s) => s.hardSolved;
int _cats(AchStats s) => s.categoriesCovered;
int _streak(AchStats s) => s.longestStreak;
int _goalDays(AchStats s) => s.goalDays;
int _minutes(AchStats s) => s.totalMinutes;
