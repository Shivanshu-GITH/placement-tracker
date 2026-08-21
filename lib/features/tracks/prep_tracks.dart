import 'package:flutter/material.dart';

import '../../core/constants/enums.dart';
import '../../core/theme/app_palette.dart';

/// A one-tap preparation preset: it sets the target role, daily goal, the active
/// sheets (+ primary DSA sheet), then regenerates the roadmap.
class PrepTrack {
  const PrepTrack({
    required this.key,
    required this.name,
    required this.tagline,
    required this.description,
    required this.role,
    required this.primarySlug,
    required this.activeSlugs,
    required this.dailyProblems,
    required this.dailyMinutes,
    required this.icon,
    required this.color,
  });

  final String key;
  final String name;
  final String tagline;
  final String description;
  final TargetRole role;
  final String primarySlug;
  final Set<String> activeSlugs;
  final int dailyProblems;
  final int dailyMinutes;
  final IconData icon;
  final Color color;
}

const _coreAll = {'core-os', 'core-dbms', 'core-cn', 'core-oop'};

const List<PrepTrack> kPrepTracks = [
  PrepTrack(
    key: 'product',
    name: 'Product / SDE',
    tagline: 'FAANG & product companies',
    description:
        'DSA-heavy with system design and CS core. Built around Striver A2Z.',
    role: TargetRole.product,
    primarySlug: 'striver-a2z',
    activeSlugs: {'striver-a2z', ..._coreAll, 'system-design', 'interview-hr'},
    dailyProblems: 5,
    dailyMinutes: 180,
    icon: Icons.rocket_launch_rounded,
    color: AppPalette.indigo,
  ),
  PrepTrack(
    key: 'service',
    name: 'Service / Mass Recruiter',
    tagline: 'TCS, Infosys, Wipro, Accenture',
    description:
        'Aptitude-first with CS core and a beginner-friendly DSA sheet (Apna College).',
    role: TargetRole.service,
    primarySlug: 'apna-college',
    activeSlugs: {'apna-college', 'aptitude', ..._coreAll, 'interview-hr'},
    dailyProblems: 3,
    dailyMinutes: 120,
    icon: Icons.apartment_rounded,
    color: AppPalette.mint,
  ),
  PrepTrack(
    key: 'startup',
    name: 'Startup / Full-stack',
    tagline: 'Fast-moving product startups',
    description:
        'A focused fast-track (Striver SDE) plus DBMS, OOP and system-design basics.',
    role: TargetRole.startup,
    primarySlug: 'striver-sde',
    activeSlugs: {'striver-sde', 'core-dbms', 'core-oop', 'system-design', 'interview-hr'},
    dailyProblems: 4,
    dailyMinutes: 150,
    icon: Icons.bolt_rounded,
    color: AppPalette.violet,
  ),
  PrepTrack(
    key: 'core',
    name: 'Core / Non-CS',
    tagline: 'Core engineering & analyst roles',
    description: 'Aptitude and CS fundamentals with a gentle DSA base.',
    role: TargetRole.core,
    primarySlug: 'apna-college',
    activeSlugs: {'apna-college', 'aptitude', 'core-os', 'core-dbms', 'interview-hr'},
    dailyProblems: 3,
    dailyMinutes: 90,
    icon: Icons.memory_rounded,
    color: AppPalette.catAptitude,
  ),
  PrepTrack(
    key: 'cp',
    name: 'Competitive Programming',
    tagline: 'Contests & off-campus by rating',
    description: 'Codeforces-style CP ladder alongside the A2Z fundamentals.',
    role: TargetRole.product,
    primarySlug: 'striver-cp',
    activeSlugs: {'striver-cp', 'striver-a2z'},
    dailyProblems: 6,
    dailyMinutes: 180,
    icon: Icons.emoji_events_rounded,
    color: AppPalette.warning,
  ),
  PrepTrack(
    key: 'sprint',
    name: 'Interview Sprint',
    tagline: 'Placements are near — revise fast',
    description:
        'A lean, high-intensity revision plan (SDE-79) with core theory and HR.',
    role: TargetRole.product,
    primarySlug: 'striver-sde79',
    activeSlugs: {'striver-sde79', ..._coreAll, 'interview-hr'},
    dailyProblems: 6,
    dailyMinutes: 180,
    icon: Icons.timer_rounded,
    color: AppPalette.danger,
  ),
];
