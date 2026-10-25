import 'package:wordshool/features/admin/domain/models/json_read.dart';

/// One page of a list callable; [nextStartAfterId] is null on the last page.
class PagedResult<T> {
  const PagedResult({required this.items, this.nextStartAfterId});

  final List<T> items;
  final String? nextStartAfterId;

  bool get hasMore => nextStartAfterId != null;
}

/// What a save callable returns: the document id and whether it was new.
class SaveResult {
  const SaveResult({required this.id, required this.created, this.number});

  final String id;
  final bool created;

  /// Puzzle number (puzzles only).
  final int? number;

  factory SaveResult.fromJson(Map<String, dynamic> json) => SaveResult(
        id: json['id'] as String? ?? '',
        created: json['created'] as bool? ?? false,
        number: json['number'] == null ? null : readInt(json['number']),
      );
}
