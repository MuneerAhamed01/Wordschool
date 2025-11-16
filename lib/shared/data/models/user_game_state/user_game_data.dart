import 'package:wordshool/core/firebase/dt_converter.dart';
import 'package:wordshool/shared/domains/entities/user_game_state/user_game_data.dart';

class UserGameDataModel extends UserGameDataEntity {
  const UserGameDataModel({
    required super.id,
    super.guessedWords = const [],
    super.isCompleted = false,
    super.isCorrect = false,
    required super.createdDate,
    required super.updatedDate,
  });

  UserGameDataModel copyWith({
    String? id,
    List<String>? guessedWords,
    bool? isCompleted,
    bool? isCorrect,
    DateTime? createdDate,
    DateTime? updatedDate,
  }) {
    return UserGameDataModel(
      id: id ?? this.id,
      guessedWords: guessedWords ?? this.guessedWords,
      isCompleted: isCompleted ?? this.isCompleted,
      isCorrect: isCorrect ?? this.isCorrect,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
    );
  }

  factory UserGameDataModel.fromJson(Map<String, dynamic> json) {
    return UserGameDataModel(
      id: json['id'],
      guessedWords:
          (json['guessedWords'] as List).map((e) => e.toString()).toList(),
      isCompleted: json['isCompleted'],
      isCorrect: json['isCorrect'],
      createdDate: FirebaseDTConverter.fromTimestamp(json['createdDate']),
      updatedDate: FirebaseDTConverter.fromTimestamp(json['updatedDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'guessedWords': guessedWords,
      'isCompleted': isCompleted,
      'isCorrect': isCorrect,
      'createdDate': FirebaseDTConverter.toTimestamp(createdDate),
      'updatedDate': FirebaseDTConverter.toTimestamp(updatedDate),
    };
  }
}
