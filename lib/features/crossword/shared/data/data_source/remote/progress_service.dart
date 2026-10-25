import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wordshool/core/firebase/collections.dart';
import 'package:wordshool/core/firebase/server_ack.dart';
import 'package:wordshool/core/resorces/data_guard.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/crossword/shared/data/data_source/progress_service.dart';
import 'package:wordshool/features/crossword/shared/data/models/progress.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/progress.dart';

class ProgressDataSourceImpl extends ProgressDataSource {
  ProgressDataSourceImpl({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _progress {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw const NotSignedInException();
    return _firestore
        .collection(FirebaseCollections.users)
        .doc(uid)
        .collection(FirebaseCollections.crosswordProgress);
  }

  @override
  Future<DataState<CrosswordProgressModel?>> getProgress(String puzzleId) {
    return guardData('Progress.get', () async {
      final snap = await _progress.doc(puzzleId).get();
      final data = snap.data();
      return data == null
          ? null
          : CrosswordProgressModel.fromJson(data, documentId: snap.id);
    });
  }

  @override
  Future<DataState<List<CrosswordProgressModel>>> getProgressFor(
      List<String> puzzleIds) {
    return guardData('Progress.getFor', () async {
      if (puzzleIds.isEmpty) return <CrosswordProgressModel>[];
      final snap =
          await _progress.where(FieldPath.documentId, whereIn: puzzleIds).get();
      return [
        for (final doc in snap.docs)
          CrosswordProgressModel.fromJson(doc.data(), documentId: doc.id),
      ];
    });
  }

  @override
  Future<DataState<int>> countCompleted(String categoryId) {
    return guardData('Progress.countCompleted', () async {
      // Puzzle ids are `{categoryId}-{0000}`, so the 4-digit range keeps
      // `kerala` from matching `kerala-history-0001`.
      final snap = await _progress
          .where('status', isEqualTo: CrosswordProgressStatus.completed.wire)
          .where(FieldPath.documentId,
              isGreaterThanOrEqualTo: '$categoryId-0000')
          .where(FieldPath.documentId, isLessThanOrEqualTo: '$categoryId-9999')
          .count()
          .get();
      return snap.count ?? 0;
    });
  }

  @override
  Future<DataState<void>> saveProgress(
    CrosswordProgressEntity progress, {
    required bool create,
  }) {
    return guardData('Progress.save', () async {
      final ref = _progress.doc(progress.puzzleId);
      final fields = CrosswordProgressModel.toJsonOf(progress);
      final now = FieldValue.serverTimestamp();
      final write = create
          ? ref.set({...fields, 'startedAt': now, 'updatedAt': now})
          // `status` can't change from the app; leave it out of the update.
          : ref.update({...fields..remove('status'), 'updatedAt': now});
      await awaitServerAck(write, 'Progress.save ${progress.puzzleId}');
      // CW-047: one line per write, to confirm saves stay ≤ 1 per 30 s.
      log('progress saved ${progress.puzzleId} (${create ? 'create' : 'update'})',
          name: 'CROSSWORD_AUTOSAVE');
    });
  }
}
