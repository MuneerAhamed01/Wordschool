import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wordshool/features/crossword/puzzle/domain/utils/grid.dart';
import 'package:wordshool/features/crossword/puzzle/presentation/widgets/clue_chips.dart';
import 'package:wordshool/features/crossword/puzzle/presentation/widgets/board.dart';
import 'package:wordshool/features/crossword/puzzle/presentation/widgets/keyboard.dart';
import 'package:wordshool/features/crossword/puzzle/hints/presentation/widgets/hints_sheet.dart';

import '../../../crossword_fixtures.dart';

Widget _app(Widget child) =>
    MaterialApp(home: Scaffold(body: Center(child: child)));

CrosswordCellState _stateOf(WidgetTester tester, int index) =>
    tester.widget<CrosswordCellView>(find.byKey(ValueKey('cell-$index'))).state;

void main() {
  group('CrosswordBoard (CW-046)', () {
    testWidgets('highlights the active word and the cursor', (tester) async {
      final grid = CrosswordGrid.fromPuzzle(examplePuzzle());
      var revision = grid.revision;
      late StateSetter setState;
      await tester.pumpWidget(_app(StatefulBuilder(builder: (context, set) {
        setState = set;
        return SizedBox(
          width: 320,
          height: 320,
          child: CrosswordBoard(
            grid: grid,
            revision: revision,
            onCellTap: (i) => set(() {
              grid.tap(i);
              revision = grid.revision;
            }),
          ),
        );
      })));

      // 1A: cursor on its first square, the other six highlighted.
      expect(_stateOf(tester, 0), CrosswordCellState.cursor);
      for (var col = 1; col < 7; col++) {
        expect(_stateOf(tester, col), CrosswordCellState.word);
      }
      expect(_stateOf(tester, 8), CrosswordCellState.normal); // 1D, not active
      expect(_stateOf(tester, 7), CrosswordCellState.block);

      // Tap a 2D-only square → 2D becomes the active word.
      await tester.tap(find.byKey(const ValueKey('cell-34')));
      await tester.pump();
      expect(_stateOf(tester, 34), CrosswordCellState.cursor);
      for (final i in [18, 26, 42, 50]) {
        expect(_stateOf(tester, i), CrosswordCellState.word, reason: '$i');
      }
      expect(_stateOf(tester, 1), CrosswordCellState.normal);

      // Check colours right and wrong squares.
      setState(() {
        grid.selectWord('6A');
        grid.type('E');
        grid.type('X');
        grid.check();
        grid.selectWord('1A');
        revision = grid.revision;
      });
      await tester.pump();
      expect(_stateOf(tester, 57), CrosswordCellState.correct);
      expect(_stateOf(tester, 58), CrosswordCellState.wrong);
    });

    testWidgets('cells announce position, letter and check result',
        (tester) async {
      final grid = CrosswordGrid.fromPuzzle(examplePuzzle())..type('M');
      await tester.pumpWidget(_app(SizedBox(
          width: 320,
          height: 320,
          child: CrosswordBoard(grid: grid, revision: grid.revision))));
      expect(
          find.bySemanticsLabel('Row 1, column 1, clue 1, letter M'), findsOne);
    });
  });

  testWidgets('CrosswordKeyboard sends letters, delete and check',
      (tester) async {
    final typed = <String>[];
    var deletes = 0;
    var checks = 0;
    await tester.binding.setSurfaceSize(const Size(360, 400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_app(CrosswordKeyboard(
      onLetter: typed.add,
      onBackspace: () => deletes++,
      onCheck: () => checks++,
    )));
    await tester.tap(find.byKey(const ValueKey('key-Q')));
    await tester.tap(find.byKey(const ValueKey('key-M')));
    await tester.tap(find.byKey(const ValueKey('key-Delete')));
    await tester.tap(find.byKey(const ValueKey('key-Check answers')));
    expect(typed, ['Q', 'M']);
    expect(deletes, 1);
    expect(checks, 1);
    // Keys are 52 high (≥ 44 touch target).
    expect(tester.getSize(find.byKey(const ValueKey('key-Q'))).height, 52);
  });

  testWidgets('ClueChips selects a word', (tester) async {
    String? picked;
    await tester.pumpWidget(_app(ClueChips(
      wordIds: const ['1A', '2D'],
      activeId: '1A',
      filledIds: const {'2D'},
      onSelected: (id) => picked = id,
    )));
    await tester.tap(find.text('2D'));
    expect(picked, '2D');
  });

  group('HintsSheet (CW-048)', () {
    final word = examplePuzzle().words.firstWhere((w) => w.id == '2D');

    Future<HintChoice?> open(WidgetTester tester,
        {required int revealsLeft, required VoidCallback onShowClue}) async {
      HintChoice? result;
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await showModalBottomSheet<HintChoice>(
                context: context,
                isScrollControlled: true,
                builder: (_) => SingleChildScrollView(
                  child: HintsSheet(
                    word: word,
                    revealsLeft: revealsLeft,
                    letterPenalty: 5,
                    wordPenalty: 15,
                    clueShown: false,
                    onShowClue: onShowClue,
                  ),
                ),
              );
            },
            child: const Text('open'),
          ),
        ),
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      return result;
    }

    testWidgets('shows the clue once for free and picks a reveal',
        (tester) async {
      var shown = 0;
      await open(tester, revealsLeft: 3, onShowClue: () => shown++);
      expect(find.text('3 reveals left in this puzzle'), findsOne);
      expect(find.text('Fills all 6 letters of 2 Down · −15 XP'), findsOne);

      await tester.tap(find.byKey(const ValueKey('hint-clue')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('hint-clue')));
      await tester.pump();
      expect(shown, 1);
      expect(find.byKey(const ValueKey('hint-clue-text')), findsOne);

      await tester.tap(find.byKey(const ValueKey('hint-letter')));
      await tester.pumpAndSettle();
      expect(find.text('Need a hint?'), findsNothing);
    });

    testWidgets('not enough reveals disables the word reveal', (tester) async {
      await open(tester, revealsLeft: 2, onShowClue: () {});
      expect(find.text('Not enough reveals'), findsOne);
      await tester.tap(find.byKey(const ValueKey('hint-word')));
      await tester.pump();
      expect(find.text('Need a hint?'), findsOne); // still open
    });
  });
}
