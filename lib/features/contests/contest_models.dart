/// A recurring competitive-programming contest series (e.g. LeetCode Weekly).
/// Times are in **IST** (UTC+5:30); the schedule engine converts as needed.
class ContestSeries {
  const ContestSeries({
    required this.key,
    required this.platform,
    required this.name,
    required this.weekday,
    required this.timeIst,
    required this.durationMins,
    required this.cadence,
    required this.url,
    this.anchor,
    this.note = '',
  });

  final String key;
  final String platform;
  final String name;

  /// 0 = Sunday … 6 = Saturday, matching JS getDay(); null for [Cadence.varies].
  final int? weekday;

  /// "HH:MM" in IST.
  final String timeIst;
  final int durationMins;
  final Cadence cadence;
  final String url;

  /// For [Cadence.biweekly]: a known date on which the series occurs, used to
  /// phase the every-other-week pattern.
  final DateTime? anchor;
  final String note;

  int get istHour => int.parse(timeIst.split(':')[0]);
  int get istMinute => int.parse(timeIst.split(':')[1]);
}

enum Cadence { weekly, biweekly, varies }

/// A concrete, dated instance of a [ContestSeries].
class ContestOccurrence {
  const ContestOccurrence({
    required this.series,
    required this.startIst,
    required this.durationMins,
  });

  final ContestSeries series;

  /// The start time as an IST wall-clock DateTime (its y/m/d/h/m fields are the
  /// IST values). Use [startUtc] for correct absolute-time scheduling.
  final DateTime startIst;
  final int durationMins;

  String get platform => series.platform;
  String get name => series.name;
  String get url => series.url;

  /// The absolute UTC instant of the start (IST is a fixed UTC+5:30, no DST).
  DateTime get startUtc =>
      DateTime.utc(startIst.year, startIst.month, startIst.day, startIst.hour,
              startIst.minute)
          .subtract(const Duration(hours: 5, minutes: 30));

  DateTime get endIst => startIst.add(Duration(minutes: durationMins));
}
