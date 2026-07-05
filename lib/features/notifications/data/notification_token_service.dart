import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wordshool/core/firebase/collections.dart';
import 'package:wordshool/features/notifications/domain/notification_preferences.dart';

class NotificationTokenService {
  NotificationTokenService({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection() {
    return _firestore.collection(FirebaseCollections.userGameStates);
  }

  Future<void> syncUserNotifications({
    required String userId,
    required String? fcmToken,
    required NotificationPreferences preferences,
    required String timezone,
  }) async {
    final docRef = _collection().doc(userId);
    final snapshot = await docRef.get();
    if (!snapshot.exists) {
      return;
    }

    final updates = <String, dynamic>{
      'timezone': timezone,
      'notifications': preferences.toFirestoreMap(),
      'updatedDate': FieldValue.serverTimestamp(),
    };

    if (fcmToken != null && fcmToken.isNotEmpty) {
      updates['fcmTokens'] = FieldValue.arrayUnion([fcmToken]);
    }

    await docRef.update(updates);
  }

  Future<void> removeToken({
    required String userId,
    required String fcmToken,
  }) async {
    final docRef = _collection().doc(userId);
    final snapshot = await docRef.get();
    if (!snapshot.exists) {
      return;
    }

    await docRef.update({
      'fcmTokens': FieldValue.arrayRemove([fcmToken]),
      'updatedDate': FieldValue.serverTimestamp(),
    });
  }
}
