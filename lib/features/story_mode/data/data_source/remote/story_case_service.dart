import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wordshool/core/firebase/collections.dart';
import 'package:wordshool/core/logging/app_logger.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/core/utils/date_helper.dart';
import 'package:wordshool/features/story_mode/data/data_source/story_case_service.dart';
import 'package:wordshool/features/story_mode/data/models/detective_case.dart';
import 'package:wordshool/features/story_mode/data/models/story_mode_progress.dart';

class StoryCaseDataSourceImpl extends StoryCaseDataSource {
  StoryCaseDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  @override
  Future<DataState<DetectiveCaseModel>> getTodayCase() {
    return getCaseByDate(DateHelper.todayUtcDateId());
  }

  @override
  Future<DataState<DetectiveCaseModel>> getCaseByDate(String dateId) async {
    try {
      if (!DateHelper.isValidDateId(dateId)) {
        return DataError<DetectiveCaseModel>(
          error: AppError.validation(
            message: 'Invalid case date',
            error: 'Invalid date format',
          ),
        );
      }

      if (DateHelper.isFutureUtcDateId(dateId)) {
        return DataError<DetectiveCaseModel>(
          error: AppError.validation(
            message: 'Invalid case date',
            error: 'Future case date',
          ),
        );
      }

      final response = await _firestore
          .collection(FirebaseCollections.detectiveCases)
          .doc(dateId)
          .get();

      if (!response.exists) {
        return DataError<DetectiveCaseModel>(
          error: AppError.notFound(
            message: "Today's detective case isn't ready yet. Check back soon.",
            error: 'Case not found for $dateId',
          ),
        );
      }

      final caseDoc = response.data();
      if (caseDoc == null) {
        return DataError<DetectiveCaseModel>(
          error: AppError.notFound(
            message: "Today's detective case isn't ready yet. Check back soon.",
            error: 'Case data is empty',
          ),
        );
      }

      return DataSuccess<DetectiveCaseModel>(
        data: DetectiveCaseModel.fromJson(caseDoc, documentId: dateId),
      );
    } catch (error, stackTrace) {
      return DataError<DetectiveCaseModel>(
        error: AppError.fromException(error),
        stackTrace: stackTrace,
        context: 'StoryCaseDataSource.getCaseByDate',
      );
    }
  }

  @override
  Future<StoryModeProgressModel?> getTodayProgress(String userId) async {
    try {
      final dateId = DateHelper.todayUtcDateId();
      final response = await _firestore
          .collection(FirebaseCollections.userStoryProgress)
          .doc(userId)
          .collection(FirebaseCollections.storyCases)
          .doc(dateId)
          .get();

      if (!response.exists) {
        return null;
      }

      final progressDoc = response.data();
      if (progressDoc == null) {
        return null;
      }

      return StoryModeProgressModel.fromJson(
        progressDoc,
        userId: userId,
        caseId: dateId,
      );
    } catch (error, stackTrace) {
      AppLogger.instance.warning(
        'Failed to load story progress',
        tag: 'FIREBASE',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }
}
