import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wordshool/core/firebase/collections.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/leaderboard/data/data_source/detective_leaderboard_service.dart';
import 'package:wordshool/features/leaderboard/domain/entities/detective_leaderboard_entry.dart';

class DetectiveLeaderboardDataSourceImpl implements DetectiveLeaderboardDataSource {
  DetectiveLeaderboardDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _entriesCollection(String weekId) {
    return _firestore
        .collection(FirebaseCollections.detectiveLeaderboard)
        .doc(weekId)
        .collection(FirebaseCollections.leaderboardEntries);
  }

  @override
  Future<DataState<DetectiveLeaderboardSnapshot>> loadWeeklyLeaderboard({
    required String weekId,
    required String? currentUserId,
    int topLimit = 50,
  }) async {
    try {
      final topSnapshot = await _entriesCollection(weekId)
          .orderBy('totalPoints', descending: true)
          .limit(topLimit)
          .get();

      final topEntries = topSnapshot.docs
          .map((doc) => _entryFromDoc(doc.id, doc.data()))
          .toList();

      DetectiveLeaderboardEntry? currentUserEntry;
      int? currentUserRank;

      if (currentUserId != null) {
        final userDoc =
            await _entriesCollection(weekId).doc(currentUserId).get();
        if (userDoc.exists) {
          currentUserEntry =
              _entryFromDoc(userDoc.id, userDoc.data()!);

          final higherCount = await _entriesCollection(weekId)
              .where('totalPoints',
                  isGreaterThan: currentUserEntry.totalPoints)
              .count()
              .get();
          currentUserRank = higherCount.count! + 1;
        }
      }

      return DataSuccess(
        data: DetectiveLeaderboardSnapshot(
          weekId: weekId,
          topEntries: topEntries,
          currentUserEntry: currentUserEntry,
          currentUserRank: currentUserRank,
        ),
      );
    } catch (error) {
      return DataError(
        error: AppError.fromException(error),
      );
    }
  }

  DetectiveLeaderboardEntry _entryFromDoc(
    String userId,
    Map<String, dynamic> data,
  ) {
    return DetectiveLeaderboardEntry(
      userId: userId,
      displayName: (data['displayName'] as String?) ?? 'Detective',
      totalPoints: (data['totalPoints'] as num?)?.toInt() ?? 0,
      casesCompleted: (data['casesCompleted'] as num?)?.toInt() ?? 0,
    );
  }
}
