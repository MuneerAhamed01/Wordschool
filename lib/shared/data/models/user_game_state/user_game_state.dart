import 'package:wordshool/core/firebase/dt_converter.dart';
import 'package:wordshool/shared/domains/entities/user_game_state/user_game_state.dart';

class UserGameStateModel extends UserGameStateEntity {
  const UserGameStateModel({
    required super.id,
    super.streak = 0,
    super.completedGames = 0,
    super.totalGames = 0,
    required super.createdDate,
    required super.updatedDate,
  });

  UserGameStateModel copyWith({
    String? id,
    int? streak,
    int? completedGames,
    int? totalGames,
    DateTime? createdDate,
    DateTime? updatedDate,
  }) {
    return UserGameStateModel(
      id: id ?? this.id,
      streak: streak ?? this.streak,
      completedGames: completedGames ?? this.completedGames,
      totalGames: totalGames ?? this.totalGames,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
    );
  }

  factory UserGameStateModel.fromJson(Map<String, dynamic> json) {
    return UserGameStateModel(
      id: json['id'],
      streak: json['streak'],
      completedGames: json['completedGames'],
      totalGames: json['totalGames'],
      createdDate: FirebaseDTConverter.fromTimestamp(json['createdDate']),
      updatedDate: FirebaseDTConverter.fromTimestamp(json['updatedDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'streak': streak,
      'completedGames': completedGames,
      'totalGames': totalGames,
      'createdDate': FirebaseDTConverter.toTimestamp(createdDate),
      'updatedDate': FirebaseDTConverter.toTimestamp(updatedDate),
    };
  }
}
