import 'package:equatable/equatable.dart';
import 'package:wordshool/shared/domains/entities/localized_text.dart';

/// A Home category (`crosswordCategories/{id}`, active only).
class CrosswordCategoryEntity extends Equatable {
  const CrosswordCategoryEntity({
    required this.id,
    required this.name,
    this.description = LocalizedText.empty,
    required this.icon,
    required this.color,
    required this.order,
    required this.publishedPuzzleCount,
  });

  final String id;
  final LocalizedText name;
  final LocalizedText description;

  /// Icon key, e.g. `landmark` (mapped to an icon in presentation).
  final String icon;

  /// `#6AAA64`.
  final String color;
  final int order;
  final int publishedPuzzleCount;

  @override
  List<Object?> get props =>
      [id, name, description, icon, color, order, publishedPuzzleCount];
}
