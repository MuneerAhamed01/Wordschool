import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:wordshool/features/crossword/shared/data/data_source/progress_service.dart';
import 'package:wordshool/features/crossword/shared/data/data_source/remote/progress_service.dart';
import 'package:wordshool/features/crossword/shared/data/repositories/changes_repository_impl.dart';
import 'package:wordshool/features/crossword/shared/data/repositories/progress_repository_impl.dart';
import 'package:wordshool/features/crossword/shared/domain/repositories/changes_repository.dart';
import 'package:wordshool/features/crossword/shared/domain/repositories/progress_repository.dart';
import 'package:wordshool/features/crossword/shared/domain/usecases/watch_changes.dart';

/// What two or more crossword modules use: the progress cache and the
/// change signal. Register before the modules.
void initCrosswordShared(GetIt getIt) {
  getIt
    ..registerSingleton<ProgressDataSource>(ProgressDataSourceImpl(
      firestore: getIt<FirebaseFirestore>(),
      auth: getIt<FirebaseAuth>(),
    ))
    ..registerSingleton<CrosswordProgressRepository>(
        CrosswordProgressRepositoryImpl(source: getIt<ProgressDataSource>()))
    ..registerSingleton<CrosswordChangesRepository>(
        CrosswordChangesRepositoryImpl())
    ..registerSingleton(WatchCrosswordChangesUseCase(
        repository: getIt<CrosswordChangesRepository>()));
}
