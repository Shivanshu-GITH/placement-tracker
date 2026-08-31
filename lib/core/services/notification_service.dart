import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../features/contests/contest_models.dart';

/// Thin wrapper around flutter_local_notifications for local (offline) study
/// reminders. No network, no third-party service.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static const int _dailyReminderId = 1001;
  static const String _channelId = 'daily_reminder';

  static const int _contestIdBase = 3000;
  static const int _contestIdMax = 40; // cap on scheduled contest reminders
  static const String _contestChannelId = 'contest_reminders';

  Future<void> init() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    try {
      final local = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(local.identifier));
    } catch (_) {
      // Fall back to UTC if the platform timezone can't be resolved.
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: darwin),
    );
    _ready = true;
  }

  /// Asks the OS for notification permission. Returns true if granted.
  Future<bool> requestPermission() async {
    await init();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final granted = await ios.requestPermissions(alert: true, badge: true, sound: true);
      return granted ?? false;
    }
    return true;
  }

  /// Schedules a repeating daily reminder at [hour]:[minute] local time.
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    await init();
    await _plugin.zonedSchedule(
      id: _dailyReminderId,
      title: 'Time to prep 💪',
      body: 'Keep your streak alive — a few problems today go a long way.',
      scheduledDate: _nextInstanceOf(hour, minute),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'Daily reminders',
          channelDescription: 'Daily nudge to keep your prep streak going',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelDailyReminder() async {
    await init();
    await _plugin.cancel(id: _dailyReminderId);
  }

  /// Schedules a one-off reminder [leadMinutes] before each upcoming contest.
  /// Replaces any previously scheduled contest reminders. Skips occurrences
  /// whose reminder time is already past.
  Future<void> scheduleContestReminders(
    List<ContestOccurrence> upcoming, {
    int leadMinutes = 60,
  }) async {
    await init();
    await cancelContestReminders();
    final nowUtc = DateTime.now().toUtc();
    var slot = 0;
    for (final o in upcoming) {
      if (slot >= _contestIdMax) break;
      final fireUtc = o.startUtc.subtract(Duration(minutes: leadMinutes));
      if (!fireUtc.isAfter(nowUtc)) continue;
      await _plugin.zonedSchedule(
        id: _contestIdBase + slot,
        title: '${o.platform} ${o.name} soon 🏆',
        body:
            'Starts around ${o.series.timeIst} IST. Warm up and give it a shot!',
        scheduledDate: tz.TZDateTime.from(fireUtc, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _contestChannelId,
            'Contest reminders',
            channelDescription:
                'Reminders before competitive programming contests',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
      slot++;
    }
  }

  Future<void> cancelContestReminders() async {
    await init();
    for (var i = 0; i < _contestIdMax; i++) {
      await _plugin.cancel(id: _contestIdBase + i);
    }
  }

  /// Fires an immediate notification — used to verify notifications work on
  /// this device (some vendors block/delay them until whitelisted).
  Future<void> showTest() async {
    await init();
    await _plugin.show(
      id: 2002,
      title: 'PrepPilot notifications work ✅',
      body: 'This is a test. Daily reminders will look like this.',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'Daily reminders',
          channelDescription: 'Daily nudge to keep your prep streak going',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
