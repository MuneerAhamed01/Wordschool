import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:wordshool/features/admin/puzzles/domain/utils/puzzle_draft.dart';
import 'package:wordshool/features/admin/shared/domain/models/enums.dart';
import 'package:wordshool/features/admin/shared/domain/models/question.dart';
import 'package:wordshool/features/admin/shared/domain/utils/grid_validator.dart';

/// What "Auto-create puzzle" aims for.
class AutoPuzzleOptions extends Equatable {
  const AutoPuzzleOptions({
    int size = 9,
    int targetWords = 8,
    this.difficulty,
    this.preferUnused = true,
    this.seed = 0,
    this.attempts = 40,
  })  : size = size < minGridSize
            ? minGridSize
            : (size > maxGridSize ? maxGridSize : size),
        targetWords = targetWords < minWords
            ? minWords
            : (targetWords > maxWords ? maxWords : targetWords);

  /// Reads the `size`, `words` and `difficulty` query parameters of
  /// `/puzzles/new?auto=1`; anything missing or unreadable keeps its default.
  factory AutoPuzzleOptions.fromQuery(Map<String, String> query) =>
      AutoPuzzleOptions(
        size: int.tryParse(query['size'] ?? '') ?? 9,
        targetWords: int.tryParse(query['words'] ?? '') ?? 8,
        difficulty: Difficulty.tryValue(query['difficulty']),
      );

  static const minWords = 2;
  static const maxWords = 20;

  /// Square grid side (3–15) before it is fitted to the words.
  final int size;

  /// Stop after this many words (2–20).
  final int targetWords;

  /// Only questions of this difficulty; null = any.
  final Difficulty? difficulty;

  /// Questions in no puzzle yet go in first.
  final bool preferUnused;

  /// Same seed and questions → same grid. "Try another" adds 1.
  final int seed;

  /// Grids tried; the best one wins.
  final int attempts;

  AutoPuzzleOptions copyWith({
    int? size,
    int? targetWords,
    Difficulty? difficulty,
    bool clearDifficulty = false,
    bool? preferUnused,
    int? seed,
  }) =>
      AutoPuzzleOptions(
        size: size ?? this.size,
        targetWords: targetWords ?? this.targetWords,
        difficulty: clearDifficulty ? null : (difficulty ?? this.difficulty),
        preferUnused: preferUnused ?? this.preferUnused,
        seed: seed ?? this.seed,
        attempts: attempts,
      );

  @override
  List<Object?> get props =>
      [size, targetWords, difficulty, preferUnused, seed, attempts];
}

/// A generated grid, ready for the builder (not saved).
class AutoPuzzleResult extends Equatable {
  const AutoPuzzleResult({
    required this.draft,
    required this.used,
    required this.crossings,
    required this.notes,
  });

  final PuzzleDraft draft;

  /// The questions on the grid, in placement order.
  final List<AdminQuestion> used;

  /// Squares shared by an across and a down word.
  final int crossings;

  /// Things the admin may want to know (skipped questions, reused ones).
  final List<String> notes;

  @override
  List<Object?> get props => [draft, used, crossings, notes];
}

/// Most questions tried in one attempt, so a big category stays quick.
const _poolLimit = 60;

final _gridAnswer = RegExp(r'^[A-Z]{2,}$');

/// The questions [autoPuzzle] may use: checked, a 2+ letter A–Z answer that
/// fits a [AutoPuzzleOptions.size] grid, the wanted difficulty, one question
/// per answer. Unused questions first when [AutoPuzzleOptions.preferUnused].
List<AdminQuestion> autoPuzzleCandidates(
    List<AdminQuestion> questions, AutoPuzzleOptions options) {
  final seen = <String>{};
  final result = <AdminQuestion>[];
  for (final q in questions) {
    if (q.status != QuestionStatus.verified || q.id == null) continue;
    if (!_gridAnswer.hasMatch(q.answer) || q.answer.length > options.size) {
      continue;
    }
    if (options.difficulty != null && q.difficulty != options.difficulty) {
      continue;
    }
    if (!seen.add(q.answer)) continue;
    result.add(q);
  }
  if (options.preferUnused) {
    // Stable: unused ones keep their order, then the used ones.
    return [
      ...result.where((q) => q.usedInPuzzles.isEmpty),
      ...result.where((q) => q.usedInPuzzles.isNotEmpty),
    ];
  }
  return result;
}

/// Builds a connected crossword from [questions] with [PuzzleDraft]'s own
/// placement rules, trying [AutoPuzzleOptions.attempts] shuffles and keeping
/// the one with the most words, then crossings, then filled squares. Returns
/// null when no attempt gets 2 crossing words. Clues and facts are the
/// questions' own (see [placementFor]); nothing is saved.
AutoPuzzleResult? autoPuzzle(
    List<AdminQuestion> questions, AutoPuzzleOptions options) {
  final candidates = autoPuzzleCandidates(questions, options);
  if (candidates.length < 2) return null;

  _Attempt? best;
  for (var attempt = 0; attempt < options.attempts; attempt++) {
    final result = _build(candidates, options, Random(options.seed + attempt));
    if (result == null) continue;
    if (best == null || result.beats(best)) best = result;
  }
  if (best == null) return null;

  final notes = <String>[];
  final skipped = questions
      .where((q) =>
          q.status == QuestionStatus.verified &&
          _gridAnswer.hasMatch(q.answer) &&
          q.answer.length > options.size)
      .length;
  if (skipped > 0) {
    notes.add('$skipped checked answer${skipped == 1 ? ' is' : 's are'} '
        'longer than ${options.size} letters and were left out.');
  }
  final reused = best.used.where((q) => q.usedInPuzzles.isNotEmpty).length;
  if (reused > 0) {
    notes.add('$reused word${reused == 1 ? ' is' : 's are'} already in '
        'another puzzle.');
  }
  return AutoPuzzleResult(
    draft: best.draft,
    used: best.used,
    crossings: best.crossings,
    notes: notes,
  );
}

class _Attempt {
  _Attempt(this.draft, this.used)
      : crossings = _crossings(draft),
        density = draft.letters.length / (draft.rows * draft.cols);

  final PuzzleDraft draft;
  final List<AdminQuestion> used;
  final int crossings;
  final double density;

  bool beats(_Attempt other) {
    if (used.length != other.used.length) {
      return used.length > other.used.length;
    }
    if (crossings != other.crossings) return crossings > other.crossings;
    return density > other.density;
  }

  static int _crossings(PuzzleDraft draft) {
    final seen = <Cell>{};
    final shared = <Cell>{};
    for (final p in draft.placements) {
      for (final cell in p.cells) {
        if (!seen.add(cell)) shared.add(cell);
      }
    }
    return shared.length;
  }
}

/// One attempt: longest-ish word across the middle, then greedily the word
/// whose best spot crosses the most letters (ties: nearer the centre). With
/// [AutoPuzzleOptions.preferUnused], an unused question that fits always
/// goes before a used one.
_Attempt? _build(
    List<AdminQuestion> candidates, AutoPuzzleOptions options, Random random) {
  final pool = ([...candidates]..shuffle(random)).take(_poolLimit).toList();
  bool unused(AdminQuestion q) =>
      options.preferUnused && q.usedInPuzzles.isEmpty;
  // Unused first (if preferred), then mostly longest first, with up to 2
  // letters of jitter.
  final key = {
    for (final q in pool)
      q.id: (unused(q) ? 100 : 0) + q.answer.length + random.nextDouble() * 2
  };
  pool.sort((a, b) => key[b.id]!.compareTo(key[a.id]!));

  final size = options.size;
  final first = pool.removeAt(0);
  var draft = PuzzleDraft(rows: size, cols: size).add(placementFor(first,
      size ~/ 2, (size - first.answer.length) ~/ 2, WordDirection.across));
  final used = [first];

  while (used.length < options.targetWords && pool.isNotEmpty) {
    int? bestIndex;
    PlacementSpot? bestSpot;
    double bestDistance = 0;
    for (var i = 0; i < pool.length; i++) {
      final q = pool[i];
      final spots = draft.suggestions(q.answer, limit: 1);
      if (spots.isEmpty) continue;
      final spot = spots.first;
      final distance = _distance(spot, q.answer.length, size);
      final better = bestSpot == null ||
          (unused(q) != unused(pool[bestIndex!])
              ? unused(q)
              : spot.crossings != bestSpot.crossings
                  ? spot.crossings > bestSpot.crossings
                  : distance < bestDistance);
      if (better) {
        bestIndex = i;
        bestSpot = spot;
        bestDistance = distance;
      }
    }
    if (bestSpot == null) break;
    final q = pool.removeAt(bestIndex!);
    draft = draft.add(
        placementFor(q, bestSpot.row, bestSpot.col, bestSpot.direction));
    used.add(q);
  }

  if (used.length < 2) return null;
  final trimmed = draft.trimmed();
  if (trimmed.problems.isNotEmpty) return null;
  return _Attempt(trimmed, used);
}

/// How far the middle of a word at [spot] is from the grid centre.
double _distance(PlacementSpot spot, int length, int size) {
  final centre = (size - 1) / 2;
  final midRow = spot.row + spot.direction.dRow * (length - 1) / 2;
  final midCol = spot.col + spot.direction.dCol * (length - 1) / 2;
  return (midRow - centre).abs() + (midCol - centre).abs();
}
