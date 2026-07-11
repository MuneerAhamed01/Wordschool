class AdminGameSummary {
  const AdminGameSummary({
    required this.dateId,
    required this.todayWord,
    required this.exists,
  });

  final String dateId;
  final String todayWord;
  final bool exists;

  factory AdminGameSummary.fromJson(Map<String, dynamic> json) {
    return AdminGameSummary(
      dateId: json['dateId'] as String? ?? '',
      todayWord: json['todayWord'] as String? ?? '',
      exists: json['exists'] as bool? ?? false,
    );
  }
}
