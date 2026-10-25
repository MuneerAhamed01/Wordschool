import 'package:wordshool/features/crossword/shared/domain/entities/puzzle.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/result.dart';

/// One word to revise on the Results screen.
class ResultMistake {
  const ResultMistake({
    required this.wordId,
    required this.answer,
    required this.clue,
    required this.fact,
    required this.typed,
    required this.revealed,
    required this.reference,
  });

  final String wordId;
  final String answer;
  final String clue;
  final String fact;
  final String typed;
  final bool revealed;

  /// "2 Down".
  final String reference;
}

/// Everything Results needs, passed from the puzzle screen (no extra reads).
/// Built by the puzzle module (`resultArgsOf`), shown by the result module.
class ResultArgs {
  const ResultArgs({
    required this.puzzle,
    required this.outcome,
    required this.mistakes,
  });

  final CrosswordPuzzleEntity puzzle;
  final CrosswordSubmitOutcome outcome;
  final List<ResultMistake> mistakes;
}
