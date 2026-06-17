part of 'archive_bloc.dart';

@freezed
class ArchiveEvent with _$ArchiveEvent {
  const factory ArchiveEvent.loadMonth({
    required int year,
    required int month,
  }) = LoadMonth;

  const factory ArchiveEvent.previousMonth() = PreviousMonth;
  const factory ArchiveEvent.nextMonth() = NextMonth;
}
