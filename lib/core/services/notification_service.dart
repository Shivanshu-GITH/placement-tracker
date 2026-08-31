import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../data/database/database.dart';
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

  static const int _timetableIdBase = 4000;
  // 20 blocks x 7 days — well beyond any realistic timetable, and safely under
  // the platform's per-app scheduled-notification limit.
  static const int _timetableIdMax = 140;
  static const String _timetableChannelId = 'timetable_reminders';

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

  /// Rebuilds the timetable reminders from [blocks].
  ///
  /// One weekly-repeating notification per (block, weekday) pair, fired
  /// [TimetableBlock.leadMinutes] before the block starts. Always cancels the
  /// whole range first, so this is the single place that defines what is
  /// scheduled — call it after any timetable edit.
  Future<void> syncTimetableReminders(List<TimetableBlock> blocks) async {
    await init();
    await cancelTimetableReminders();
    var slot = 0;
    for (final b in blocks) {
      if (!b.enabled || !b.reminder || b.daysMask == 0) continue;
      for (var day = 0; day < 7; day++) {
        if (slot >= _timetableIdMax) return;
        if ((b.daysMask & (1 << day)) == 0) continue;

        // Fire time, rolled back by the lead and wrapped into the previous day
        // if that crosses midnight.
        var minute = b.startMinute - b.leadMinutes;
        var weekday = day + 1; // DateTime.weekday: 1 = Monday
        if (minute < 0) {
          minute += 24 * 60;
          weekday = weekday == 1 ? 7 : weekday - 1;
        }
        final lead = b.leadMinutes > 0 ? ' in ${b.leadMinutes} min' : ' now';
        await _plugin.zonedSchedule(
          id: _timetableIdBase + slot,
          title: '${b.title}$lead 📚',
          body: 'Scheduled for ${_clock(b.startMinute)} · '
              '${b.durationMinutes} min. Let\'s get it done.',
          scheduledDate: _nextInstanceOfWeekday(weekday, minute),
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              _timetableChannelId,
              'Timetable reminders',
              channelDescription:
                  'Reminders for the study blocks in your daily timetable',
              importance: Importance.high,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          // Repeat weekly at this weekday + time.
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
        slot++;
      }
    }
  }

  Future<void> cancelTimetableReminders() async {
    await init();
    for (var i = 0; i < _timetableIdMax; i++) {
      await _plugin.cancel(id: _timetableIdBase + i);
    }
  }

  static String _clock(int minuteOfDay) {
    final h24 = (minuteOfDay ~/ 60) % 24;
    final m = minuteOfDay % 60;
    final period = h24 < 12 ? 'AM' : 'PM';
    final h12 = h24 % 12 == 0 ? 12 : h24 % 12;
    return '$h12:${m.toString().padLeft(2, '0')} $period';
  }

  /// The next occurrence of [weekday] (1 = Monday) at [minuteOfDay].
  tz.TZDateTime _nextInstanceOfWeekday(int weekday, int minuteOfDay) {
    var d = _nextInstanceOf(minuteOfDay ~/ 60, minuteOfDay % 60);
    var guard = 0;
    while (d.weekday != weekday && guard++ < 7) {
      d = d.add(const Duration(days: 1));
    }
    return d;
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
