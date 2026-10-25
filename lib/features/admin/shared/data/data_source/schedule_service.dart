import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/admin/shared/data/data_source/callable.dart';

/// Puts a puzzle on a date (puzzle detail and the schedule calendar).
class AdminScheduleService {
  AdminScheduleService(this._callable);

  final AdminCallable _callable;

  Future<DataState<void>> scheduleDaily({
    required String dateId,
    required String puzzleId,
  }) async {
    final result = await _callable.call('adminScheduleDaily', {
      'dateId': dateId,
      'puzzleId': puzzleId,
    });
    return AdminCallable.convert(result, (_) {});
  }
}
