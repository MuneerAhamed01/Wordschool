import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseDTConverter {
  static DateTime fromTimestamp(Timestamp timestamp) {
    return timestamp.toDate();
  }

  static Timestamp toTimestamp(DateTime dateTime) {
    return Timestamp.fromDate(dateTime);
  }

  /// A Firestore `Timestamp`, a `DateTime`, an ISO string (JSON fixtures) or
  /// epoch milliseconds; null for anything else (e.g. a pending server time).
  static DateTime? tryParse(Object? value) => switch (value) {
        Timestamp t => t.toDate(),
        DateTime d => d,
        String s => DateTime.tryParse(s),
        int ms => DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true),
        _ => null,
      };
}
