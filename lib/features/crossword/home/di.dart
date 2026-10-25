import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:wordshool/features/crossword/home/data/data_source/home_service.dart';
import 'package:wordshool/features/crossword/home/data/data_source/remote/home_service.dart';
import 'package:wordshool/features/crossword/home/data/repositories/home_repository_impl.dart';
import 'package:wordshool/features/crossword/home/domain/repositories/home_repository.dart';
import 'package:wordshool/features/crossword/home/domain/usecases/count_revision_items.dart';
import 'package:wordshool/features/crossword/home/domain/usecases/load_home.dart';
import 'package:wordshool/features/crossword/home/domain/usecases/load_home_progress.dart';
import 'package:wordshool/features/crossword/shared/domain/repositories/progress_repository.dart';

void initCrosswordHome(GetIt getIt) {
  getIt
    ..registerSingleton<HomeDataSource>(HomeDataSourceImpl(
      firestore: getIt<FirebaseFirestore>(),
      auth: getIt<FirebaseAuth>(),
    ))
    ..registerSingleton<HomeRepository>(HomeRepositoryImpl(
      source: getIt<HomeDataSource>(),
      progress: getIt<CrosswordProgressRepository>(),
    ));
  final repository = getIt<HomeRepository>();
  getIt
    ..registerSingleton(LoadCrosswordHomeUseCase(repository: repository))
    ..registerSingleton(LoadHomeProgressUseCase(repository: repository))
    ..registerSingleton(CountRevisionItemsUseCase(repository: repository));
}
