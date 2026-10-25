import 'package:wordshool/features/crossword/revise/domain/entities/revision_item.dart';

class LoadRevisionItemsParam {
  const LoadRevisionItemsParam({this.after});

  /// The last item shown (null = first page).
  final RevisionItemEntity? after;
}
