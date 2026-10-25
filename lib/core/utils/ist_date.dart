/// India Standard Time helpers. Daily keys are IST `YYYY-MM-DD` (DEC-001).
const istOffset = Duration(hours: 5, minutes: 30);

/// The IST calendar date of [instant], as a UTC-midnight `DateTime`.
DateTime istDate(DateTime instant) {
  final ist = instant.toUtc().add(istOffset);
  return DateTime.utc(ist.year, ist.month, ist.day);
}

/// `YYYY-MM-DD` of a date (only year/month/day are used).
String dateId(DateTime date) => '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

/// Today's IST date id.
String istTodayId([DateTime? now]) => dateId(istDate(now ?? DateTime.now()));

/// [count] consecutive IST date ids starting at today.
List<String> nextIstDateIds(int count, [DateTime? now]) {
  final start = istDate(now ?? DateTime.now());
  return [
    for (var i = 0; i < count; i++) dateId(start.add(Duration(days: i))),
  ];
}

/// 00:00 IST on [id], as a UTC instant.
DateTime startOfIstDay(String id) {
  final parts = id.split('-').map(int.parse).toList();
  return DateTime.utc(parts[0], parts[1], parts[2]).subtract(istOffset);
}

/// The instant [time] (hour/minute) on IST date [day], as UTC.
DateTime istDateTime(DateTime day, int hour, int minute) =>
    DateTime.utc(day.year, day.month, day.day, hour, minute)
        .subtract(istOffset);

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];
const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

/// `Fri, 23 Oct 2026` for a date id.
String friendlyDate(String id) {
  final parts = id.split('-').map(int.parse).toList();
  final date = DateTime.utc(parts[0], parts[1], parts[2]);
  return '${_weekdays[date.weekday - 1]}, ${date.day} ${_months[date.month - 1]} ${date.year}';
}

/// `23 Oct 2026, 12:00 AM IST` for an instant.
String friendlyIstDateTime(DateTime instant) {
  final ist = instant.toUtc().add(istOffset);
  final hour12 = ist.hour % 12 == 0 ? 12 : ist.hour % 12;
  final minute = ist.minute.toString().padLeft(2, '0');
  final period = ist.hour < 12 ? 'AM' : 'PM';
  return '${ist.day} ${_months[ist.month - 1]} ${ist.year}, $hour12:$minute $period IST';
}

/// ISO 8601 week id `YYYY-Www` of the IST day of [now] — weekly leaderboards
/// roll over at Monday 00:00 IST (twin of `functions/utils/iso_week_id.py`).
String istIsoWeekId([DateTime? now]) {
  final day = istDate(now ?? DateTime.now());
  // The Thursday of this ISO week decides the year.
  final thursday = day.add(Duration(days: DateTime.thursday - day.weekday));
  final firstDay = DateTime.utc(thursday.year, 1, 1);
  final week = thursday.difference(firstDay).inDays ~/ 7 + 1;
  return '${thursday.year}-W${week.toString().padLeft(2, '0')}';
}

/// `22 OCT` for a date id (Home's daily card overline).
String shortDateLabel(String id) {
  final parts = id.split('-').map(int.parse).toList();
  return '${parts[2]} ${_months[parts[1] - 1].toUpperCase()}';
}
