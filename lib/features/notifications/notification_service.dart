import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:wordshool/core/analytics/analytics_service.dart';
import 'package:wordshool/core/utils/date_helper.dart';
import 'package:wordshool/features/notifications/data/notification_preferences_store.dart';
import 'package:wordshool/features/notifications/data/notification_token_service.dart';
import 'package:wordshool/features/notifications/domain/notification_preferences.dart';
import 'package:wordshool/features/notifications/notification_payload.dart';

typedef NotificationRouteHandler = void Function(String route);

class NotificationService {
  NotificationService({
    required NotificationPreferencesStore preferencesStore,
    required NotificationTokenService tokenService,
    required AnalyticsService analytics,
  })  : _preferencesStore = preferencesStore,
        _tokenService = tokenService,
        _analytics = analytics;

  static const _androidChannelId = 'wordschool_reminders';
  static const _androidChannelName = 'WordSchool Reminders';
  static const _detectiveCaseTopic = 'detective_case_daily';

  static const int dailyPuzzleNotificationId = 1;
  static const int detectiveCaseNotificationId = 2;
  static const int streakFallbackNotificationId = 3;

  static const _androidNotificationDetails = AndroidNotificationDetails(
    _androidChannelId,
    _androidChannelName,
    importance: Importance.high,
    priority: Priority.high,
  );

  static const _iosNotificationDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  static const _platformNotificationDetails = NotificationDetails(
    android: _androidNotificationDetails,
    iOS: _iosNotificationDetails,
  );

  final NotificationPreferencesStore _preferencesStore;
  final NotificationTokenService _tokenService;
  final AnalyticsService _analytics;

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  NotificationRouteHandler? onRouteTap;
  String? _currentUserId;
  String? _fcmToken;
  bool _initialized = false;

  NotificationPreferences get preferences => _preferencesStore.load();

  Future<void> _configureLocalTimezone() async {
    try {
      final timezoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneName));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
  }

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    await _configureLocalTimezone();

    if (Platform.isIOS && await hasPermission()) {
      await _enableIosForegroundPresentation();
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _localNotifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              _androidChannelId,
              _androidChannelName,
              description: 'Daily puzzle and detective case reminders',
              importance: Importance.high,
            ),
          );
    }

    FirebaseMessaging.onMessageOpenedApp.listen(_onFcmMessageOpened);
    _messaging.onTokenRefresh.listen((token) async {
      _fcmToken = token;
      _logFcmToken(token);
      await _syncToFirestore();
    });

    _initialized = true;
  }

  /// Called from [main] via an early [FirebaseMessaging.onMessage] listener.
  void handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      debugPrint('FCM foreground message: ${message.messageId ?? 'no-id'}');
    }

    final notification = message.notification;
    final title = notification?.title ?? message.data['title'] as String?;
    final body = notification?.body ?? message.data['body'] as String?;

    if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) {
      return;
    }

    // Android has no system foreground banner — always show locally.
    // iOS: show locally only for data-only messages (notification payloads
    // use setForegroundNotificationPresentationOptions for the system banner).
    if (Platform.isAndroid || notification == null) {
      _showLocalNotification(
        id: message.hashCode,
        title: title ?? 'WordSchool',
        body: body ?? '',
        data: message.data,
      );
    }
  }

  /// Call after [onRouteTap] is wired so cold-start notification taps navigate.
  Future<void> handleColdStartMessage() async {
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleRemoteMessage(initialMessage, source: 'fcm_cold_start');
    }
  }

  Future<void> bindUser(String? userId) async {
    _currentUserId = userId;
    if (userId == null) return;
    if (Platform.isIOS && await hasPermission()) {
      await _enableIosForegroundPresentation();
    }
    await _refreshFcmToken();
    await _syncToFirestore();
    await rescheduleLocalNotifications();
  }

  Future<bool> requestPermission() async {
    await _analytics.logNotificationPermissionRequested();

    var granted = false;

    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      granted = status.isGranted;
    } else {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      granted = settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    }

    if (granted) {
      await _analytics.logNotificationPermissionGranted();
      if (Platform.isIOS) {
        await _enableIosForegroundPresentation();
      }
      await _refreshFcmToken();
      await _syncToFirestore();
      await rescheduleLocalNotifications();
    } else {
      await _analytics.logNotificationPermissionDenied();
    }

    return granted;
  }

  Future<bool> hasPermission() async {
    if (Platform.isAndroid) {
      return Permission.notification.isGranted;
    }
    final settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  Future<void> updatePreferences(NotificationPreferences preferences) async {
    await _preferencesStore.save(preferences);
    await _analytics.logNotificationSettingsChanged(
      enabled: preferences.enabled,
      dailyPuzzle: preferences.dailyPuzzleEnabled,
      detectiveCase: preferences.detectiveCaseEnabled,
      streakReminder: preferences.streakReminderEnabled,
    );

    if (preferences.enabled) {
      await _subscribeToTopics();
    } else {
      await _unsubscribeFromTopics();
    }

    await _syncToFirestore();
    await rescheduleLocalNotifications();
  }

  Future<void> markPermissionPromptShown() async {
    final current = preferences;
    if (current.permissionPromptShown) return;
    await _preferencesStore.save(
      current.copyWith(permissionPromptShown: true),
    );
  }

  Future<void> rescheduleLocalNotifications({
    int? dailyStreak,
    bool dailyPlayedToday = false,
    bool detectivePlayedToday = false,
    bool storyModeEnabled = true,
  }) async {
    if (!_initialized) return;

    await _localNotifications.cancelAll();

    final prefs = preferences;
    if (!prefs.enabled) return;

    final hasPerm = await hasPermission();
    if (!hasPerm) return;

    final location = _resolveTimezone();
    tz.setLocalLocation(location);

    if (prefs.dailyPuzzleEnabled && !dailyPlayedToday) {
      await _scheduleDaily(
        id: dailyPuzzleNotificationId,
        hour: prefs.dailyReminderHour,
        title: "Today's puzzle is ready",
        body: '5 letters. One shot. Can you solve it?',
        payload: const NotificationPayload(type: 'daily_puzzle', route: '/game'),
      );
    }

    if (prefs.detectiveCaseEnabled &&
        storyModeEnabled &&
        !detectivePlayedToday) {
      final detectiveHour = (prefs.dailyReminderHour + 1) % 24;
      await _scheduleDaily(
        id: detectiveCaseNotificationId,
        hour: detectiveHour,
        minute: 30,
        title: 'New detective case',
        body: 'Three clues. One culprit. Open today\'s case file.',
        payload: const NotificationPayload(
          type: 'detective_case',
          route: '/story',
        ),
      );
    }

    if (prefs.streakReminderEnabled &&
        !dailyPlayedToday &&
        dailyStreak != null &&
        dailyStreak > 0) {
      await _scheduleDaily(
        id: streakFallbackNotificationId,
        hour: prefs.streakReminderHour,
        title: 'Streak at risk',
        body:
            "Don't lose your $dailyStreak-day streak — 10 minutes is all it takes.",
        payload: const NotificationPayload(
          type: 'streak_reminder',
          feature: 'daily',
          route: '/game',
        ),
      );
    }
  }

  Future<void> openSystemSettings() => openAppSettings();

  void _onLocalNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) {
      onRouteTap?.call('/home');
      return;
    }

    final parts = payload.split('|');
    final type = parts.first;
    final route = parts.length > 1 ? parts[1] : null;
    _navigateFromPayload(
      NotificationPayload(type: type, route: route),
      source: 'local',
    );
  }

  Future<void> _enableIosForegroundPresentation() async {
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void _showLocalNotification({
    required int id,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) {
    _localNotifications.show(
      id,
      title,
      body,
      _platformNotificationDetails,
      payload: _encodePayload(data),
    );
  }

  void _onFcmMessageOpened(RemoteMessage message) {
    _handleRemoteMessage(message, source: 'fcm');
  }

  void _handleRemoteMessage(RemoteMessage message, {required String source}) {
    _navigateFromPayload(
      NotificationPayload.fromMap(message.data),
      source: source,
    );
  }

  void _navigateFromPayload(
    NotificationPayload payload, {
    required String source,
  }) {
    _analytics.logNotificationOpened(type: payload.type, source: source);
    onRouteTap?.call(payload.resolveRoute());
  }

  Future<void> _scheduleDaily({
    required int id,
    required int hour,
    int minute = 0,
    required String title,
    required String body,
    required NotificationPayload payload,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      _platformNotificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: _encodePayload({
        'type': payload.type,
        'route': payload.route,
        'feature': payload.feature,
      }),
    );
  }

  tz.Location _resolveTimezone() {
    final stored = preferences.timezone;
    if (stored != null && stored.isNotEmpty) {
      try {
        return tz.getLocation(stored);
      } catch (_) {
        // Fall through to local.
      }
    }

    try {
      return tz.local;
    } catch (_) {
      return tz.getLocation('UTC');
    }
  }

  String _deviceTimezone() {
    try {
      return tz.local.name;
    } catch (_) {
      return DateTime.now().timeZoneName;
    }
  }

  Future<void> _refreshFcmToken() async {
    try {
      if (Platform.isIOS && !await hasPermission()) {
        return;
      }

      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) {
        return;
      }

      _fcmToken = token;
      _logFcmToken(token);
      await _subscribeToTopics();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('FCM token refresh failed: $e');
      }
    }
  }

  void _logFcmToken(String token) {
    if (kDebugMode) {
      debugPrint('FCM token (paste into Firebase Console test): $token');
    }
  }

  Future<void> _syncToFirestore() async {
    final userId = _currentUserId;
    if (userId == null) return;

    var prefs = preferences;
    final timezone = _deviceTimezone();
    if (prefs.timezone != timezone) {
      prefs = prefs.copyWith(timezone: timezone);
      await _preferencesStore.save(prefs);
    }

    await _tokenService.syncUserNotifications(
      userId: userId,
      fcmToken: _fcmToken,
      preferences: prefs,
      timezone: timezone,
    );
  }

  Future<void> _subscribeToTopics() async {
    if (!preferences.enabled || !preferences.detectiveCaseEnabled) return;
    try {
      await _messaging.subscribeToTopic(_detectiveCaseTopic);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('FCM topic subscribe failed: $e');
      }
    }
  }

  Future<void> _unsubscribeFromTopics() async {
    try {
      await _messaging.unsubscribeFromTopic(_detectiveCaseTopic);
    } catch (_) {}
  }

  String _encodePayload(Map<String, dynamic> data) {
    final payload = NotificationPayload.fromMap(data);
    return '${payload.type}|${payload.resolveRoute()}';
  }

  Future<void> clearOnLogout() async {
    final userId = _currentUserId;
    final token = _fcmToken;
    if (userId != null && token != null) {
      await _tokenService.removeToken(userId: userId, fcmToken: token);
    }
    await _unsubscribeFromTopics();
    await _localNotifications.cancelAll();
    _currentUserId = null;
  }
}

/// Helpers for scheduling eligibility checks.
class NotificationScheduleContext {
  const NotificationScheduleContext({
    required this.dailyStreak,
    required this.dailyPlayedToday,
    required this.detectivePlayedToday,
    required this.storyModeEnabled,
  });

  final int dailyStreak;
  final bool dailyPlayedToday;
  final bool detectivePlayedToday;
  final bool storyModeEnabled;

  static bool isDailyPlayedToday(String? lastStreakDate) {
    return lastStreakDate == DateHelper.todayDateId();
  }

  static bool isDetectivePlayedToday(String? lastStoryModeStreakDate) {
    return lastStoryModeStreakDate == DateHelper.todayUtcDateId();
  }
}
