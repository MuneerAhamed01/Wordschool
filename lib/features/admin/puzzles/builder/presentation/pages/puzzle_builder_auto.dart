part of 'puzzle_builder_page.dart';

/// "Auto-create puzzle" (CW-038): fills the grid from the category's checked
/// questions. The result is an unsaved draft the admin checks and saves.
extension _BuilderAuto on _AdminPuzzleBuilderPageState {
  /// Checked questions of the chosen category, in a fixed order so the same
  /// seed always gives the same grid.
  List<AdminQuestion> get _autoPool {
    final subject = _category?.subject;
    return _verified.values.where((q) => q.subject == subject).toList()
      ..sort((a, b) => a.id!.compareTo(b.id!));
  }

  void _autoFill(AutoPuzzleOptions options) {
    final pool = _autoPool;
    final result = autoPuzzle(pool, options);
    _update(() {
      _autoOptions = options;
      _autoResult = result;
      _autoChecked = pool.length;
      _autoFits = autoPuzzleCandidates(pool, options).length;
    });
    if (result == null) return;
    final name = _category?.name.en;
    if (_titleEn.text.trim().isEmpty && name != null) {
      _titleEn.text = '$name mix';
    }
    _difficulty = _mostCommonDifficulty(result.used);
    _minutes.text = '${max(3, result.used.length)}';
    _placing = null;
    _change(result.draft);
  }

  void _autoTryAnother() {
    final options = _autoOptions;
    if (options != null) _autoFill(options.copyWith(seed: options.seed + 1));
  }

  Future<void> _autoChangeOptions() async {
    final options = _autoOptions;
    if (options == null) return;
    final next = await AutoPuzzleOptionsDialog.show(context, options);
    if (next != null && mounted) _autoFill(next);
  }

  Widget _buildAutoCard() {
    final options = _autoOptions!;
    return AutoPuzzleCard(
      result: _autoResult,
      categoryName: _category?.name.en ?? 'this category',
      checkedCount: _autoChecked,
      fitCount: _autoFits,
      size: options.size,
      onTryAnother: _autoTryAnother,
      onOptions: _autoChangeOptions,
      onOpenQuestions: () =>
          context.go(AdminRoutes.questionsOf(subject: _category?.subject)),
    );
  }
}

/// Most common difficulty of [questions] (ties go to the easier one).
Difficulty _mostCommonDifficulty(List<AdminQuestion> questions) {
  final counts = {for (final d in Difficulty.values) d: 0};
  for (final q in questions) {
    counts[q.difficulty] = counts[q.difficulty]! + 1;
  }
  return Difficulty.values
      .reduce((best, d) => counts[d]! > counts[best]! ? d : best);
}
