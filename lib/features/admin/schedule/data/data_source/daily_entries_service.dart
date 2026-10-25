import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wordshool/core/firebase/collections.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/admin/schedule/domain/models/daily_entry.dart';

/// Reads `crosswordDaily` docs straight from Firestore (players may read
/// them, so no callable is needed).
class DailyEntriesService {
  DailyEntriesService(this._firestore);

  final FirebaseFirestore _firestore;

  /// The `crosswordDaily` docs for [dateIds] (one read each; missing days are
  /// left out). Players may read these docs, so no callable is needed.
  Future<DataState<Map<String, CrosswordDailyEntry>>> getDailyEntries(
    List<String> dateIds,
  ) async {
    try {
      final collection =
          _firestore.collection(FirebaseCollections.crosswordDaily);
      final snapshots =
          await Future.wait(dateIds.map((id) => collection.doc(id).get()));
      return DataSuccess(data: {
        for (final snapshot in snapshots)
          if (snapshot.exists)
            snapshot.id: CrosswordDailyEntry.fromJson(
              snapshot.data()!,
              documentId: snapshot.id,
            ),
      });
    } on FirebaseException catch (e) {
      return DataError(
        error: AppError(
          error: e,
          code: e.code,
          message: 'Could not load the daily schedule: ${e.message ?? e.code}',
        ),
      );
    }
  }
}
