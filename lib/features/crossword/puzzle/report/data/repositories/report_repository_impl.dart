import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/crossword/puzzle/report/data/data_source/report_service.dart';
import 'package:wordshool/features/crossword/puzzle/report/domain/entities/content_report.dart';
import 'package:wordshool/features/crossword/puzzle/report/domain/repositories/report_repository.dart';

class ReportRepositoryImpl implements ReportRepository {
  ReportRepositoryImpl({required ReportDataSource source}) : _source = source;

  final ReportDataSource _source;

  @override
  Future<DataState<void>> reportContent(ContentReportEntity report) =>
      _source.report(report);
}
