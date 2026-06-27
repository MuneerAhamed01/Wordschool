import 'package:flutter_test/flutter_test.dart';
import 'package:wordshool/features/story_mode/domain/entities/case_outcome.dart';
import 'package:wordshool/features/story_mode/domain/utils/case_outcome_resolver.dart';

void main() {
  group('CaseOutcomeResolver.resolve', () {
    test('returns caseClosed when all clues solved', () {
      expect(
        CaseOutcomeResolver.resolve(const [true, true, true]),
        CaseOutcome.caseClosed,
      );
    });

    test('returns coldCase when two clues solved', () {
      expect(
        CaseOutcomeResolver.resolve(const [false, true, true]),
        CaseOutcome.coldCase,
      );
    });

    test('returns unsolved when one clue solved', () {
      expect(
        CaseOutcomeResolver.resolve(const [false, true, false]),
        CaseOutcome.unsolved,
      );
    });

    test('returns dismissed when no clues solved', () {
      expect(
        CaseOutcomeResolver.resolve(const [false, false, false]),
        CaseOutcome.dismissed,
      );
    });
  });
}
