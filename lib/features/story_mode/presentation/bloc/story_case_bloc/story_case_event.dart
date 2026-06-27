part of 'story_case_bloc.dart';

@freezed
class StoryCaseEvent with _$StoryCaseEvent {
  const factory StoryCaseEvent.loadTodayCase() = LoadTodayCase;
  const factory StoryCaseEvent.retry() = Retry;
  const factory StoryCaseEvent.progressUpdated(
    StoryModeProgressEntity progress,
  ) = ProgressUpdated;
}
