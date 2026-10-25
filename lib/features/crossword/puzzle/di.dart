import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wordshool/features/crossword/puzzle/data/data_source/local/reveals_service.dart';
import 'package:wordshool/features/crossword/puzzle/data/data_source/puzzle_service.dart';
import 'package:wordshool/features/crossword/puzzle/data/data_source/remote/puzzle_service.dart';
import 'package:wordshool/features/crossword/puzzle/data/data_source/reveals_service.dart';
import 'package:wordshool/features/crossword/puzzle/data/repositories/puzzle_repository_impl.dart';
import 'package:wordshool/features/crossword/puzzle/domain/repositories/puzzle_repository.dart';
import 'package:wordshool/features/crossword/puzzle/domain/usecases/load_puzzle.dart';
import 'package:wordshool/features/crossword/puzzle/domain/usecases/save_progress.dart';
import 'package:wordshool/features/crossword/puzzle/domain/usecases/submit_puzzle.dart';
import 'package:wordshool/features/crossword/puzzle/report/data/data_source/remote/report_service.dart';
import 'package:wordshool/features/crossword/puzzle/report/data/data_source/report_service.dart';
import 'package:wordshool/features/crossword/puzzle/report/data/repositories/report_repository_impl.dart';
import 'package:wordshool/features/crossword/puzzle/report/domain/repositories/report_repository.dart';
import 'package:wordshool/features/crossword/puzzle/report/domain/usecases/report_content.dart';
import 'package:wordshool/features/crossword/shared/domain/repositories/changes_repository.dart';
import 'package:wordshool/features/crossword/shared/domain/repositories/progress_repository.dart';

void initCrosswordPuzzle(GetIt getIt) {
  getIt
    ..registerSingleton<PuzzleDataSource>(PuzzleDataSourceImpl(
      firestore: getIt<FirebaseFirestore>(),
      functions: getIt<FirebaseFunctions>(),
    ))
    ..registerSingleton<RevealsDataSource>(
        RevealsDataSourceImpl(prefs: getIt<SharedPreferences>()))
    ..registerSingleton<PuzzleRepository>(PuzzleRepositoryImpl(
      source: getIt<PuzzleDataSource>(),
      reveals: getIt<RevealsDataSource>(),
      progress: getIt<CrosswordProgressRepository>(),
      changes: getIt<CrosswordChangesRepository>(),
    ));
  final repository = getIt<PuzzleRepository>();
  getIt
    ..registerSingleton(LoadPuzzleUseCase(repository: repository))
    ..registerSingleton(SaveCrosswordProgressUseCase(repository: repository))
    ..registerSingleton(SubmitCrosswordUseCase(repository: repository));
  _initReport(getIt);
}

void _initReport(GetIt getIt) {
  getIt
    ..registerSingleton<ReportDataSource>(ReportDataSourceImpl(
      firestore: getIt<FirebaseFirestore>(),
      auth: getIt<FirebaseAuth>(),
    ))
    ..registerSingleton<ReportRepository>(
        ReportRepositoryImpl(source: getIt<ReportDataSource>()))
    ..registerSingleton(
        ReportContentUseCase(repository: getIt<ReportRepository>()));
}
