import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wordshool/core/firebase/collections.dart';
import 'package:wordshool/core/firebase/server_ack.dart';
import 'package:wordshool/core/resorces/data_guard.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/crossword/puzzle/report/data/data_source/report_service.dart';
import 'package:wordshool/features/crossword/puzzle/report/domain/entities/content_report.dart';

class ReportDataSourceImpl extends ReportDataSource {
  ReportDataSourceImpl({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  @override
  Future<DataState<void>> report(ContentReportEntity report) {
    return guardData('Report.report', () async {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw const NotSignedInException();
      final write =
          _firestore.collection(FirebaseCollections.contentReports).add({
        'uid': uid,
        'puzzleId': report.puzzleId,
        'wordId': report.wordId,
        'questionId': report.questionId,
        'reason': report.reason.wire,
        'message': report.message.trim(),
        'status': 'open',
        'createdAt': FieldValue.serverTimestamp(),
      });
      await awaitServerAck(write, 'Report.report');
    });
  }
}
