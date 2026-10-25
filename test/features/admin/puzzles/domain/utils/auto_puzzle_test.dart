import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:wordshool/features/admin/puzzles/domain/utils/auto_puzzle.dart';
import 'package:wordshool/features/admin/puzzles/domain/utils/puzzle_draft.dart';
import 'package:wordshool/features/admin/shared/domain/models/enums.dart';
import 'package:wordshool/features/admin/shared/domain/models/puzzle.dart';
import 'package:wordshool/features/admin/shared/domain/models/question.dart';
import 'package:wordshool/features/admin/shared/domain/utils/grid_validator.dart';
import 'package:wordshool/shared/domains/entities/localized_text.dart';

const examplePath =
    '.claude/skills/crossword-content/examples/kerala-history-0012.puzzle.json';

/// Shared with functions/crossword/validate_puzzle_test.py, which checks the
/// server accepts the same generated grid.
const generatedPath = 'test/fixtures/admin/auto_puzzle.puzzle.json';

AdminQuestion question(
  String answer, {
  QuestionStatus status = QuestionStatus.verified,
  Difficulty difficulty = Difficulty.medium,
  List<String> usedIn = const [],
  String? id,
}) =>
    AdminQuestion(
      id: id ?? 'q-$answer',
      answer: answer,
      answerDisplay: LocalizedText(en: answer),
      clues: [
        QuestionClue(en: 'Easy clue for $answer', level: Difficulty.easy),
        QuestionClue(en: 'Hard clue for $answer', level: Difficulty.hard),
      ],
      fact: LocalizedText(en: 'Fact about $answer'),
      subject: 'kerala_history',
      difficulty: difficulty,
      source: const QuestionSource(type: SourceType.book, ref: 'A book'),
      status: status,
      usedInPuzzles: usedIn,
    );

/// Every letter square reachable from the first one.
bool connected(PuzzleDraft draft) {
  final cells = draft.letters.keys.toSet();
  final seen = <Cell>{cells.first};
  final queue = [cells.first];
  while (queue.isNotEmpty) {
    final (r, c) = queue.removeLast();
    for (final next in [(r + 1, c), (r - 1, c), (r, c + 1), (r, c - 1)]) {
      if (cells.contains(next) && seen.add(next)) queue.add(next);
    }
  }
  return seen.length == cells.length;
}

void main() {
  late List<AdminQuestion> example;

  setUp(() {
    final puzzle = AdminPuzzle.fromJson(
      jsonDecode(File(examplePath).readAsStringSync()) as Map<String, dynamic>,
    );
    example = [for (final w in puzzle.words) question(w.answer)];
  });

  test('the example answers make a clean, connected grid', () {
    final result = autoPuzzle(example, const AutoPuzzleOptions())!;
    expect(result.draft.problems, isEmpty);
    expect(result.used.length, greaterThanOrEqualTo(5));
    expect(result.crossings, greaterThanOrEqualTo(result.used.length - 1));
    expect(connected(result.draft), isTrue);
    expect(result.draft.words, hasLength(result.used.length));
  });

  test('clues and facts are the question\'s own', () {
    final result = autoPuzzle(example, const AutoPuzzleOptions())!;
    for (final word in result.draft.words) {
      expect(word.questionId, 'q-${word.answer}');
      expect(word.clue.en, 'Easy clue for ${word.answer}');
      expect(word.extraClue?.en, 'Hard clue for ${word.answer}');
      expect(word.fact?.en, 'Fact about ${word.answer}');
    }
  });

  test('same seed gives the same grid; other seeds can differ', () {
    const options = AutoPuzzleOptions(seed: 7);
    final a = autoPuzzle(example, options)!;
    final b = autoPuzzle(example, options)!;
    expect(a.draft, b.draft);
    final layouts = {
      for (var seed = 0; seed < 30; seed++)
        autoPuzzle(example, AutoPuzzleOptions(seed: seed, attempts: 1))!
            .draft
            .layout,
    };
    expect(layouts.length, greaterThan(1));
  });

  test('only checked questions, each answer once', () {
    final questions = [
      ...example,
      question('KOCHI', status: QuestionStatus.draft),
      question('MUNNAR', status: QuestionStatus.retired),
      question('VAIKOM', id: 'q-VAIKOM-2'),
    ];
    for (var seed = 0; seed < 10; seed++) {
      final result = autoPuzzle(
          questions, AutoPuzzleOptions(seed: seed, targetWords: 20))!;
      expect(result.used.every((q) => q.isVerified), isTrue);
      final answers = result.used.map((q) => q.answer).toList();
      expect(answers.toSet().length, answers.length);
      final ids = result.used.map((q) => q.id).toList();
      expect(ids.toSet().length, ids.length);
      expect(answers, isNot(contains('KOCHI')));
      expect(answers, isNot(contains('MUNNAR')));
    }
  });

  test('nothing longer than the grid size', () {
    final result =
        autoPuzzle(example, const AutoPuzzleOptions(size: 6, targetWords: 20))!;
    expect(result.used.every((q) => q.answer.length <= 6), isTrue);
    expect(result.draft.rows, lessThanOrEqualTo(6));
    expect(result.draft.cols, lessThanOrEqualTo(6));
    expect(result.notes.first, contains('longer than 6 letters'));
  });

  test('the difficulty filter is respected', () {
    final questions = [
      for (final q in example) question(q.answer, difficulty: Difficulty.hard),
      question('KOCHI', difficulty: Difficulty.easy),
      question('CHERA', difficulty: Difficulty.easy),
    ];
    final hard = autoPuzzle(questions,
        const AutoPuzzleOptions(difficulty: Difficulty.hard, targetWords: 20))!;
    expect(hard.used.every((q) => q.difficulty == Difficulty.hard), isTrue);
    final easy = autoPuzzle(
        questions, const AutoPuzzleOptions(difficulty: Difficulty.easy))!;
    expect(easy.used.map((q) => q.answer), unorderedEquals(['KOCHI', 'CHERA']));
  });

  test('preferUnused puts unused questions in when they fit', () {
    // Every example answer is used elsewhere except VAIKOM and GAMA, which
    // both fit; with 3 words wanted they should always be in.
    final questions = [
      for (final q in example)
        question(q.answer,
            usedIn: {'VAIKOM', 'GAMA'}.contains(q.answer) ? [] : ['p1']),
    ];
    for (var seed = 0; seed < 10; seed++) {
      final result =
          autoPuzzle(questions, AutoPuzzleOptions(seed: seed, targetWords: 3))!;
      final answers = result.used.map((q) => q.answer);
      expect(answers, containsAll(['VAIKOM', 'GAMA']));
      expect(result.notes.last, contains('already in another puzzle'));
    }
  });

  test('fewer than 2 answers that can cross → null', () {
    expect(autoPuzzle([], const AutoPuzzleOptions()), isNull);
    expect(autoPuzzle([question('KERALA')], const AutoPuzzleOptions()), isNull);
    // No shared letters.
    expect(
        autoPuzzle(
            [question('ABC'), question('XYZ')], const AutoPuzzleOptions()),
        isNull);
    // Too long for the grid.
    expect(
        autoPuzzle([question('MALABAR'), question('MUZIRIS')],
            const AutoPuzzleOptions(size: 5)),
        isNull);
    // Not checked.
    expect(
        autoPuzzle([
          question('CAT', status: QuestionStatus.draft),
          question('TOE', status: QuestionStatus.draft),
        ], const AutoPuzzleOptions()),
        isNull);
    expect(
        autoPuzzle(
            [question('CAT'), question('TOE')], const AutoPuzzleOptions()),
        isNotNull);
  });

  test('options are clamped and read from the query', () {
    const tooBig = AutoPuzzleOptions(size: 40, targetWords: 99);
    expect((tooBig.size, tooBig.targetWords), (maxGridSize, 20));
    const tooSmall = AutoPuzzleOptions(size: 1, targetWords: 0);
    expect((tooSmall.size, tooSmall.targetWords), (minGridSize, 2));
    final query = AutoPuzzleOptions.fromQuery(
        {'size': '11', 'words': '12', 'difficulty': 'hard'});
    expect((query.size, query.targetWords, query.difficulty),
        (11, 12, Difficulty.hard));
    expect(
        AutoPuzzleOptions.fromQuery({'size': 'x'}), const AutoPuzzleOptions());
  });

  test('60 random answer sets × 3 sizes never give a grid with problems', () {
    final random = Random(42);
    const letters = 'AAAEEEIIOOUUNRSTLMKPDGHVY';
    for (var set = 0; set < 60; set++) {
      final answers = <String>{};
      final count = 4 + random.nextInt(20);
      while (answers.length < count) {
        final length = 2 + random.nextInt(9);
        answers.add(String.fromCharCodes([
          for (var i = 0; i < length; i++)
            letters.codeUnitAt(random.nextInt(letters.length))
        ]));
      }
      final questions = [for (final a in answers) question(a)];
      for (final size in [5, 9, 15]) {
        final result = autoPuzzle(questions,
            AutoPuzzleOptions(size: size, targetWords: 12, seed: set));
        if (result == null) continue;
        expect(result.draft.problems, isEmpty,
            reason: 'set $set size $size: ${result.draft.layout}');
        expect(connected(result.draft), isTrue);
        expect(result.draft.rows, lessThanOrEqualTo(size));
        expect(result.draft.cols, lessThanOrEqualTo(size));
      }
    }
  });

  test('the shared generated fixture is this generator\'s output', () {
    // Regenerate with UPDATE_FIXTURES=1 if the generator changes on purpose.
    final result = autoPuzzle(example, const AutoPuzzleOptions(seed: 1))!;
    final draft = result.draft;
    final json = {
      'id': 'kerala-history-auto',
      'categoryId': 'kerala-history',
      'number': 1,
      'title': {'en': 'Kerala History mix'},
      'difficulty': 'medium',
      'rows': draft.rows,
      'cols': draft.cols,
      'layout': draft.layout,
      'xpReward': 50,
      'estimatedMinutes': max(3, draft.words.length),
      'words': [
        for (final w in draft.words)
          {
            'id': w.id,
            'number': w.number,
            'direction': w.direction.value,
            'row': w.row,
            'col': w.col,
            'length': w.answer.length,
            'answer': w.answer,
            'clue': w.clue.toJson(),
            'questionId': w.questionId,
          }
      ],
    };
    final file = File(generatedPath);
    if (Platform.environment['UPDATE_FIXTURES'] == '1') {
      file.writeAsStringSync(
          '${const JsonEncoder.withIndent('  ').convert(json)}\n');
    }
    final saved = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    expect(saved, json);
    final puzzle = AdminPuzzle.fromJson(saved);
    expect(
      gridProblems(
          rows: puzzle.rows,
          cols: puzzle.cols,
          layout: puzzle.layout,
          words: puzzle.words),
      isEmpty,
    );
  });
}
