import 'package:equatable/equatable.dart';
import 'package:wordshool/features/admin/domain/models/json_read.dart';
import 'package:wordshool/shared/domains/entities/localized_text.dart';

/// `crosswordCategories/{id}`; the id is the slug, e.g. `kerala-history`.
class AdminCategory extends Equatable {
  const AdminCategory({
    required this.id,
    required this.name,
    this.description,
    required this.icon,
    required this.color,
    required this.order,
    required this.isActive,
    this.publishedPuzzleCount = 0,
    this.lastPuzzleNumber = 0,
  });

  final String id;
  final LocalizedText name;
  final LocalizedText? description;
  final String icon;

  /// `#RRGGBB`.
  final String color;
  final int order;
  final bool isActive;
  final int publishedPuzzleCount;
  final int lastPuzzleNumber;

  /// Question subjects are snake_case: `kerala-history` → `kerala_history`.
  String get subject => id.replaceAll('-', '_');

  factory AdminCategory.fromJson(Map<String, dynamic> json,
      {String? documentId}) {
    final description = json['description'];
    return AdminCategory(
      id: documentId ?? json['id'] as String? ?? '',
      name: LocalizedText.fromJson(json['name']),
      description:
          description == null ? null : LocalizedText.fromJson(description),
      icon: json['icon'] as String? ?? 'folder',
      color: json['color'] as String? ?? '#538D4E',
      order: readInt(json['order']),
      isActive: json['isActive'] as bool? ?? false,
      publishedPuzzleCount: readInt(json['publishedPuzzleCount']),
      lastPuzzleNumber: readInt(json['lastPuzzleNumber']),
    );
  }

  /// The `adminSaveCategory` payload (server-owned counters left out).
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name.toJson(),
        if (description != null && !description!.isEmpty)
          'description': description!.toJson(),
        'icon': icon,
        'color': color,
        'order': order,
        'isActive': isActive,
      };

  AdminCategory copyWith({int? order, bool? isActive}) => AdminCategory(
        id: id,
        name: name,
        description: description,
        icon: icon,
        color: color,
        order: order ?? this.order,
        isActive: isActive ?? this.isActive,
        publishedPuzzleCount: publishedPuzzleCount,
        lastPuzzleNumber: lastPuzzleNumber,
      );

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        icon,
        color,
        order,
        isActive,
        publishedPuzzleCount,
        lastPuzzleNumber,
      ];
}
