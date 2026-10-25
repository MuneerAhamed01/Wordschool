import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wordshool/core/remote_config/app_remote_config.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/crossword/category/domain/repositories/category_repository.dart';
import 'package:wordshool/features/crossword/category/domain/usecases/count_completed.dart';
import 'package:wordshool/features/crossword/category/domain/usecases/load_category.dart';
import 'package:wordshool/features/crossword/category/domain/usecases/load_category_puzzles.dart';
import 'package:wordshool/features/crossword/category/domain/usecases/load_puzzle_marks.dart';
import 'package:wordshool/features/crossword/home/domain/entities/home.dart';
import 'package:wordshool/features/crossword/home/domain/repositories/home_repository.dart';
import 'package:wordshool/features/crossword/home/domain/usecases/count_revision_items.dart';
import 'package:wordshool/features/crossword/home/domain/usecases/load_home.dart';
import 'package:wordshool/features/crossword/home/domain/usecases/load_home_progress.dart';
import 'package:wordshool/features/crossword/leaderboard/domain/entities/leaderboard.dart';
import 'package:wordshool/features/crossword/leaderboard/domain/repositories/leaderboard_repository.dart';
import 'package:wordshool/features/crossword/leaderboard/domain/usecases/load_leaderboard.dart';
import 'package:wordshool/features/crossword/puzzle/domain/entities/session.dart';
import 'package:wordshool/features/crossword/puzzle/domain/repositories/puzzle_repository.dart';
import 'package:wordshool/features/crossword/puzzle/domain/usecases/load_puzzle.dart';
import 'package:wordshool/features/crossword/puzzle/domain/usecases/save_progress.dart';
import 'package:wordshool/features/crossword/puzzle/domain/usecases/submit_puzzle.dart';
import 'package:wordshool/features/crossword/puzzle/presentation/bloc/puzzle_bloc.dart';
import 'package:wordshool/features/crossword/puzzle/report/domain/entities/content_report.dart';
import 'package:wordshool/features/crossword/puzzle/report/domain/repositories/report_repository.dart';
import 'package:wordshool/features/crossword/puzzle/report/domain/usecases/report_content.dart';
import 'package:wordshool/features/crossword/revise/domain/entities/revision_item.dart';
import 'package:wordshool/features/crossword/revise/domain/repositories/revise_repository.dart';
import 'package:wordshool/features/crossword/revise/domain/usecases/load_revision_items.dart';
import 'package:wordshool/features/crossword/revise/domain/usecases/set_revision_mastered.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/category.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/change.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/progress.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/puzzle.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/result.dart';
import 'package:wordshool/features/crossword/shared/domain/repositories/changes_repository.dart';
import 'package:wordshool/features/crossword/shared/domain/usecases/watch_changes.dart';
import 'package:wordshool/shared/data/data_source/session_handler.dart';
import 'package:wordshool/shared/domains/entities/paged.dart';

import 'crossword_fixtures.dart';

DataError<T> dataError<T>([String message = 'Network down']) => DataError<T>(
    error: AppError(error: message, code: 'unavailable', message: message));

/// In-memory stand-in for every crossword module's repository; set the
/// fields to shape answers and read the recorded calls in asserts.
class FakeCrosswordRepository
    implements
        HomeRepository,
        CategoryRepository,
        PuzzleRepository,
        ReportRepository,
        ReviseRepository,
        LeaderboardRepository,
        CrosswordChangesRepository {
  FakeCrosswordRepository({CrosswordPuzzleEntity? puzzle})
      : puzzle = puzzle ?? examplePuzzle();

  // ---------- Home ----------
  DataState<CrosswordHomeEntity>? home;
  HomeProgressEntity homeProgress = const HomeProgressEntity();
  int revisionCount = 0;
  int homeLoads = 0;
  int homeProgressLoads = 0;
  int revisionCounts = 0;

  // ---------- Category ----------
  CrosswordCategoryEntity? category;
  List<Paged<CrosswordPuzzleEntity>> puzzlePages = [];
  Map<String, CrosswordProgressEntity> marks = {};
  int completedCount = 0;
  final pageRequests = <int?>[];
  final markRequests = <List<String>>[];

  // ---------- Puzzle ----------
  CrosswordPuzzleEntity puzzle;
  CrosswordProgressEntity? progress;
  bool failLoad = false;
  bool failSubmit = false;
  bool failSave = false;

  /// When set, saves wait for it (to test a save that is still writing).
  Completer<void>? saveGate;

  /// When set, submits wait for it (to test a submit still in flight).
  Completer<void>? submitGate;
  final saves = <({CrosswordProgressEntity progress, bool create})>[];
  final submits =
      <({CrosswordProgressEntity progress, List<String> revealed})>[];
  CrosswordSubmitOutcome outcome = const CrosswordSubmitOutcome(
    result: CrosswordResultEntity(
      score: 71,
      correctWords: 5,
      totalWords: 7,
      xpEarned: 21,
      timeSec: 312,
      wrongWordIds: ['2D', '3D'],
      revealedWordIds: ['3D'],
    ),
    xp: 1285,
    currentStreak: 4,
  );

  // ---------- Report ----------
  final reports = <ContentReportEntity>[];

  // ---------- Revise ----------
  List<Paged<RevisionItemEntity>> revisionPages = [];
  bool failMastered = false;
  final mastered = <String>[];

  /// Question id of the `after` cursor per request (null = first page).
  final revisionRequests = <String?>[];

  // ---------- Leaderboard ----------
  LeaderboardEntity? leaderboard;
  final boardRequests = <String>[];

  // ---------- Changes ----------
  final changesController = StreamController<CrosswordChange>.broadcast();

  @override
  Stream<CrosswordChange> get changes => changesController.stream;

  @override
  void notify(CrosswordChange change) => changesController.add(change);

  @override
  Future<DataState<CrosswordHomeEntity>> loadHome(
      {required String todayId}) async {
    homeLoads++;
    return home ?? DataSuccess(data: CrosswordHomeEntity(todayId: todayId));
  }

  @override
  Future<DataState<HomeProgressEntity>> loadHomeProgress({
    String? dailyPuzzleId,
    required List<String> categoryIds,
  }) async {
    homeProgressLoads++;
    return DataSuccess(data: homeProgress);
  }

  @override
  Future<DataState<int>> countRevisionItems() async {
    revisionCounts++;
    return DataSuccess(data: revisionCount);
  }

  @override
  Future<DataState<CrosswordCategoryEntity>> getCategory(
          String categoryId) async =>
      category == null ? dataError() : DataSuccess(data: category);

  @override
  Future<DataState<Paged<CrosswordPuzzleEntity>>> getCategoryPuzzles({
    required String categoryId,
    int? afterNumber,
  }) async {
    pageRequests.add(afterNumber);
    if (puzzlePages.isEmpty) return dataError();
    return DataSuccess(data: puzzlePages.removeAt(0));
  }

  @override
  Future<DataState<Map<String, CrosswordProgressEntity>>> getPuzzleMarks(
      List<String> puzzleIds) async {
    markRequests.add(puzzleIds);
    return DataSuccess(data: {
      for (final id in puzzleIds)
        if (marks[id] != null) id: marks[id]!,
    });
  }

  @override
  Future<DataState<int>> countCompleted(String categoryId) async =>
      DataSuccess(data: completedCount);

  @override
  Future<DataState<PuzzleSessionEntity>> loadPuzzle(String puzzleId) async {
    if (failLoad) return dataError("This puzzle isn't available.");
    return DataSuccess(
        data: PuzzleSessionEntity(puzzle: puzzle, progress: progress));
  }

  @override
  Future<DataState<void>> saveProgress({
    required CrosswordProgressEntity progress,
    required bool create,
    required List<int> revealedCells,
    required List<String> revealedWordIds,
  }) async {
    await saveGate?.future;
    if (failSave) return dataError();
    saves.add((progress: progress, create: create));
    return DataSuccess(data: null);
  }

  @override
  Future<DataState<CrosswordSubmitOutcome>> submit({
    required CrosswordProgressEntity progress,
    required List<String> revealedWordIds,
  }) async {
    submits.add((progress: progress, revealed: revealedWordIds));
    await submitGate?.future;
    if (failSubmit) {
      return dataError('Too many tries. Wait a little and try again.');
    }
    return DataSuccess(data: outcome);
  }

  @override
  Future<DataState<void>> reportContent(ContentReportEntity report) async {
    reports.add(report);
    return DataSuccess(data: null);
  }

  @override
  Future<DataState<Paged<RevisionItemEntity>>> getRevisionItems(
      {RevisionItemEntity? after}) async {
    revisionRequests.add(after?.questionId);
    if (revisionPages.isEmpty) return dataError();
    return DataSuccess(data: revisionPages.removeAt(0));
  }

  @override
  Future<DataState<void>> setRevisionMastered({
    required String questionId,
    required bool mastered,
  }) async {
    if (failMastered) return dataError();
    this.mastered.add(questionId);
    return DataSuccess(data: null);
  }

  @override
  Future<DataState<LeaderboardEntity>> getLeaderboard(String boardId) async {
    boardRequests.add(boardId);
    return leaderboard == null ? dataError() : DataSuccess(data: leaderboard);
  }
}

class FakeConfig implements AppRemoteConfig {
  FakeConfig({this.reveals = 3, this.autosaveSeconds = 30});

  final int reveals;
  final int autosaveSeconds;

  @override
  HintPenalties get crosswordHintPenalties => HintPenalties.fallback;

  @override
  int get crosswordRevealsPerPuzzle => reveals;

  @override
  XpLevelFormula get xpLevelFormula => XpLevelFormula.fallback;

  @override
  Duration get crosswordAutosaveInterval => Duration(seconds: autosaveSeconds);

  @override
  int get minSupportedBuild => 0;

  @override
  Future<void> initialize() async {}
}

/// Real use cases over [repo].
class FakeUseCases {
  FakeUseCases(this.repo);

  final FakeCrosswordRepository repo;

  LoadCrosswordHomeUseCase get loadHome =>
      LoadCrosswordHomeUseCase(repository: repo);
  LoadHomeProgressUseCase get loadHomeProgress =>
      LoadHomeProgressUseCase(repository: repo);
  CountRevisionItemsUseCase get countRevision =>
      CountRevisionItemsUseCase(repository: repo);
  LoadCrosswordCategoryUseCase get loadCategory =>
      LoadCrosswordCategoryUseCase(repository: repo);
  LoadCategoryPuzzlesUseCase get loadPuzzles =>
      LoadCategoryPuzzlesUseCase(repository: repo);
  LoadPuzzleMarksUseCase get loadMarks =>
      LoadPuzzleMarksUseCase(repository: repo);
  CountCompletedUseCase get countCompleted =>
      CountCompletedUseCase(repository: repo);
  LoadPuzzleUseCase get loadPuzzle => LoadPuzzleUseCase(repository: repo);
  SaveCrosswordProgressUseCase get saveProgress =>
      SaveCrosswordProgressUseCase(repository: repo);
  SubmitCrosswordUseCase get submit => SubmitCrosswordUseCase(repository: repo);
  ReportContentUseCase get report => ReportContentUseCase(repository: repo);
  LoadRevisionItemsUseCase get loadRevision =>
      LoadRevisionItemsUseCase(repository: repo);
  SetRevisionMasteredUseCase get setMastered =>
      SetRevisionMasteredUseCase(repository: repo);
  LoadLeaderboardUseCase get loadLeaderboard =>
      LoadLeaderboardUseCase(repository: repo);

  PuzzleBloc puzzleBloc({FakeConfig? config}) => PuzzleBloc(
        loadPuzzle: loadPuzzle,
        saveProgress: saveProgress,
        submit: submit,
        report: report,
        config: config ?? FakeConfig(),
        startTicker: false,
      );
}

/// Lets queued bloc events run.
Future<void> settle() => Future<void>.delayed(Duration.zero);

/// Registers what the app router's crossword tabs take from `getIt`, backed
/// by [repo]. Call `getIt.reset()` in tearDown.
Future<void> registerCrosswordFakes(
    GetIt getIt, FakeCrosswordRepository repo) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final uc = FakeUseCases(repo);
  getIt
    ..registerSingleton<SessionHandler>(SessionHandler(prefs))
    ..registerSingleton(uc.loadHome)
    ..registerSingleton(uc.loadHomeProgress)
    ..registerSingleton(uc.countRevision)
    ..registerSingleton(uc.loadRevision)
    ..registerSingleton(uc.setMastered)
    ..registerSingleton(uc.loadLeaderboard)
    ..registerSingleton(WatchCrosswordChangesUseCase(repository: repo));
}
