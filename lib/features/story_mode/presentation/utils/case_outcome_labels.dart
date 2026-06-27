import 'package:wordshool/features/story_mode/domain/entities/case_outcome.dart';

String caseOutcomeLabel(CaseOutcome outcome) {
  return switch (outcome) {
    CaseOutcome.caseClosed => 'Case Closed',
    CaseOutcome.coldCase => 'Cold Case',
    CaseOutcome.unsolved => 'Unsolved',
    CaseOutcome.dismissed => 'Dismissed',
  };
}
