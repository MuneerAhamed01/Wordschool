import 'package:wordshool/core/resorces/data_state.dart';

/// Revealed squares and words per puzzle, kept on the device (the rules
/// don't allow them on the progress doc).
abstract class RevealsDataSource {
  Future<DataState<({List<int> cells, List<String> wordIds})>> getReveals(
      String puzzleId);

  Future<DataState<void>> saveReveals(
    String puzzleId, {
    required List<int> cells,
    required List<String> wordIds,
  });

  Future<DataState<void>> clearReveals(String puzzleId);
}
