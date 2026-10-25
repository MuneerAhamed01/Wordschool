import 'package:equatable/equatable.dart';

enum ReportReason {
  wrongAnswer('wrong_answer', 'The answer is wrong'),
  typo('typo', 'Spelling or typo'),
  other('other', 'Something else');

  const ReportReason(this.wire, this.label);

  final String wire;
  final String label;
}

/// "Report a wrong answer" (`contentReports`, create only).
class ContentReportEntity extends Equatable {
  const ContentReportEntity({
    required this.puzzleId,
    required this.wordId,
    required this.questionId,
    required this.reason,
    this.message = '',
  });

  final String puzzleId;
  final String wordId;
  final String questionId;
  final ReportReason reason;

  /// ≤ 500 chars (rules).
  final String message;

  static const maxMessageLength = 500;

  @override
  List<Object?> get props => [puzzleId, wordId, questionId, reason, message];
}
