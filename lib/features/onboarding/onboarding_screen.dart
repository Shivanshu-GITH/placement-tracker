import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/enums.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_palette.dart';
import '../../data/database/database.dart';
import '../../providers/providers.dart';
import '../leaderboard/college_picker.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;
  bool _submitting = false;

  // Collected answers.
  final _nameController = TextEditingController();
  String? _college;
  TargetRole _role = TargetRole.product;
  SkillLevel _level = SkillLevel.beginner;
  int _months = 3;
  int _dailyHours = 2;
  final Set<String> _companies = {};

  // Sheet selection (populated from a smart default once sheets load).
  final Set<int> _activeSheets = {};
  int? _primarySheet;
  bool _sheetsInit = false;

  static const _companyOptions = [
    'Google', 'Amazon', 'Microsoft', 'Adobe', 'Atlassian', 'Uber',
    'Flipkart', 'Swiggy', 'TCS', 'Infosys', 'Wipro', 'Accenture',
  ];

  static const _totalPages = 6;

  /// Recommended default active sheets given the chosen role/skill.
  void _computeDefaultSelection(List<Sheet> sheets) {
    final primarySlug =
        _level == SkillLevel.beginner ? 'apna-college' : 'striver-a2z';
    final active = <String>{
      primarySlug,
      'core-os', 'core-dbms', 'core-cn', 'core-oop',
      'aptitude', 'interview-hr',
      if (_role == TargetRole.product || _role == TargetRole.startup)
        'system-design',
      if (_role == TargetRole.startup || _role == TargetRole.product)
        'web-dev',
    };
    _activeSheets.clear();
    for (final s in sheets) {
      if (active.contains(s.slug)) _activeSheets.add(s.id);
      if (s.slug == primarySlug) _primarySheet = s.id;
    }
  }

  @override
  void initState() {
    super.initState();
    // Prefill the name & college from the signed-in Google identity, if any.
    ref.read(lbIdentityProvider.future).then((id) {
      if (!mounted) return;
      final n = id.name.trim();
      setState(() {
        if (n.isNotEmpty && n != 'You' && _nameController.text.trim().isEmpty) {
          _nameController.text = n;
        }
        _college ??= (id.college != null && id.college!.isNotEmpty)
            ? id.college
            : null;
      });
    });
  }

  Future<void> _pickCollege() async {
    final picked = await showCollegePicker(context, current: _college);
    if (picked != null) {
      setState(() => _college = picked.isEmpty ? null : picked);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _totalPages - 1) {
      _controller.nextPage(
          duration: AppMotion.medium, curve: AppMotion.emphasized);
    } else {
      _finish();
    }
  }

  void _back() {
    if (_page > 0) {
      _controller.previousPage(
          duration: AppMotion.medium, curve: AppMotion.emphasized);
    }
  }

  Future<void> _finish() async {
    setState(() => _submitting = true);
    try {
      // Persist sheet selection and the primary DSA sheet FIRST — the planner
      // reads the active sheets and the target date live, so they should be in
      // place before onboarding flips and opens the app shell.
      final repo = ref.read(prepRepositoryProvider);
      final sheets = ref.read(sheetsProvider).valueOrNull ?? const [];
      for (final s in sheets) {
        await repo.setSheetActive(s.id, _activeSheets.contains(s.id));
      }
      if (_primarySheet != null) {
        await repo.setPrimarySheet(_primarySheet!);
      }

      // Persist the leaderboard identity (name + college) for THIS account, and
      // if signed in, push the initial stats so they appear on the boards.
      final name = _nameController.text.trim().isEmpty
          ? 'Aspirant'
          : _nameController.text.trim();
      await saveLbIdentity(ref, name, _college);
      final board = ref.read(leaderboardRepositoryProvider);
      if (ref.read(authUserProvider).valueOrNull != null && board.isLive) {
        try {
          await board.syncMyStats(ref.read(myStatsProvider),
              name: name, college: _college);
        } catch (_) {
          // Non-fatal — stats sync will retry on next app open.
        }
      }

      // Flip onboarded LAST — the profileProvider stream then advances the
      // router to the shell, with sheets + deadline already set.
      await ref.read(profileRepositoryProvider).completeOnboarding(
            name: _nameController.text,
            targetRole: _role.name,
            targetCompanies: _companies.toList(),
            skillLevel: _level.name,
            dailyGoalMinutes: _dailyHours * 60,
            dailyGoalProblems: (_dailyHours * 2).clamp(2, 12),
            targetDate: DateTime.now().add(Duration(days: _months * 30)),
          );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sheets = ref.watch(sheetsProvider).valueOrNull ?? const [];
    if (!_sheetsInit && sheets.isNotEmpty) {
      _sheetsInit = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _computeDefaultSelection(sheets));
      });
    }
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _ProgressBar(page: _page, total: _totalPages, onBack: _back),
            Expanded(
              child: PageView(
                controller: _controller,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _WelcomeStep(
                    nameController: _nameController,
                    college: _college,
                    onPickCollege: _pickCollege,
                  ),
                  _RoleStep(
                    selected: _role,
                    onSelect: (r) => setState(() => _role = r),
                  ),
                  _LevelStep(
                    selected: _level,
                    onSelect: (l) => setState(() => _level = l),
                  ),
                  _CompaniesStep(
                    options: _companyOptions,
                    selected: _companies,
                    onToggle: (c) => setState(() {
                      _companies.contains(c)
                          ? _companies.remove(c)
                          : _companies.add(c);
                    }),
                  ),
                  _GoalStep(
                    months: _months,
                    dailyHours: _dailyHours,
                    onMonths: (v) => setState(() => _months = v),
                    onHours: (v) => setState(() => _dailyHours = v),
                  ),
                  _SheetsStep(
                    sheets: sheets,
                    active: _activeSheets,
                    primary: _primarySheet,
                    onToggle: (id) => setState(() {
                      _activeSheets.contains(id)
                          ? _activeSheets.remove(id)
                          : _activeSheets.add(id);
                    }),
                    onPrimary: (id) => setState(() {
                      _primarySheet = id;
                      _activeSheets.add(id);
                    }),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: FilledButton(
                onPressed: _submitting ? null : _next,
                child: _submitting
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white),
                      )
                    : Text(_page == _totalPages - 1
                        ? 'Generate my roadmap'
                        : 'Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar(
      {required this.page, required this.total, required this.onBack});
  final int page;
  final int total;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.sm, AppSpacing.xl, AppSpacing.sm),
      child: Row(
        children: [
          IconButton(
            onPressed: page == 0 ? null : onBack,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          Expanded(
            child: Row(
              children: [
                for (var i = 0; i < total; i++)
                  Expanded(
                    child: AnimatedContainer(
                      duration: AppMotion.fast,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: i <= page
                            ? scheme.primary
                            : scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---- Step scaffolding -----------------------------------------------------

class _StepShell extends StatelessWidget {
  const _StepShell({
    required this.title,
    required this.subtitle,
    required this.child,
  });
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),
          Text(title, style: theme.textTheme.headlineMedium)
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.1, end: 0),
          const SizedBox(height: AppSpacing.sm),
          Text(subtitle,
                  style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant))
              .animate()
              .fadeIn(delay: 100.ms, duration: 400.ms),
          const SizedBox(height: AppSpacing.xxl),
          child,
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep({
    required this.nameController,
    required this.college,
    required this.onPickCollege,
  });
  final TextEditingController nameController;
  final String? college;
  final Future<void> Function() onPickCollege;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return _StepShell(
      title: 'Welcome to PrepPilot 🚀',
      subtitle:
          'Let\'s set up a plan that gets you placement-ready. First, tell us a bit about you.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Friendly gradient hero.
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: AppPalette.brandGradient,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: [
                BoxShadow(
                  color: AppPalette.indigo.withValues(alpha: 0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(Icons.waving_hand_rounded,
                      color: Colors.white, size: 26),
                ),
                const SizedBox(width: AppSpacing.lg),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Just two quick things',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800)),
                      SizedBox(height: 2),
                      Text(
                          'They personalize your roadmap and put you on your leaderboards.',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 12.5)),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.12, end: 0),
          const SizedBox(height: AppSpacing.xxl),
          _FieldLabel('YOUR NAME'),
          const SizedBox(height: AppSpacing.sm),
          _FieldCard(
            icon: Icons.person_rounded,
            child: TextField(
              controller: nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
                hintText: 'e.g. Shivanshu Tiwari',
              ),
            ),
          ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.12, end: 0),
          const SizedBox(height: AppSpacing.lg),
          _FieldLabel('COLLEGE'),
          const SizedBox(height: AppSpacing.sm),
          _FieldCard(
            icon: Icons.school_rounded,
            onTap: onPickCollege,
            trailing: Icon(Icons.expand_more_rounded,
                color: scheme.onSurfaceVariant),
            child: Text(
              college ?? 'Select your college',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                color: college == null
                    ? scheme.onSurfaceVariant
                    : scheme.onSurface,
              ),
            ),
          ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.12, end: 0),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline_rounded,
                    size: 18, color: scheme.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'You can change your name and college anytime in Profile.',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 350.ms),
        ],
      ),
    );
  }
}

/// Small uppercase field label used in the onboarding welcome step.
class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
      ),
    );
  }
}

/// A filled, rounded field container with a leading icon — used for both the
/// name input and the tappable college picker so they read as a matching set.
class _FieldCard extends StatelessWidget {
  const _FieldCard({
    required this.icon,
    required this.child,
    this.onTap,
    this.trailing,
  });
  final IconData icon;
  final Widget child;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: scheme.primary),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: child),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleStep extends StatelessWidget {
  const _RoleStep({required this.selected, required this.onSelect});
  final TargetRole selected;
  final ValueChanged<TargetRole> onSelect;

  @override
  Widget build(BuildContext context) {
    return _StepShell(
      title: 'What are you targeting?',
      subtitle: 'This shapes how we weight DSA, aptitude and system design.',
      child: Column(
        children: [
          for (var i = 0; i < TargetRole.values.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _SelectCard(
                title: TargetRole.values[i].label,
                subtitle: TargetRole.values[i].description,
                selected: selected == TargetRole.values[i],
                onTap: () => onSelect(TargetRole.values[i]),
              ).animate().fadeIn(delay: (80 * i).ms).slideX(begin: 0.1, end: 0),
            ),
        ],
      ),
    );
  }
}

class _LevelStep extends StatelessWidget {
  const _LevelStep({required this.selected, required this.onSelect});
  final SkillLevel selected;
  final ValueChanged<SkillLevel> onSelect;

  @override
  Widget build(BuildContext context) {
    return _StepShell(
      title: 'Where are you right now?',
      subtitle: 'Be honest — we\'ll calibrate the plan\'s starting point.',
      child: Column(
        children: [
          for (var i = 0; i < SkillLevel.values.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _SelectCard(
                title: SkillLevel.values[i].label,
                subtitle: SkillLevel.values[i].description,
                selected: selected == SkillLevel.values[i],
                onTap: () => onSelect(SkillLevel.values[i]),
              ).animate().fadeIn(delay: (80 * i).ms).slideX(begin: 0.1, end: 0),
            ),
        ],
      ),
    );
  }
}

class _CompaniesStep extends StatelessWidget {
  const _CompaniesStep({
    required this.options,
    required this.selected,
    required this.onToggle,
  });
  final List<String> options;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _StepShell(
      title: 'Any dream companies?',
      subtitle: 'Optional — pick a few to keep yourself motivated.',
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          for (var i = 0; i < options.length; i++)
            GestureDetector(
              onTap: () => onToggle(options[i]),
              child: AnimatedContainer(
                duration: AppMotion.fast,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: selected.contains(options[i])
                      ? scheme.primary
                      : scheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(
                    color: selected.contains(options[i])
                        ? scheme.primary
                        : scheme.outline,
                  ),
                ),
                child: Text(
                  options[i],
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: selected.contains(options[i])
                        ? Colors.white
                        : scheme.onSurface,
                  ),
                ),
              ),
            ).animate().fadeIn(delay: (40 * i).ms).scaleXY(begin: 0.9, end: 1),
        ],
      ),
    );
  }
}

class _GoalStep extends StatelessWidget {
  const _GoalStep({
    required this.months,
    required this.dailyHours,
    required this.onMonths,
    required this.onHours,
  });
  final int months;
  final int dailyHours;
  final ValueChanged<int> onMonths;
  final ValueChanged<int> onHours;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _StepShell(
      title: 'Set your pace',
      subtitle: 'We\'ll build phases and a daily schedule around this.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SliderTile(
            label: 'Months until placements',
            value: months,
            min: 1,
            max: 12,
            suffix: months == 1 ? 'month' : 'months',
            onChanged: onMonths,
            accent: AppPalette.indigo,
          ),
          const SizedBox(height: AppSpacing.xl),
          _SliderTile(
            label: 'Hours you can study daily',
            value: dailyHours,
            min: 1,
            max: 10,
            suffix: dailyHours == 1 ? 'hour' : 'hours',
            onChanged: onHours,
            accent: AppPalette.mint,
          ),
          const SizedBox(height: AppSpacing.xxl),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_awesome_rounded,
                    color: theme.colorScheme.primary),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'That\'s about ${dailyHours * 2} problems a day and '
                    '${(dailyHours * 60 * 6 * months * 4.3 / 60).round()}+ study hours before your target.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetsStep extends StatelessWidget {
  const _SheetsStep({
    required this.sheets,
    required this.active,
    required this.primary,
    required this.onToggle,
    required this.onPrimary,
  });
  final List<Sheet> sheets;
  final Set<int> active;
  final int? primary;
  final ValueChanged<int> onToggle;
  final ValueChanged<int> onPrimary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final byCat = <PrepCategory, List<Sheet>>{};
    for (final s in sheets) {
      byCat.putIfAbsent(PrepCategory.fromName(s.category), () => []).add(s);
    }
    final cats = PrepCategory.values.where(byCat.containsKey).toList();

    return _StepShell(
      title: 'Choose your sheets',
      subtitle:
          'We\'ve pre-picked a solid set. Keep only what you\'ll actually solve — you can change this anytime in Profile.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final cat in cats) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 6, top: AppSpacing.sm),
              child: Row(
                children: [
                  Icon(cat.icon, size: 16, color: cat.color),
                  const SizedBox(width: 6),
                  Text(cat.label,
                      style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            for (final s in byCat[cat]!)
              _SheetPickRow(
                sheet: s,
                selected: active.contains(s.id),
                isDsa: cat == PrepCategory.dsa,
                isPrimary: s.id == primary,
                onToggle: () => onToggle(s.id),
                onPrimary: () => onPrimary(s.id),
              ),
          ],
        ],
      ),
    );
  }
}

class _SheetPickRow extends StatelessWidget {
  const _SheetPickRow({
    required this.sheet,
    required this.selected,
    required this.isDsa,
    required this.isPrimary,
    required this.onToggle,
    required this.onPrimary,
  });
  final Sheet sheet;
  final bool selected;
  final bool isDsa;
  final bool isPrimary;
  final VoidCallback onToggle;
  final VoidCallback onPrimary;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: selected
              ? scheme.primaryContainer.withValues(alpha: 0.5)
              : scheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
              color: selected ? scheme.primary : scheme.outline,
              width: selected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.circle_outlined,
              color: selected ? scheme.primary : scheme.onSurfaceVariant,
              size: 22,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(sheet.title,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
            ),
            if (isDsa && selected)
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: onPrimary,
                icon: Icon(
                  isPrimary ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: isPrimary ? scheme.primary : scheme.onSurfaceVariant,
                  size: 20,
                ),
                tooltip: 'Primary DSA sheet',
              ),
          ],
        ),
      ),
    );
  }
}

class _SliderTile extends StatelessWidget {
  const _SliderTile({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.suffix,
    required this.onChanged,
    required this.accent,
  });
  final String label;
  final int value;
  final int min;
  final int max;
  final String suffix;
  final ValueChanged<int> onChanged;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: theme.textTheme.titleSmall),
            Text('$value $suffix',
                style: theme.textTheme.titleMedium
                    ?.copyWith(color: accent, fontWeight: FontWeight.w800)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: accent,
            thumbColor: accent,
            overlayColor: accent.withValues(alpha: 0.15),
            inactiveTrackColor: theme.colorScheme.surfaceContainerHighest,
            trackHeight: 6,
          ),
          child: Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min,
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
      ],
    );
  }
}

class _SelectCard extends StatelessWidget {
  const _SelectCard({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: selected
              ? scheme.primaryContainer.withValues(alpha: 0.6)
              : scheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: selected ? scheme.primary : scheme.outline,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant)),
                ],
              ),
            ),
            AnimatedScale(
              duration: AppMotion.fast,
              scale: selected ? 1 : 0,
              child: Icon(Icons.check_circle_rounded, color: scheme.primary),
            ),
          ],
        ),
      ),
    );
  }
}
