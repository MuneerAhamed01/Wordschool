import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wordshool/features/admin/shared/domain/models/enums.dart';
import 'package:wordshool/features/admin/shared/domain/models/puzzle.dart';
import 'package:wordshool/features/admin/shared/domain/utils/grid_validator.dart';
import 'package:wordshool/shared/domains/entities/localized_text.dart';

// Same cases as functions/crossword/validate_puzzle_test.py.
const examplePath =
    '.claude/skills/crossword-content/examples/kerala-history-0012.puzzle.json';

AdminPuzzleWord word(String id, int number, WordDirection direction, int row,
        int col, String answer) =>
    AdminPuzzleWord(
      id: id,
      number: number,
      direction: direction,
      row: row,
      col: col,
      answer: answer,
      clue: const LocalizedText(en: 'clue'),
      questionId: 'q$id',
    );

// C A T
// O # O
// B E E
List<AdminPuzzleWord> smallWords() => [
      word('1A', 1, WordDirection.across, 0, 0, 'CAT'),
      word('1D', 1, WordDirection.down, 0, 0, 'COB'),
      word('2D', 2, WordDirection.down, 0, 2, 'TOE'),
      word('3A', 3, WordDirection.across, 2, 0, 'BEE'),
    ];

List<String> problems({
  int rows = 3,
  int cols = 3,
  String layout = '....#....',
  List<AdminPuzzleWord>? words,
}) =>
    gridProblems(
            rows: rows,
            cols: cols,
            layout: layout,
            words: words ?? smallWords())
        .map((p) => p.message)
        .toList();

List<AdminPuzzleWord> withWord(int index, AdminPuzzleWord replacement) =>
    smallWords()..[index] = replacement;

void main() {
  test('the example puzzle passes', () {
    final puzzle = AdminPuzzle.fromJson(
      jsonDecode(File(examplePath).readAsStringSync()) as Map<String, dynamic>,
    );
    expect(
      gridProblems(
          rows: puzzle.rows,
          cols: puzzle.cols,
          layout: puzzle.layout,
          words: puzzle.words),
      isEmpty,
    );
  });

  test('the small grid passes', () => expect(problems(), isEmpty));

  test('implied numbers follow the standard order', () {
    expect(
        impliedNumbers('....#....', 3, 3), {(0, 0): 1, (0, 2): 2, (2, 0): 3});
  });

  group('grid shape', () {
    test('size', () {
      expect(problems(rows: 2), [contains('between 3 and 15')]);
      expect(problems(cols: 16), [contains('between 3 and 15')]);
    });
    test('layout length and characters', () {
      expect(problems(layout: '....#...'), [contains('needs 9')]);
      expect(problems(layout: '....X....'), [contains('may only contain')]);
    });
    test('no words', () => expect(problems(words: []), [contains('no words')]));
  });

  group('word problems', () {
    void expectProblem(List<AdminPuzzleWord> words, String fragment) {
      final found = problems(words: words);
      expect(found.any((p) => p.contains(fragment)), isTrue, reason: '$found');
    }

    test('answers must be A–Z', () {
      expectProblem(
          withWord(0, word('1A', 1, WordDirection.across, 0, 0, 'cat')),
          '2 or more letters A–Z');
      expectProblem(withWord(0, word('1A', 1, WordDirection.across, 0, 0, 'C')),
          '2 or more letters A–Z');
    });
    test('duplicate and wrong ids', () {
      expectProblem(
          withWord(0, word('1D', 1, WordDirection.across, 0, 0, 'CAT')),
          'both numbered');
      expectProblem(
          withWord(3, word('3D', 3, WordDirection.across, 2, 0, 'BEE')),
          'ID should be 3A');
    });
    test('words must fill their whole run', () {
      expectProblem(
          withWord(3, word('3A', 3, WordDirection.across, 2, 1, 'EE')),
          'touches another letter');
      expectProblem(
          withWord(0, word('1A', 1, WordDirection.across, 0, 0, 'CA')),
          'touches another letter');
    });
    test('off the grid or over a block', () {
      expectProblem(
          withWord(0, word('1A', 1, WordDirection.across, 1, 0, 'OXO')),
          'runs off the grid');
      expectProblem(withWord(2, word('2D', 2, WordDirection.down, 1, 2, 'OEX')),
          'runs off the grid');
    });
    test('wrong number', () {
      expectProblem(withWord(2, word('3D', 3, WordDirection.down, 0, 2, 'TOE')),
          'number should be 2');
    });
    test('clashing letters name both words', () {
      final found = problems(
          words: withWord(2, word('2D', 2, WordDirection.down, 0, 2, 'XOE')));
      expect(
          found.any((p) =>
              p.contains('"X" at row 1, column 3') && p.contains('needs "T"')),
          isTrue);
    });
  });

  test('a letter cell without a word', () {
    final found = problems(words: smallWords()..removeAt(2));
    expect(found.where((p) => p.contains('no word uses it')), hasLength(1));
    expect(found.where((p) => p.contains('Down word')), hasLength(3));
  });

  test('a run without a word', () {
    final found = problems(words: smallWords()..removeAt(3));
    expect(
        found.any((p) =>
            p.startsWith('Row 3, column 1') && p.contains('Across word')),
        isTrue);
    expect(
        found.any((p) =>
            p.startsWith('Row 3, column 2') && p.contains('no word uses it')),
        isTrue);
  });

  test('each problem is listed once, with its cells', () {
    final result = gridProblems(
        rows: 3,
        cols: 3,
        layout: '....#....',
        words: smallWords()..removeAt(2));
    final messages = result.map((p) => p.message).toList();
    expect(messages.toSet(), hasLength(messages.length));
    expect(result.expand((p) => p.cells), contains((1, 2)));
  });
}
