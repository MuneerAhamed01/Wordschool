import 'package:wordshool/features/admin/shared/domain/models/enums.dart';
import 'package:wordshool/features/admin/shared/domain/models/puzzle.dart';

/// Dart port of `functions/crossword/validate_puzzle.py` (CW-013). Same
/// checks, so a grid that is clean here is accepted by the server; messages
/// are written for people (rows and columns count from 1) and carry the cells
/// to highlight.

const minGridSize = 3;
const maxGridSize = 15;
final _answerPattern = RegExp(r'^[A-Z]{2,}$');

typedef Cell = (int row, int col);

class GridProblem {
  const GridProblem(this.message, [this.cells = const {}]);

  final String message;
  final Set<Cell> cells;

  @override
  String toString() => message;
}

/// `row 3, column 5` (1-based).
String cellName(Cell cell) => 'row ${cell.$1 + 1}, column ${cell.$2 + 1}';

/// `2 Down (VAIKOM)`.
String wordLabel(AdminPuzzleWord word) =>
    '${word.number} ${word.direction.label} (${word.answer})';

/// Cells a word covers, first letter first.
List<Cell> wordCells(int row, int col, WordDirection direction, int length) => [
      for (var i = 0; i < length; i++)
        (row + direction.dRow * i, col + direction.dCol * i),
    ];

/// Standard crossword numbering: row by row, a letter cell gets the next
/// number when it starts an across or a down run of two or more letters.
Map<Cell, int> impliedNumbers(String layout, int rows, int cols) {
  bool isOpen(int r, int c) =>
      r >= 0 && r < rows && c >= 0 && c < cols && layout[r * cols + c] == '.';

  final numbers = <Cell, int>{};
  for (var r = 0; r < rows; r++) {
    for (var c = 0; c < cols; c++) {
      if (!isOpen(r, c)) continue;
      final startsAcross = !isOpen(r, c - 1) && isOpen(r, c + 1);
      final startsDown = !isOpen(r - 1, c) && isOpen(r + 1, c);
      if (startsAcross || startsDown) numbers[(r, c)] = numbers.length + 1;
    }
  }
  return numbers;
}

/// Every problem with the grid; empty when the server will accept it.
List<GridProblem> gridProblems({
  required int rows,
  required int cols,
  required String layout,
  required List<AdminPuzzleWord> words,
}) {
  if (rows < minGridSize ||
      rows > maxGridSize ||
      cols < minGridSize ||
      cols > maxGridSize) {
    return [
      const GridProblem(
          'The grid must be between $minGridSize and $maxGridSize cells each way.')
    ];
  }
  if (layout.length != rows * cols) {
    return [
      GridProblem(
          'The layout has ${layout.length} cells but the grid needs ${rows * cols}.')
    ];
  }
  if (layout.split('').any((ch) => ch != '.' && ch != '#')) {
    return [
      const GridProblem(
          'The layout may only contain "." (letter) and "#" (block).')
    ];
  }
  if (words.isEmpty) return [const GridProblem('The puzzle has no words yet.')];

  bool isOpen(int r, int c) =>
      r >= 0 && r < rows && c >= 0 && c < cols && layout[r * cols + c] == '.';

  final problems = <GridProblem>[];
  final numbers = impliedNumbers(layout, rows, cols);
  final letters = <Cell, (String, AdminPuzzleWord)>{};
  final covered = {
    WordDirection.across: <Cell>{},
    WordDirection.down: <Cell>{}
  };
  final seenIds = <String>{};

  for (final word in words) {
    final label = wordLabel(word);
    if (!seenIds.add(word.id)) {
      problems.add(GridProblem(
          'Two words are both numbered ${word.number} ${word.direction.label}.'));
    }
    if (!_answerPattern.hasMatch(word.answer)) {
      problems.add(
          GridProblem('$label: the answer must be 2 or more letters A–Z.'));
      continue;
    }
    final expectedId = '${word.number}${word.direction.letter}';
    if (word.id != expectedId) {
      problems.add(GridProblem('$label: its ID should be $expectedId.'));
    }
    final cells = wordCells(word.row, word.col, word.direction, word.length);
    if (!cells.every((cell) => isOpen(cell.$1, cell.$2))) {
      problems.add(GridProblem(
          '$label runs off the grid or over a black square.',
          cells.where((cell) => isOpen(cell.$1, cell.$2)).toSet()));
      continue;
    }
    final first = cells.first;
    final last = cells.last;
    final dr = word.direction.dRow;
    final dc = word.direction.dCol;
    if (isOpen(first.$1 - dr, first.$2 - dc) ||
        isOpen(last.$1 + dr, last.$2 + dc)) {
      problems.add(GridProblem(
        '$label touches another letter at its start or end, so players would '
        'read a longer word. Move it so there is a gap.',
        {
          if (isOpen(first.$1 - dr, first.$2 - dc))
            (first.$1 - dr, first.$2 - dc),
          if (isOpen(last.$1 + dr, last.$2 + dc)) (last.$1 + dr, last.$2 + dc),
          ...cells,
        },
      ));
    }
    final startNumber = numbers[first];
    if (startNumber != word.number) {
      problems.add(GridProblem(
          '$label: its number should be ${startNumber ?? '–'}.', {first}));
    }
    for (var i = 0; i < cells.length; i++) {
      final cell = cells[i];
      final letter = word.answer[i];
      final previous = letters[cell];
      if (previous != null && previous.$1 != letter) {
        problems.add(GridProblem(
          '$label puts "$letter" at ${cellName(cell)}, but ${wordLabel(previous.$2)} '
          'needs "${previous.$1}" there.',
          {cell},
        ));
      } else {
        letters[cell] = (letter, word);
      }
      covered[word.direction]!.add(cell);
    }
  }

  for (var r = 0; r < rows; r++) {
    for (var c = 0; c < cols; c++) {
      if (!isOpen(r, c)) continue;
      final cell = (r, c);
      if (!letters.containsKey(cell)) {
        problems.add(GridProblem(
            '${_cap(cellName(cell))} is a letter square but no word uses it.',
            {cell}));
      }
      final inAcrossRun = isOpen(r, c - 1) || isOpen(r, c + 1);
      if (inAcrossRun && !covered[WordDirection.across]!.contains(cell)) {
        problems.add(GridProblem(
          '${_cap(cellName(cell))}: letters side by side here don\'t form an Across word. '
          'Move a word so they don\'t touch.',
          {cell},
        ));
      }
      final inDownRun = isOpen(r - 1, c) || isOpen(r + 1, c);
      if (inDownRun && !covered[WordDirection.down]!.contains(cell)) {
        problems.add(GridProblem(
          '${_cap(cellName(cell))}: letters above/below each other here don\'t form a Down word. '
          'Move a word so they don\'t touch.',
          {cell},
        ));
      }
    }
  }

  // Same message once (like the server), with every cell it applies to.
  final merged = <String, Set<Cell>>{};
  for (final problem in problems) {
    merged.putIfAbsent(problem.message, () => <Cell>{}).addAll(problem.cells);
  }
  return [
    for (final entry in merged.entries) GridProblem(entry.key, entry.value)
  ];
}

String _cap(String text) =>
    text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);
