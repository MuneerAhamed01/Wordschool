import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/crossword/puzzle/report/domain/entities/content_report.dart';

abstract class ReportRepository {
  Future<DataState<void>> reportContent(ContentReportEntity report);
}
