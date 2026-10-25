import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wordshool/features/admin/shared/domain/models/enums.dart';
import 'package:wordshool/features/admin/shared/domain/utils/grid_validator.dart';
import 'package:wordshool/features/admin/puzzles/domain/utils/puzzle_draft.dart';
import 'package:wordshool/features/admin/puzzles/presentation/widgets/crossword_grid.dart';
import 'package:wordshool/shared/domains/entities/localized_text.dart';

void main() {
  testWidgets('shows letters and numbers and reports taps', (tester) async {
    final draft = const PuzzleDraft(rows: 3, cols: 3)
        .add(const Placement(
          questionId: 'q1',
          answer: 'CAT',
          row: 0,
          col: 0,
          direction: WordDirection.across,
          clue: LocalizedText(en: 'Pet'),
        ))
        .add(const Placement(
          questionId: 'q2',
          answer: 'COB',
          row: 0,
          col: 0,
          direction: WordDirection.down,
          clue: LocalizedText(en: 'Corn'),
        ));
    Cell? tapped;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 300,
          child: CrosswordGrid(
            rows: draft.rows,
            cols: draft.cols,
            letters: draft.letters,
            numbers: draft.numbers,
            editing: true,
            onCellTap: (cell) => tapped = cell,
          ),
        ),
      ),
    ));

    expect(find.text('C'), findsOneWidget);
    expect(find.text('T'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);

    await tester.tap(find.text('T'));
    expect(tapped, (0, 2));
  });
}
