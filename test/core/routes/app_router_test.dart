import 'package:flutter_test/flutter_test.dart';
import 'package:wordshool/core/routes/app_router.dart';

void main() {
  group('authRedirect', () {
    test('sends signed-out users to /auth', () {
      for (final location in [
        '/home',
        '/revise',
        '/ranks',
        '/profile',
        '/game'
      ]) {
        expect(
          authRedirect(location: location, signedIn: false),
          '/auth',
          reason: location,
        );
      }
    });

    test('keeps signed-out users on /auth', () {
      expect(authRedirect(location: '/auth', signedIn: false), isNull);
    });

    test('sends signed-in users away from /auth to Play', () {
      expect(authRedirect(location: '/auth', signedIn: true), '/home');
    });

    test('leaves signed-in users where they are', () {
      for (final location in [
        '/home',
        '/revise',
        '/ranks',
        '/profile',
        '/game'
      ]) {
        expect(
          authRedirect(location: location, signedIn: true),
          isNull,
          reason: location,
        );
      }
    });
  });
}
