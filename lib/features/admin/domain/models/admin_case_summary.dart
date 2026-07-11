class AdminCaseSummary {
  const AdminCaseSummary({
    required this.dateId,
    required this.exists,
    this.title,
    required this.hasPlanned,
  });

  final String dateId;
  final bool exists;
  final String? title;
  final bool hasPlanned;

  factory AdminCaseSummary.fromJson(Map<String, dynamic> json) {
    return AdminCaseSummary(
      dateId: json['dateId'] as String? ?? '',
      exists: json['exists'] as bool? ?? false,
      title: json['title'] as String?,
      hasPlanned: json['hasPlanned'] as bool? ?? false,
    );
  }
}
