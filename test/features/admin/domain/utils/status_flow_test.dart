import 'package:flutter_test/flutter_test.dart';
import 'package:wordshool/features/admin/domain/models/admin_enums.dart';
import 'package:wordshool/features/admin/domain/utils/status_flow.dart';

void main() {
  test('every allowed move has exactly one button, and nothing else', () {
    for (final status in PuzzleStatus.values) {
      final targets = statusActions(status).map((a) => a.target).toList();
      expect(targets, puzzleTransitions[status], reason: status.name);
    }
  });

  test('scheduling asks for a date; publishing and archiving ask to confirm',
      () {
    final inReview = {
      for (final a in statusActions(PuzzleStatus.inReview)) a.target: a
    };
    expect(inReview[PuzzleStatus.scheduled]!.needsDate, isTrue);
    expect(inReview[PuzzleStatus.published]!.confirm, isNotNull);
    expect(statusActions(PuzzleStatus.scheduled).first.label, 'Change date');
    expect(statusActions(PuzzleStatus.published).single.destructive, isTrue);
    expect(statusActions(PuzzleStatus.archived), isEmpty);
  });

  test('canBeDaily', () {
    final dayStart = DateTime.utc(2026, 10, 31, 18, 30);
    expect(
        canBeDaily(
            status: PuzzleStatus.published,
            publishAt: null,
            dayStart: dayStart),
        isTrue);
    expect(
        canBeDaily(
            status: PuzzleStatus.scheduled,
            publishAt: dayStart,
            dayStart: dayStart),
        isTrue);
    expect(
      canBeDaily(
        status: PuzzleStatus.scheduled,
        publishAt: dayStart.add(const Duration(minutes: 1)),
        dayStart: dayStart,
      ),
      isFalse,
    );
    expect(
        canBeDaily(
            status: PuzzleStatus.inReview, publishAt: null, dayStart: dayStart),
        isFalse);
  });
}
