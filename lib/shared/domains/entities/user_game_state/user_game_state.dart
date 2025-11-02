import 'package:equatable/equatable.dart';

class UserGameStateEntity extends Equatable {
  final String id; // EQUAVILANT TO USER ID
  final int streak;
  final int completedGames;
  final int totalGames;
  final DateTime createdDate;
  final DateTime updatedDate;

  const UserGameStateEntity({
    required this.id,
    this.streak = 0,
    this.completedGames = 0,
    this.totalGames = 0,
    required this.createdDate,
    required this.updatedDate,
  });

  @override
  List<Object?> get props =>
      [id, streak, completedGames, totalGames, createdDate, updatedDate];
}
