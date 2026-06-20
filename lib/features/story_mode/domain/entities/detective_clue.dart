import 'package:equatable/equatable.dart';
import 'package:wordshool/features/story_mode/domain/entities/clue_type.dart';

class DetectiveClueEntity extends Equatable {
  final int index;
  final ClueType type;
  final String hint;
  final String answer;
  final String reaction;
  final String investigatePrompt;

  const DetectiveClueEntity({
    required this.index,
    required this.type,
    required this.hint,
    required this.answer,
    required this.reaction,
    required this.investigatePrompt,
  });

  @override
  List<Object?> get props =>
      [index, type, hint, answer, reaction, investigatePrompt];
}
