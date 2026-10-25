import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wordshool/core/firebase/collections.dart';
import 'package:wordshool/core/resorces/data_guard.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/crossword/home/data/data_source/home_service.dart';
import 'package:wordshool/features/crossword/home/data/models/daily.dart';
import 'package:wordshool/features/crossword/home/data/models/player_profile.dart';
import 'package:wordshool/features/crossword/shared/data/models/category.dart';

class HomeDataSourceImpl extends HomeDataSource {
  HomeDataSourceImpl({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  DocumentReference<Map<String, dynamic>> get _user {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw const NotSignedInException();
    return _firestore.collection(FirebaseCollections.users).doc(uid);
  }

  @override
  Future<DataState<CrosswordDailyModel?>> getDaily(String dateId) {
    return guardData('Home.getDaily', () async {
      final snap = await _firestore
          .collection(FirebaseCollections.crosswordDaily)
          .doc(dateId)
          .get();
      final data = snap.data();
      return data == null
          ? null
          : CrosswordDailyModel.fromJson(data, documentId: snap.id);
    });
  }

  @override
  Future<DataState<List<CrosswordCategoryModel>>> getCategories() {
    return guardData('Home.getCategories', () async {
      // Sorted here: a handful of docs, and no composite index needed.
      final snap = await _firestore
          .collection(FirebaseCollections.crosswordCategories)
          .where('isActive', isEqualTo: true)
          .get();
      return [
        for (final doc in snap.docs)
          CrosswordCategoryModel.fromJson(doc.data(), documentId: doc.id),
      ]..sort((a, b) => a.order.compareTo(b.order));
    });
  }

  @override
  Future<DataState<PlayerProfileModel?>> getProfile() {
    return guardData('Home.getProfile', () async {
      final snap = await _user.get();
      final data = snap.data();
      return data == null
          ? null
          : PlayerProfileModel.fromJson(data, documentId: snap.id);
    });
  }

  @override
  Future<DataState<int>> countRevisionItems() {
    return guardData('Home.countRevisionItems', () async {
      final snap = await _user
          .collection(FirebaseCollections.revisionItems)
          .where('mastered', isEqualTo: false)
          .count()
          .get();
      return snap.count ?? 0;
    });
  }
}
