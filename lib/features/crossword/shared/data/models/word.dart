import 'package:wordshool/core/utils/json_read.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/word.dart';
import 'package:wordshool/shared/domains/entities/localized_text.dart';

class CrosswordWordModel extends CrosswordWordEntity {
  const CrosswordWordModel({
    required super.id,
    required super.number,
    required super.direction,
    required super.row,
    required super.col,
    required super.length,
    required super.clue,
    super.extraClue,
    super.fact,
    required super.answerEnc,
    super.questionId,
  });

  factory CrosswordWordModel.fromJson(Map<String, dynamic> json) {
    return CrosswordWordModel(
      id: asString(json['id']),
      number: asInt(json['number']),
      direction: CrosswordDirection.fromWire(json['direction']),
      row: asInt(json['row']),
      col: asInt(json['col']),
      length: asInt(json['length']),
      clue: LocalizedText.fromJson(json['clue']),
      extraClue: LocalizedText.fromJson(json['extraClue']),
      fact: LocalizedText.fromJson(json['fact']),
      answerEnc: asString(json['answerEnc']),
      questionId: asString(json['questionId']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'number': number,
        'direction': direction.wire,
        'row': row,
        'col': col,
        'length': length,
        'clue': clue.toJson(),
        'extraClue': extraClue.toJson(),
        'fact': fact.toJson(),
        'answerEnc': answerEnc,
        'questionId': questionId,
      };
}
