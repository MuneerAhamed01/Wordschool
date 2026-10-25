import 'package:flutter_test/flutter_test.dart';
import 'package:wordshool/features/crossword/shared/data/models/category.dart';
import 'package:wordshool/features/crossword/shared/data/models/progress.dart';
import 'package:wordshool/features/crossword/shared/data/models/puzzle.dart';
import 'package:wordshool/features/crossword/shared/data/models/result.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/progress.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/puzzle.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/word.dart';

import '../../../crossword_fixtures.dart';

void main() {
  test('puzzle doc', () {
    final puzzle = examplePuzzle();
    expect(puzzle.id, 'kerala-history-0012');
    expect(puzzle.categoryId, 'kerala-history');
    expect(puzzle.difficulty, CrosswordDifficulty.medium);
    expect(puzzle.rows * puzzle.cols, puzzle.layout.length);
    expect(puzzle.wordCount, 7);
    expect(puzzle.letterCount, 31);
    expect(puzzle.publishedAt, DateTime.utc(2026, 10, 22, 0, 5));
    final down2 = puzzle.words.firstWhere((w) => w.id == '2D');
    expect(down2.direction, CrosswordDirection.down);
    expect(down2.length, 6);
    expect(down2.answerEnc, 'PSQ7KiMs'); // fixture in FIREBASE_DESIGN.md
    expect(down2.extraClue.en, startsWith('Held in Travancore'));
    expect(down2.label, '2 DOWN · 6 LETTERS');

    // toJson leaves out server-only fields (publishedAt).
    final again =
        CrosswordPuzzleModel.fromJson(puzzle.toJson(), documentId: puzzle.id);
    expect(again.words, puzzle.words);
    expect(again.layout, puzzle.layout);
    expect(again.title, puzzle.title);
  });

  test('category doc', () {
    final (data, id) = fixtureDoc('category');
    final category = CrosswordCategoryModel.fromJson(data, documentId: id);
    expect(category.id, 'kerala-history');
    expect(category.name.ml, 'കേരള ചരിത്രം');
    expect(category.publishedPuzzleCount, 42);
    expect(CrosswordCategoryModel.fromJson(category.toJson(), documentId: id),
        category);
  });

  test('progress docs, in progress and completed', () {
    var (data, id) = fixtureDoc('progress_in_progress');
    final playing = CrosswordProgressModel.fromJson(data, documentId: id);
    expect(playing.isCompleted, isFalse);
    expect(playing.hintsUsed, const HintCount(letter: 1, clue: 2));
    expect(playing.hintsUsed.revealsSpent, 1);
    expect(playing.filledCount, 11);
    expect(playing.result, isNull);
    expect(CrosswordProgressModel.toJsonOf(playing), {
      'status': 'in_progress',
      'letters': data['letters'],
      'elapsedSec': 95,
      'hintsUsed': {'letter': 1, 'word': 0, 'clue': 2},
      'checksUsed': 1,
    });

    (data, id) = fixtureDoc('progress_completed');
    final done = CrosswordProgressModel.fromJson(data, documentId: id);
    expect(done.isCompleted, isTrue);
    expect(done.isSolved, isFalse);
    expect(done.result!.wrongWordIds, ['2D', '3D']);
    expect(done.hintsUsed.revealsSpent, 3);
  });

  test('submitCrossword response', () {
    final outcome =
        CrosswordSubmitOutcomeModel.fromJson(fixture('submit_response'));
    expect(outcome.result.score, 71);
    expect(outcome.result.isPerfect, isFalse);
    expect(outcome.xp, 1285);
    expect(outcome.currentStreak, 4);
    expect(outcome.alreadySubmitted, isFalse);
    final result = outcome.result as CrosswordResultModel;
    expect(CrosswordResultModel.fromJson(result.toJson()), result);
  });
}
