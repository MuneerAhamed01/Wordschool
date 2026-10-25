import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:wordshool/core/resorces/data_state.dart';

/// Thrown by data sources when the call needs a signed-in player.
class NotSignedInException implements Exception {
  const NotSignedInException();
}

/// Runs [body] and wraps the outcome, so data sources never throw across
/// layers: `return guardData('CrosswordContent.getDaily', () async {...});`
/// Errors are logged with [context] and carry a message a player can read.
Future<DataState<T>> guardData<T>(
  String context,
  Future<T> Function() body,
) async {
  try {
    return DataSuccess<T>(data: await body());
  } on FirebaseException catch (error, stackTrace) {
    log('$context failed: ${error.code}',
        name: 'DATA', error: error, stackTrace: stackTrace);
    return DataError<T>(
      error: AppError(
        error: error,
        code: error.code,
        message: playerErrorMessage(error.code, error.message),
      ),
    );
  } on NotSignedInException catch (error) {
    return DataError<T>(
      error: AppError(
        error: error,
        code: 'unauthenticated',
        message: playerErrorMessage('unauthenticated', null),
      ),
    );
  } catch (error, stackTrace) {
    log('$context failed', name: 'DATA', error: error, stackTrace: stackTrace);
    return DataError<T>(error: AppError(error: error, code: '500'));
  }
}

/// Plain words for a Firebase error code. Callable errors (`invalid-argument`,
/// `failed-precondition`, …) already carry a message written for players.
String playerErrorMessage(String code, String? serverMessage) {
  switch (code) {
    case 'unavailable':
    case 'deadline-exceeded':
      return "You're offline or the connection is slow. Try again in a moment.";
    case 'unauthenticated':
      return 'Please sign in again.';
    case 'permission-denied':
      return "You can't do that right now.";
    case 'resource-exhausted':
      return 'Too many tries. Wait a little and try again.';
    case 'invalid-argument':
    case 'failed-precondition':
    case 'not-found':
      if (serverMessage != null && serverMessage.isNotEmpty) {
        return serverMessage;
      }
      return 'Something went wrong. Please try again.';
    default:
      return 'Something went wrong. Please try again.';
  }
}
