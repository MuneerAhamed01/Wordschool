import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/shared/data/models/user.dart';

class SessionHandler {
  final SharedPreferences _prefs;

  WordSchoolUserModel? _cachedUser;

  SessionHandler(this._prefs);

  Future<DataState<bool>> saveUser(WordSchoolUserModel user) async {
    try {
      _cachedUser = user;
      await _prefs.setString('user', jsonEncode(user));
      return DataSuccess<bool>(data: true);
    } catch (e) {
      return DataError<bool>(error: AppError(error: e.toString(), code: '500'));
    }
  }

  WordSchoolUserModel? get currentUser => _cachedUser;

  void loadUser() async {
    final data = _prefs.getString('user');
    if (data != null) {
      _cachedUser = WordSchoolUserModel.fromJson(jsonDecode(data));
    }
  }

  Future<DataState<bool>> clear() async {
    try {
      _cachedUser = null;
      await _prefs.remove('user');
      return DataSuccess<bool>(data: true);
    } catch (e) {
      return DataError<bool>(error: AppError(error: e.toString(), code: '500'));
    }
  }
}
