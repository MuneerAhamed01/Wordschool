import 'package:intl/intl.dart';

/// `4:07`, `12:30`, `1:02:05`.
String formatClock(int seconds) {
  final s = seconds < 0 ? 0 : seconds;
  final h = s ~/ 3600;
  final m = (s % 3600) ~/ 60;
  final sec = (s % 60).toString().padLeft(2, '0');
  return h > 0 ? '$h:${m.toString().padLeft(2, '0')}:$sec' : '$m:$sec';
}

final _thousands = NumberFormat.decimalPattern('en_IN');

/// `1,285` (Indian grouping: `1,28,500`).
String formatCount(int value) => _thousands.format(value);

/// `1 word` / `3 words`.
String plural(int count, String one, [String? many]) =>
    '$count ${count == 1 ? one : (many ?? '${one}s')}';
