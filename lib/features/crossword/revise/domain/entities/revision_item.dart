import 'package:equatable/equatable.dart';
import 'package:wordshool/shared/domains/entities/localized_text.dart';

/// A fact the player got wrong (`users/{uid}/revisionItems/{questionId}`).
class RevisionItemEntity extends Equatable {
  const RevisionItemEntity({
    required this.questionId,
    required this.answer,
    required this.answerDisplay,
    required this.clue,
    required this.fact,
    this.subject = '',
    this.puzzleId,
    this.wrongCount = 1,
    this.lastWrongAt,
    this.mastered = false,
  });

  final String questionId;
  final String answer;
  final LocalizedText answerDisplay;
  final LocalizedText clue;
  final LocalizedText fact;

  /// `kerala_history`.
  final String subject;
  final String? puzzleId;
  final int wrongCount;
  final DateTime? lastWrongAt;
  final bool mastered;

  /// `Kerala history` from `kerala_history`.
  String get subjectLabel {
    final words = subject.split('_').where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '';
    final text = words.join(' ');
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  List<Object?> get props => [
        questionId,
        answer,
        answerDisplay,
        clue,
        fact,
        subject,
        puzzleId,
        wrongCount,
        lastWrongAt,
        mastered,
      ];
}
