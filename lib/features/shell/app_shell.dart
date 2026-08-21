import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_dimens.dart';
import '../dashboard/dashboard_screen.dart';
import '../leaderboard/leaderboard_screen.dart';
import '../profile/profile_screen.dart';
import '../resources/resources_screen.dart';
import '../roadmap/roadmap_screen.dart';
import '../tracker/tracker_screen.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _index = 0;

  static const _tabs = <_TabSpec>[
    _TabSpec('Home', Icons.home_rounded, Icons.home_outlined),
    _TabSpec('Tracker', Icons.checklist_rounded, Icons.checklist_outlined),
    _TabSpec('Roadmap', Icons.map_rounded, Icons.map_outlined),
    _TabSpec('Ranks', Icons.leaderboard_rounded, Icons.leaderboard_outlined),
    _TabSpec('Resources', Icons.menu_book_rounded, Icons.menu_book_outlined),
    _TabSpec('Profile', Icons.person_rounded, Icons.person_outline_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          DashboardScreen(),
          TrackerScreen(),
          RoadmapScreen(),
          LeaderboardScreen(),
          ResourcesScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        tabs: _tabs,
        index: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

class _TabSpec {
  const _TabSpec(this.label, this.active, this.inactive);
  final String label;
  final IconData active;
  final IconData inactive;
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.tabs,
    required this.index,
    required this.onTap,
  });

  final List<_TabSpec> tabs;
  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outline)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              for (var i = 0; i < tabs.length; i++)
                Expanded(
                  child: _NavItem(
                    spec: tabs[i],
                    selected: i == index,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.spec,
    required this.selected,
    required this.onTap,
  });

  final _TabSpec spec;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = selected ? scheme.primary : scheme.onSurfaceVariant;
    return InkResponse(
      onTap: onTap,
      radius: 44,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: AppMotion.fast,
            curve: AppMotion.enter,
            padding: EdgeInsets.symmetric(
              horizontal: selected ? 12 : 8,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? scheme.primaryContainer.withValues(alpha: 0.7)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Icon(selected ? spec.active : spec.inactive,
                color: color, size: 24),
          ),
          const SizedBox(height: 3),
          Text(
            spec.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
