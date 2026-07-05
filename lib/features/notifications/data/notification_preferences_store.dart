import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:wordshool/features/notifications/domain/notification_preferences.dart';

class NotificationPreferencesStore {
  NotificationPreferencesStore(this._prefs);

  static const _prefsKey = 'notification_preferences';

  final SharedPreferences _prefs;

  NotificationPreferences load() {
    final raw = _prefs.getString(_prefsKey);
    if (raw == null) {
      return const NotificationPreferences();
    }
    return NotificationPreferences.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  Future<void> save(NotificationPreferences preferences) async {
    await _prefs.setString(_prefsKey, jsonEncode(preferences.toJson()));
  }
}
