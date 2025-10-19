import 'package:equatable/equatable.dart';

class GameEntity extends Equatable {
  final String todayWord;
  final bool isCompleted;
  final DateTime createdDate;
  final DateTime updatedDate;

  const GameEntity({
    required this.todayWord,
    required this.isCompleted,
    required this.createdDate,
    required this.updatedDate,
  });

  @override
  List<Object?> get props => [todayWord, isCompleted, createdDate, updatedDate];
}
