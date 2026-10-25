import 'dart:async';

import 'package:wordshool/features/crossword/shared/domain/entities/change.dart';
import 'package:wordshool/features/crossword/shared/domain/repositories/changes_repository.dart';

class CrosswordChangesRepositoryImpl implements CrosswordChangesRepository {
  final _controller = StreamController<CrosswordChange>.broadcast();

  @override
  Stream<CrosswordChange> get changes => _controller.stream;

  @override
  void notify(CrosswordChange change) => _controller.add(change);
}
