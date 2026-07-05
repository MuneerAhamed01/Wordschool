import 'package:wordshool/core/resorces/data_state.dart';

abstract class SettingsRepository {
  Future<DataState<bool>> logout();

  Future<DataState<bool>> deleteAccount({
    required String firestoreDatabaseId,
  });
}


