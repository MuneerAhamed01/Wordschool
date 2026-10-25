import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:wordshool/features/crossword/revise/data/data_source/remote/revise_service.dart';
import 'package:wordshool/features/crossword/revise/data/data_source/revise_service.dart';
import 'package:wordshool/features/crossword/revise/data/repositories/revise_repository_impl.dart';
import 'package:wordshool/features/crossword/revise/domain/repositories/revise_repository.dart';
import 'package:wordshool/features/crossword/revise/domain/usecases/load_revision_items.dart';
import 'package:wordshool/features/crossword/revise/domain/usecases/set_revision_mastered.dart';
import 'package:wordshool/features/crossword/shared/domain/repositories/changes_repository.dart';

void initCrosswordRevise(GetIt getIt) {
  getIt
    ..registerSingleton<ReviseDataSource>(ReviseDataSourceImpl(
      firestore: getIt<FirebaseFirestore>(),
      auth: getIt<FirebaseAuth>(),
    ))
    ..registerSingleton<ReviseRepository>(ReviseRepositoryImpl(
      source: getIt<ReviseDataSource>(),
      changes: getIt<CrosswordChangesRepository>(),
    ));
  final repository = getIt<ReviseRepository>();
  getIt
    ..registerSingleton(LoadRevisionItemsUseCase(repository: repository))
    ..registerSingleton(SetRevisionMasteredUseCase(repository: repository));
}
