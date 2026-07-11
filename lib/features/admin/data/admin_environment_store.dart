import 'package:shared_preferences/shared_preferences.dart';

enum AdminTargetEnvironment {
  dev('development', 'Dev'),
  prod('(default)', 'Prod');

  const AdminTargetEnvironment(this.databaseId, this.label);

  final String databaseId;
  final String label;

  bool get isProd => this == AdminTargetEnvironment.prod;
}

class AdminEnvironmentStore {
  AdminEnvironmentStore(this._prefs);

  static const _key = 'admin_target_environment';

  final SharedPreferences _prefs;

  AdminTargetEnvironment get current {
    final raw = _prefs.getString(_key);
    if (raw == AdminTargetEnvironment.prod.databaseId) {
      return AdminTargetEnvironment.prod;
    }
    return AdminTargetEnvironment.dev;
  }

  Future<void> setEnvironment(AdminTargetEnvironment env) async {
    await _prefs.setString(_key, env.databaseId);
  }
}
