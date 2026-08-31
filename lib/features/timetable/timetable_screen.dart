import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/enums.dart';
import '../../core/services/notification_service.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_palette.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/database/database.dart';
import '../../providers/providers.dart';
import 'timetable_models.dart';

/// The user's daily timetable: recurring study/habit blocks with per-block
/// reminders. Editing anything here re-syncs the scheduled notifications.
class TimetableScreen extends ConsumerWidget {
  const TimetableScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final blocks = ref.watch(timetableProvider).valueOrNull ?? const [];
    final today = ref.watch(todayTimetableProvider);
    final current = ref.watch(currentBlockProvider);
    final todayIds = {for (final b in today) b.id};
    final otherDays = [
      for (final b in blocks)
        if (!todayIds.contains(b.id)) b,
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('My timetable'),
        titleTextStyle: theme.textTheme.headlineSmall,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add block'),
      ),
      body: blocks.isEmpty
          ? _EmptyTimetable(onStarter: () => _addStarter(context, ref))
          : ListView(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenH,
                  AppSpacing.md, AppSpacing.screenH, AppSpacing.huge + 60),
              children: [
                Text('TODAY · ${Weekdays.shortLabels[DateTime.now().weekday - 1]}',
                    style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: AppSpacing.sm),
                if (today.isEmpty)
                  AppCard(
                    child: Text('Nothing scheduled today.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                  )
                else
                  for (final b in today)
                    _BlockTile(
                      block: b,
                      highlighted: current?.id == b.id,
                      onTap: () => _edit(context, ref, block: b),
                      onToggle: (v) => _setEnabled(ref, b, v),
                    ),
                // Only the blocks that DON'T run today, so nothing is listed
                // twice on a day when the whole timetable is active.
                if (otherDays.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xl),
                  Text('OTHER DAYS',
                      style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: AppSpacing.sm),
                  for (final b in otherDays)
                    _BlockTile(
                      block: b,
                      onTap: () => _edit(context, ref, block: b),
                      onToggle: (v) => _setEnabled(ref, b, v),
                    ),
                ],
              ],
            ),
    );
  }

  Future<void> _setEnabled(
      WidgetRef ref, TimetableBlock b, bool enabled) async {
    await ref.read(timetableRepositoryProvider).setEnabled(b.id, enabled);
    await syncTimetableReminders(ref);
  }

  /// Seeds a sensible starting timetable so the feature is useful immediately.
  Future<void> _addStarter(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(timetableRepositoryProvider);
    await repo.add(
      title: 'DSA practice',
      category: PrepCategory.dsa.name,
      startMinute: 7 * 60,
      durationMinutes: 90,
      daysMask: Weekdays.all,
      leadMinutes: 10,
    );
    await repo.add(
      title: 'Core subjects',
      category: PrepCategory.core.name,
      startMinute: 18 * 60,
      durationMinutes: 45,
      daysMask: Weekdays.weekdays,
      leadMinutes: 10,
    );
    await repo.add(
      title: 'Aptitude drill',
      category: PrepCategory.aptitude.name,
      startMinute: 21 * 60,
      durationMinutes: 30,
      daysMask: Weekdays.all,
      leadMinutes: 5,
    );
    await _ensurePermissionAndSync(ref);
  }

  /// Asks for notification permission (no-op if already answered) and rebuilds
  /// the scheduled reminders from the saved blocks.
  Future<void> _ensurePermissionAndSync(WidgetRef ref) async {
    await NotificationService.instance.requestPermission();
    await syncTimetableReminders(ref);
  }

  /// Opens the block editor. Passing [block] edits it, otherwise creates one.
  Future<void> _edit(BuildContext context, WidgetRef ref,
      {TimetableBlock? block}) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _BlockEditor(block: block),
    );
    if (saved == true) await _ensurePermissionAndSync(ref);
  }
}

class _EmptyTimetable extends StatelessWidget {
  const _EmptyTimetable({required this.onStarter});
  final VoidCallback onStarter;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const EmptyState(
              icon: Icons.schedule_rounded,
              title: 'Plan your day',
              message:
                  'Block out when you study each subject. PrepPilot will remind '
                  'you at the right time and track the habit.',
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: onStarter,
              icon: const Icon(Icons.auto_awesome_rounded, size: 18),
              label: const Text('Use a starter timetable'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BlockTile extends StatelessWidget {
  const _BlockTile({
    required this.block,
    required this.onTap,
    required this.onToggle,
    this.highlighted = false,
  });
  final TimetableBlock block;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggle;

  /// True for the block happening now (or next up today).
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cat = categoryFromName(block.category);
    final accent = cat?.color ?? AppPalette.indigo;
    final end = block.startMinute + block.durationMinutes;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        padding: EdgeInsets.zero,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 44,
                  decoration: BoxDecoration(
                    color: block.enabled ? accent : theme.disabledColor,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              block.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: block.enabled
                                    ? null
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          if (highlighted) ...[
                            const SizedBox(width: AppSpacing.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.15),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.pill),
                              ),
                              child: Text('NEXT',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                      color: accent,
                                      fontWeight: FontWeight.w800)),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${formatMinuteOfDay(block.startMinute)} – '
                        '${formatMinuteOfDay(end)} · ${Weekdays.label(block.daysMask)}'
                        '${block.reminder ? '' : ' · muted'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Switch(value: block.enabled, onChanged: onToggle),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Create/edit sheet for one timetable block.
class _BlockEditor extends ConsumerStatefulWidget {
  const _BlockEditor({this.block});
  final TimetableBlock? block;

  @override
  ConsumerState<_BlockEditor> createState() => _BlockEditorState();
}

class _BlockEditorState extends ConsumerState<_BlockEditor> {
  late final TextEditingController _title =
      TextEditingController(text: widget.block?.title ?? '');
  late int _start = widget.block?.startMinute ?? 19 * 60;
  late int _duration = widget.block?.durationMinutes ?? 60;
  late int _days = widget.block?.daysMask ?? Weekdays.all;
  late String _category = widget.block?.category ?? '';
  late bool _reminder = widget.block?.reminder ?? true;
  late int _lead = widget.block?.leadMinutes ?? 10;
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    FocusScope.of(context).unfocus();
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _start ~/ 60, minute: _start % 60),
    );
    if (picked != null) {
      setState(() => _start = picked.hour * 60 + picked.minute);
    }
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    if (title.isEmpty || _days == 0) return;
    setState(() => _saving = true);
    final repo = ref.read(timetableRepositoryProvider);
    final existing = widget.block;
    if (existing == null) {
      await repo.add(
        title: title,
        startMinute: _start,
        durationMinutes: _duration,
        daysMask: _days,
        category: _category,
        reminder: _reminder,
        leadMinutes: _lead,
      );
    } else {
      await repo.update(existing.copyWith(
        title: title,
        startMinute: _start,
        durationMinutes: _duration,
        daysMask: _days,
        category: _category,
        reminder: _reminder,
        leadMinutes: _lead,
      ));
    }
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _delete() async {
    final b = widget.block;
    if (b == null) return;
    await ref.read(timetableRepositoryProvider).delete(b.id);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final valid = _title.text.trim().isNotEmpty && _days != 0;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                      widget.block == null ? 'New block' : 'Edit block',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800)),
                ),
                if (widget.block != null)
                  IconButton(
                    tooltip: 'Delete',
                    onPressed: _saving ? null : _delete,
                    icon: Icon(Icons.delete_outline_rounded,
                        color: theme.colorScheme.error),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _title,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'What are you doing?',
                hintText: 'e.g. DSA practice',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: _Field(
                    label: 'Starts',
                    value: formatMinuteOfDay(_start),
                    icon: Icons.schedule_rounded,
                    onTap: _pickTime,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _Field(
                    label: 'For',
                    value: '$_duration min',
                    icon: Icons.timelapse_rounded,
                    onTap: () async {
                      final picked = await showModalBottomSheet<int>(
                        context: context,
                        builder: (ctx) => _DurationPicker(current: _duration),
                      );
                      if (picked != null) setState(() => _duration = picked);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('REPEATS ON',
                style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 6,
              children: [
                for (var i = 0; i < 7; i++)
                  FilterChip(
                    label: Text(Weekdays.shortLabels[i]),
                    selected: Weekdays.hasDay(_days, i),
                    onSelected: (_) =>
                        setState(() => _days = Weekdays.toggle(_days, i)),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('SUBJECT (OPTIONAL)',
                style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ChoiceChip(
                  label: const Text('None'),
                  selected: _category.isEmpty,
                  onSelected: (_) => setState(() => _category = ''),
                ),
                for (final c in PrepCategory.values)
                  ChoiceChip(
                    label: Text(c.label),
                    selected: _category == c.name,
                    onSelected: (_) => setState(() => _category = c.name),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _reminder,
              onChanged: (v) => setState(() => _reminder = v),
              title: const Text('Remind me'),
              subtitle: Text(_reminder
                  ? (_lead == 0
                      ? 'At the start time'
                      : '$_lead min before it starts')
                  : 'No notification'),
            ),
            if (_reminder)
              Slider(
                value: _lead.toDouble(),
                min: 0,
                max: 30,
                divisions: 6,
                label: _lead == 0 ? 'On time' : '$_lead min before',
                onChanged: (v) => setState(() => _lead = v.round()),
              ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: (!valid || _saving) ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.4, color: Colors.white))
                    : const Text('Save block'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 18, color: scheme.primary),
        ),
        child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}

class _DurationPicker extends StatelessWidget {
  const _DurationPicker({required this.current});
  final int current;

  static const _options = [15, 30, 45, 60, 90, 120, 150, 180];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          for (final m in _options)
            ListTile(
              onTap: () => Navigator.pop(context, m),
              leading: Icon(
                m == current
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: m == current
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              title: Text(m < 60
                  ? '$m minutes'
                  : '${m ~/ 60}h${m % 60 == 0 ? '' : ' ${m % 60}m'}'),
            ),
        ],
      ),
    );
  }
}
