import 'package:wordshool/features/crossword/shared/domain/entities/change.dart';

/// In-app signal between crossword modules (no Firestore involved).
abstract class CrosswordChangesRepository {
  Stream<CrosswordChange> get changes;

  void notify(CrosswordChange change);
}
