import 'package:flutter_test/flutter_test.dart';
import 'package:wordshool/features/admin/shared/domain/utils/sign_in_errors.dart';

void main() {
  group('emailProblem', () {
    test('asks for an email when empty', () {
      expect(emailProblem(null), 'Enter your email');
      expect(emailProblem('   '), 'Enter your email');
    });

    test('refuses text that is not an address', () {
      expect(emailProblem('admin'), 'Enter a valid email');
      expect(emailProblem('admin@site'), 'Enter a valid email');
      expect(emailProblem('a b@site.com'), 'Enter a valid email');
    });

    test('accepts an address, ignoring outer spaces', () {
      expect(emailProblem(' admin@example.com '), isNull);
    });
  });

  test('passwordProblem only asks for something to be typed', () {
    expect(passwordProblem(''), 'Enter your password');
    expect(passwordProblem(null), 'Enter your password');
    expect(passwordProblem('x'), isNull);
  });

  group('signInErrorMessage', () {
    test('wrong password and unknown email read the same', () {
      for (final code in [
        'invalid-credential',
        'wrong-password',
        'user-not-found',
        'invalid-login-credentials',
      ]) {
        expect(signInErrorMessage(code), 'Wrong email or password.');
      }
    });

    test('explains a provider that is turned off', () {
      expect(signInErrorMessage('operation-not-allowed'),
          contains('Enable Email/Password'));
    });

    test('keeps the code for anything unknown', () {
      expect(signInErrorMessage('weird-thing'), 'Sign-in failed (weird-thing).');
    });
  });
}
