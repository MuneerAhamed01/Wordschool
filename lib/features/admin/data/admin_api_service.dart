import 'package:cloud_functions/cloud_functions.dart';
import 'package:wordshool/core/resorces/data_state.dart';

/// Calls the admin Cloud Functions (`functions/crossword/`). Every method
/// returns a [DataState]; a failed call carries the server's message, which
/// lists every problem separated by "; ".
class AdminApiService {
  AdminApiService({required FirebaseFunctions functions})
      : _functions = functions;

  final FirebaseFunctions _functions;

  /// Confirms the server accepts this account as an admin.
  Future<DataState<void>> checkAccess() async {
    final result = await _call('adminListCategories');
    return result is DataSuccess
        ? DataSuccess(data: null)
        : DataError(error: result.error);
  }

  Future<DataState<Map<String, dynamic>>> _call(
    String name, [
    Map<String, dynamic> data = const {},
  ]) async {
    try {
      final result = await _functions.httpsCallable(name).call<dynamic>(data);
      final body = result.data;
      return DataSuccess(
        data: body is Map ? Map<String, dynamic>.from(body) : const {},
      );
    } on FirebaseFunctionsException catch (e) {
      return DataError(
        error: AppError(
          error: e,
          code: e.code,
          message: _friendlyMessage(e),
        ),
      );
    } catch (e) {
      return DataError(
        error: AppError(error: e, code: 'unknown', message: '$name failed: $e'),
      );
    }
  }

  static String _friendlyMessage(FirebaseFunctionsException e) {
    switch (e.code) {
      case 'unauthenticated':
        return 'Your session has expired. Please sign in again.';
      case 'permission-denied':
        return e.message ?? 'This account is not allowed to do that.';
      case 'unavailable':
      case 'deadline-exceeded':
        return 'Could not reach the server. Check your internet and try again.';
      default:
        return e.message ?? 'Something went wrong (${e.code}).';
    }
  }
}
