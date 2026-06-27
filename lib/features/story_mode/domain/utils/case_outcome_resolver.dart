import 'package:wordshool/features/story_mode/domain/entities/case_outcome.dart';

class CaseOutcomeResolver {
  CaseOutcomeResolver._();

  static CaseOutcome resolve(List<bool> clueSolved) {
    final solvedCount = clueSolved.where((solved) => solved).length;

    return switch (solvedCount) {
      3 => CaseOutcome.caseClosed,
      2 => CaseOutcome.coldCase,
      1 => CaseOutcome.unsolved,
      _ => CaseOutcome.dismissed,
    };
  }
}
