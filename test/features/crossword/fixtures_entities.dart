import 'package:wordshool/features/crossword/revise/domain/entities/revision_item.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/category.dart';
import 'package:wordshool/shared/domains/entities/localized_text.dart';

/// Small hand-made entities shared by bloc and screen tests.
const exampleCategory = CrosswordCategoryEntity(
  id: 'kerala-history',
  name: LocalizedText(en: 'Kerala History'),
  icon: 'history_edu',
  color: '#538D4E',
  order: 10,
  publishedPuzzleCount: 42,
);

RevisionItemEntity revisionItem(String id, int day) => RevisionItemEntity(
      questionId: id,
      answer: id.toUpperCase(),
      answerDisplay: LocalizedText(en: id),
      clue: const LocalizedText(en: 'clue'),
      fact: const LocalizedText(en: 'fact'),
      lastWrongAt: DateTime.utc(2026, 10, day),
    );
