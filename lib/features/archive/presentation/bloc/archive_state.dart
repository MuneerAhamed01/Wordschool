part of 'archive_bloc.dart';

@freezed
class ArchiveState with _$ArchiveState {
  const factory ArchiveState.initial() = _Initial;
  const factory ArchiveState.loading() = _Loading;
  const factory ArchiveState.loaded({
    required int year,
    required int month,
    required Map<String, UserGameDataEntity> gameHistoryByDate,
  }) = _Loaded;
  const factory ArchiveState.error(String message) = _Error;
}
