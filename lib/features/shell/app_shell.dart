import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_dimens.dart';
import '../../providers/providers.dart';
import '../ads/ad_config.dart';
import '../ads/ad_service.dart';
import '../ads/banner_ad_widget.dart';
import '../dashboard/dashboard_screen.dart';
import '../leaderboard/leaderboard_screen.dart';
import '../planner/planner_screen.dart';
import '../profile/profile_screen.dart';
import '../resources/resources_screen.dart';
import '../tracker/tracker_screen.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell>
    with WidgetsBindingObserver {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Returning to the app from the background is a natural, policy-friendly
    // moment for an app-open ad (frequency-capped inside the manager).
    if (state == AppLifecycleState.resumed) {
      AdService.instance.appOpen.maybeShow();
    }
  }

  static const _tabs = <_TabSpec>[
    _TabSpec('Home', Icons.home_rounded, Icons.home_outlined),
    _TabSpec('Tracker', Icons.checklist_rounded, Icons.checklist_outlined),
    _TabSpec('Planner', Icons.flag_rounded, Icons.flag_outlined),
    _TabSpec('Ranks', Icons.leaderboard_rounded, Icons.leaderboard_outlined),
    _TabSpec('Resources', Icons.menu_book_rounded, Icons.menu_book_outlined),
    _TabSpec('Profile', Icons.person_rounded, Icons.person_outline_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _index,
              children: const [
                DashboardScreen(),
                TrackerScreen(),
                PlannerScreen(),
                LeaderboardScreen(),
                ResourcesScreen(),
                ProfileScreen(),
              ],
            ),
          ),
          // Banner only when ads are on and the user isn't premium.
          if (AdConfig.enabled && !ref.watch(premiumProvider))
            const BottomBannerAd(),
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
            // The bar is a fixed 64dp tall; cap label scaling so very large
            // accessibility font sizes can't overflow it.
            textScaler:
                MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.3),
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
