import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:wordshool/core/firebase/collections.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/admin/domain/models/admin_category.dart';
import 'package:wordshool/features/admin/domain/models/admin_enums.dart';
import 'package:wordshool/features/admin/domain/models/admin_puzzle.dart';
import 'package:wordshool/features/admin/domain/models/admin_question.dart';
import 'package:wordshool/features/admin/domain/models/admin_report.dart';
import 'package:wordshool/features/admin/domain/models/admin_results.dart';
import 'package:wordshool/features/admin/domain/models/crossword_daily.dart';
import 'package:wordshool/features/admin/domain/models/json_read.dart';

/// Calls the admin Cloud Functions (`functions/crossword/`). Every method
/// returns a [DataState]; a failed call carries the server's message, which
/// lists every problem separated by "; ".
class AdminApiService {
  AdminApiService({
    required FirebaseFunctions functions,
    required FirebaseFirestore firestore,
  })  : _functions = functions,
        _firestore = firestore;

  final FirebaseFunctions _functions;
  final FirebaseFirestore _firestore;

  /// Confirms the server accepts this account as an admin.
  Future<DataState<void>> checkAccess() async {
    final result = await _call('adminListCategories');
    return _map(result, (_) {});
  }

  // ---------- Categories ----------

  Future<DataState<List<AdminCategory>>> listCategories() async {
    final result = await _call('adminListCategories');
    return _map(
      result,
      (json) =>
          readMaps(json['categories']).map(AdminCategory.fromJson).toList(),
    );
  }

  Future<DataState<SaveResult>> saveCategory(AdminCategory category) async {
    final result = await _call('adminSaveCategory', category.toJson());
    return _map(result, SaveResult.fromJson);
  }

  // ---------- Questions ----------

  Future<DataState<PagedResult<AdminQuestion>>> listQuestions({
    String? subject,
    QuestionStatus? status,
    String? startAfterId,
    int limit = 20,
  }) async {
    final result = await _call('adminListQuestions', {
      if (subject != null && subject.isNotEmpty) 'subject': subject,
      if (status != null) 'status': status.value,
      if (startAfterId != null) 'startAfterId': startAfterId,
      'limit': limit,
    });
    return _map(
      result,
      (json) => PagedResult(
        items: readMaps(json['questions']).map(AdminQuestion.fromJson).toList(),
        nextStartAfterId: json['nextStartAfterId'] as String?,
      ),
    );
  }

  /// Every question matching the filters, page by page (100 per call).
  /// For import matching and the puzzle builder's question picker.
  Future<DataState<List<AdminQuestion>>> listAllQuestions({
    String? subject,
    QuestionStatus? status,
  }) async {
    final all = <AdminQuestion>[];
    String? cursor;
    do {
      final page = await listQuestions(
        subject: subject,
        status: status,
        startAfterId: cursor,
        limit: 100,
      );
      if (page is! DataSuccess) return DataError(error: page.error);
      all.addAll(page.data!.items);
      cursor = page.data!.nextStartAfterId;
    } while (cursor != null);
    return DataSuccess(data: all);
  }

  /// Creates (no id) or updates a question. Any edit sets it back to draft.
  Future<DataState<SaveResult>> saveQuestion(AdminQuestion question) async {
    final result = await _call('adminSaveQuestion', question.toJson());
    return _map(result, SaveResult.fromJson);
  }

  Future<DataState<AdminQuestion>> getQuestion(String id) async {
    final result = await _call('adminGetQuestion', {'id': id});
    return _map(
      result,
      (json) => AdminQuestion.fromJson(readMap(json['question'])),
    );
  }

  Future<DataState<void>> verifyQuestion(String id) async {
    final result = await _call('adminVerifyQuestion', {'id': id});
    return _map(result, (_) {});
  }

  // ---------- Puzzles ----------

  Future<DataState<PagedResult<AdminPuzzleSummary>>> listPuzzles({
    required String categoryId,
    PuzzleStatus? status,
    String? startAfterId,
    int limit = 20,
  }) async {
    final result = await _call('adminListPuzzles', {
      'categoryId': categoryId,
      if (status != null) 'status': status.value,
      if (startAfterId != null) 'startAfterId': startAfterId,
      'limit': limit,
    });
    return _map(
      result,
      (json) => PagedResult(
        items:
            readMaps(json['puzzles']).map(AdminPuzzleSummary.fromJson).toList(),
        nextStartAfterId: json['nextStartAfterId'] as String?,
      ),
    );
  }

  /// The puzzle with plain answers, for editing and preview.
  Future<DataState<AdminPuzzle>> getPuzzle(String puzzleId) async {
    final result = await _call('adminGetPuzzle', {'puzzleId': puzzleId});
    return _map(
        result, (json) => AdminPuzzle.fromJson(readMap(json['puzzle'])));
  }

  /// Creates (no id) or re-saves a draft / in-review puzzle; it becomes a draft.
  Future<DataState<SaveResult>> savePuzzle(AdminPuzzle puzzle) async {
    final result = await _call('adminSaveCrosswordPuzzle', puzzle.toJson());
    return _map(result, SaveResult.fromJson);
  }

  /// Moves a puzzle along draft → in_review → scheduled → published → archived.
  /// [publishAt] is required for `scheduled`.
  Future<DataState<void>> setPuzzleStatus({
    required String puzzleId,
    required PuzzleStatus status,
    DateTime? publishAt,
  }) async {
    final result = await _call('adminSetPuzzleStatus', {
      'puzzleId': puzzleId,
      'status': status.value,
      if (publishAt != null) 'publishAt': publishAt.toUtc().toIso8601String(),
    });
    return _map(result, (_) {});
  }

  // ---------- Daily schedule ----------

  Future<DataState<void>> scheduleDaily({
    required String dateId,
    required String puzzleId,
  }) async {
    final result = await _call('adminScheduleDaily', {
      'dateId': dateId,
      'puzzleId': puzzleId,
    });
    return _map(result, (_) {});
  }

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

  // ---------- Reports ----------

  Future<DataState<PagedResult<AdminReport>>> listReports({
    ReportStatus status = ReportStatus.open,
    String? startAfterId,
    int limit = 20,
  }) async {
    final result = await _call('adminListReports', {
      'status': status.value,
      if (startAfterId != null) 'startAfterId': startAfterId,
      'limit': limit,
    });
    return _map(
      result,
      (json) => PagedResult(
        items: readMaps(json['reports']).map(AdminReport.fromJson).toList(),
        nextStartAfterId: json['nextStartAfterId'] as String?,
      ),
    );
  }

  Future<DataState<void>> resolveReport({
    required String reportId,
    required ReportStatus status,
    String? note,
  }) async {
    final result = await _call('adminResolveReport', {
      'reportId': reportId,
      'status': status.value,
      if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
    });
    return _map(result, (_) {});
  }

  // ---------- Plumbing ----------

  DataState<T> _map<T>(
    DataState<Map<String, dynamic>> result,
    T Function(Map<String, dynamic> json) convert,
  ) {
    if (result is! DataSuccess) return DataError(error: result.error);
    try {
      return DataSuccess(data: convert(result.data!));
    } catch (e) {
      return DataError(
        error: AppError(
          error: e,
          code: 'bad-response',
          message: 'The server sent something unexpected: $e',
        ),
      );
    }
  }

  Future<DataState<Map<String, dynamic>>> _call(
    String name, [
    Map<String, dynamic> data = const {},
  ]) async {
    try {
      final result = await _functions.httpsCallable(name).call<dynamic>(data);
      return DataSuccess(data: readMap(result.data));
    } on FirebaseFunctionsException catch (e) {
      return DataError(
        error: AppError(error: e, code: e.code, message: _friendlyMessage(e)),
      );
    } catch (e) {
      return DataError(
        error: AppError(error: e, code: 'unknown', message: '$name failed: $e'),
      );
    }
  }

  static String _friendlyMessage(FirebaseFunctionsException e) {
    switch (e.code) {
      case 'unauthenticated':
        return 'Your session has expired. Please sign in again.';
      case 'permission-denied':
        return e.message ?? 'This account is not allowed to do that.';
      case 'unavailable':
      case 'deadline-exceeded':
        return 'Could not reach the server. Check your internet and try again.';
      default:
        return e.message ?? 'Something went wrong (${e.code}).';
    }
  }
}
