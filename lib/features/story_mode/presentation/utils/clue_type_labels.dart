import 'package:wordshool/features/story_mode/domain/entities/clue_type.dart';

String clueTypeLabel(ClueType type) {
  switch (type) {
    case ClueType.location:
      return 'Crime Scene';
    case ClueType.weapon:
      return 'Murder Weapon';
    case ClueType.suspect:
      return 'Prime Suspect';
  }
}
