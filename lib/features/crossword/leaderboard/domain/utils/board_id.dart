import 'package:wordshool/core/utils/ist_date.dart';

/// `crossword-2026-W43`: this IST week's board, like the server.
String weeklyBoardId(DateTime now) => 'crossword-${istIsoWeekId(now)}';
