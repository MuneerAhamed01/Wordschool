import 'package:wordshool/core/firebase/dt_converter.dart';
import 'package:wordshool/core/utils/json_read.dart';
import 'package:wordshool/features/crossword/shared/data/models/word.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/puzzle.dart';
import 'package:wordshool/shared/domains/entities/localized_text.dart';

class CrosswordPuzzleModel extends CrosswordPuzzleEntity {
  const CrosswordPuzzleModel({
    required super.id,
    required super.categoryId,
    required super.number,
    required super.title,
    required super.difficulty,
    required super.rows,
    required super.cols,
    required super.layout,
    required super.words,
    required super.xpReward,
    required super.estimatedMinutes,
    super.publishedAt,
  });

  factory CrosswordPuzzleModel.fromJson(
    Map<String, dynamic> json, {
    String? documentId,
  }) {
    final words = json['words'] is List ? json['words'] as List : const [];
    return CrosswordPuzzleModel(
      id: documentId ?? asString(json['id']),
      categoryId: asString(json['categoryId']),
      number: asInt(json['number']),
      title: LocalizedText.fromJson(json['title']),
      difficulty: CrosswordDifficulty.fromWire(json['difficulty']),
      rows: asInt(json['rows']),
      cols: asInt(json['cols']),
      layout: asString(json['layout']),
      words: [
        for (final w in words.whereType<Map>())
          CrosswordWordModel.fromJson(Map<String, dynamic>.from(w)),
      ],
      xpReward: asInt(json['xpReward']),
      estimatedMinutes: asInt(json['estimatedMinutes']),
      publishedAt: FirebaseDTConverter.tryParse(json['publishedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'categoryId': categoryId,
        'number': number,
        'title': title.toJson(),
        'difficulty': difficulty.wire,
        'rows': rows,
        'cols': cols,
        'layout': layout,
        'words': [for (final w in words) (w as CrosswordWordModel).toJson()],
        'wordCount': wordCount,
        'xpReward': xpReward,
        'estimatedMinutes': estimatedMinutes,
      };
}
