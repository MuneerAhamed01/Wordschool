import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wordshool/core/firebase/collections.dart';
import 'package:wordshool/core/firebase/server_ack.dart';
import 'package:wordshool/core/resorces/data_guard.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/crossword/revise/data/data_source/revise_service.dart';
import 'package:wordshool/features/crossword/revise/data/models/revision_item.dart';
import 'package:wordshool/features/crossword/revise/domain/entities/revision_item.dart';

class ReviseDataSourceImpl extends ReviseDataSource {
  ReviseDataSourceImpl({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _revision {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw const NotSignedInException();
    return _firestore
        .collection(FirebaseCollections.users)
        .doc(uid)
        .collection(FirebaseCollections.revisionItems);
  }

  @override
  Future<DataState<List<RevisionItemModel>>> getRevisionItems({
    RevisionItemEntity? after,
    required int limit,
  }) {
    return guardData('Revise.getRevisionItems', () async {
      // One submit stamps every mistake with the same `lastWrongAt`, so the
      // id breaks ties; the (mastered, lastWrongAt desc) index covers it.
      Query<Map<String, dynamic>> query = _revision
          .where('mastered', isEqualTo: false)
          .orderBy('lastWrongAt', descending: true)
          .orderBy(FieldPath.documentId, descending: true)
          .limit(limit);
      final lastWrongAt = after?.lastWrongAt;
      if (after != null && lastWrongAt == null) return <RevisionItemModel>[];
      if (after != null) {
        query = query
            .startAfter([Timestamp.fromDate(lastWrongAt!), after.questionId]);
      }
      final snap = await query.get();
      return [
        for (final doc in snap.docs)
          RevisionItemModel.fromJson(doc.data(), documentId: doc.id),
      ];
    });
  }

  @override
  Future<DataState<void>> setRevisionMastered(
      String questionId, bool mastered) {
    return guardData('Revise.setRevisionMastered', () async {
      final write = _revision.doc(questionId).update({
        'mastered': mastered,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      await awaitServerAck(write, 'Revise.setRevisionMastered $questionId');
    });
  }
}
