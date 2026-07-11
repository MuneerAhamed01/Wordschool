import 'package:cloud_functions/cloud_functions.dart';
import 'package:wordshool/features/admin/data/admin_environment_store.dart';
import 'package:wordshool/features/admin/domain/models/admin_case_summary.dart';
import 'package:wordshool/features/admin/domain/models/admin_game_summary.dart';
import 'package:wordshool/features/admin/domain/models/admin_metrics.dart';
import 'package:wordshool/features/admin/domain/models/admin_user_summary.dart';

class AdminApiService {
  AdminApiService({
    required FirebaseFunctions functions,
    required AdminEnvironmentStore environmentStore,
  })  : _functions = functions,
        _environmentStore = environmentStore;

  final FirebaseFunctions _functions;
  final AdminEnvironmentStore _environmentStore;

  String get _databaseId => _environmentStore.current.databaseId;

  Future<Map<String, dynamic>> _call(
    String name,
    Map<String, dynamic> data,
  ) async {
    final callable = _functions.httpsCallable(name);
    final result = await callable.call<Map<String, dynamic>>({
      ...data,
      'databaseId': _databaseId,
    });
    return Map<String, dynamic>.from(result.data as Map);
  }

  Future<AdminMetrics> getOperationalMetrics({int days = 7}) async {
    final data = await _call('adminGetOperationalMetrics', {'days': days});
    return AdminMetrics.fromJson(data);
  }

  Future<Ga4Metrics> getGa4Metrics({int days = 7}) async {
    final callable = _functions.httpsCallable('adminGetGa4Metrics');
    final result = await callable.call<Map<String, dynamic>>({'days': days});
    return Ga4Metrics.fromJson(Map<String, dynamic>.from(result.data as Map));
  }

  Future<List<AdminGameSummary>> listGames({
    required String startDateId,
    required String endDateId,
  }) async {
    final data = await _call('adminListGames', {
      'startDateId': startDateId,
      'endDateId': endDateId,
    });
    final games = (data['games'] as List<dynamic>? ?? [])
        .map((e) => AdminGameSummary.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    return games;
  }

  Future<String> seedDailyGame({
    required String dateId,
    String? todayWord,
    bool force = false,
  }) async {
    final data = await _call('adminSeedDailyGame', {
      'dateId': dateId,
      if (todayWord != null) 'todayWord': todayWord,
      'force': force,
    });
    return data['todayWord'] as String? ?? '';
  }

  Future<Map<String, dynamic>> seedMissingGames({
    required String startDateId,
    required String endDateId,
  }) async {
    return _call('adminSeedMissingGames', {
      'startDateId': startDateId,
      'endDateId': endDateId,
    });
  }

  Future<void> deleteGame(String dateId) async {
    await _call('adminDeleteGame', {'dateId': dateId});
  }

  Future<List<AdminCaseSummary>> listCases({
    required String startDateId,
    required String endDateId,
  }) async {
    final data = await _call('adminListCases', {
      'startDateId': startDateId,
      'endDateId': endDateId,
    });
    return (data['cases'] as List<dynamic>? ?? [])
        .map((e) => AdminCaseSummary.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<Map<String, dynamic>> seedDetectiveCase({
    required String dateId,
    required String source,
    bool force = false,
  }) async {
    return _call('adminSeedDetectiveCase', {
      'dateId': dateId,
      'source': source,
      'force': force,
    });
  }

  Future<Map<String, dynamic>> bulkSeedPlannedCases({
    String? startDateId,
    String? endDateId,
    bool force = false,
  }) async {
    return _call('adminBulkSeedPlannedCases', {
      if (startDateId != null) 'startDateId': startDateId,
      if (endDateId != null) 'endDateId': endDateId,
      'force': force,
    });
  }

  Future<Map<String, dynamic>> getCasePreview(String dateId) async {
    return _call('adminGetCasePreview', {'dateId': dateId});
  }

  Future<AdminUserSummary> searchUsers(String query) async {
    final data = await _call('adminSearchUsers', {'query': query});
    return AdminUserSummary.fromJson(data);
  }

  Future<void> blockUser({
    required String uid,
    String? reason,
    bool disableAuth = false,
  }) async {
    await _call('adminBlockUser', {
      'uid': uid,
      if (reason != null) 'reason': reason,
      'disableAuth': disableAuth,
    });
  }

  Future<void> unblockUser({
    required String uid,
    bool enableAuth = true,
  }) async {
    await _call('adminUnblockUser', {
      'uid': uid,
      'enableAuth': enableAuth,
    });
  }
}
