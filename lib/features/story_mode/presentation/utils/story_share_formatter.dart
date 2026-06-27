import 'package:wordshool/core/utils/wordle_guess_evaluator.dart';
import 'package:wordshool/features/story_mode/domain/entities/detective_case.dart';
import 'package:wordshool/features/story_mode/domain/entities/story_mode_progress.dart';
import 'package:wordshool/features/story_mode/domain/utils/detective_score_calculator.dart';
import 'package:wordshool/features/story_mode/presentation/utils/case_outcome_labels.dart';
import 'package:wordshool/features/story_mode/presentation/utils/clue_type_labels.dart';

class StoryShareFormatter {
  StoryShareFormatter._();

  static const appTagline = "Play today's case in WordSchool";

  static String format({
    required DetectiveCaseEntity detectiveCase,
    required StoryModeProgressEntity progress,
  }) {
    final buffer = StringBuffer()
      ..writeln('Detective Wordle — Case Closed 🕵️')
      ..writeln('Score: ${progress.totalScore}/${DetectiveScoreCalculator.maxPointsPerDay}');

    if (progress.outcome != null) {
      buffer.writeln('Outcome: ${caseOutcomeLabel(progress.outcome!)}');
    }

    buffer.writeln();

    for (var index = 0; index < detectiveCase.clues.length; index++) {
      final clue = detectiveCase.clues[index];
      buffer.writeln('Clue ${index + 1} — ${clueTypeLabel(clue.type)}');

      final guesses = progress.clueGuesses[index];
      if (guesses.isEmpty) {
        buffer.writeln('⬛⬛⬛⬛⬛');
      } else {
        for (final guess in guesses) {
          buffer.writeln(
            WordleGuessEvaluator.guessToEmojiRow(guess, clue.answer),
          );
        }
      }
      buffer.writeln();
    }

    buffer.write(appTagline);
    return buffer.toString().trim();
  }
}
