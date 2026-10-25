import 'package:equatable/equatable.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/puzzle.dart';
import 'package:wordshool/shared/domains/entities/localized_text.dart';

/// Today's puzzle pointer (`crosswordDaily/{YYYY-MM-DD}`, IST).
class CrosswordDailyEntity extends Equatable {
  const CrosswordDailyEntity({
    required this.dateId,
    required this.puzzleId,
    required this.categoryId,
    required this.title,
    required this.difficulty,
    required this.wordCount,
    required this.xpReward,
    required this.estimatedMinutes,
  });

  final String dateId;
  final String puzzleId;
  final String categoryId;
  final LocalizedText title;
  final CrosswordDifficulty difficulty;
  final int wordCount;
  final int xpReward;
  final int estimatedMinutes;

  @override
  List<Object?> get props => [
        dateId,
        puzzleId,
        categoryId,
        title,
        difficulty,
        wordCount,
        xpReward,
        estimatedMinutes,
      ];
}
