import 'package:firebase_analytics/firebase_analytics.dart';

import 'analytics_events.dart';

/// App-wide analytics facade. Inject via GetIt; call from UI and blocs.
abstract class AnalyticsService {
  Future<void> setUserId(String? userId);

  Future<void> setUserProperty({
    required String name,
    required String? value,
  });

  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  });

  Future<void> logFeatureOpened({
    required String featureName,
    String source = 'dashboard',
  });

  Future<void> logSignIn({required String method});

  Future<void> logSignOut();

  Future<void> logGameStarted({
    required String gameMode,
    required bool isResume,
  });

  Future<void> logGameCompleted({
    required String gameMode,
    required bool won,
    required int attempts,
  });

  /// Call when a paywall or upgrade prompt is shown.
  Future<void> logPaywallViewed({required String placement});

  /// Call when the user taps buy / subscribe.
  Future<void> logPurchaseStarted({
    required String productId,
    required String placement,
  });

  Future<void> logPurchaseCompleted({
    required String productId,
    required String productType,
  });

  Future<void> logPurchaseFailed({
    required String productId,
    required String reason,
  });

  Future<void> logScreenEngagement({
    required String screenName,
    required int durationSeconds,
  });
}

class FirebaseAnalyticsService implements AnalyticsService {
  FirebaseAnalyticsService(this._analytics);

  final FirebaseAnalytics _analytics;

  @override
  Future<void> setUserId(String? userId) =>
      _analytics.setUserId(id: userId);

  @override
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) =>
      _analytics.setUserProperty(name: name, value: value);

  @override
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) =>
      _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      );

  @override
  Future<void> logFeatureOpened({
    required String featureName,
    String source = 'dashboard',
  }) =>
      _analytics.logEvent(
        name: AnalyticsEvents.featureOpened,
        parameters: {
          AnalyticsParams.featureName: featureName,
          AnalyticsParams.source: source,
        },
      );

  @override
  Future<void> logSignIn({required String method}) =>
      _analytics.logLogin(loginMethod: method);

  @override
  Future<void> logSignOut() => _analytics.logEvent(name: AnalyticsEvents.signOut);

  @override
  Future<void> logGameStarted({
    required String gameMode,
    required bool isResume,
  }) =>
      _analytics.logEvent(
        name: AnalyticsEvents.gameStarted,
        parameters: {
          AnalyticsParams.gameMode: gameMode,
          AnalyticsParams.isResume: isResume ? 1 : 0,
        },
      );

  @override
  Future<void> logGameCompleted({
    required String gameMode,
    required bool won,
    required int attempts,
  }) =>
      _analytics.logEvent(
        name: AnalyticsEvents.gameCompleted,
        parameters: {
          AnalyticsParams.gameMode: gameMode,
          AnalyticsParams.won: won ? 1 : 0,
          AnalyticsParams.attempts: attempts,
        },
      );

  @override
  Future<void> logPaywallViewed({required String placement}) =>
      _analytics.logEvent(
        name: AnalyticsEvents.paywallViewed,
        parameters: {AnalyticsParams.placement: placement},
      );

  @override
  Future<void> logPurchaseStarted({
    required String productId,
    required String placement,
  }) =>
      _analytics.logEvent(
        name: AnalyticsEvents.purchaseStarted,
        parameters: {
          AnalyticsParams.productId: productId,
          AnalyticsParams.placement: placement,
        },
      );

  @override
  Future<void> logPurchaseCompleted({
    required String productId,
    required String productType,
  }) =>
      _analytics.logEvent(
        name: AnalyticsEvents.purchaseCompleted,
        parameters: {
          AnalyticsParams.productId: productId,
          AnalyticsParams.productType: productType,
        },
      );

  @override
  Future<void> logPurchaseFailed({
    required String productId,
    required String reason,
  }) =>
      _analytics.logEvent(
        name: AnalyticsEvents.purchaseFailed,
        parameters: {
          AnalyticsParams.productId: productId,
          AnalyticsParams.reason: reason,
        },
      );

  @override
  Future<void> logScreenEngagement({
    required String screenName,
    required int durationSeconds,
  }) =>
      _analytics.logEvent(
        name: AnalyticsEvents.screenEngagement,
        parameters: {
          AnalyticsParams.screenName: screenName,
          AnalyticsParams.durationSeconds: durationSeconds,
        },
      );
}

/// No-op implementation for tests.
class NoOpAnalyticsService implements AnalyticsService {
  @override
  Future<void> setUserId(String? userId) async {}

  @override
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {}

  @override
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {}

  @override
  Future<void> logFeatureOpened({
    required String featureName,
    String source = 'dashboard',
  }) async {}

  @override
  Future<void> logSignIn({required String method}) async {}

  @override
  Future<void> logSignOut() async {}

  @override
  Future<void> logGameStarted({
    required String gameMode,
    required bool isResume,
  }) async {}

  @override
  Future<void> logGameCompleted({
    required String gameMode,
    required bool won,
    required int attempts,
  }) async {}

  @override
  Future<void> logPaywallViewed({required String placement}) async {}

  @override
  Future<void> logPurchaseStarted({
    required String productId,
    required String placement,
  }) async {}

  @override
  Future<void> logPurchaseCompleted({
    required String productId,
    required String productType,
  }) async {}

  @override
  Future<void> logPurchaseFailed({
    required String productId,
    required String reason,
  }) async {}

  @override
  Future<void> logScreenEngagement({
    required String screenName,
    required int durationSeconds,
  }) async {}
}
