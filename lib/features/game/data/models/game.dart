import 'package:wordshool/core/firebase/dt_converter.dart';
import 'package:wordshool/features/game/domain/entities/game.dart';

class GameModel extends GameEntity {
  const GameModel({
    required super.todayWord,
    required super.isCompleted,
    required super.createdDate,
    required super.updatedDate,
  });

  GameModel copyWith({
    String? todayWord,
    bool? isCompleted,
    DateTime? createdDate,
    DateTime? updatedDate,
  }) {
    return GameModel(
      todayWord: todayWord ?? this.todayWord,
      isCompleted: isCompleted ?? this.isCompleted,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
    );
  }

  factory GameModel.fromJson(Map<String, dynamic> json) {
    return GameModel(
      todayWord: json['todayWord'],
      isCompleted: json['isCompleted'],
      createdDate: FirebaseDTConverter.fromTimestamp(json['createdDate']),
      updatedDate: FirebaseDTConverter.fromTimestamp(json['updatedDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'todayWord': todayWord,
      'isCompleted': isCompleted,
      'createdDate': FirebaseDTConverter.toTimestamp(createdDate),
      'updatedDate': FirebaseDTConverter.toTimestamp(updatedDate),
    };
  }
}
