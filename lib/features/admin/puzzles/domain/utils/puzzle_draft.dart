import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:wordshool/features/admin/shared/domain/models/enums.dart';
import 'package:wordshool/features/admin/shared/domain/models/puzzle.dart';
import 'package:wordshool/features/admin/shared/domain/models/question.dart';
import 'package:wordshool/features/admin/shared/domain/utils/grid_validator.dart';
import 'package:wordshool/shared/domains/entities/localized_text.dart';

/// A question placed on the grid. Numbers, ids and black squares are worked
/// out from the placements, so the admin never edits them by hand.
class Placement extends Equatable {
  const Placement({
    required this.questionId,
    required this.answer,
    required this.row,
    required this.col,
    required this.direction,
    required this.clue,
    this.extraClue,
    this.fact,
  });

  final String questionId;
  final String answer;
  final int row;
  final int col;
  final WordDirection direction;
  final LocalizedText clue;
  final LocalizedText? extraClue;
  final LocalizedText? fact;

  List<Cell> get cells => wordCells(row, col, direction, answer.length);

  Placement copyWith({
    int? row,
    int? col,
    LocalizedText? clue,
    LocalizedText? extraClue,
    bool clearExtraClue = false,
  }) =>
      Placement(
        questionId: questionId,
        answer: answer,
        row: row ?? this.row,
        col: col ?? this.col,
        direction: direction,
        clue: clue ?? this.clue,
        extraClue: clearExtraClue ? null : (extraClue ?? this.extraClue),
        fact: fact,
      );

  @override
  List<Object?> get props =>
      [questionId, answer, row, col, direction, clue, extraClue, fact];
}

/// [question] placed at ([row], [col]): its easiest clue as the clue, the next
/// clue as the extra hint and its fact, word for word.
Placement placementFor(
    AdminQuestion question, int row, int col, WordDirection direction) {
  final first = question.firstClue;
  final extra = question.clues.where((c) => c != first).firstOrNull;
  return Placement(
    questionId: question.id!,
    answer: question.answer,
    row: row,
    col: col,
    direction: direction,
    clue: LocalizedText(en: first?.en ?? '', ml: first?.ml),
    extraClue: extra == null ? null : LocalizedText(en: extra.en, ml: extra.ml),
    fact: question.fact,
  );
}

/// A spot where a word fits, crossing [crossings] existing letters.
class PlacementSpot extends Equatable {
  const PlacementSpot(this.row, this.col, this.direction, this.crossings);

  final int row;
  final int col;
  final WordDirection direction;
  final int crossings;

  String get label =>
      '${direction.label} from row ${row + 1}, column ${col + 1}'
      '${crossings == 0 ? '' : ' · crosses $crossings'}';

  @override
  List<Object?> get props => [row, col, direction, crossings];
}

/// A puzzle grid under construction.
class PuzzleDraft extends Equatable {
  const PuzzleDraft(
      {required this.rows, required this.cols, this.placements = const []});

  /// Rebuilds the draft from a saved puzzle (its words become placements).
  factory PuzzleDraft.fromPuzzle(AdminPuzzle puzzle) => PuzzleDraft(
        rows: puzzle.rows,
        cols: puzzle.cols,
        placements: [
          for (final word in puzzle.words)
            Placement(
              questionId: word.questionId,
              answer: word.answer,
              row: word.row,
              col: word.col,
              direction: word.direction,
              clue: word.clue,
              extraClue: word.extraClue,
              fact: word.fact,
            ),
        ],
      );

  final int rows;
  final int cols;
  final List<Placement> placements;

  bool _inGrid(Cell cell) =>
      cell.$1 >= 0 && cell.$1 < rows && cell.$2 >= 0 && cell.$2 < cols;

  bool fits(Placement placement) => placement.cells.every(_inGrid);

  /// Letter cells are the cells covered by a word; everything else is a block.
  String get layout {
    final open = <Cell>{
      for (final p in placements)
        for (final cell in p.cells)
          if (_inGrid(cell)) cell,
    };
    final buffer = StringBuffer();
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        buffer.write(open.contains((r, c)) ? '.' : '#');
      }
    }
    return buffer.toString();
  }

  Map<Cell, int> get numbers => impliedNumbers(layout, rows, cols);

  /// Letter shown in each cell (the first word wins where letters clash).
  Map<Cell, String> get letters {
    final result = <Cell, String>{};
    for (final p in placements) {
      final cells = p.cells;
      for (var i = 0; i < cells.length; i++) {
        if (_inGrid(cells[i])) result.putIfAbsent(cells[i], () => p.answer[i]);
      }
    }
    return result;
  }

  /// The puzzle words with numbers and ids, in clue order (number, across first).
  List<AdminPuzzleWord> get words {
    final numbering = numbers;
    final result = [
      for (final p in placements)
        if (fits(p))
          AdminPuzzleWord(
            id: '${numbering[(p.row, p.col)] ?? 0}${p.direction.letter}',
            number: numbering[(p.row, p.col)] ?? 0,
            direction: p.direction,
            row: p.row,
            col: p.col,
            answer: p.answer,
            clue: p.clue,
            extraClue: p.extraClue,
            fact: p.fact,
            questionId: p.questionId,
          ),
    ];
    result.sort((a, b) {
      final byNumber = a.number.compareTo(b.number);
      return byNumber != 0
          ? byNumber
          : a.direction.index.compareTo(b.direction.index);
    });
    return result;
  }

  /// Everything that would stop the server from saving the grid.
  List<GridProblem> get problems {
    final result = <GridProblem>[];
    for (final p in placements) {
      if (!fits(p)) {
        result.add(GridProblem(
          '${p.answer} runs off the grid. Move it or make the grid bigger.',
          p.cells.where(_inGrid).toSet(),
        ));
      }
    }
    final placed = placements.where(fits).toList();
    final seen = <String>{};
    for (final p in placed) {
      if (!seen.add('${p.row},${p.col},${p.direction.value}')) {
        result.add(GridProblem(
            'Two words start at the same square in the same direction.',
            {(p.row, p.col)}));
      }
    }
    if (placed.length < 2) {
      result.add(const GridProblem('Add at least 2 words.'));
    }
    if (placed.isNotEmpty) {
      result.addAll(
          gridProblems(rows: rows, cols: cols, layout: layout, words: words));
    }
    return result;
  }

  Set<Cell> get problemCells => {for (final p in problems) ...p.cells};

  PuzzleDraft copyWith({int? rows, int? cols, List<Placement>? placements}) =>
      PuzzleDraft(
        rows: rows ?? this.rows,
        cols: cols ?? this.cols,
        placements: placements ?? this.placements,
      );

  PuzzleDraft add(Placement placement) =>
      copyWith(placements: [...placements, placement]);

  PuzzleDraft removeAt(int index) =>
      copyWith(placements: [...placements]..removeAt(index));

  PuzzleDraft replaceAt(int index, Placement placement) =>
      copyWith(placements: [...placements]..[index] = placement);

  /// Index of the placement covering [cell], preferring [direction].
  int? placementAt(Cell cell, {WordDirection? direction}) {
    int? fallback;
    for (var i = 0; i < placements.length; i++) {
      if (!placements[i].cells.contains(cell)) continue;
      if (direction == null || placements[i].direction == direction) return i;
      fallback ??= i;
    }
    return fallback;
  }

  /// Shrinks the grid to the words (at least 3×3) and moves them to the top left.
  PuzzleDraft trimmed() {
    final cells = [for (final p in placements) ...p.cells];
    if (cells.isEmpty) return this;
    final top = cells.map((c) => c.$1).reduce(min);
    final left = cells.map((c) => c.$2).reduce(min);
    final bottom = cells.map((c) => c.$1).reduce(max);
    final right = cells.map((c) => c.$2).reduce(max);
    final newRows = (bottom - top + 1).clamp(minGridSize, maxGridSize);
    final newCols = (right - left + 1).clamp(minGridSize, maxGridSize);
    return PuzzleDraft(
      rows: newRows,
      cols: newCols,
      placements: [
        for (final p in placements)
          p.copyWith(row: p.row - top, col: p.col - left)
      ],
    );
  }

  /// Can [answer] go at ([row], [col]) in [direction] without breaking the grid?
  /// Returns the number of existing letters it crosses, or null if it can't.
  int? crossingsAt(
    String answer,
    int row,
    int col,
    WordDirection direction, {
    Map<Cell, String>? currentLetters,
  }) {
    final cells = wordCells(row, col, direction, answer.length);
    if (!cells.every(_inGrid)) return null;
    final current = currentLetters ?? letters;
    final dr = direction.dRow;
    final dc = direction.dCol;
    // No letter right before or after the word.
    if (current.containsKey((row - dr, col - dc))) return null;
    final end = cells.last;
    if (current.containsKey((end.$1 + dr, end.$2 + dc))) return null;
    // Same start and direction as an existing word.
    if (placements
        .any((p) => p.row == row && p.col == col && p.direction == direction)) {
      return null;
    }

    var crossings = 0;
    for (var i = 0; i < cells.length; i++) {
      final cell = cells[i];
      final existing = current[cell];
      if (existing != null) {
        if (existing != answer[i]) return null;
        // Crossing a word running the same way would merge the two.
        final covering = placementAt(cell, direction: direction);
        if (covering != null && placements[covering].direction == direction) {
          return null;
        }
        crossings++;
      } else {
        // A new letter must not touch letters on its sides.
        final side1 = (cell.$1 + dc, cell.$2 + dr);
        final side2 = (cell.$1 - dc, cell.$2 - dr);
        if (current.containsKey(side1) || current.containsKey(side2)) {
          return null;
        }
      }
    }
    if (crossings == cells.length) return null;
    return crossings;
  }

  /// Good spots for [answer]: crossing existing words when there are any,
  /// otherwise centred. Best first, at most [limit].
  List<PlacementSpot> suggestions(String answer, {int limit = 8}) {
    if (answer.length < 2) return const [];
    final spots = <PlacementSpot>[];
    final current = letters;
    final hasWords = placements.isNotEmpty;
    for (final direction in WordDirection.values) {
      for (final (r, c) in _starts(answer, direction, current, hasWords)) {
        final crossings =
            crossingsAt(answer, r, c, direction, currentLetters: current);
        if (crossings == null) continue;
        if (hasWords && crossings == 0) continue;
        spots.add(PlacementSpot(r, c, direction, crossings));
      }
    }
    double distance(PlacementSpot s) {
      final midRow = s.row + s.direction.dRow * (answer.length - 1) / 2;
      final midCol = s.col + s.direction.dCol * (answer.length - 1) / 2;
      return (midRow - (rows - 1) / 2).abs() + (midCol - (cols - 1) / 2).abs();
    }

    spots.sort((a, b) {
      final byCrossings = b.crossings.compareTo(a.crossings);
      if (byCrossings != 0) return byCrossings;
      final byDistance = distance(a).compareTo(distance(b));
      if (byDistance != 0) return byDistance;
      final byDirection = a.direction.index.compareTo(b.direction.index);
      if (byDirection != 0) return byDirection;
      return (a.row * cols + a.col).compareTo(b.row * cols + b.col);
    });
    return spots.take(limit).toList();
  }

  /// Start squares worth trying for [answer]: every square on an empty grid,
  /// otherwise only those that put one of its letters on a matching letter
  /// (a spot that crosses nothing isn't suggested once there are words).
  Iterable<Cell> _starts(String answer, WordDirection direction,
      Map<Cell, String> current, bool hasWords) {
    if (!hasWords) {
      return [
        for (var r = 0; r < rows; r++)
          for (var c = 0; c < cols; c++) (r, c)
      ];
    }
    final starts = <Cell>{};
    for (final MapEntry(key: cell, value: letter) in current.entries) {
      for (var i = 0; i < answer.length; i++) {
        if (answer[i] != letter) continue;
        starts.add((cell.$1 - i * direction.dRow, cell.$2 - i * direction.dCol));
      }
    }
    return starts;
  }

  @override
  List<Object?> get props => [rows, cols, placements];
}
