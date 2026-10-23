import 'package:flutter_test/flutter_test.dart';
import 'package:wordshool/shared/data/models/user.dart';

void main() {
  group('WordSchoolUserModel.fromJson', () {
    test('reads a signed-in user', () {
      final model = WordSchoolUserModel.fromJson({
        'id': 'uid-123',
        'email': 'player@example.com',
        'name': 'Player One',
        'isAnonymous': false,
      });

      expect(model.id, 'uid-123');
      expect(model.email, 'player@example.com');
      expect(model.name, 'Player One');
      expect(model.isAnonymous, isFalse);
    });

    test('reads a guest without a name', () {
      final model = WordSchoolUserModel.fromJson({
        'id': 'uid-guest',
        'email': '',
        'name': null,
        'isAnonymous': true,
      });

      expect(model.name, isNull);
      expect(model.isAnonymous, isTrue);
    });

    test('round-trips through toJson', () {
      const model = WordSchoolUserModel(
        id: 'uid-123',
        email: 'player@example.com',
        name: 'Player One',
        isAnonymous: false,
      );

      expect(WordSchoolUserModel.fromJson(model.toJson()), model);
    });
  });
}
