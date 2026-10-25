import 'package:wordshool/features/crossword/puzzle/domain/utils/grid.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/puzzle.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/result.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/result_args.dart';

/// What the Results screen shows, from the finished grid (no extra reads).
ResultArgs resultArgsOf(
  CrosswordPuzzleEntity puzzle,
  CrosswordGrid grid,
  CrosswordSubmitOutcome outcome,
) {
  final revealed = outcome.result.revealedWordIds.toSet();
  return ResultArgs(
    puzzle: puzzle,
    outcome: outcome,
    mistakes: [
      for (final w in puzzle.words)
        if (outcome.result.wrongWordIds.contains(w.id))
          ResultMistake(
            wordId: w.id,
            answer: grid.word(w.id)?.answer ?? '',
            clue: w.clue.en,
            fact: w.fact.en,
            typed: grid.typedAnswer(w.id),
            revealed: revealed.contains(w.id),
            reference: '${w.number} ${w.direction.label}',
          ),
    ],
  );
}
