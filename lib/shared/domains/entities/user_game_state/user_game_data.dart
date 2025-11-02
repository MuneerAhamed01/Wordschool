import 'package:equatable/equatable.dart';

class UserGameDataEntity extends Equatable {
  final String id; // EQUAVILANT TO GAME ID
  final List<String> guessedWords;
  final bool isCompleted;
  final bool isCorrect;
  final DateTime createdDate;
  final DateTime updatedDate;

  const UserGameDataEntity({
    required this.id,
    this.guessedWords = const [],
    this.isCompleted = false,
    this.isCorrect = false,
    required this.createdDate,
    required this.updatedDate,
  });

  @override
  List<Object?> get props =>
      [id, guessedWords, isCompleted, isCorrect, createdDate, updatedDate];
}
