import 'package:wordshool/core/utils/json_read.dart';
import 'package:wordshool/features/crossword/home/domain/entities/daily.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/puzzle.dart';
import 'package:wordshool/shared/domains/entities/localized_text.dart';

class CrosswordDailyModel extends CrosswordDailyEntity {
  const CrosswordDailyModel({
    required super.dateId,
    required super.puzzleId,
    required super.categoryId,
    required super.title,
    required super.difficulty,
    required super.wordCount,
    required super.xpReward,
    required super.estimatedMinutes,
  });

  /// [documentId] is the IST date (`2026-10-22`).
  factory CrosswordDailyModel.fromJson(
    Map<String, dynamic> json, {
    String? documentId,
  }) {
    return CrosswordDailyModel(
      dateId: documentId ?? asString(json['dateId']),
      puzzleId: asString(json['puzzleId']),
      categoryId: asString(json['categoryId']),
      title: LocalizedText.fromJson(json['title']),
      difficulty: CrosswordDifficulty.fromWire(json['difficulty']),
      wordCount: asInt(json['wordCount']),
      xpReward: asInt(json['xpReward']),
      estimatedMinutes: asInt(json['estimatedMinutes']),
    );
  }

  Map<String, dynamic> toJson() => {
        'puzzleId': puzzleId,
        'categoryId': categoryId,
        'title': title.toJson(),
        'difficulty': difficulty.wire,
        'wordCount': wordCount,
        'xpReward': xpReward,
        'estimatedMinutes': estimatedMinutes,
      };
}
