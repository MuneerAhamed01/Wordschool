import 'package:wordshool/features/story_mode/domain/entities/clue_type.dart';
import 'package:wordshool/features/story_mode/domain/entities/detective_clue.dart';

class DetectiveClueModel extends DetectiveClueEntity {
  const DetectiveClueModel({
    required super.index,
    required super.type,
    required super.hint,
    required super.answer,
    required super.reaction,
    required super.investigatePrompt,
  });

  factory DetectiveClueModel.fromJson(Map<String, dynamic> json) {
    return DetectiveClueModel(
      index: json['index'] as int,
      type: ClueTypeFirestore.fromFirestoreString(json['type'] as String),
      hint: json['hint'] as String,
      answer: json['answer'] as String,
      reaction: json['reaction'] as String,
      investigatePrompt: json['investigatePrompt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'type': type.toFirestoreString(),
      'hint': hint,
      'answer': answer,
      'reaction': reaction,
      'investigatePrompt': investigatePrompt,
    };
  }
}
