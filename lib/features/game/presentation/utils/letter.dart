import 'package:wordshool/core/enums/word_tile_type.dart';

class Letter {
  final String letter;
  final WordTileType? type;

  Letter({required this.letter, this.type});

  @override
  bool operator ==(covariant Letter other) {
    if (identical(this, other)) return true;

    return other.letter == letter && other.type == type;
  }

  @override
  int get hashCode => letter.hashCode ^ type.hashCode;

  Letter copyWith({
    String? letter,
    WordTileType? type,
  }) {
    return Letter(
      letter: letter ?? this.letter,
      type: type ?? this.type,
    );
  }
}
