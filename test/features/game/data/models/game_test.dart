import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wordshool/features/game/data/models/game.dart';

void main() {
  final created = DateTime.utc(2026, 10, 23, 4, 30);
  final updated = DateTime.utc(2026, 10, 23, 5, 15);

  Map<String, dynamic> firestoreJson() => {
        'todayWord': 'KERALA',
        'isCompleted': false,
        'createdDate': Timestamp.fromDate(created),
        'updatedDate': Timestamp.fromDate(updated),
      };

  group('GameModel.fromJson', () {
    test('reads a Firestore-shaped document', () {
      final model = GameModel.fromJson(firestoreJson());

      expect(model.todayWord, 'KERALA');
      expect(model.isCompleted, isFalse);
      expect(model.createdDate.isAtSameMomentAs(created), isTrue);
      expect(model.updatedDate.isAtSameMomentAs(updated), isTrue);
    });

    test('round-trips through toJson', () {
      final model = GameModel.fromJson(firestoreJson());

      expect(GameModel.fromJson(model.toJson()), model);
    });

    test('toJson writes timestamps', () {
      final json = GameModel.fromJson(firestoreJson()).toJson();

      expect(json['createdDate'], Timestamp.fromDate(created));
      expect(json['updatedDate'], Timestamp.fromDate(updated));
    });
  });

  test('copyWith changes only the given fields', () {
    final model = GameModel.fromJson(firestoreJson());
    final done = model.copyWith(isCompleted: true);

    expect(done.isCompleted, isTrue);
    expect(done.todayWord, model.todayWord);
    expect(done.createdDate, model.createdDate);
  });
}
