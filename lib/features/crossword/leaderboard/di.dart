import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:wordshool/features/crossword/leaderboard/data/data_source/leaderboard_service.dart';
import 'package:wordshool/features/crossword/leaderboard/data/data_source/remote/leaderboard_service.dart';
import 'package:wordshool/features/crossword/leaderboard/data/repositories/leaderboard_repository_impl.dart';
import 'package:wordshool/features/crossword/leaderboard/domain/repositories/leaderboard_repository.dart';
import 'package:wordshool/features/crossword/leaderboard/domain/usecases/load_leaderboard.dart';

void initCrosswordLeaderboard(GetIt getIt) {
  getIt
    ..registerSingleton<LeaderboardDataSource>(LeaderboardDataSourceImpl(
      firestore: getIt<FirebaseFirestore>(),
      auth: getIt<FirebaseAuth>(),
    ))
    ..registerSingleton<LeaderboardRepository>(
        LeaderboardRepositoryImpl(source: getIt<LeaderboardDataSource>()))
    ..registerSingleton(
        LoadLeaderboardUseCase(repository: getIt<LeaderboardRepository>()));
}
