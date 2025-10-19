import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseDTConverter {
  static DateTime fromTimestamp(Timestamp timestamp) {
    return timestamp.toDate();
  }

  static Timestamp toTimestamp(DateTime dateTime) {
    return Timestamp.fromDate(dateTime);
  }
}
