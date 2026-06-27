part of 'story_case_bloc.dart';

@freezed
class StoryCaseState with _$StoryCaseState {
  const factory StoryCaseState.initial() = _Initial;
  const factory StoryCaseState.loading() = _Loading;
  const factory StoryCaseState.loaded({
    required DetectiveCaseEntity detectiveCase,
    StoryModeProgressEntity? progress,
  }) = _Loaded;
  const factory StoryCaseState.alreadyCompleted({
    required DetectiveCaseEntity detectiveCase,
    required StoryModeProgressEntity progress,
  }) = _AlreadyCompleted;
  const factory StoryCaseState.error(String message) = _Error;
}
