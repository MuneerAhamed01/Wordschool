import 'package:flutter_test/flutter_test.dart';
import 'package:wordshool/features/admin/reports/domain/models/report.dart';
import 'package:wordshool/features/admin/shared/domain/models/enums.dart';

void main() {
  test('AdminReport.fromJson', () {
    final report = AdminReport.fromJson({
      'id': 'r1',
      'reason': 'wrong_answer',
      'status': 'open',
      'puzzleId': 'p',
      'wordId': '1A',
      'questionId': 'q',
      'message': 'm',
      'uid': 'u',
    });
    expect(report.reason, ReportReason.wrongAnswer);
    expect(report.status, ReportStatus.open);
  });
}
