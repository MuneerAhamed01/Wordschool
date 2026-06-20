import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wordshool/features/story_mode/data/models/detective_case.dart';
import 'package:wordshool/features/story_mode/data/models/detective_clue.dart';
import 'package:wordshool/features/story_mode/domain/entities/clue_type.dart';

void main() {
  group('DetectiveCaseModel', () {
    final createdAt = DateTime.utc(2026, 6, 18, 12);

    List<DetectiveClueModel> sampleClues() {
      return const [
        DetectiveClueModel(
          index: 0,
          type: ClueType.location,
          hint: 'Where the crime happened.',
          answer: 'STUDY',
          reaction: 'The study was locked.',
          investigatePrompt: 'Find the location.',
        ),
        DetectiveClueModel(
          index: 1,
          type: ClueType.weapon,
          hint: 'What caused the wound.',
          answer: 'KNIFE',
          reaction: 'A knife is missing.',
          investigatePrompt: 'Find the weapon.',
        ),
        DetectiveClueModel(
          index: 2,
          type: ClueType.suspect,
          hint: 'Who benefits most.',
          answer: 'HEIRS',
          reaction: 'The heir had motive.',
          investigatePrompt: 'Name the suspect.',
        ),
      ];
    }

    test('round-trips JSON with nested clues and timestamp', () {
      final model = DetectiveCaseModel(
        id: '2026-06-18',
        title: 'The Midnight Ledger',
        introduction: 'A financier is found dead.',
        clues: sampleClues(),
        resolution: 'The case is closed.',
        createdAt: createdAt,
      );

      final json = model.toJson();
      final restored = DetectiveCaseModel.fromJson(
        json,
        documentId: '2026-06-18',
      );

      expect(restored.id, '2026-06-18');
      expect(restored.title, model.title);
      expect(restored.introduction, model.introduction);
      expect(restored.resolution, model.resolution);
      expect(restored.createdAt.millisecondsSinceEpoch,
          model.createdAt.millisecondsSinceEpoch);
      expect(restored.clues.length, 3);
      expect(restored.clues[0].type, ClueType.location);
      expect(json['createdAt'], isA<Timestamp>());
    });

    test('uses documentId when id is missing from payload', () {
      final json = {
        'title': 'The Midnight Ledger',
        'introduction': 'A financier is found dead.',
        'clues': sampleClues().map((clue) => clue.toJson()).toList(),
        'resolution': 'The case is closed.',
        'createdAt': Timestamp.fromDate(createdAt),
      };

      final restored = DetectiveCaseModel.fromJson(
        json,
        documentId: '2026-06-18',
      );

      expect(restored.id, '2026-06-18');
    });

    test('rejects invalid clue count', () {
      final json = {
        'id': '2026-06-18',
        'title': 'Invalid case',
        'introduction': 'Too few clues.',
        'clues': [sampleClues().first.toJson()],
        'resolution': 'Incomplete.',
        'createdAt': Timestamp.fromDate(createdAt),
      };

      expect(
        () => DetectiveCaseModel.fromJson(json),
        throwsArgumentError,
      );
    });
  });
}
