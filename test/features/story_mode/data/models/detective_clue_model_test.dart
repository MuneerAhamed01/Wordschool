import 'package:flutter_test/flutter_test.dart';
import 'package:wordshool/features/story_mode/data/models/detective_clue.dart';
import 'package:wordshool/features/story_mode/domain/entities/clue_type.dart';

void main() {
  group('DetectiveClueModel', () {
    test('serializes and deserializes all clue types', () {
      for (final type in ClueType.values) {
        final model = DetectiveClueModel(
          index: type.index,
          type: type,
          hint: 'hint for ${type.name}',
          answer: 'CRANE',
          reaction: 'reaction for ${type.name}',
          investigatePrompt: 'Investigate the ${type.name}.',
        );

        final json = model.toJson();
        final restored = DetectiveClueModel.fromJson(json);

        expect(restored.index, model.index);
        expect(restored.type, model.type);
        expect(restored.hint, model.hint);
        expect(restored.answer, model.answer);
        expect(restored.reaction, model.reaction);
        expect(restored.investigatePrompt, model.investigatePrompt);
        expect(json['type'], type.name);
      }
    });
  });
}
