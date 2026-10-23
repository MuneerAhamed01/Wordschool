import 'package:equatable/equatable.dart';
import 'package:wordshool/features/admin/domain/models/admin_enums.dart';
import 'package:wordshool/features/admin/domain/models/json_read.dart';

/// `contentReports/{id}` — a problem a player reported on a crossword word.
class AdminReport extends Equatable {
  const AdminReport({
    required this.id,
    required this.uid,
    required this.puzzleId,
    required this.wordId,
    required this.questionId,
    required this.reason,
    required this.message,
    required this.status,
    this.createdAt,
    this.resolvedBy,
    this.resolvedAt,
    this.resolutionNote,
  });

  final String id;
  final String uid;
  final String puzzleId;
  final String wordId;
  final String questionId;
  final ReportReason reason;
  final String message;
  final ReportStatus status;
  final DateTime? createdAt;
  final String? resolvedBy;
  final DateTime? resolvedAt;
  final String? resolutionNote;

  factory AdminReport.fromJson(Map<String, dynamic> json,
      {String? documentId}) {
    return AdminReport(
      id: documentId ?? json['id'] as String? ?? '',
      uid: json['uid'] as String? ?? '',
      puzzleId: json['puzzleId'] as String? ?? '',
      wordId: json['wordId'] as String? ?? '',
      questionId: json['questionId'] as String? ?? '',
      reason: ReportReason.fromValue(json['reason']),
      message: json['message'] as String? ?? '',
      status: ReportStatus.fromValue(json['status']),
      createdAt: readDate(json['createdAt']),
      resolvedBy: json['resolvedBy'] as String?,
      resolvedAt: readDate(json['resolvedAt']),
      resolutionNote: json['resolutionNote'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        uid,
        puzzleId,
        wordId,
        questionId,
        reason,
        message,
        status,
        createdAt,
        resolvedBy,
        resolvedAt,
        resolutionNote,
      ];
}
