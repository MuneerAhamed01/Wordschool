import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wordshool/core/firebase/collections.dart';
import 'package:wordshool/core/resorces/data_guard.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/crossword/leaderboard/data/data_source/leaderboard_service.dart';
import 'package:wordshool/features/crossword/leaderboard/data/models/leaderboard.dart';

class LeaderboardDataSourceImpl extends LeaderboardDataSource {
  LeaderboardDataSourceImpl({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  @override
  Future<DataState<LeaderboardModel>> getLeaderboard(String boardId) {
    return guardData('Leaderboard.getLeaderboard', () async {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw const NotSignedInException();
      final board =
          _firestore.collection(FirebaseCollections.leaderboards).doc(boardId);
      final entries = board.collection(FirebaseCollections.leaderboardEntries);
      final results = await Future.wait([board.get(), entries.doc(uid).get()]);
      final meData = results[1].data();
      final me = meData == null
          ? null
          : LeaderboardEntryModel.fromJson(meData, documentId: uid);
      final myRank = me == null ? null : await _rankOf(entries, me.points);
      return LeaderboardModel.fromJson(results[0].data() ?? const {},
          documentId: boardId, me: me, myRank: myRank);
    });
  }

  /// Players with more points + 1 (one aggregation read).
  Future<int> _rankOf(
    CollectionReference<Map<String, dynamic>> entries,
    int points,
  ) async {
    final above =
        await entries.where('points', isGreaterThan: points).count().get();
    return (above.count ?? 0) + 1;
  }
}
