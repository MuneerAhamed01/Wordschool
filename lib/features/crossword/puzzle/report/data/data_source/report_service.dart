import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/crossword/puzzle/report/domain/entities/content_report.dart';

/// "Report a wrong answer" (`contentReports`, create only).
abstract class ReportDataSource {
  Future<DataState<void>> report(ContentReportEntity report);
}
