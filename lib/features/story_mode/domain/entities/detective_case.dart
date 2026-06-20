import 'package:equatable/equatable.dart';
import 'package:wordshool/features/story_mode/domain/entities/detective_clue.dart';

class DetectiveCaseEntity extends Equatable {
  final String id;
  final String title;
  final String introduction;
  final List<DetectiveClueEntity> clues;
  final String resolution;
  final DateTime createdAt;

  const DetectiveCaseEntity({
    required this.id,
    required this.title,
    required this.introduction,
    required this.clues,
    required this.resolution,
    required this.createdAt,
  });

  @override
  List<Object?> get props =>
      [id, title, introduction, clues, resolution, createdAt];
}
