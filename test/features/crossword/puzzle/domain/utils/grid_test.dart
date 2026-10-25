import 'package:flutter_test/flutter_test.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/word.dart';
import 'package:wordshool/features/crossword/puzzle/domain/utils/grid.dart';

import '../../../crossword_fixtures.dart';

void main() {
  // The example puzzle (kerala-history-0012), answers encoded by the server.
  late CrosswordGrid grid;
  int at(int row, int col) => row * 8 + col;

  setUp(() => grid = CrosswordGrid.fromPuzzle(examplePuzzle()));

  group('layout', () {
    test('decodes every answer and numbers the start squares', () {
      expect(grid.word('2D')!.answer, 'VAIKOM');
      expect(grid.word('1A')!.answer, 'MUZIRIS');
      expect(grid.cells[at(0, 0)].number, 1);
      expect(grid.cells[at(2, 2)].number, 2);
      expect(grid.cells[at(0, 1)].number, isNull);
      expect(grid.cells[at(0, 7)].isBlock, isTrue);
      expect(grid.letterCount, 31);
    });

    test('orders words across first, then down', () {
      expect(grid.words.map((w) => w.id),
          ['1A', '4A', '5A', '6A', '1D', '2D', '3D']);
    });

    test('a crossing square belongs to both words', () {
      final cell = grid.cells[at(0, 0)];
      expect(cell.acrossWordId, '1A');
      expect(cell.downWordId, '1D');
      expect(cell.wordIdIn(CrosswordDirection.down), '1D');
    });

    test('starts on the first word', () {
      expect(grid.cursor, at(0, 0));
      expect(grid.direction, CrosswordDirection.across);
      expect(grid.activeWord!.id, '1A');
      expect(grid.activeCells, hasLength(7));
    });
  });

  group('restore', () {
    test('letters from a progress doc', () {
      final restored = CrosswordGrid.fromPuzzle(
        examplePuzzle(),
        letters: exampleLetters['inProgress'],
      );
      expect(restored.typedAnswer('1A'), 'MUZIRIS');
      expect(restored.typedAnswer('2D'), '·A····'); // crosses ASAN
      expect(restored.filledCount, 11);
      expect(restored.lettersString, exampleLetters['inProgress']);
      // Cursor opens on the first word's first empty square (1A is full).
      expect(restored.cursor, at(0, 0));
    });

    test('revealed squares are refilled and locked', () {
      final restored = CrosswordGrid.fromPuzzle(
        examplePuzzle(),
        revealedCells: [at(2, 6), 999],
        revealedWordIds: ['3D', 'ZZ'],
      );
      expect(restored.letterAt(at(2, 6)), 'G');
      expect(restored.isRevealed(at(2, 6)), isTrue);
      expect(restored.revealedCells, [at(2, 6)]);
      expect(restored.revealedWordIds, ['3D']);
    });

    test('a letters string of the wrong length is ignored', () {
      final restored =
          CrosswordGrid.fromPuzzle(examplePuzzle(), letters: 'ABC');
      expect(restored.filledCount, 0);
    });
  });

  group('tap', () {
    test('moves the cursor and keeps the direction when a word runs that way',
        () {
      grid.tap(at(3, 2));
      expect(grid.cursor, at(3, 2));
      expect(grid.activeWord!.id, '4A');
    });

    test('switches direction when no word runs the current way', () {
      grid.tap(at(4, 2)); // only 2D passes here
      expect(grid.direction, CrosswordDirection.down);
      expect(grid.activeWord!.id, '2D');
    });

    test('tapping the cursor again toggles across/down on a crossing', () {
      grid.tap(at(0, 0));
      expect(grid.activeWord!.id, '1D');
      grid.tap(at(0, 0));
      expect(grid.activeWord!.id, '1A');
    });

    test('tapping again does not toggle when only one word passes', () {
      grid.tap(at(0, 3));
      grid.tap(at(0, 3));
      expect(grid.activeWord!.id, '1A');
    });

    test('blocks and out-of-range squares are ignored', () {
      final before = grid.revision;
      grid.tap(at(0, 7));
      grid.tap(-1);
      expect(grid.cursor, at(0, 0));
      expect(grid.revision, before);
    });
  });

  group('typing', () {
    test('fills and moves to the next square, staying on the last', () {
      for (final ch in 'muziris'.split('')) {
        grid.type(ch);
      }
      expect(grid.typedAnswer('1A'), 'MUZIRIS');
      expect(grid.cursor, at(0, 6));
      grid.type('X');
      expect(grid.typedAnswer('1A'), 'MUZIRIX');
    });

    test('ignores anything that is not A–Z', () {
      grid.type('1');
      grid.type('ab');
      grid.type('');
      expect(grid.filledCount, 0);
    });

    test('backspace clears, then moves back and clears', () {
      grid.type('M');
      grid.type('U');
      expect(grid.cursor, at(0, 2));
      grid.backspace(); // empty square → back to U and clear it
      expect(grid.cursor, at(0, 1));
      expect(grid.letterAt(at(0, 1)), '');
      grid.backspace(); // empty again → back to M and clear it
      expect(grid.cursor, at(0, 0));
      expect(grid.filledCount, 0);
      grid.backspace(); // first square: stays
      expect(grid.cursor, at(0, 0));
    });

    test('backspace on a filled square clears it in place', () {
      grid.type('M');
      grid.tap(at(0, 0));
      grid.tap(at(0, 0)); // back to across
      grid.backspace();
      expect(grid.cursor, at(0, 0));
      expect(grid.letterAt(at(0, 0)), '');
    });

    test('revealed squares are not overwritten or cleared', () {
      grid.revealLetter(); // M at (0,0)
      grid.tap(at(0, 0));
      grid.tap(at(0, 0));
      grid.type('Q');
      expect(grid.letterAt(at(0, 0)), 'M');
      expect(grid.cursor, at(0, 1));
      grid.backspace(); // (0,1) empty → back to (0,0), revealed → kept
      expect(grid.letterAt(at(0, 0)), 'M');
    });
  });

  group('words', () {
    test('selectWord jumps to the first empty square', () {
      grid.selectWord('2D');
      expect(grid.cursor, at(2, 2));
      grid.type('V');
      grid.selectWord('1A');
      grid.selectWord('2D');
      expect(grid.cursor, at(3, 2));
      grid.selectWord('nope');
      expect(grid.activeWord!.id, '2D');
    });

    test('a full word selects its first square', () {
      for (final ch in 'GAMA'.split('')) {
        grid.selectWord('3D');
        grid.type(ch);
      }
      grid.selectWord('3D');
      expect(grid.cursor, at(2, 6));
    });

    test('next and previous wrap around', () {
      grid.previousWord();
      expect(grid.activeWord!.id, '3D');
      grid.nextWord();
      expect(grid.activeWord!.id, '1A');
      grid.nextWord();
      expect(grid.activeWord!.id, '4A');
    });

    test('filled and correct per word', () {
      expect(grid.isWordFilled('6A'), isFalse);
      grid.selectWord('6A');
      for (final ch in 'EMZ'.split('')) {
        grid.type(ch);
      }
      expect(grid.isWordFilled('6A'), isTrue);
      expect(grid.isWordCorrect('6A'), isFalse);
      grid.backspace();
      grid.type('S');
      expect(grid.isWordCorrect('6A'), isTrue);
      expect(grid.isWordFilled('ZZ'), isFalse);
      expect(grid.isWordCorrect('ZZ'), isFalse);
    });
  });

  group('check', () {
    test('marks filled squares until they are edited', () {
      grid.type('M');
      grid.type('X');
      final summary = grid.check();
      expect(summary.correct, 1);
      expect(summary.wrong, 1);
      expect(grid.checkedAt(at(0, 0)), isTrue);
      expect(grid.checkedAt(at(0, 1)), isFalse);
      expect(grid.checkedAt(at(0, 2)), isNull);

      grid.tap(at(0, 1));
      grid.type('U');
      expect(grid.checkedAt(at(0, 1)), isNull);
      expect(grid.checkedAt(at(0, 0)), isTrue);
    });

    test('revealed squares are not counted', () {
      grid.revealLetter();
      final summary = grid.check();
      expect(summary.correct + summary.wrong, 0);
    });
  });

  group('reveal', () {
    test('letter fills the cursor square once', () {
      expect(grid.revealLetter(), isTrue);
      expect(grid.letterAt(at(0, 0)), 'M');
      expect(grid.revealLetter(), isFalse);
      expect(grid.revealedWordIds, isEmpty);
    });

    test('word fills the active word and is recorded', () {
      grid.selectWord('2D');
      expect(grid.revealWord(), isTrue);
      expect(grid.typedAnswer('2D'), 'VAIKOM');
      expect(grid.revealedWordIds, ['2D']);
      expect(grid.revealWord(), isFalse);
    });
  });

  group('solved', () {
    test('only when every letter matches', () {
      final full = CrosswordGrid.fromPuzzle(
        examplePuzzle(),
        letters: exampleLetters['completedWithTypo'],
      );
      expect(full.isComplete, isTrue);
      expect(full.isSolved, isFalse);
      expect(full.typedAnswer('2D'), 'VAIKAM');

      final solved = CrosswordGrid.fromPuzzle(
        examplePuzzle(),
        letters: exampleLetters['solved'],
      );
      expect(solved.isSolved, isTrue);
      expect(solved.lettersString, exampleLetters['solved']);
    });
  });

  test('an empty puzzle does nothing', () {
    final empty = CrosswordGrid(rows: 1, cols: 2, layout: '##', words: []);
    empty.type('A');
    empty.backspace();
    empty.nextWord();
    expect(empty.activeWord, isNull);
    expect(empty.revealLetter(), isFalse);
    expect(empty.revealWord(), isFalse);
    expect(empty.isSolved, isTrue);
  });
}
