import 'package:flutter_test/flutter_test.dart';
import 'package:wordshool/features/admin/shared/domain/utils/server_problems.dart';

void main() {
  test('splitProblems splits the server message', () {
    expect(splitProblems('a is required; b must be a string'),
        ['a is required', 'b must be a string']);
    expect(splitProblems('one problem'), ['one problem']);
  });
}
