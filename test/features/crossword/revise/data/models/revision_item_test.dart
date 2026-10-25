import 'package:flutter_test/flutter_test.dart';
import 'package:wordshool/features/crossword/revise/data/models/revision_item.dart';

import '../../../crossword_fixtures.dart';

void main() {
  test('revision item', () {
    final (data, id) = fixtureDoc('revision_item');
    final item = RevisionItemModel.fromJson(data, documentId: id);
    expect(item.questionId, 'q-vaikom');
    expect(item.answerDisplay.en, 'Vaikom');
    expect(item.puzzleId, 'kerala-history-0012');
    expect(item.wrongCount, 2);
    expect(item.subjectLabel, 'Kerala history');
    expect(item.lastWrongAt, isNotNull);
  });
}
