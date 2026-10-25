import 'dart:async';
import 'dart:developer';

/// Firestore applies a write to its local cache at once and sends it when
/// online, but the future only completes on the server's answer. Waiting
/// this long still surfaces online errors (rules) without hanging offline.
const serverAckWait = Duration(seconds: 5);

/// Awaits a Firestore [write] the player is waiting on for at most [wait].
/// After that the write stays queued (Firestore sends it when back online)
/// and this completes normally; errors that arrive in time still throw.
Future<void> awaitServerAck(
  Future<Object?> write,
  String context, {
  Duration wait = serverAckWait,
}) async {
  await write.timeout(wait, onTimeout: () {
    log('$context queued offline', name: 'DATA');
    return null;
  });
}
