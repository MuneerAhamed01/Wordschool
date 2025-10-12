// lib/shared/domain/entities/user_entity.dart
import 'package:equatable/equatable.dart';

class WordSchoolUserEntity extends Equatable {
  final String id;
  final String email;
  final String? name;
  final bool isAnonymous;

  const WordSchoolUserEntity({
    required this.id,
    required this.email,
    this.name,
    this.isAnonymous = false,
  });

  @override
  List<Object?> get props => [id, email, name, isAnonymous];
}
