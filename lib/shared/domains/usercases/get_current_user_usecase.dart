import 'dart:async';

import 'package:wordshool/core/resorces/usecase.dart';
import 'package:wordshool/shared/domains/entities/user_entity.dart';
import 'package:wordshool/shared/domains/repostiories/session_repository.dart';

class GetCurrentUserUseCase extends UseCase<WordSchoolUserEntity?, void> {
  final SessionRepository _sessionRepository;

  GetCurrentUserUseCase({required SessionRepository sessionRepository})
      : _sessionRepository = sessionRepository;
  @override
  FutureOr<WordSchoolUserEntity?> call({void param}) async {
    return _sessionRepository.getCurrentUser();
  }
}
