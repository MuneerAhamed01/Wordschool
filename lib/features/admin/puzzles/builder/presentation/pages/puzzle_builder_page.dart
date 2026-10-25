import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wordshool/features/admin/shared/presentation/widgets/empty_state.dart';
import 'package:wordshool/features/admin/shared/presentation/widgets/loading_block.dart';
import 'package:wordshool/core/routes/admin_routes.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/di_admin.dart';
import 'package:wordshool/features/admin/shared/data/data_source/categories_service.dart';
import 'package:wordshool/features/admin/shared/data/data_source/puzzles_service.dart';
import 'package:wordshool/features/admin/shared/data/data_source/questions_service.dart';
import 'package:wordshool/features/admin/shared/domain/models/category.dart';
import 'package:wordshool/features/admin/shared/domain/models/enums.dart';
import 'package:wordshool/features/admin/shared/domain/models/puzzle.dart';
import 'package:wordshool/features/admin/shared/domain/models/question.dart';
import 'package:wordshool/features/admin/shared/domain/utils/grid_validator.dart';
import 'package:wordshool/features/admin/puzzles/domain/utils/auto_puzzle.dart';
import 'package:wordshool/features/admin/puzzles/domain/utils/puzzle_draft.dart';
import 'package:wordshool/features/admin/shared/domain/utils/question_text.dart';
import 'package:wordshool/features/admin/shared/presentation/widgets/feedback.dart';
import 'package:wordshool/features/admin/shared/presentation/widgets/page.dart';
import 'package:wordshool/features/admin/puzzles/presentation/widgets/crossword_grid.dart';
import 'package:wordshool/shared/domains/entities/localized_text.dart';

import 'package:wordshool/features/admin/puzzles/builder/presentation/widgets/selected_word_card.dart';
import 'package:wordshool/features/admin/puzzles/builder/presentation/widgets/problems_card.dart';
import 'package:wordshool/features/admin/puzzles/builder/presentation/widgets/builder_panel.dart';
import 'package:wordshool/features/admin/puzzles/builder/presentation/widgets/size_dropdown.dart';
import 'package:wordshool/features/admin/puzzles/builder/presentation/widgets/grid_legend.dart';
import 'package:wordshool/features/admin/puzzles/builder/presentation/widgets/auto_puzzle_card.dart';
import 'package:wordshool/features/admin/puzzles/builder/presentation/widgets/auto_puzzle_options_dialog.dart';

part 'puzzle_builder_auto.dart';
part 'puzzle_builder_cards.dart';

/// Builds or edits a crossword: pick checked questions, place them on the
/// grid (suggested spots cross existing words), fix anything shown in red,
/// then save. Black squares, numbers and word ids are worked out automatically.
/// With [autoOptions] a new puzzle starts pre-filled (unsaved) from the
/// category's checked questions.
class AdminPuzzleBuilderPage extends StatefulWidget {
  const AdminPuzzleBuilderPage(
      {super.key, this.puzzleId, this.initialCategoryId, this.autoOptions});

  /// Null for a new puzzle.
  final String? puzzleId;
  final String? initialCategoryId;

  /// Set for `/puzzles/new?auto=1` (CW-038).
  final AutoPuzzleOptions? autoOptions;

  @override
  State<AdminPuzzleBuilderPage> createState() => _AdminPuzzleBuilderPageState();
}

class _AdminPuzzleBuilderPageState extends State<AdminPuzzleBuilderPage> {
  final _categoryService = adminGetIt<AdminCategoriesService>();
  final _puzzleService = adminGetIt<AdminPuzzlesService>();
  final _questionService = adminGetIt<AdminQuestionsService>();

  // Loaded data.
  bool _loading = true;
  String? _loadError;
  List<AdminCategory> _categories = [];
  Map<String, AdminQuestion> _verified = {};
  AdminPuzzle? _existing;

  // Details.
  String? _categoryId;
  final _titleEn = TextEditingController();
  final _titleMl = TextEditingController();
  final _xp = TextEditingController(text: '50');
  final _minutes = TextEditingController(text: '6');
  Difficulty _difficulty = Difficulty.medium;

  // Grid.
  PuzzleDraft _draft = const PuzzleDraft(rows: 9, cols: 9);
  final List<PuzzleDraft> _history = [];
  int? _selected;
  AdminQuestion? _placing;
  WordDirection _placingDirection = WordDirection.across;

  // Question picker.
  final _search = TextEditingController();
  bool _onlyCategorySubject = true;

  bool _saving = false;
  bool _dirty = false;

  // Auto-create (puzzle_builder_auto.dart); null options = not used.
  AutoPuzzleOptions? _autoOptions;
  AutoPuzzleResult? _autoResult;
  int _autoChecked = 0;
  int _autoFits = 0;

  bool get _isNew => widget.puzzleId == null;

  AdminCategory? get _category {
    for (final c in _categories) {
      if (c.id == _categoryId) return c;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in [_titleEn, _titleMl, _xp, _minutes, _search]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    final results = await Future.wait([
      _categoryService.listCategories(),
      _questionService.listAllQuestions(status: QuestionStatus.verified),
      if (!_isNew) _puzzleService.getPuzzle(widget.puzzleId!),
    ]);
    if (!mounted) return;
    final failed = results.where((r) => r is! DataSuccess).toList();
    if (failed.isNotEmpty) {
      setState(() {
        _loading = false;
        _loadError = failed.first.error?.message;
      });
      return;
    }
    final categories = results[0].data as List<AdminCategory>;
    final questions = results[1].data as List<AdminQuestion>;
    final existing = _isNew ? null : results[2].data as AdminPuzzle;
    setState(() {
      _loading = false;
      _categories = categories;
      _verified = {for (final q in questions) q.id!: q};
      if (existing != null) {
        _existing = existing;
        _categoryId = existing.categoryId;
        _titleEn.text = existing.title.en;
        _titleMl.text = existing.title.ml ?? '';
        _xp.text = '${existing.xpReward}';
        _minutes.text = '${existing.estimatedMinutes}';
        _difficulty = existing.difficulty;
        _draft = PuzzleDraft.fromPuzzle(existing);
      } else {
        final wanted = widget.initialCategoryId;
        _categoryId = categories.any((c) => c.id == wanted)
            ? wanted
            : (categories.isEmpty ? null : categories.first.id);
      }
    });
    final auto = widget.autoOptions;
    if (_isNew && auto != null) _autoFill(auto);
  }

  // ---------- Editing ----------

  void _change(PuzzleDraft next, {int? select}) {
    setState(() {
      _history.add(_draft);
      if (_history.length > 50) _history.removeAt(0);
      _draft = next;
      _selected = select;
      _dirty = true;
    });
  }

  void _undo() {
    if (_history.isEmpty) return;
    setState(() {
      _draft = _history.removeLast();
      _selected = null;
    });
  }

  void _startPlacing(AdminQuestion question) {
    setState(() {
      _placing = question;
      _selected = null;
      final spots = _draft.suggestions(question.answer, limit: 1);
      if (spots.isNotEmpty) _placingDirection = spots.first.direction;
    });
  }

  void _place(int row, int col, WordDirection direction) {
    final question = _placing;
    if (question == null) return;
    final placement = placementFor(question, row, col, direction);
    _placing = null;
    _change(_draft.add(placement), select: _draft.placements.length);
  }

  void _onCellTap(Cell cell) {
    if (_placing != null) {
      _place(cell.$1, cell.$2, _placingDirection);
      return;
    }
    // Tapping the selected word's square again switches to the crossing word.
    final current = _selected == null ? null : _draft.placements[_selected!];
    final prefer = current != null && current.cells.contains(cell)
        ? (current.direction == WordDirection.across
            ? WordDirection.down
            : WordDirection.across)
        : null;
    setState(() => _selected = _draft.placementAt(cell, direction: prefer));
  }

  void _removeSelected() {
    final index = _selected;
    if (index == null) return;
    _change(_draft.removeAt(index));
  }

  void _updateSelected(Placement placement) {
    final index = _selected;
    if (index == null) return;
    setState(() {
      _draft = _draft.replaceAt(index, placement);
      _dirty = true;
    });
  }

  void _resize({int? rows, int? cols}) =>
      _change(_draft.copyWith(rows: rows, cols: cols), select: _selected);

  Future<void> _clear() async {
    final ok = await confirmAction(
      context,
      title: 'Clear the grid?',
      message: 'All words are removed from the grid. You can undo this.',
      confirmLabel: 'Clear grid',
      destructive: true,
    );
    if (ok) _change(_draft.copyWith(placements: const []));
  }

  // ---------- Checks and save ----------

  /// Problems outside the grid itself: details and question status.
  List<String> get _otherProblems {
    final problems = <String>[];
    if (_categoryId == null) problems.add('Choose a category.');
    if (_titleEn.text.trim().isEmpty) problems.add('Give the puzzle a title.');
    final xp = int.tryParse(_xp.text.trim());
    if (xp == null || xp < 1 || xp > 1000) {
      problems.add('XP reward must be a number from 1 to 1000.');
    }
    final minutes = int.tryParse(_minutes.text.trim());
    if (minutes == null || minutes < 1 || minutes > 120) {
      problems.add('Estimated time must be 1 to 120 minutes.');
    }
    for (final p in _draft.placements) {
      final question = _verified[p.questionId];
      if (question == null) {
        problems.add(
            '${p.answer}: its question isn\'t checked (or no longer exists). '
            'Check it in Questions, or remove the word.');
      } else if (question.answer != p.answer) {
        problems.add(
            '${p.answer}: the question\'s answer is now ${question.answer}. Remove the word and place it again.');
      }
      if (p.clue.isEmpty) problems.add('${p.answer}: write a clue.');
    }
    return problems;
  }

  AdminPuzzle _buildPuzzle() => AdminPuzzle(
        id: _existing?.id,
        categoryId: _categoryId!,
        title: LocalizedText(en: _titleEn.text, ml: _titleMl.text),
        difficulty: _difficulty,
        rows: _draft.rows,
        cols: _draft.cols,
        layout: _draft.layout,
        words: _draft.words,
        xpReward: int.parse(_xp.text.trim()),
        estimatedMinutes: int.parse(_minutes.text.trim()),
      );

  Future<void> _save() async {
    setState(() => _saving = true);
    final result = await _puzzleService.savePuzzle(_buildPuzzle());
    if (!mounted) return;
    setState(() => _saving = false);
    if (result is! DataSuccess) {
      showAdminError(context, result.error);
      return;
    }
    _dirty = false;
    final saved = result.data!;
    showSuccess(
      context,
      saved.created
          ? 'Puzzle #${saved.number} saved as a draft'
          : 'Puzzle saved — it is a draft again',
    );
    context.go(AdminRoutes.puzzleDetail(saved.id));
  }

  Future<void> _leave() async {
    if (_dirty) {
      final ok = await confirmAction(
        context,
        title: 'Leave without saving?',
        message: 'Your changes to this puzzle will be lost.',
        confirmLabel: 'Leave',
        destructive: true,
      );
      if (!ok || !mounted) return;
    }
    context.go(_isNew
        ? AdminRoutes.puzzlesOf(categoryId: _categoryId)
        : AdminRoutes.puzzleDetail(widget.puzzleId!));
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    final title =
        _isNew ? 'New puzzle' : 'Edit puzzle #${_existing?.number ?? ''}';
    if (_loading || _loadError != null) {
      return AdminPage(
        title: title,
        child: _loadError == null
            ? const LoadingBlock()
            : EmptyState(
                icon: Icons.cloud_off,
                title: 'Could not open the builder',
                message: _loadError,
                action: OutlinedButton(
                    onPressed: _load, child: const Text('Try again')),
              ),
      );
    }
    if (_existing != null && !_existing!.status.isEditable) {
      return AdminPage(
        title: title,
        child: EmptyState(
          icon: Icons.lock_outline,
          title:
              'This puzzle is ${_existing!.status.label.toLowerCase()} and can\'t be edited',
          message: 'Archive it and build a new puzzle instead.',
          action: OutlinedButton(onPressed: _leave, child: const Text('Back')),
        ),
      );
    }

    final gridProblems = _draft.problems;
    final otherProblems = _otherProblems;
    final allProblems = [
      ...otherProblems,
      ...gridProblems.map((p) => p.message)
    ];

    final wide = MediaQuery.sizeOf(context).width >= 1200;
    final left = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_autoOptions != null) ...[
          _buildAutoCard(),
          const SizedBox(height: 16),
        ],
        _buildGridCard(gridProblems),
        const SizedBox(height: 16),
        ProblemsCard(problems: allProblems),
        const SizedBox(height: 16),
        _buildDetailsCard(),
      ],
    );
    final right = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _placing == null ? _buildPickerCard() : _buildPlacingCard(),
        const SizedBox(height: 16),
        if (_selected != null && _selected! < _draft.placements.length) ...[
          SelectedWordCard(
            key: ValueKey(_selected),
            placement: _draft.placements[_selected!],
            number: _draft.numbers[(
              _draft.placements[_selected!].row,
              _draft.placements[_selected!].col
            )],
            question: _verified[_draft.placements[_selected!].questionId],
            onChanged: _updateSelected,
            onRemove: _removeSelected,
            onClose: () => setState(() => _selected = null),
          ),
          const SizedBox(height: 16),
        ],
        _buildWordsCard(),
      ],
    );

    return AdminPage(
      title: title,
      subtitle: _category == null ? null : 'Category: ${_category!.name.en}',
      leading: IconButton(
          tooltip: 'Back',
          onPressed: _leave,
          icon: const Icon(Icons.arrow_back)),
      help:
          '1. Pick a checked question on the right.  2. Choose a suggested spot, or tap '
          'a square to start the word there.  3. Fix anything in red.  4. Save.',
      actions: [
        OutlinedButton.icon(
          onPressed: _history.isEmpty ? null : _undo,
          icon: const Icon(Icons.undo),
          label: const Text('Undo'),
        ),
        FilledButton.icon(
          onPressed: _saving || allProblems.isNotEmpty ? null : _save,
          icon: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.save_outlined),
          label: Text(allProblems.isEmpty
              ? 'Save puzzle'
              : 'Fix ${allProblems.length} to save'),
        ),
      ],
      child: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: left),
                const SizedBox(width: 20),
                Expanded(flex: 2, child: right),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [right, const SizedBox(height: 16), left],
            ),
    );
  }

  /// For the card builders in `puzzle_builder_cards.dart`.
  void _update(VoidCallback fn) => setState(fn);
}
