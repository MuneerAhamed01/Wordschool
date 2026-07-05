class NotificationPayload {
  const NotificationPayload({
    required this.type,
    this.route,
    this.feature,
    this.streak,
  });

  final String type;
  final String? route;
  final String? feature;
  final int? streak;

  factory NotificationPayload.fromMap(Map<String, dynamic> data) {
    return NotificationPayload(
      type: data['type'] as String? ?? 'reengagement',
      route: data['route'] as String?,
      feature: data['feature'] as String?,
      streak: int.tryParse('${data['streak'] ?? ''}'),
    );
  }

  String resolveRoute() {
    if (route != null && route!.isNotEmpty) {
      return route!;
    }

    switch (type) {
      case 'daily_puzzle':
        return '/game';
      case 'detective_case':
        return '/story';
      case 'streak_reminder':
        return feature == 'detective' ? '/story' : '/game';
      case 'milestone':
      case 'reengagement':
        return '/home';
      default:
        return '/home';
    }
  }
}
