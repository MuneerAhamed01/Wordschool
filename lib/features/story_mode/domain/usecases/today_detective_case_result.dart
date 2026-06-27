import 'package:wordshool/features/story_mode/domain/entities/detective_case.dart';
import 'package:wordshool/features/story_mode/domain/entities/story_mode_progress.dart';

class TodayDetectiveCaseResult {
  const TodayDetectiveCaseResult({
    required this.detectiveCase,
    this.progress,
  });

  final DetectiveCaseEntity detectiveCase;
  final StoryModeProgressEntity? progress;
}
