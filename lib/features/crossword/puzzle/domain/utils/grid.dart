import 'package:wordshool/features/crossword/shared/domain/entities/puzzle.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/word.dart';
import 'package:wordshool/features/crossword/puzzle/domain/utils/answer_encoding.dart';

/// One answer slot with its decoded answer and the cells it covers.
class GridWord {
  GridWord({
    required this.id,
    required this.number,
    required this.direction,
    required this.answer,
    required this.cells,
  });

  final String id;
  final int number;
  final CrosswordDirection direction;

  /// Decoded, uppercase A–Z.
  final String answer;

  /// Cell indexes (row * cols + col), first to last.
  final List<int> cells;

  int get length => cells.length;
}

/// A square of the grid.
class GridCell {
  GridCell({
    required this.index,
    required this.row,
    required this.col,
    required this.isBlock,
    this.solution = '',
  });

  final int index;
  final int row;
  final int col;
  final bool isBlock;

  /// The correct letter ('' for blocks).
  final String solution;

  /// Clue number shown in the corner, if a word starts here.
  int? number;
  String? acrossWordId;
  String? downWordId;

  String? wordIdIn(CrosswordDirection direction) =>
      direction == CrosswordDirection.across ? acrossWordId : downWordId;
}

/// Result of a Check: filled, non-revealed letters marked right or wrong.
class CheckSummary {
  const CheckSummary({required this.correct, required this.wrong});

  final int correct;
  final int wrong;
}

/// The crossword engine (CW-043): layout, cursor, typing, check and reveal.
///
/// Pure Dart and mutable; the puzzle bloc owns one instance and emits a new
/// state with [revision] after every change. One source of truth for the cell
/// states in `design/screens/psc-crossword.md#2-puzzle`.
class CrosswordGrid {
  CrosswordGrid({
    required this.rows,
    required this.cols,
    required String layout,
    required List<GridWord> words,
    String? letters,
    Iterable<int> revealedCells = const [],
    Iterable<String> revealedWordIds = const [],
  })  : assert(layout.length == rows * cols, 'layout must be rows × cols'),
        words = _ordered(words) {
    final solutions = <int, String>{};
    for (final word in words) {
      for (var i = 0; i < word.cells.length; i++) {
        solutions[word.cells[i]] = word.answer[i];
      }
    }
    cells = [
      for (var i = 0; i < layout.length; i++)
        GridCell(
          index: i,
          row: i ~/ cols,
          col: i % cols,
          isBlock: layout[i] == '#',
          solution: solutions[i] ?? '',
        ),
    ];
    for (final word in words) {
      cells[word.cells.first].number = word.number;
      for (final index in word.cells) {
        if (word.direction == CrosswordDirection.across) {
          cells[index].acrossWordId = word.id;
        } else {
          cells[index].downWordId = word.id;
        }
      }
      _wordsById[word.id] = word;
    }
    _letters = List.filled(layout.length, '');
    if (letters != null && letters.length == layout.length) {
      for (var i = 0; i < letters.length; i++) {
        final ch = letters[i];
        if (!cells[i].isBlock && _isLetter(ch)) _letters[i] = ch;
      }
    }
    _revealed.addAll(revealedCells.where(_isLetterCell));
    _revealedWords.addAll(revealedWordIds.where(_wordsById.containsKey));
    for (final index in _revealed) {
      _letters[index] = cells[index].solution;
    }
    if (this.words.isNotEmpty) {
      final first = this.words.first;
      direction = first.direction;
      cursor = _firstEmptyOr(first);
    }
  }

  /// Builds the engine for a published puzzle, decoding every answer.
  factory CrosswordGrid.fromPuzzle(
    CrosswordPuzzleEntity puzzle, {
    String? letters,
    Iterable<int> revealedCells = const [],
    Iterable<String> revealedWordIds = const [],
  }) {
    return CrosswordGrid(
      rows: puzzle.rows,
      cols: puzzle.cols,
      layout: puzzle.layout,
      letters: letters,
      revealedCells: revealedCells,
      revealedWordIds: revealedWordIds,
      words: [
        for (final w in puzzle.words)
          GridWord(
            id: w.id,
            number: w.number,
            direction: w.direction,
            answer: decodeAnswer(w.answerEnc, puzzle.id, w.id),
            cells: [
              for (var i = 0; i < w.length; i++)
                w.direction == CrosswordDirection.across
                    ? w.row * puzzle.cols + w.col + i
                    : (w.row + i) * puzzle.cols + w.col,
            ],
          ),
      ],
    );
  }

  final int rows;
  final int cols;

  /// Across words by number, then down words by number (`1A 4A … 1D 2D`).
  final List<GridWord> words;
  late final List<GridCell> cells;

  final Map<String, GridWord> _wordsById = {};
  late final List<String> _letters;
  final Set<int> _revealed = {};
  final Set<String> _revealedWords = {};

  /// Cells marked by the last Check, until edited: true = right.
  final Map<int, bool> _checked = {};

  int cursor = 0;
  CrosswordDirection direction = CrosswordDirection.across;

  /// Goes up on every change, so blocs can tell states apart.
  int revision = 0;

  static List<GridWord> _ordered(List<GridWord> words) =>
      [...words]..sort((a, b) => a.direction != b.direction
          ? a.direction.index.compareTo(b.direction.index)
          : a.number.compareTo(b.number));

  static bool _isLetter(String ch) =>
      ch.length == 1 && ch.codeUnitAt(0) >= 65 && ch.codeUnitAt(0) <= 90;

  bool _isLetterCell(int index) =>
      index >= 0 && index < cells.length && !cells[index].isBlock;

  // ---------- Reading ----------

  GridWord? word(String id) => _wordsById[id];

  String letterAt(int index) => _letters[index];

  bool isRevealed(int index) => _revealed.contains(index);

  /// True/false after a Check (until the cell changes), null otherwise.
  bool? checkedAt(int index) => _checked[index];

  /// The word under the cursor in the current direction (or the other one).
  GridWord? get activeWord {
    if (cells.isEmpty || cells[cursor].isBlock) return null;
    final id = cells[cursor].wordIdIn(direction) ??
        cells[cursor].wordIdIn(direction.other);
    return id == null ? null : _wordsById[id];
  }

  Set<int> get activeCells => activeWord?.cells.toSet() ?? const {};

  int get letterCount => cells.where((c) => !c.isBlock).length;

  int get filledCount => [
        for (final c in cells)
          if (!c.isBlock && _letters[c.index] != '') c
      ].length;

  bool get isComplete => filledCount == letterCount;

  /// Every letter matches the answer key.
  bool get isSolved => cells
      .where((c) => !c.isBlock)
      .every((c) => _letters[c.index] == c.solution);

  bool isWordFilled(String id) =>
      _wordsById[id]?.cells.every((i) => _letters[i] != '') ?? false;

  bool isWordCorrect(String id) =>
      _wordsById[id]?.cells.every((i) => _letters[i] == cells[i].solution) ??
      false;

  /// What the player has in [id], `·` for empty squares (`VAI·OM`).
  String typedAnswer(String id) => [
        for (final i in _wordsById[id]?.cells ?? const <int>[])
          _letters[i] == '' ? '·' : _letters[i],
      ].join();

  /// Progress doc / `submitCrossword` format: `.` empty, `#` block.
  String get lettersString => [
        for (final c in cells)
          c.isBlock ? '#' : (_letters[c.index] == '' ? '.' : _letters[c.index]),
      ].join();

  List<int> get revealedCells => _revealed.toList()..sort();

  /// Words filled by "Reveal the word" (sent as `revealedWordIds`).
  List<String> get revealedWordIds => _revealedWords.toList()..sort();

  // ---------- Cursor ----------

  /// Tap: move the cursor there; tapping the cursor again switches
  /// across/down when a word runs the other way.
  void tap(int index) {
    if (!_isLetterCell(index)) return;
    if (index == cursor) {
      if (cells[index].wordIdIn(direction.other) != null) {
        direction = direction.other;
      }
    } else {
      cursor = index;
      if (cells[index].wordIdIn(direction) == null) direction = direction.other;
    }
    revision++;
  }

  /// Jump to a word's first empty square (or its first square).
  void selectWord(String id) {
    final target = _wordsById[id];
    if (target == null) return;
    direction = target.direction;
    cursor = _firstEmptyOr(target);
    revision++;
  }

  void nextWord() => _stepWord(1);

  void previousWord() => _stepWord(-1);

  void _stepWord(int step) {
    if (words.isEmpty) return;
    final current = activeWord;
    final at = current == null ? -1 : words.indexOf(current);
    final next = words[(at + step + words.length) % words.length];
    selectWord(next.id);
  }

  int _firstEmptyOr(GridWord w) =>
      w.cells.firstWhere((i) => _letters[i] == '', orElse: () => w.cells.first);

  // ---------- Editing ----------

  /// Fills the cursor square and moves to the next square of the word.
  /// Revealed squares are locked; the cursor just moves past them.
  void type(String letter) {
    final ch = letter.toUpperCase();
    if (!_isLetter(ch) || cells.isEmpty || cells[cursor].isBlock) return;
    if (!_revealed.contains(cursor)) {
      _letters[cursor] = ch;
      _checked.remove(cursor);
    }
    final w = activeWord;
    if (w != null) {
      final at = w.cells.indexOf(cursor);
      if (at < w.cells.length - 1) cursor = w.cells[at + 1];
    }
    revision++;
  }

  /// Clears the cursor square, or moves back and clears when it's empty.
  void backspace() {
    if (cells.isEmpty || cells[cursor].isBlock) return;
    if (_letters[cursor] != '' && !_revealed.contains(cursor)) {
      _clear(cursor);
    } else {
      final w = activeWord;
      final at = w?.cells.indexOf(cursor) ?? 0;
      if (w != null && at > 0) {
        cursor = w.cells[at - 1];
        if (!_revealed.contains(cursor)) _clear(cursor);
      }
    }
    revision++;
  }

  void _clear(int index) {
    _letters[index] = '';
    _checked.remove(index);
  }

  /// Marks every filled, non-revealed square right or wrong.
  CheckSummary check() {
    _checked.clear();
    var correct = 0;
    var wrong = 0;
    for (final c in cells) {
      if (c.isBlock || _letters[c.index] == '' || _revealed.contains(c.index)) {
        continue;
      }
      final ok = _letters[c.index] == c.solution;
      _checked[c.index] = ok;
      ok ? correct++ : wrong++;
    }
    revision++;
    return CheckSummary(correct: correct, wrong: wrong);
  }

  /// Fills the cursor square with its answer. False if already revealed.
  bool revealLetter() {
    if (cells.isEmpty || cells[cursor].isBlock || _revealed.contains(cursor)) {
      return false;
    }
    _reveal(cursor);
    revision++;
    return true;
  }

  /// Fills the whole active word. False if it was already revealed.
  bool revealWord() {
    final w = activeWord;
    if (w == null || w.cells.every(_revealed.contains)) return false;
    w.cells.forEach(_reveal);
    _revealedWords.add(w.id);
    revision++;
    return true;
  }

  void _reveal(int index) {
    _letters[index] = cells[index].solution;
    _revealed.add(index);
    _checked.remove(index);
  }
}
