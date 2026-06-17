class DateHelper {
  DateHelper._();

  static String toDateId(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  static String todayDateId() {
    return toDateId(DateTime.now());
  }

  static DateTime parseDateId(String dateId) {
    final parts = dateId.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  static String previousDateId(String dateId) {
    final date = parseDateId(dateId);
    return toDateId(date.subtract(const Duration(days: 1)));
  }

  static String monthStartDateId(int year, int month) {
    return toDateId(DateTime(year, month, 1));
  }

  static String monthEndDateId(int year, int month) {
    final lastDay = DateTime(year, month + 1, 0).day;
    return toDateId(DateTime(year, month, lastDay));
  }

  static bool isValidDateId(String value) {
    return RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value);
  }

  static bool isFutureDateId(String dateId) {
    return dateId.compareTo(todayDateId()) > 0;
  }
}
