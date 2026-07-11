class AdminMetrics {
  const AdminMetrics({
    required this.days,
    required this.totalUsers,
    required this.activeUsers,
    required this.blockedUsers,
    required this.totalCompletedGames,
    required this.totalDetectivePoints,
    required this.contentHealth,
    required this.dailyActiveTrend,
  });

  final int days;
  final int totalUsers;
  final int activeUsers;
  final int blockedUsers;
  final int totalCompletedGames;
  final int totalDetectivePoints;
  final ContentHealth contentHealth;
  final List<DailyActivePoint> dailyActiveTrend;

  factory AdminMetrics.fromJson(Map<String, dynamic> json) {
    return AdminMetrics(
      days: (json['days'] as num?)?.toInt() ?? 7,
      totalUsers: (json['totalUsers'] as num?)?.toInt() ?? 0,
      activeUsers: (json['activeUsers'] as num?)?.toInt() ?? 0,
      blockedUsers: (json['blockedUsers'] as num?)?.toInt() ?? 0,
      totalCompletedGames: (json['totalCompletedGames'] as num?)?.toInt() ?? 0,
      totalDetectivePoints: (json['totalDetectivePoints'] as num?)?.toInt() ?? 0,
      contentHealth: ContentHealth.fromJson(
        Map<String, dynamic>.from(json['contentHealth'] as Map? ?? {}),
      ),
      dailyActiveTrend: (json['dailyActiveTrend'] as List<dynamic>? ?? [])
          .map((e) => DailyActivePoint.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

class ContentHealth {
  const ContentHealth({
    required this.todayGameExists,
    required this.todayCaseExists,
    required this.todayGameDateId,
    required this.todayCaseDateId,
    required this.missingPlannedCasesNext14Days,
  });

  final bool todayGameExists;
  final bool todayCaseExists;
  final String todayGameDateId;
  final String todayCaseDateId;
  final List<String> missingPlannedCasesNext14Days;

  factory ContentHealth.fromJson(Map<String, dynamic> json) {
    return ContentHealth(
      todayGameExists: json['todayGameExists'] as bool? ?? false,
      todayCaseExists: json['todayCaseExists'] as bool? ?? false,
      todayGameDateId: json['todayGameDateId'] as String? ?? '',
      todayCaseDateId: json['todayCaseDateId'] as String? ?? '',
      missingPlannedCasesNext14Days:
          (json['missingPlannedCasesNext14Days'] as List<dynamic>? ?? [])
              .map((e) => e.toString())
              .toList(),
    );
  }
}

class DailyActivePoint {
  const DailyActivePoint({required this.dateId, required this.activeUsers});

  final String dateId;
  final int activeUsers;

  factory DailyActivePoint.fromJson(Map<String, dynamic> json) {
    return DailyActivePoint(
      dateId: json['dateId'] as String? ?? '',
      activeUsers: (json['activeUsers'] as num?)?.toInt() ?? 0,
    );
  }
}

class Ga4Metrics {
  const Ga4Metrics({
    required this.configured,
    required this.days,
    this.message,
    this.daily = const [],
    this.topEvents = const [],
    this.consoleUrl,
  });

  final bool configured;
  final int days;
  final String? message;
  final List<Ga4DailyPoint> daily;
  final List<Ga4TopEvent> topEvents;
  final String? consoleUrl;

  factory Ga4Metrics.fromJson(Map<String, dynamic> json) {
    return Ga4Metrics(
      configured: json['configured'] as bool? ?? false,
      days: (json['days'] as num?)?.toInt() ?? 7,
      message: json['message'] as String?,
      daily: (json['daily'] as List<dynamic>? ?? [])
          .map((e) => Ga4DailyPoint.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      topEvents: (json['topEvents'] as List<dynamic>? ?? [])
          .map((e) => Ga4TopEvent.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      consoleUrl: json['consoleUrl'] as String?,
    );
  }
}

class Ga4DailyPoint {
  const Ga4DailyPoint({
    required this.date,
    required this.activeUsers,
    required this.eventCount,
  });

  final String date;
  final int activeUsers;
  final int eventCount;

  factory Ga4DailyPoint.fromJson(Map<String, dynamic> json) {
    return Ga4DailyPoint(
      date: json['date'] as String? ?? '',
      activeUsers: (json['activeUsers'] as num?)?.toInt() ?? 0,
      eventCount: (json['eventCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class Ga4TopEvent {
  const Ga4TopEvent({required this.eventName, required this.count});

  final String eventName;
  final int count;

  factory Ga4TopEvent.fromJson(Map<String, dynamic> json) {
    return Ga4TopEvent(
      eventName: json['eventName'] as String? ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }
}
