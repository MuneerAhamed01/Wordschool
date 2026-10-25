// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/foundation.dart';

import 'package:wordshool/features/game/presentation/utils/letter.dart';

class Word {
  List<Letter> letters;

  bool isCompleted;

  Word({required this.letters, this.isCompleted = false});

  @override
  bool operator ==(covariant Word other) {
    if (identical(this, other)) return true;

    return listEquals(other.letters, letters) &&
        other.isCompleted == isCompleted;
  }

  @override
  int get hashCode => letters.hashCode ^ isCompleted.hashCode;

  String get word => letters.map((e) => e.letter).join('').trim();

  Word copyWith({
    List<Letter>? letters,
    bool? isCompleted,
  }) {
    return Word(
      letters: letters ?? this.letters,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
