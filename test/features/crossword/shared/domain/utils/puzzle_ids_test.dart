import 'package:flutter_test/flutter_test.dart';
import 'package:wordshool/features/crossword/shared/domain/utils/puzzle_ids.dart';

void main() {
  test('categoryOfPuzzle', () {
    expect(categoryOfPuzzle('kerala-history-0012'), 'kerala-history');
    expect(categoryOfPuzzle('gk-0001'), 'gk');
    expect(categoryOfPuzzle('odd'), 'odd');
  });
}
