import 'package:equatable/equatable.dart';
import 'package:wordshool/shared/domains/entities/localized_text.dart';

enum CrosswordDirection {
  across('across', 'Across', 'A'),
  down('down', 'Down', 'D');

  const CrosswordDirection(this.wire, this.label, this.suffix);

  final String wire;
  final String label;

  /// Letter after the number in a word id (`2D`).
  final String suffix;

  CrosswordDirection get other => this == across ? down : across;

  static CrosswordDirection fromWire(Object? value) =>
      value == down.wire ? down : across;
}

/// One answer slot of a puzzle (`crosswordPuzzles.words[]`).
class CrosswordWordEntity extends Equatable {
  const CrosswordWordEntity({
    required this.id,
    required this.number,
    required this.direction,
    required this.row,
    required this.col,
    required this.length,
    required this.clue,
    this.extraClue = LocalizedText.empty,
    this.fact = LocalizedText.empty,
    required this.answerEnc,
    this.questionId = '',
  });

  /// `2D`, `1A`.
  final String id;
  final int number;
  final CrosswordDirection direction;
  final int row;
  final int col;
  final int length;
  final LocalizedText clue;

  /// Free "Show a clue" hint.
  final LocalizedText extraClue;
  final LocalizedText fact;

  /// See `domain/utils/answer_encoding.dart`.
  final String answerEnc;
  final String questionId;

  /// "2 DOWN · 6 LETTERS".
  String get label =>
      '$number ${direction.label.toUpperCase()} · $length LETTERS';

  @override
  List<Object?> get props => [
        id,
        number,
        direction,
        row,
        col,
        length,
        clue,
        extraClue,
        fact,
        answerEnc,
        questionId,
      ];
}
