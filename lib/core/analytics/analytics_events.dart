/// Firebase Analytics event names. Keep snake_case — GA4 convention.
abstract final class AnalyticsEvents {
  static const screenEngagement = 'screen_engagement';
  static const featureOpened = 'feature_opened';
  static const signIn = 'sign_in';
  static const signOut = 'sign_out';
  static const gameStarted = 'game_started';
  static const gameCompleted = 'game_completed';
  static const paywallViewed = 'paywall_viewed';
  static const purchaseStarted = 'purchase_started';
  static const purchaseCompleted = 'purchase_completed';
  static const purchaseFailed = 'purchase_failed';
  static const storyCaseStarted = 'story_case_started';
  static const storyClueStarted = 'story_clue_started';
  static const storyClueSolved = 'story_clue_solved';
  static const storyClueFailed = 'story_clue_failed';
  static const storyCaseCompleted = 'story_case_completed';
  static const storyShareTapped = 'story_share_tapped';
  static const storyHintUsed = 'story_hint_used';
  static const notificationPermissionRequested =
      'notification_permission_requested';
  static const notificationPermissionGranted =
      'notification_permission_granted';
  static const notificationPermissionDenied = 'notification_permission_denied';
  static const notificationOpened = 'notification_opened';
  static const notificationSettingsChanged = 'notification_settings_changed';
}

/// Parameter keys shared across events.
abstract final class AnalyticsParams {
  static const screenName = 'screen_name';
  static const durationSeconds = 'duration_seconds';
  static const featureName = 'feature_name';
  static const source = 'source';
  static const method = 'method';
  static const gameMode = 'game_mode';
  static const isResume = 'is_resume';
  static const won = 'won';
  static const attempts = 'attempts';
  static const placement = 'placement';
  static const productId = 'product_id';
  static const productType = 'product_type';
  static const reason = 'reason';
  static const clueIndex = 'clue_index';
  static const outcome = 'outcome';
  static const score = 'score';
  static const hintSource = 'source';
  static const notificationType = 'notification_type';
  static const notificationSource = 'notification_source';
  static const notificationsEnabled = 'notifications_enabled';
  static const dailyPuzzleReminder = 'daily_puzzle_reminder';
  static const detectiveCaseReminder = 'detective_case_reminder';
  static const streakReminder = 'streak_reminder';
}

/// Known features for adoption reporting in Firebase.
abstract final class AnalyticsFeatures {
  static const dailyGame = 'daily_game';
  static const archive = 'archive';
  static const leaderboard = 'leaderboard';
  static const settings = 'settings';
  static const storyMode = 'story_mode';
}

/// Paywall / IAP surfaces — wire these when monetization ships.
abstract final class AnalyticsPlacements {
  static const dashboardBanner = 'dashboard_banner';
  static const storyHint = 'story_hint';
  static const postGameInterstitial = 'post_game_interstitial';
  static const settingsUpgrade = 'settings_upgrade';
}
