import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wordshool/features/admin/shared/domain/models/enums.dart';
import 'package:wordshool/features/admin/shared/domain/models/puzzle.dart';
import 'package:wordshool/features/admin/puzzles/domain/utils/puzzle_draft.dart';
import 'package:wordshool/shared/domains/entities/localized_text.dart';

const examplePath =
    '.claude/skills/crossword-content/examples/kerala-history-0012.puzzle.json';

Placement place(String answer, int row, int col, WordDirection direction) =>
    Placement(
      questionId: 'q-$answer',
      answer: answer,
      row: row,
      col: col,
      direction: direction,
      clue: LocalizedText(en: 'Clue for $answer'),
    );

void main() {
  late AdminPuzzle example;

  setUp(() {
    example = AdminPuzzle.fromJson(
      jsonDecode(File(examplePath).readAsStringSync()) as Map<String, dynamic>,
    );
  });

  test('the example puzzle can be rebuilt from its placements alone', () {
    // Placements carry no numbers, ids or layout — the draft works them out.
    final draft = PuzzleDraft(
      rows: 8,
      cols: 8,
      placements: [
        for (final w in example.words)
          place(w.answer, w.row, w.col, w.direction),
      ],
    );
    expect(draft.layout, example.layout);
    expect(draft.problems, isEmpty);
    expect(
      draft.words.map((w) => '${w.id}:${w.answer}'),
      example.words.map((w) => '${w.id}:${w.answer}'),
    );
  });

  test('fromPuzzle keeps clues and question ids', () {
    final draft = PuzzleDraft.fromPuzzle(example);
    expect(draft.placements, hasLength(7));
    expect(draft.words.first.clue, example.words.first.clue);
    expect(draft.words.first.questionId, 'TODO');
  });

  test('a single word is not enough', () {
    final draft = const PuzzleDraft(rows: 5, cols: 5)
        .add(place('CAT', 0, 0, WordDirection.across));
    expect(draft.problems.map((p) => p.message),
        contains('Add at least 2 words.'));
  });

  test('a word off the grid is reported', () {
    final draft = const PuzzleDraft(rows: 3, cols: 3)
        .add(place('CAT', 0, 0, WordDirection.across))
        .add(place('TOES', 0, 2, WordDirection.down));
    expect(draft.problems.first.message, contains('TOES runs off the grid'));
  });

  test('a clash highlights the cell', () {
    final draft = const PuzzleDraft(rows: 3, cols: 3)
        .add(place('CAT', 0, 0, WordDirection.across))
        .add(place('DOG', 0, 0, WordDirection.down));
    expect(draft.problemCells, contains((0, 0)));
    expect(draft.problems.any((p) => p.message.contains('needs "C"')), isTrue);
  });

  group('suggestions', () {
    test('the first word goes in the middle', () {
      final spots = const PuzzleDraft(rows: 7, cols: 7).suggestions('CAT');
      expect(spots.first, const PlacementSpot(3, 2, WordDirection.across, 0));
    });

    test('later words must cross an existing word on a matching letter', () {
      final draft = const PuzzleDraft(rows: 7, cols: 7)
          .add(place('CAT', 3, 2, WordDirection.across));
      final spots = draft.suggestions('TOE');
      expect(spots, isNotEmpty);
      for (final spot in spots) {
        expect(spot.crossings, greaterThan(0));
        final placed =
            draft.add(place('TOE', spot.row, spot.col, spot.direction));
        expect(placed.problems.where((p) => !p.message.contains('at least 2')),
            isEmpty,
            reason: spot.label);
      }
      expect(spots, contains(const PlacementSpot(3, 4, WordDirection.down, 1)));
    });

    test('no spot when nothing crosses', () {
      final draft = const PuzzleDraft(rows: 7, cols: 7)
          .add(place('CAT', 3, 2, WordDirection.across));
      expect(draft.suggestions('XYZ'), isEmpty);
    });

    test('a word can\'t extend or sit next to another word', () {
      final draft = const PuzzleDraft(rows: 7, cols: 7)
          .add(place('CAT', 3, 2, WordDirection.across));
      expect(draft.crossingsAt('TO', 3, 5, WordDirection.across),
          isNull); // touches the T
      expect(draft.crossingsAt('DOG', 2, 2, WordDirection.across),
          isNull); // parallel neighbour
      expect(draft.crossingsAt('CAT', 3, 2, WordDirection.across),
          isNull); // same spot
    });
  });

  test('trimmed moves words to the top left and shrinks the grid', () {
    final draft = const PuzzleDraft(rows: 10, cols: 10)
        .add(place('CAT', 4, 3, WordDirection.across))
        .add(place('COB', 4, 3, WordDirection.down))
        .trimmed();
    expect(draft.rows, 3);
    expect(draft.cols, 3);
    expect(draft.placements.first.row, 0);
    expect(draft.layout, '...' '.##' '.##');
  });

  test('placementAt prefers the asked direction', () {
    final draft = const PuzzleDraft(rows: 3, cols: 3)
        .add(place('CAT', 0, 0, WordDirection.across))
        .add(place('COB', 0, 0, WordDirection.down));
    expect(draft.placementAt((0, 0), direction: WordDirection.down), 1);
    expect(draft.placementAt((0, 1), direction: WordDirection.down), 0);
    expect(draft.placementAt((2, 2)), isNull);
  });
}
