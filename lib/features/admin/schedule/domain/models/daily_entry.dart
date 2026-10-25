import 'package:equatable/equatable.dart';
import 'package:wordshool/features/admin/shared/domain/models/enums.dart';
import 'package:wordshool/core/utils/json_read.dart';
import 'package:wordshool/shared/domains/entities/localized_text.dart';

/// `crosswordDaily/{YYYY-MM-DD}` (IST) — the puzzle of the day.
class CrosswordDailyEntry extends Equatable {
  const CrosswordDailyEntry({
    required this.dateId,
    required this.puzzleId,
    required this.categoryId,
    required this.title,
    required this.difficulty,
    required this.wordCount,
  });

  final String dateId;
  final String puzzleId;
  final String categoryId;
  final LocalizedText title;
  final Difficulty difficulty;
  final int wordCount;

  factory CrosswordDailyEntry.fromJson(Map<String, dynamic> json,
      {required String documentId}) {
    return CrosswordDailyEntry(
      dateId: documentId,
      puzzleId: json['puzzleId'] as String? ?? '',
      categoryId: json['categoryId'] as String? ?? '',
      title: LocalizedText.fromJson(json['title']),
      difficulty: Difficulty.fromValue(json['difficulty']),
      wordCount: asInt(json['wordCount']),
    );
  }

  @override
  List<Object?> get props =>
      [dateId, puzzleId, categoryId, title, difficulty, wordCount];
}
