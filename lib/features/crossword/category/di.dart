import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:wordshool/features/crossword/category/data/data_source/category_service.dart';
import 'package:wordshool/features/crossword/category/data/data_source/remote/category_service.dart';
import 'package:wordshool/features/crossword/category/data/repositories/category_repository_impl.dart';
import 'package:wordshool/features/crossword/category/domain/repositories/category_repository.dart';
import 'package:wordshool/features/crossword/category/domain/usecases/count_completed.dart';
import 'package:wordshool/features/crossword/category/domain/usecases/load_category.dart';
import 'package:wordshool/features/crossword/category/domain/usecases/load_category_puzzles.dart';
import 'package:wordshool/features/crossword/category/domain/usecases/load_puzzle_marks.dart';
import 'package:wordshool/features/crossword/shared/domain/repositories/progress_repository.dart';

void initCrosswordCategory(GetIt getIt) {
  getIt
    ..registerSingleton<CategoryDataSource>(
        CategoryDataSourceImpl(firestore: getIt<FirebaseFirestore>()))
    ..registerSingleton<CategoryRepository>(CategoryRepositoryImpl(
      source: getIt<CategoryDataSource>(),
      progress: getIt<CrosswordProgressRepository>(),
    ));
  final repository = getIt<CategoryRepository>();
  getIt
    ..registerSingleton(LoadCrosswordCategoryUseCase(repository: repository))
    ..registerSingleton(LoadCategoryPuzzlesUseCase(repository: repository))
    ..registerSingleton(LoadPuzzleMarksUseCase(repository: repository))
    ..registerSingleton(CountCompletedUseCase(repository: repository));
}
