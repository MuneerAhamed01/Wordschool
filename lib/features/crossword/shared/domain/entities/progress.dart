import 'package:equatable/equatable.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/result.dart';

/// Hints used in one puzzle; every count only goes up.
class HintCount extends Equatable {
  const HintCount({this.letter = 0, this.word = 0, this.clue = 0});

  static const zero = HintCount();

  final int letter;
  final int word;
  final int clue;

  HintCount copyWith({int? letter, int? word, int? clue}) => HintCount(
        letter: letter ?? this.letter,
        word: word ?? this.word,
        clue: clue ?? this.clue,
      );

  /// Reveals spent (DEC-008): letter = 1, word = 3. Clues are free.
  int get revealsSpent => letter * revealLetterCost + word * revealWordCost;

  static const revealLetterCost = 1;
  static const revealWordCost = 3;

  int get total => letter + word + clue;

  @override
  List<Object?> get props => [letter, word, clue];
}

enum CrosswordProgressStatus {
  inProgress('in_progress'),
  completed('completed');

  const CrosswordProgressStatus(this.wire);

  final String wire;

  static CrosswordProgressStatus fromWire(Object? value) =>
      value == completed.wire ? completed : inProgress;
}

/// The player's state in one puzzle (`users/{uid}/crosswordProgress/{puzzleId}`).
class CrosswordProgressEntity extends Equatable {
  const CrosswordProgressEntity({
    required this.puzzleId,
    this.status = CrosswordProgressStatus.inProgress,
    required this.letters,
    this.elapsedSec = 0,
    this.hintsUsed = HintCount.zero,
    this.checksUsed = 0,
    this.result,
  });

  final String puzzleId;
  final CrosswordProgressStatus status;

  /// Same length as the layout; `.` = empty, `#` = block.
  final String letters;
  final int elapsedSec;
  final HintCount hintsUsed;
  final int checksUsed;

  /// Set by the server once completed.
  final CrosswordResultEntity? result;

  bool get isCompleted => status == CrosswordProgressStatus.completed;

  bool get isSolved => isCompleted && (result?.isPerfect ?? false);

  /// Letters typed so far (A–Z only).
  int get filledCount => RegExp('[A-Z]').allMatches(letters).length;

  @override
  List<Object?> get props =>
      [puzzleId, status, letters, elapsedSec, hintsUsed, checksUsed, result];
}
