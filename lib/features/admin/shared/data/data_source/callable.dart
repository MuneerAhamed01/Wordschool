import 'package:cloud_functions/cloud_functions.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/core/utils/json_read.dart';

/// Calls the admin Cloud Functions (`functions/crossword/`) and wraps the
/// answer in a [DataState]; a failed call carries the server's message,
/// which lists every problem separated by "; ".
class AdminCallable {
  AdminCallable(this._functions);

  final FirebaseFunctions _functions;

  /// [result]'s JSON through [parse]; a bad shape becomes a [DataError].
  static DataState<T> convert<T>(
    DataState<Map<String, dynamic>> result,
    T Function(Map<String, dynamic> json) parse,
  ) {
    if (result is! DataSuccess) return DataError(error: result.error);
    try {
      return DataSuccess(data: parse(result.data!));
    } catch (e) {
      return DataError(
        error: AppError(
          error: e,
          code: 'bad-response',
          message: 'The server sent something unexpected: $e',
        ),
      );
    }
  }

  Future<DataState<Map<String, dynamic>>> call(
    String name, [
    Map<String, dynamic> data = const {},
  ]) async {
    try {
      final result = await _functions.httpsCallable(name).call<dynamic>(data);
      return DataSuccess(data: asMap(result.data));
    } on FirebaseFunctionsException catch (e) {
      return DataError(
        error: AppError(error: e, code: e.code, message: _friendlyMessage(e)),
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
