import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/admin/shared/data/data_source/callable.dart';
import 'package:wordshool/features/admin/shared/domain/models/enums.dart';
import 'package:wordshool/features/admin/shared/domain/models/results.dart';
import 'package:wordshool/features/admin/reports/domain/models/report.dart';
import 'package:wordshool/core/utils/json_read.dart';

/// Player reports: list and resolve.
class AdminReportsService {
  AdminReportsService(this._callable);

  final AdminCallable _callable;

  Future<DataState<PagedResult<AdminReport>>> listReports({
    ReportStatus status = ReportStatus.open,
    String? startAfterId,
    int limit = 20,
  }) async {
    final result = await _callable.call('adminListReports', {
      'status': status.value,
      if (startAfterId != null) 'startAfterId': startAfterId,
      'limit': limit,
    });
    return AdminCallable.convert(
      result,
      (json) => PagedResult(
        items: asMapList(json['reports']).map(AdminReport.fromJson).toList(),
        nextStartAfterId: json['nextStartAfterId'] as String?,
      ),
    );
  }

  Future<DataState<void>> resolveReport({
    required String reportId,
    required ReportStatus status,
    String? note,
  }) async {
    final result = await _callable.call('adminResolveReport', {
      'reportId': reportId,
      'status': status.value,
      if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
    });
    return AdminCallable.convert(result, (_) {});
  }
}
