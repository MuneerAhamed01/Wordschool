import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wordshool/core/firebase/server_ack.dart';

void main() {
  const wait = Duration(milliseconds: 20);

  test('waits for the server answer when it comes', () async {
    await expectLater(
        awaitServerAck(Future.value('doc-id'), 'Test.write', wait: wait),
        completes);
  });

  test('an offline write (no answer) completes after the wait', () async {
    final offline = Completer<void>().future;
    await expectLater(
        awaitServerAck(offline, 'Test.write', wait: wait), completes);
  });

  test('an online error (rules) still surfaces', () async {
    await expectLater(
      awaitServerAck(
          Future<void>.error(StateError('permission-denied')), 'Test.write',
          wait: wait),
      throwsStateError,
    );
  });
}
