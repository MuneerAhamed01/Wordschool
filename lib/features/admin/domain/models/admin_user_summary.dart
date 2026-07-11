class AdminUserSummary {
  const AdminUserSummary({
    required this.uid,
    this.email,
    this.displayName,
    required this.authDisabled,
    required this.streak,
    required this.completedGames,
    required this.detectivePoints,
    required this.isBlocked,
    this.blockedReason,
    this.blockedBy,
  });

  final String uid;
  final String? email;
  final String? displayName;
  final bool authDisabled;
  final int streak;
  final int completedGames;
  final int detectivePoints;
  final bool isBlocked;
  final String? blockedReason;
  final String? blockedBy;

  factory AdminUserSummary.fromJson(Map<String, dynamic> json) {
    return AdminUserSummary(
      uid: json['uid'] as String? ?? '',
      email: json['email'] as String?,
      displayName: json['displayName'] as String?,
      authDisabled: json['authDisabled'] as bool? ?? false,
      streak: (json['streak'] as num?)?.toInt() ?? 0,
      completedGames: (json['completedGames'] as num?)?.toInt() ?? 0,
      detectivePoints: (json['detectivePoints'] as num?)?.toInt() ?? 0,
      isBlocked: json['blockedAt'] != null,
      blockedReason: json['blockedReason'] as String?,
      blockedBy: json['blockedBy'] as String?,
    );
  }
}
