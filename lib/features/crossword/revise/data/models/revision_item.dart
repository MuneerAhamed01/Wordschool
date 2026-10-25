import 'package:wordshool/core/firebase/dt_converter.dart';
import 'package:wordshool/core/utils/json_read.dart';
import 'package:wordshool/features/crossword/revise/domain/entities/revision_item.dart';
import 'package:wordshool/shared/domains/entities/localized_text.dart';

class RevisionItemModel extends RevisionItemEntity {
  const RevisionItemModel({
    required super.questionId,
    required super.answer,
    required super.answerDisplay,
    required super.clue,
    required super.fact,
    super.subject,
    super.puzzleId,
    super.wrongCount,
    super.lastWrongAt,
    super.mastered,
  });

  /// [documentId] is the question id.
  factory RevisionItemModel.fromJson(
    Map<String, dynamic> json, {
    String? documentId,
  }) {
    final source = asMap(json['source']);
    return RevisionItemModel(
      questionId: documentId ?? asString(json['questionId']),
      answer: asString(json['answer']),
      answerDisplay: LocalizedText.fromJson(json['answerDisplay']),
      clue: LocalizedText.fromJson(json['clue']),
      fact: LocalizedText.fromJson(json['fact']),
      subject: asString(json['subject']),
      puzzleId: source['puzzleId'] as String?,
      wrongCount: asInt(json['wrongCount'], 1),
      lastWrongAt: FirebaseDTConverter.tryParse(json['lastWrongAt']),
      mastered: asBool(json['mastered']),
    );
  }
}
