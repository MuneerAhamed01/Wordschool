enum CaseOutcome {
  caseClosed,
  coldCase,
  unsolved,
  dismissed,
}

extension CaseOutcomeFirestore on CaseOutcome {
  String toFirestoreString() {
    switch (this) {
      case CaseOutcome.caseClosed:
        return 'case_closed';
      case CaseOutcome.coldCase:
        return 'cold_case';
      case CaseOutcome.unsolved:
        return 'unsolved';
      case CaseOutcome.dismissed:
        return 'dismissed';
    }
  }

  static CaseOutcome fromFirestoreString(String value) {
    switch (value) {
      case 'case_closed':
        return CaseOutcome.caseClosed;
      case 'cold_case':
        return CaseOutcome.coldCase;
      case 'unsolved':
        return CaseOutcome.unsolved;
      case 'dismissed':
        return CaseOutcome.dismissed;
      default:
        throw ArgumentError('Unknown case outcome: $value');
    }
  }
}
