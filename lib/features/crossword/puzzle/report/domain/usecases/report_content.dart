import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/core/resorces/usecase.dart';
import 'package:wordshool/features/crossword/puzzle/report/domain/entities/content_report.dart';
import 'package:wordshool/features/crossword/puzzle/report/domain/repositories/report_repository.dart';

class ReportContentUseCase
    extends UseCase<DataState<void>, ContentReportEntity> {
  ReportContentUseCase({required ReportRepository repository})
      : _repository = repository;

  final ReportRepository _repository;

  @override
  Future<DataState<void>> call({required ContentReportEntity param}) =>
      _repository.reportContent(param);
}
