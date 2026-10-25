import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/crossword/home/data/data_source/home_service.dart';
import 'package:wordshool/features/crossword/home/domain/entities/home.dart';
import 'package:wordshool/features/crossword/home/domain/repositories/home_repository.dart';
import 'package:wordshool/features/crossword/shared/domain/repositories/progress_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl({
    required HomeDataSource source,
    required CrosswordProgressRepository progress,
  })  : _source = source,
        _progress = progress;

  final HomeDataSource _source;
  final CrosswordProgressRepository _progress;

  @override
  Future<DataState<CrosswordHomeEntity>> loadHome({
    required String todayId,
  }) async {
    final daily = _source.getDaily(todayId);
    final categories = _source.getCategories();
    final profile = _source.getProfile();
    final revisionCount = _source.countRevisionItems();

    final categoriesResult = await categories;
    if (categoriesResult is DataError) {
      return DataError(error: categoriesResult.error);
    }
    final dailyData = (await daily).data;
    final list = categoriesResult.data ?? const [];
    final progress = await loadHomeProgress(
      dailyPuzzleId: dailyData?.puzzleId,
      categoryIds: [for (final c in list) c.id],
    );
    // The rest degrade gracefully: Home still shows categories.
    return DataSuccess(
      data: CrosswordHomeEntity(
        todayId: todayId,
        daily: dailyData,
        categories: list,
        progress: progress.data ?? const HomeProgressEntity(),
        profile: (await profile).data,
        revisionCount: (await revisionCount).data ?? 0,
      ),
    );
  }

  @override
  Future<DataState<HomeProgressEntity>> loadHomeProgress({
    String? dailyPuzzleId,
    required List<String> categoryIds,
  }) async {
    final daily =
        dailyPuzzleId == null ? null : _progress.getProgress(dailyPuzzleId);
    final counts = {
      for (final id in categoryIds) id: _progress.countCompleted(id),
    };
    final completed = <String, int>{};
    for (final entry in counts.entries) {
      final count = (await entry.value).data;
      if (count != null) completed[entry.key] = count;
    }
    return DataSuccess(
      data: HomeProgressEntity(
        dailyProgress: daily == null ? null : (await daily).data,
        completedByCategory: completed,
      ),
    );
  }

  @override
  Future<DataState<int>> countRevisionItems() => _source.countRevisionItems();
}
