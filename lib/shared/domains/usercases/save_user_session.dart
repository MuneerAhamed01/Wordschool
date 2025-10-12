import 'dart:async';

import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/core/resorces/usecase.dart';
import 'package:wordshool/shared/domains/entities/user_entity.dart';
import 'package:wordshool/shared/domains/repostiories/session_repository.dart';

class SaveUserSessionUseCase
    extends UseCase<DataState<bool>, WordSchoolUserEntity> {
  final SessionRepository _sessionRepository;

  SaveUserSessionUseCase({required SessionRepository sessionRepository})
      : _sessionRepository = sessionRepository;

  @override
  FutureOr<DataState<bool>> call({required WordSchoolUserEntity param}) {
    return _sessionRepository.saveUser(param);
  }
}
