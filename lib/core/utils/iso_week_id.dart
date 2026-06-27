/// ISO 8601 week identifier in `yyyy-Www` format (Monday–Sunday, UTC).
class IsoWeekId {
  IsoWeekId._();

  static String current() => fromDate(DateTime.now().toUtc());

  static String fromDate(DateTime utcDate) {
    final date = DateTime.utc(utcDate.year, utcDate.month, utcDate.day);
    final thursday =
        date.add(Duration(days: DateTime.thursday - date.weekday));
    final weekYear = thursday.year;
    final firstThursday = DateTime.utc(weekYear, 1, 4);
    final week =
        1 + (thursday.difference(firstThursday).inDays / 7).floor();
    return '$weekYear-W${week.toString().padLeft(2, '0')}';
  }
}
