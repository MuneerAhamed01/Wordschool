import 'package:flutter_test/flutter_test.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/crossword/home/data/data_source/home_service.dart';
import 'package:wordshool/features/crossword/home/data/models/daily.dart';
import 'package:wordshool/features/crossword/home/data/models/player_profile.dart';
import 'package:wordshool/features/crossword/home/data/repositories/home_repository_impl.dart';
import 'package:wordshool/features/crossword/shared/data/models/category.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/progress.dart';
import 'package:wordshool/features/crossword/shared/domain/repositories/progress_repository.dart';

import '../../../crossword_fakes.dart';
import '../../../crossword_fixtures.dart';

class _Source implements HomeDataSource {
  bool failCategories = false;
  bool failDaily = false;

  @override
  Future<DataState<List<CrosswordCategoryModel>>> getCategories() async {
    if (failCategories) return dataError('offline');
    final (data, id) = fixtureDoc('category');
    return DataSuccess(
        data: [CrosswordCategoryModel.fromJson(data, documentId: id)]);
  }

  @override
  Future<DataState<CrosswordDailyModel?>> getDaily(String dateId) async {
    if (failDaily) return dataError();
    final (data, id) = fixtureDoc('daily');
    return DataSuccess(
        data: CrosswordDailyModel.fromJson(data, documentId: id));
  }

  @override
  Future<DataState<PlayerProfileModel?>> getProfile() async {
    final (data, id) = fixtureDoc('user');
    return DataSuccess(data: PlayerProfileModel.fromJson(data, documentId: id));
  }

  @override
  Future<DataState<int>> countRevisionItems() async => dataError();
}

class _Progress implements CrosswordProgressRepository {
  final asked = <String>[];

  @override
  Future<DataState<CrosswordProgressEntity?>> getProgress(String id) async {
    asked.add(id);
    return DataSuccess(
        data: CrosswordProgressEntity(puzzleId: id, letters: 'MU'));
  }

  @override
  Future<DataState<int>> countCompleted(String categoryId) async =>
      DataSuccess(data: 5);

  @override
  Future<DataState<Map<String, CrosswordProgressEntity>>> getProgressFor(
          List<String> ids) async =>
      DataSuccess(data: const {});

  @override
  Future<DataState<void>> saveProgress(CrosswordProgressEntity progress,
          {required bool create}) async =>
      DataSuccess(data: null);

  @override
  void markCompleted(CrosswordProgressEntity progress) {}
}

void main() {
  late _Source source;
  late _Progress progress;
  late HomeRepositoryImpl repo;

  setUp(() {
    source = _Source();
    progress = _Progress();
    repo = HomeRepositoryImpl(source: source, progress: progress);
  });

  test('home: one load reads only today and per-category counts', () async {
    final home = (await repo.loadHome(todayId: '2026-10-22')).data!;
    expect(home.categories.single.id, 'kerala-history');
    expect(home.dailyProgress!.puzzleId, 'kerala-history-0012');
    expect(progress.asked, ['kerala-history-0012']);
    expect(home.completedIn('kerala-history'), 5);
    expect(home.profile!.xp, 1285);
    expect(home.revisionCount, 0); // count failed → 0
  });

  test('failed extras degrade', () async {
    source.failDaily = true;
    final home = (await repo.loadHome(todayId: '2026-10-22')).data!;
    expect(home.daily, isNull);
    expect(home.dailyProgress, isNull);
    expect(progress.asked, isEmpty);
  });

  test('home fails only when categories fail', () async {
    source.failCategories = true;
    final result = await repo.loadHome(todayId: '2026-10-22');
    expect(result, isA<DataError>());
    expect(result.error!.message, 'offline');
  });
}
