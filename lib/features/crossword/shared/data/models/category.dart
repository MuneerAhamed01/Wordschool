import 'package:wordshool/core/utils/json_read.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/category.dart';
import 'package:wordshool/shared/domains/entities/localized_text.dart';

class CrosswordCategoryModel extends CrosswordCategoryEntity {
  const CrosswordCategoryModel({
    required super.id,
    required super.name,
    super.description,
    required super.icon,
    required super.color,
    required super.order,
    required super.publishedPuzzleCount,
  });

  factory CrosswordCategoryModel.fromJson(
    Map<String, dynamic> json, {
    String? documentId,
  }) {
    return CrosswordCategoryModel(
      id: documentId ?? asString(json['id']),
      name: LocalizedText.fromJson(json['name']),
      description: LocalizedText.fromJson(json['description']),
      icon: asString(json['icon']),
      color: asString(json['color'], '#6AAA64'),
      order: asInt(json['order']),
      publishedPuzzleCount: asInt(json['publishedPuzzleCount']),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name.toJson(),
        'description': description.toJson(),
        'icon': icon,
        'color': color,
        'order': order,
        'publishedPuzzleCount': publishedPuzzleCount,
      };
}
