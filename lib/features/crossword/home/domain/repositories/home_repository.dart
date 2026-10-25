import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/crossword/home/domain/entities/home.dart';

/// Crossword Home for the signed-in player.
abstract class HomeRepository {
  /// Daily pointer for [todayId], active categories, profile, the
  /// "My mistakes" count and the player's marks, in parallel.
  Future<DataState<CrosswordHomeEntity>> loadHome({required String todayId});

  /// Today's progress and solved counts, from the session cache when known.
  Future<DataState<HomeProgressEntity>> loadHomeProgress({
    String? dailyPuzzleId,
    required List<String> categoryIds,
  });

  Future<DataState<int>> countRevisionItems();
}
