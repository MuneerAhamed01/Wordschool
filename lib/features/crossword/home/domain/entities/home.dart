import 'package:equatable/equatable.dart';
import 'package:wordshool/features/crossword/home/domain/entities/daily.dart';
import 'package:wordshool/features/crossword/home/domain/entities/player_profile.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/category.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/progress.dart';

/// The player's marks on Home: today's puzzle and solved counts.
class HomeProgressEntity extends Equatable {
  const HomeProgressEntity({
    this.dailyProgress,
    this.completedByCategory = const {},
  });

  /// Null when today's puzzle isn't started (or none is scheduled).
  final CrosswordProgressEntity? dailyProgress;
  final Map<String, int> completedByCategory;

  @override
  List<Object?> get props => [dailyProgress, completedByCategory];
}

/// Everything Crossword Home shows, from one load.
class CrosswordHomeEntity extends Equatable {
  const CrosswordHomeEntity({
    required this.todayId,
    this.daily,
    this.categories = const [],
    this.progress = const HomeProgressEntity(),
    this.profile,
    this.revisionCount = 0,
  });

  /// IST `YYYY-MM-DD`.
  final String todayId;

  /// Null when no puzzle is scheduled today.
  final CrosswordDailyEntity? daily;
  final List<CrosswordCategoryEntity> categories;
  final HomeProgressEntity progress;
  final PlayerProfileEntity? profile;

  /// Unlearned "My mistakes".
  final int revisionCount;

  CrosswordProgressEntity? get dailyProgress => progress.dailyProgress;

  /// Completed puzzles in [categoryId].
  int completedIn(String categoryId) =>
      progress.completedByCategory[categoryId] ?? 0;

  int get currentStreak => profile?.crossword.currentStreak ?? 0;

  CrosswordHomeEntity copyWith({
    HomeProgressEntity? progress,
    int? revisionCount,
  }) =>
      CrosswordHomeEntity(
        todayId: todayId,
        daily: daily,
        categories: categories,
        progress: progress ?? this.progress,
        profile: profile,
        revisionCount: revisionCount ?? this.revisionCount,
      );

  @override
  List<Object?> get props =>
      [todayId, daily, categories, progress, profile, revisionCount];
}
