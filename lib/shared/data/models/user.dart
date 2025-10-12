// lib/shared/data/models/user_model.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wordshool/shared/domains/entities/user_entity.dart';

class WordSchoolUserModel extends WordSchoolUserEntity {
  const WordSchoolUserModel({
    required super.id,
    required super.email,
    required super.isAnonymous,
    super.name,
  });

  factory WordSchoolUserModel.fromFirebase({
    required User user,
  }) {
    return WordSchoolUserModel(
      id: user.uid,
      email: user.email ?? '',
      name: user.displayName,
      isAnonymous: user.isAnonymous,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'isAnonymous': isAnonymous,
      };

  factory WordSchoolUserModel.fromJson(Map<String, dynamic> json) {
    return WordSchoolUserModel(
      id: json['id'],
      email: json['email'],
      isAnonymous: json['isAnonymous'],
      name: json['name'],
    );
  }
}
