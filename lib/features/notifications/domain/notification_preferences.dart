import 'package:equatable/equatable.dart';

class NotificationPreferences extends Equatable {
  const NotificationPreferences({
    this.enabled = true,
    this.dailyPuzzleEnabled = true,
    this.detectiveCaseEnabled = true,
    this.streakReminderEnabled = true,
    this.dailyReminderHour = 9,
    this.streakReminderHour = 20,
    this.timezone,
    this.permissionPromptShown = false,
  });

  final bool enabled;
  final bool dailyPuzzleEnabled;
  final bool detectiveCaseEnabled;
  final bool streakReminderEnabled;
  final int dailyReminderHour;
  final int streakReminderHour;
  final String? timezone;
  final bool permissionPromptShown;

  NotificationPreferences copyWith({
    bool? enabled,
    bool? dailyPuzzleEnabled,
    bool? detectiveCaseEnabled,
    bool? streakReminderEnabled,
    int? dailyReminderHour,
    int? streakReminderHour,
    String? timezone,
    bool? permissionPromptShown,
  }) {
    return NotificationPreferences(
      enabled: enabled ?? this.enabled,
      dailyPuzzleEnabled: dailyPuzzleEnabled ?? this.dailyPuzzleEnabled,
      detectiveCaseEnabled:
          detectiveCaseEnabled ?? this.detectiveCaseEnabled,
      streakReminderEnabled:
          streakReminderEnabled ?? this.streakReminderEnabled,
      dailyReminderHour: dailyReminderHour ?? this.dailyReminderHour,
      streakReminderHour: streakReminderHour ?? this.streakReminderHour,
      timezone: timezone ?? this.timezone,
      permissionPromptShown:
          permissionPromptShown ?? this.permissionPromptShown,
    );
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
      'enabled': enabled,
      'dailyPuzzleEnabled': dailyPuzzleEnabled,
      'detectiveCaseEnabled': detectiveCaseEnabled,
      'streakReminderEnabled': streakReminderEnabled,
      'dailyReminderHour': dailyReminderHour,
      'streakReminderHour': streakReminderHour,
    };
  }

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      enabled: json['enabled'] as bool? ?? true,
      dailyPuzzleEnabled: json['dailyPuzzleEnabled'] as bool? ?? true,
      detectiveCaseEnabled: json['detectiveCaseEnabled'] as bool? ?? true,
      streakReminderEnabled: json['streakReminderEnabled'] as bool? ?? true,
      dailyReminderHour: json['dailyReminderHour'] as int? ?? 9,
      streakReminderHour: json['streakReminderHour'] as int? ?? 20,
      timezone: json['timezone'] as String?,
      permissionPromptShown: json['permissionPromptShown'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'dailyPuzzleEnabled': dailyPuzzleEnabled,
      'detectiveCaseEnabled': detectiveCaseEnabled,
      'streakReminderEnabled': streakReminderEnabled,
      'dailyReminderHour': dailyReminderHour,
      'streakReminderHour': streakReminderHour,
      'timezone': timezone,
      'permissionPromptShown': permissionPromptShown,
    };
  }

  @override
  List<Object?> get props => [
        enabled,
        dailyPuzzleEnabled,
        detectiveCaseEnabled,
        streakReminderEnabled,
        dailyReminderHour,
        streakReminderHour,
        timezone,
        permissionPromptShown,
      ];
}
