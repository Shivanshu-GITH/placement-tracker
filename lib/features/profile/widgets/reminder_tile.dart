import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/notification_service.dart';
import '../../../core/theme/app_dimens.dart';

/// A self-contained daily-reminder setting: toggle + time, persisted locally
/// and scheduled through [NotificationService].
class ReminderTile extends StatefulWidget {
  const ReminderTile({super.key});

  @override
  State<ReminderTile> createState() => _ReminderTileState();
}

class _ReminderTileState extends State<ReminderTile> {
  static const _kEnabled = 'reminder_enabled';
  static const _kHour = 'reminder_hour';
  static const _kMinute = 'reminder_minute';

  bool _enabled = false;
  int _hour = 20;
  int _minute = 0;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _enabled = prefs.getBool(_kEnabled) ?? false;
      _hour = prefs.getInt(_kHour) ?? 20;
      _minute = prefs.getInt(_kMinute) ?? 0;
      _loaded = true;
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kEnabled, _enabled);
    await prefs.setInt(_kHour, _hour);
    await prefs.setInt(_kMinute, _minute);
  }

  Future<void> _onToggle(bool value) async {
    if (value) {
      final granted = await NotificationService.instance.requestPermission();
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Enable notifications in system settings to get reminders.')));
        }
        return;
      }
      await NotificationService.instance
          .scheduleDailyReminder(hour: _hour, minute: _minute);
    } else {
      await NotificationService.instance.cancelDailyReminder();
    }
    setState(() => _enabled = value);
    await _save();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _hour, minute: _minute),
    );
    if (picked == null) return;
    setState(() {
      _hour = picked.hour;
      _minute = picked.minute;
    });
    await _save();
    if (_enabled) {
      await NotificationService.instance
          .scheduleDailyReminder(hour: _hour, minute: _minute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeLabel = TimeOfDay(hour: _hour, minute: _minute).format(context);
    return Column(
      children: [
        SwitchListTile(
          value: _enabled,
          onChanged: _loaded ? _onToggle : null,
          secondary: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(Icons.notifications_active_rounded,
                color: theme.colorScheme.primary, size: 20),
          ),
          title: Text('Daily reminder',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
          subtitle: Text('Nudge me to keep my streak',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ),
        if (_enabled)
          ListTile(
            onTap: _pickTime,
            leading: const SizedBox(width: 36),
            title: Text('Reminder time', style: theme.textTheme.bodyMedium),
            trailing: Text(timeLabel,
                style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700)),
          ),
        // A developer aid for confirming notifications fire on a given device
        // (some vendors block them until whitelisted). Hidden in release builds.
        if (!kReleaseMode)
          ListTile(
            onTap: () async {
              final granted =
                  await NotificationService.instance.requestPermission();
              if (!granted) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content:
                          Text('Allow notifications to receive reminders.')));
                }
                return;
              }
              await NotificationService.instance.showTest();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content:
                        Text('Test sent — check your notification shade.')));
              }
            },
            leading: const SizedBox(width: 36),
            title: Text('Send a test notification',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.primary)),
            trailing: Icon(Icons.send_rounded,
                size: 18, color: theme.colorScheme.primary),
          ),
      ],
    );
  }
}
