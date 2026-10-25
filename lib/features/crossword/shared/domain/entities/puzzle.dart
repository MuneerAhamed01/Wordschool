import 'package:equatable/equatable.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/word.dart';
import 'package:wordshool/shared/domains/entities/localized_text.dart';

enum CrosswordDifficulty {
  easy('easy', 'Easy'),
  medium('medium', 'Medium'),
  hard('hard', 'Hard');

  const CrosswordDifficulty(this.wire, this.label);

  final String wire;
  final String label;

  static CrosswordDifficulty fromWire(Object? value) => values.firstWhere(
        (d) => d.wire == value,
        orElse: () => medium,
      );
}

/// A published puzzle (`crosswordPuzzles/{id}`).
class CrosswordPuzzleEntity extends Equatable {
  const CrosswordPuzzleEntity({
    required this.id,
    required this.categoryId,
    required this.number,
    required this.title,
    required this.difficulty,
    required this.rows,
    required this.cols,
    required this.layout,
    required this.words,
    required this.xpReward,
    required this.estimatedMinutes,
    this.publishedAt,
  });

  final String id;
  final String categoryId;
  final int number;
  final LocalizedText title;
  final CrosswordDifficulty difficulty;
  final int rows;
  final int cols;

  /// `rows × cols` chars row by row: `.` letter, `#` block.
  final String layout;
  final List<CrosswordWordEntity> words;
  final int xpReward;
  final int estimatedMinutes;
  final DateTime? publishedAt;

  int get wordCount => words.length;

  /// Letter squares in the grid.
  int get letterCount => '.'.allMatches(layout).length;

  @override
  List<Object?> get props => [
        id,
        categoryId,
        number,
        title,
        difficulty,
        rows,
        cols,
        layout,
        words,
        xpReward,
        estimatedMinutes,
        publishedAt,
      ];
}
