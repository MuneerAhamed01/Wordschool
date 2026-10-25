import 'package:flutter_test/flutter_test.dart';
import 'package:wordshool/features/auth/domain/utils/player_name.dart';

void main() {
  test('Google name, trimmed and capped at 40 characters', () {
    expect(playerDisplayName(uid: 'u', name: '  Asha K  '), 'Asha K');
    final long = playerDisplayName(uid: 'u', name: 'A' * 60);
    expect(long.length, maxDisplayNameLength);
  });

  test('guests get a stable "Guest 1234"', () {
    final a = playerDisplayName(uid: 'abc123');
    expect(a, matches(RegExp(r'^Guest \d{4}$')));
    expect(playerDisplayName(uid: 'abc123', name: ''), a);
    expect(playerDisplayName(uid: 'abc124'), isNot(a));
  });
}
