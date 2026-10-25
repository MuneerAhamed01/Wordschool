import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/admin/shared/data/data_source/callable.dart';
import 'package:wordshool/features/admin/shared/domain/models/enums.dart';
import 'package:wordshool/features/admin/shared/domain/models/puzzle.dart';
import 'package:wordshool/features/admin/shared/domain/models/results.dart';
import 'package:wordshool/core/utils/json_read.dart';

/// Puzzle callables (puzzles, builder, detail, schedule, bulk upload).
class AdminPuzzlesService {
  AdminPuzzlesService(this._callable);

  final AdminCallable _callable;

  Future<DataState<PagedResult<AdminPuzzleSummary>>> listPuzzles({
    required String categoryId,
    PuzzleStatus? status,
    String? startAfterId,
    int limit = 20,
  }) async {
    final result = await _callable.call('adminListPuzzles', {
      'categoryId': categoryId,
      if (status != null) 'status': status.value,
      if (startAfterId != null) 'startAfterId': startAfterId,
      'limit': limit,
    });
    return AdminCallable.convert(
      result,
      (json) => PagedResult(
        items: asMapList(json['puzzles'])
            .map(AdminPuzzleSummary.fromJson)
            .toList(),
        nextStartAfterId: json['nextStartAfterId'] as String?,
      ),
    );
  }

  /// The puzzle with plain answers, for editing and preview.
  Future<DataState<AdminPuzzle>> getPuzzle(String puzzleId) async {
    final result =
        await _callable.call('adminGetPuzzle', {'puzzleId': puzzleId});
    return AdminCallable.convert(
        result, (json) => AdminPuzzle.fromJson(asMap(json['puzzle'])));
  }

  /// Creates (no id) or re-saves a draft / in-review puzzle; it becomes a draft.
  Future<DataState<SaveResult>> savePuzzle(AdminPuzzle puzzle) async {
    final result =
        await _callable.call('adminSaveCrosswordPuzzle', puzzle.toJson());
    return AdminCallable.convert(result, SaveResult.fromJson);
  }

  /// Moves a puzzle along draft → in_review → scheduled → published → archived.
  /// [publishAt] is required for `scheduled`.
  Future<DataState<void>> setPuzzleStatus({
    required String puzzleId,
    required PuzzleStatus status,
    DateTime? publishAt,
  }) async {
    final result = await _callable.call('adminSetPuzzleStatus', {
      'puzzleId': puzzleId,
      'status': status.value,
      if (publishAt != null) 'publishAt': publishAt.toUtc().toIso8601String(),
    });
    return AdminCallable.convert(result, (_) {});
  }
}
