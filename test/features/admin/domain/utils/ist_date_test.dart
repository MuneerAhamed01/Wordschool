import 'package:flutter_test/flutter_test.dart';
import 'package:wordshool/features/admin/domain/utils/ist_date.dart';
import 'package:wordshool/features/admin/domain/utils/server_problems.dart';

void main() {
  test('IST date flips at 18:30 UTC', () {
    expect(istTodayId(DateTime.utc(2026, 10, 23, 18, 29)), '2026-10-23');
    expect(istTodayId(DateTime.utc(2026, 10, 23, 18, 30)), '2026-10-24');
  });

  test('nextIstDateIds crosses month ends', () {
    expect(nextIstDateIds(3, DateTime.utc(2026, 10, 30, 20)),
        ['2026-10-31', '2026-11-01', '2026-11-02']);
  });

  test('startOfIstDay is 18:30 UTC the day before', () {
    expect(startOfIstDay('2026-11-01'), DateTime.utc(2026, 10, 31, 18, 30));
    expect(istDateTime(DateTime.utc(2026, 11, 1), 6, 0),
        DateTime.utc(2026, 11, 1, 0, 30));
  });

  test('friendly formats', () {
    expect(friendlyDate('2026-10-23'), 'Fri, 23 Oct 2026');
    expect(friendlyIstDateTime(DateTime.utc(2026, 10, 31, 18, 30)),
        '1 Nov 2026, 12:00 AM IST');
  });

  test('splitProblems splits the server message', () {
    expect(splitProblems('a is required; b must be a string'),
        ['a is required', 'b must be a string']);
    expect(splitProblems('one problem'), ['one problem']);
  });
}
