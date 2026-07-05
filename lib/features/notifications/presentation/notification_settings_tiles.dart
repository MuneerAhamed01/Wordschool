import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/di.dart';
import 'package:wordshool/features/notifications/domain/notification_preferences.dart';
import 'package:wordshool/features/notifications/notification_service.dart';
import 'package:wordshool/shared/presentations/widgets/action_tile.dart';
import 'package:wordshool/shared/presentations/widgets/snackbar.dart';

class NotificationSettingsSection extends StatefulWidget {
  const NotificationSettingsSection({super.key});

  @override
  State<NotificationSettingsSection> createState() =>
      _NotificationSettingsSectionState();
}

class _NotificationSettingsSectionState
    extends State<NotificationSettingsSection> {
  late NotificationPreferences _prefs;
  bool _permissionDenied = false;

  NotificationService get _service => getIt<NotificationService>();

  @override
  void initState() {
    super.initState();
    _prefs = _service.preferences;
    _loadPermissionState();
  }

  Future<void> _loadPermissionState() async {
    final granted = await _service.hasPermission();
    if (mounted) {
      setState(() => _permissionDenied = !granted);
    }
  }

  Future<void> _update(NotificationPreferences updated) async {
    setState(() => _prefs = updated);
    await _service.updatePreferences(updated);
    await _loadPermissionState();
  }

  Future<void> _pickTime({
    required int currentHour,
    required ValueChanged<int> onSelected,
  }) async {
    final time = TimeOfDay(hour: currentHour, minute: 0);
    final picked = await showTimePicker(
      context: context,
      initialTime: time,
    );
    if (picked != null) {
      onSelected(picked.hour);
    }
  }

  String _formatHour(int hour) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:00 $period';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ActionTile(
          title: 'Notifications',
          subtitle: _prefs.enabled
              ? 'Daily reminders and streak alerts'
              : 'All notifications off',
          icon: Icons.notifications_outlined,
          accentColor: MyColors.streakAccent,
          trailing: Switch(
            value: _prefs.enabled,
            onChanged: (value) async {
              if (value && !await _service.hasPermission()) {
                final granted = await _service.requestPermission();
                if (!granted) {
                  if (context.mounted) {
                    CustomSnackBar.show(
                      context,
                      message: 'Enable notifications in system settings',
                      type: SnackBarType.error,
                    );
                  }
                  await _loadPermissionState();
                  return;
                }
              }
              await _update(_prefs.copyWith(enabled: value));
            },
          ),
          onTap: () async {
            final next = !_prefs.enabled;
            if (next && !await _service.hasPermission()) {
              final granted = await _service.requestPermission();
              if (!granted) return;
            }
            await _update(_prefs.copyWith(enabled: next));
          },
        ),
        if (_permissionDenied) ...[
          const SizedBox(height: 10),
          ActionTile(
            title: 'Open system settings',
            subtitle: 'Notifications are disabled for WordSchool',
            icon: Icons.settings_outlined,
            accentColor: MyColors.lightBlue3,
            onTap: _service.openSystemSettings,
          ),
        ],
        if (_prefs.enabled) ...[
          const SizedBox(height: 10),
          ActionTile(
            title: 'Daily puzzle reminder',
            subtitle: 'Morning nudge for today\'s Wordle',
            icon: Icons.extension_outlined,
            accentColor: MyColors.tileCorrect,
            trailing: Switch(
              value: _prefs.dailyPuzzleEnabled,
              onChanged: (value) =>
                  _update(_prefs.copyWith(dailyPuzzleEnabled: value)),
            ),
            onTap: () => _update(
              _prefs.copyWith(dailyPuzzleEnabled: !_prefs.dailyPuzzleEnabled),
            ),
          ),
          const SizedBox(height: 10),
          ActionTile(
            title: 'Detective case reminder',
            subtitle: 'Alert when a new case is ready',
            icon: Icons.search_rounded,
            accentColor: MyColors.lightBlue3,
            trailing: Switch(
              value: _prefs.detectiveCaseEnabled,
              onChanged: (value) =>
                  _update(_prefs.copyWith(detectiveCaseEnabled: value)),
            ),
            onTap: () => _update(
              _prefs.copyWith(
                detectiveCaseEnabled: !_prefs.detectiveCaseEnabled,
              ),
            ),
          ),
          const SizedBox(height: 10),
          ActionTile(
            title: 'Streak reminders',
            subtitle: 'Evening warning before your streak resets',
            icon: Icons.local_fire_department_outlined,
            accentColor: MyColors.streakAccent,
            trailing: Switch(
              value: _prefs.streakReminderEnabled,
              onChanged: (value) =>
                  _update(_prefs.copyWith(streakReminderEnabled: value)),
            ),
            onTap: () => _update(
              _prefs.copyWith(
                streakReminderEnabled: !_prefs.streakReminderEnabled,
              ),
            ),
          ),
          const SizedBox(height: 10),
          ActionTile(
            title: 'Morning reminder time',
            subtitle: _formatHour(_prefs.dailyReminderHour),
            icon: Icons.wb_sunny_outlined,
            accentColor: MyColors.gray6,
            onTap: () => _pickTime(
              currentHour: _prefs.dailyReminderHour,
              onSelected: (hour) =>
                  _update(_prefs.copyWith(dailyReminderHour: hour)),
            ),
          ),
          const SizedBox(height: 10),
          ActionTile(
            title: 'Streak reminder time',
            subtitle: _formatHour(_prefs.streakReminderHour),
            icon: Icons.nightlight_round,
            accentColor: MyColors.gray6,
            onTap: () => _pickTime(
              currentHour: _prefs.streakReminderHour,
              onSelected: (hour) =>
                  _update(_prefs.copyWith(streakReminderHour: hour)),
            ),
          ),
        ],
      ],
    );
  }
}
