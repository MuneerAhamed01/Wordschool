import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/admin/shared/data/data_source/callable.dart';
import 'package:wordshool/features/admin/shared/domain/models/enums.dart';
import 'package:wordshool/features/admin/shared/domain/models/question.dart';
import 'package:wordshool/features/admin/shared/domain/models/results.dart';
import 'package:wordshool/core/utils/json_read.dart';

/// Question bank callables (questions, puzzle builder, bulk upload, reports).
class AdminQuestionsService {
  AdminQuestionsService(this._callable);

  final AdminCallable _callable;

  Future<DataState<PagedResult<AdminQuestion>>> listQuestions({
    String? subject,
    QuestionStatus? status,
    String? startAfterId,
    int limit = 20,
  }) async {
    final result = await _callable.call('adminListQuestions', {
      if (subject != null && subject.isNotEmpty) 'subject': subject,
      if (status != null) 'status': status.value,
      if (startAfterId != null) 'startAfterId': startAfterId,
      'limit': limit,
    });
    return AdminCallable.convert(
      result,
      (json) => PagedResult(
        items:
            asMapList(json['questions']).map(AdminQuestion.fromJson).toList(),
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
    final result = await _callable.call('adminSaveQuestion', question.toJson());
    return AdminCallable.convert(result, SaveResult.fromJson);
  }

  Future<DataState<AdminQuestion>> getQuestion(String id) async {
    final result = await _callable.call('adminGetQuestion', {'id': id});
    return AdminCallable.convert(
      result,
      (json) => AdminQuestion.fromJson(asMap(json['question'])),
    );
  }

  Future<DataState<void>> verifyQuestion(String id) async {
    final result = await _callable.call('adminVerifyQuestion', {'id': id});
    return AdminCallable.convert(result, (_) {});
  }
}
