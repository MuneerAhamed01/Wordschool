import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/crossword/home/data/models/daily.dart';
import 'package:wordshool/features/crossword/home/data/models/player_profile.dart';
import 'package:wordshool/features/crossword/shared/data/models/category.dart';

/// What Home reads besides progress: daily pointer, categories, profile and
/// the "My mistakes" count.
abstract class HomeDataSource {
  /// Null data when no puzzle is scheduled for [dateId].
  Future<DataState<CrosswordDailyModel?>> getDaily(String dateId);

  /// `isActive == true`, sorted by `order`.
  Future<DataState<List<CrosswordCategoryModel>>> getCategories();

  /// Null data before the player has a `users/{uid}` doc.
  Future<DataState<PlayerProfileModel?>> getProfile();

  /// Unlearned revision items (one aggregation read).
  Future<DataState<int>> countRevisionItems();
}
