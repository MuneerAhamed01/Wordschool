import 'package:wordshool/core/firebase/dt_converter.dart';
import 'package:wordshool/features/story_mode/data/models/detective_clue.dart';
import 'package:wordshool/features/story_mode/domain/entities/detective_case.dart';
import 'package:wordshool/features/story_mode/domain/entities/story_mode_validators.dart';

class DetectiveCaseModel extends DetectiveCaseEntity {
  const DetectiveCaseModel({
    required super.id,
    required super.title,
    required super.introduction,
    required super.clues,
    required super.resolution,
    required super.createdAt,
  });

  factory DetectiveCaseModel.fromJson(
    Map<String, dynamic> json, {
    String? documentId,
  }) {
    final model = DetectiveCaseModel(
      id: json['id'] as String? ?? documentId ?? '',
      title: json['title'] as String,
      introduction: json['introduction'] as String,
      clues: (json['clues'] as List<dynamic>)
          .map((clue) =>
              DetectiveClueModel.fromJson(clue as Map<String, dynamic>))
          .toList(),
      resolution: json['resolution'] as String,
      createdAt: FirebaseDTConverter.fromTimestamp(json['createdAt']),
    );
    StoryModeValidators.validateCase(model);
    return model;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'introduction': introduction,
      'clues': clues
          .map((clue) => (clue as DetectiveClueModel).toJson())
          .toList(),
      'resolution': resolution,
      'createdAt': FirebaseDTConverter.toTimestamp(createdAt),
    };
  }
}
