import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wordshool/core/resorces/data_guard.dart';
import 'package:wordshool/core/resorces/data_state.dart';

void main() {
  test('success wraps the value', () async {
    final result = await guardData('t', () async => 42);
    expect(result, isA<DataSuccess<int>>());
    expect(result.data, 42);
  });

  test('Firebase errors carry the code and a player message', () async {
    final offline = await guardData<int>('t', () async {
      throw FirebaseException(plugin: 'p', code: 'unavailable');
    });
    expect(offline.error!.code, 'unavailable');
    expect(offline.error!.message, contains('offline'));

    final server = await guardData<int>('t', () async {
      throw FirebaseException(
          plugin: 'p', code: 'failed-precondition', message: 'Puzzle closed');
    });
    expect(server.error!.message, 'Puzzle closed');
  });

  test('not signed in and unknown errors', () async {
    final signedOut = await guardData<int>(
        't', () async => throw const NotSignedInException());
    expect(signedOut.error!.code, 'unauthenticated');
    final other = await guardData<int>('t', () async => throw StateError('x'));
    expect(other.error!.code, '500');
  });

  test('playerErrorMessage fallbacks', () {
    expect(
        playerErrorMessage('resource-exhausted', null), contains('Too many'));
    expect(playerErrorMessage('permission-denied', null), contains("can't"));
    expect(playerErrorMessage('not-found', ''), contains('Something'));
    expect(playerErrorMessage('weird', 'x'), contains('Something'));
  });
}
