import 'package:wordshool/core/resorces/data_state.dart';

abstract class SettingsDataSource {
  Future<DataState<bool>> signOut();
}


