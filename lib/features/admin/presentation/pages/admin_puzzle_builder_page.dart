import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/di_admin.dart';
import 'package:wordshool/features/admin/data/admin_api_service.dart';
import 'package:wordshool/features/admin/domain/models/admin_category.dart';
import 'package:wordshool/features/admin/domain/models/admin_enums.dart';
import 'package:wordshool/features/admin/domain/models/admin_puzzle.dart';
import 'package:wordshool/features/admin/domain/models/admin_question.dart';
import 'package:wordshool/features/admin/domain/utils/grid_validator.dart';
import 'package:wordshool/features/admin/domain/utils/puzzle_draft.dart';
import 'package:wordshool/features/admin/domain/utils/question_text.dart';
import 'package:wordshool/features/admin/presentation/pages/admin_puzzles_page.dart';
import 'package:wordshool/features/admin/presentation/widgets/admin_feedback.dart';
import 'package:wordshool/features/admin/presentation/widgets/admin_page.dart';
import 'package:wordshool/features/admin/presentation/widgets/crossword_grid.dart';
import 'package:wordshool/shared/domains/entities/localized_text.dart';

/// Builds or edits a crossword: pick checked questions, place them on the
/// grid (suggested spots cross existing words), fix anything shown in red,
/// then save. Black squares, numbers and word ids are worked out automatically.
class AdminPuzzleBuilderPage extends StatefulWidget {
  const AdminPuzzleBuilderPage(
      {super.key, this.puzzleId, this.initialCategoryId});

  /// Null for a new puzzle.
  final String? puzzleId;
  final String? initialCategoryId;

  @override
  State<AdminPuzzleBuilderPage> createState() => _AdminPuzzleBuilderPageState();
}

class _AdminPuzzleBuilderPageState extends State<AdminPuzzleBuilderPage> {
  final _api = adminGetIt<AdminApiService>();

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
      _api.listCategories(),
      _api.listAllQuestions(status: QuestionStatus.verified),
      if (!_isNew) _api.getPuzzle(widget.puzzleId!),
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
    final clues = question.clues;
    final first = question.firstClue;
    final extra = clues.where((c) => c != first).firstOrNull;
    final placement = Placement(
      questionId: question.id!,
      answer: question.answer,
      row: row,
      col: col,
      direction: direction,
      clue: LocalizedText(en: first?.en ?? '', ml: first?.ml),
      extraClue:
          extra == null ? null : LocalizedText(en: extra.en, ml: extra.ml),
      fact: question.fact,
    );
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
    final result = await _api.savePuzzle(_buildPuzzle());
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
    context.go(AdminPuzzlesPage.detailLocation(saved.id));
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
        ? AdminPuzzlesPage.location(categoryId: _categoryId)
        : AdminPuzzlesPage.detailLocation(widget.puzzleId!));
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
        _buildGridCard(gridProblems),
        const SizedBox(height: 16),
        _ProblemsCard(problems: allProblems),
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
          _SelectedWordCard(
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

  Widget _buildGridCard(List<GridProblem> problems) {
    final selected = _selected == null ? null : _draft.placements[_selected!];
    final letters = _draft.letters;
    final rowsCols = [for (var i = minGridSize; i <= maxGridSize; i++) i];
    return _Panel(
      title: 'Grid',
      trailing: Wrap(
        spacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _SizeDropdown(
            label: 'Rows',
            value: _draft.rows,
            options: rowsCols,
            onChanged: (v) => _resize(rows: v),
          ),
          _SizeDropdown(
            label: 'Columns',
            value: _draft.cols,
            options: rowsCols,
            onChanged: (v) => _resize(cols: v),
          ),
          Tooltip(
            message:
                'Shrink the grid to the words and move them to the top left',
            child: TextButton.icon(
              onPressed: _draft.placements.isEmpty
                  ? null
                  : () => _change(_draft.trimmed()),
              icon: const Icon(Icons.crop_free, size: 18),
              label: const Text('Fit to words'),
            ),
          ),
          TextButton.icon(
            onPressed: _draft.placements.isEmpty ? null : _clear,
            icon: const Icon(Icons.delete_sweep_outlined, size: 18),
            label: const Text('Clear'),
          ),
        ],
      ),
      child: Column(
        children: [
          if (_placing != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Tap the square where ${_placing!.answer} should start (${_placingDirection.label.toLowerCase()}).',
                style: const TextStyle(
                    color: MyColors.warnText, fontWeight: FontWeight.w700),
              ),
            ),
          CrosswordGrid(
            rows: _draft.rows,
            cols: _draft.cols,
            letters: letters,
            numbers: _draft.numbers,
            highlighted: selected?.cells.toSet() ?? const {},
            problemCells: {for (final p in problems) ...p.cells},
            editing: true,
            onCellTap: _onCellTap,
          ),
          const SizedBox(height: 12),
          const Wrap(
            spacing: 16,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              _Legend(
                  color: MyColors.gameSurface,
                  label: 'Empty — becomes a black square'),
              _Legend(color: MyColors.gridWordBg, label: 'Selected word'),
              _Legend(color: MyColors.gridWrongBg, label: 'Needs fixing'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    return _Panel(
      title: 'Puzzle details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<String>(
            value: _categoryId,
            decoration: InputDecoration(
              labelText: 'Category',
              helperText: _isNew
                  ? null
                  : 'The category can\'t change after the first save.',
            ),
            items: [
              for (final c in _categories)
                DropdownMenuItem(value: c.id, child: Text(c.name.en)),
            ],
            onChanged: _isNew ? (id) => setState(() => _categoryId = id) : null,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _titleEn,
            maxLength: 80,
            onChanged: (_) => setState(() => _dirty = true),
            decoration: const InputDecoration(
                labelText: 'Title (English) *',
                hintText: 'Kerala Renaissance and Trade'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _titleMl,
            maxLength: 80,
            onChanged: (_) => setState(() => _dirty = true),
            decoration: const InputDecoration(labelText: 'Title (Malayalam)'),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SegmentedButton<Difficulty>(
                segments: [
                  for (final d in Difficulty.values)
                    ButtonSegment(value: d, label: Text(d.label))
                ],
                selected: {_difficulty},
                onSelectionChanged: (s) => setState(() {
                  _difficulty = s.first;
                  _dirty = true;
                }),
              ),
              SizedBox(
                width: 140,
                child: TextField(
                  controller: _xp,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() => _dirty = true),
                  decoration: const InputDecoration(
                      labelText: 'XP reward', helperText: '1–1000'),
                ),
              ),
              SizedBox(
                width: 140,
                child: TextField(
                  controller: _minutes,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() => _dirty = true),
                  decoration: const InputDecoration(
                      labelText: 'Minutes to solve',
                      helperText: 'About how long'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<AdminQuestion> get _pickerQuestions {
    final used = {for (final p in _draft.placements) p.questionId};
    final subject = _category?.subject;
    final query = _search.text.trim().toLowerCase();
    return _verified.values.where((q) {
      if (used.contains(q.id)) return false;
      if (q.answer.length > _draft.rows && q.answer.length > _draft.cols) {
        return false;
      }
      if (_onlyCategorySubject && subject != null && q.subject != subject) {
        return false;
      }
      if (query.isEmpty) return true;
      return q.answer.toLowerCase().contains(query) ||
          q.clues.any((c) => c.en.toLowerCase().contains(query)) ||
          q.answerDisplay.en.toLowerCase().contains(query);
    }).toList()
      ..sort((a, b) => b.answer.length.compareTo(a.answer.length));
  }

  Widget _buildPickerCard() {
    final questions = _pickerQuestions;
    final subject = _category?.subject;
    return _Panel(
      title: 'Add a word',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              isDense: true,
              prefixIcon: Icon(Icons.search),
              hintText: 'Search checked questions',
            ),
          ),
          if (subject != null)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              value: _onlyCategorySubject,
              onChanged: (v) => setState(() => _onlyCategorySubject = v),
              title: Text('Only "${humanize(subject)}" questions'),
            ),
          const SizedBox(height: 4),
          if (_verified.isEmpty)
            EmptyState(
              icon: Icons.quiz_outlined,
              title: 'No checked questions yet',
              message: 'Only questions marked as checked can go into a puzzle.',
              action: OutlinedButton(
                  onPressed: () => context.go('/questions'),
                  child: const Text('Go to Questions')),
            )
          else if (questions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'No matching checked questions. Try turning off the subject filter.',
                textAlign: TextAlign.center,
                style: TextStyle(color: MyColors.textSecondary),
              ),
            )
          else
            SizedBox(
              height: (questions.length * 73.0).clamp(73.0, 360.0),
              child: ListView.separated(
                itemCount: questions.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final q = questions[index];
                  final fits =
                      _draft.suggestions(q.answer, limit: 1).isNotEmpty;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    title: Text(
                      '${q.answer}  ·  ${q.answer.length}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, letterSpacing: 1),
                    ),
                    subtitle: Text(q.firstClue?.en ?? '',
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: fits
                        ? const Tooltip(
                            message: 'Fits on the grid',
                            child: Icon(Icons.check_circle_outline,
                                color: MyColors.successText, size: 20),
                          )
                        : null,
                    onTap: () => _startPlacing(q),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlacingCard() {
    final question = _placing!;
    final spots = _draft.suggestions(question.answer);
    return _Panel(
      title: 'Place ${question.answer}',
      trailing: TextButton(
          onPressed: () => setState(() => _placing = null),
          child: const Text('Cancel')),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(question.firstClue?.en ?? '',
              style: const TextStyle(color: MyColors.textSecondary)),
          const SizedBox(height: 16),
          Text('Suggested spots',
              style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          if (spots.isEmpty)
            Text(
              _draft.placements.isEmpty
                  ? 'The word is longer than the grid. Make the grid bigger.'
                  : 'No spot crosses the current words. Tap a square to place it anyway, '
                      'or add other words first.',
              style: const TextStyle(color: MyColors.warnText),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final spot in spots)
                  ActionChip(
                    avatar: Icon(
                      spot.direction == WordDirection.across
                          ? Icons.arrow_forward
                          : Icons.arrow_downward,
                      size: 16,
                    ),
                    label: Text(spot.label),
                    onPressed: () => _place(spot.row, spot.col, spot.direction),
                  ),
              ],
            ),
          const SizedBox(height: 16),
          Text('Or tap a square on the grid to start it there, going:',
              style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          SegmentedButton<WordDirection>(
            segments: const [
              ButtonSegment(
                  value: WordDirection.across,
                  icon: Icon(Icons.arrow_forward),
                  label: Text('Across')),
              ButtonSegment(
                  value: WordDirection.down,
                  icon: Icon(Icons.arrow_downward),
                  label: Text('Down')),
            ],
            selected: {_placingDirection},
            onSelectionChanged: (s) =>
                setState(() => _placingDirection = s.first),
          ),
        ],
      ),
    );
  }

  Widget _buildWordsCard() {
    final numbers = _draft.numbers;
    final indexed = [
      for (var i = 0; i < _draft.placements.length; i++)
        (i, _draft.placements[i])
    ];
    indexed.sort((a, b) {
      final byNumber = (numbers[(a.$2.row, a.$2.col)] ?? 999)
          .compareTo(numbers[(b.$2.row, b.$2.col)] ?? 999);
      return byNumber != 0
          ? byNumber
          : a.$2.direction.index.compareTo(b.$2.direction.index);
    });
    return _Panel(
      title: 'Words (${_draft.placements.length})',
      child: indexed.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('No words yet. Pick a question above to start.',
                  style: TextStyle(color: MyColors.textSecondary)),
            )
          : Column(
              children: [
                for (final (index, p) in indexed)
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    selected: index == _selected,
                    selectedTileColor: MyColors.gridWordBg,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    leading: SizedBox(
                      width: 56,
                      child: Text(
                        '${numbers[(
                              p.row,
                              p.col
                            )] ?? '–'} ${p.direction.label}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: MyColors.textSecondary,
                            fontSize: 12),
                      ),
                    ),
                    title: Text(p.answer,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, letterSpacing: 1)),
                    subtitle: Text(p.clue.en,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    onTap: () => setState(() {
                      _placing = null;
                      _selected = index;
                    }),
                  ),
              ],
            ),
    );
  }
}

class _SelectedWordCard extends StatefulWidget {
  const _SelectedWordCard({
    super.key,
    required this.placement,
    required this.number,
    required this.question,
    required this.onChanged,
    required this.onRemove,
    required this.onClose,
  });

  final Placement placement;
  final int? number;
  final AdminQuestion? question;
  final ValueChanged<Placement> onChanged;
  final VoidCallback onRemove;
  final VoidCallback onClose;

  @override
  State<_SelectedWordCard> createState() => _SelectedWordCardState();
}

class _SelectedWordCardState extends State<_SelectedWordCard> {
  late final _clueEn = TextEditingController(text: widget.placement.clue.en);
  late final _clueMl = TextEditingController(text: widget.placement.clue.ml);
  late final _extraEn =
      TextEditingController(text: widget.placement.extraClue?.en);

  @override
  void dispose() {
    _clueEn.dispose();
    _clueMl.dispose();
    _extraEn.dispose();
    super.dispose();
  }

  void _emit() {
    final extra = _extraEn.text.trim();
    widget.onChanged(widget.placement.copyWith(
      clue: LocalizedText(en: _clueEn.text, ml: _clueMl.text),
      extraClue: extra.isEmpty ? null : LocalizedText(en: extra),
      clearExtraClue: extra.isEmpty,
    ));
  }

  void _useClue(QuestionClue clue) {
    _clueEn.text = clue.en;
    _clueMl.text = clue.ml ?? '';
    _emit();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.placement;
    final clues = widget.question?.clues ?? const <QuestionClue>[];
    return _Panel(
      title: '${widget.number ?? '–'} ${p.direction.label}: ${p.answer}',
      highlight: true,
      trailing: IconButton(
          tooltip: 'Close',
          onPressed: widget.onClose,
          icon: const Icon(Icons.close)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _clueEn,
            maxLength: 300,
            onChanged: (_) => _emit(),
            decoration: const InputDecoration(
                labelText: 'Clue players see (English) *'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _clueMl,
            maxLength: 300,
            onChanged: (_) => _emit(),
            decoration: const InputDecoration(labelText: 'Clue (Malayalam)'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _extraEn,
            maxLength: 300,
            onChanged: (_) => _emit(),
            decoration: const InputDecoration(
              labelText: 'Extra hint (optional)',
              helperText: 'Shown when a player asks for help with this word',
            ),
          ),
          if (clues.length > 1) ...[
            const SizedBox(height: 8),
            Text('Use a clue from the question:',
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final clue in clues)
                  ActionChip(
                    label: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 320),
                      child: Text('${clue.level.label}: ${clue.en}',
                          overflow: TextOverflow.ellipsis),
                    ),
                    onPressed: () => _useClue(clue),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: widget.onRemove,
              style:
                  OutlinedButton.styleFrom(foregroundColor: MyColors.errorText),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Remove from grid'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProblemsCard extends StatelessWidget {
  const _ProblemsCard({required this.problems});

  final List<String> problems;

  @override
  Widget build(BuildContext context) {
    if (problems.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: MyColors.successBg, borderRadius: BorderRadius.circular(12)),
        child: const Row(
          children: [
            Icon(Icons.check_circle, color: MyColors.successText),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Everything looks good — ready to save.',
                style: TextStyle(
                    color: MyColors.successText, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: MyColors.errorBg, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${problems.length} thing${problems.length == 1 ? '' : 's'} to fix before saving',
            style: const TextStyle(
                color: MyColors.errorText, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          ProblemList(problems: problems, maxItems: 8),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel(
      {required this.title,
      required this.child,
      this.trailing,
      this.highlight = false});

  final String title;
  final Widget child;
  final Widget? trailing;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: highlight
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: MyColors.gridWordBorder),
            )
          : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                Text(title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800)),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _SizeDropdown extends StatelessWidget {
  const _SizeDropdown(
      {required this.label,
      required this.value,
      required this.options,
      required this.onChanged});

  final String label;
  final int value;
  final List<int> options;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label ', style: const TextStyle(color: MyColors.textSecondary)),
        DropdownButton<int>(
          value: value,
          underline: const SizedBox.shrink(),
          items: [
            for (final o in options)
              DropdownMenuItem(value: o, child: Text('$o'))
          ],
          onChanged: (v) => v == null ? null : onChanged(v),
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: MyColors.gameBorder),
          ),
        ),
        const SizedBox(width: 6),
        Text(label,
            style:
                const TextStyle(color: MyColors.textSecondary, fontSize: 12)),
      ],
    );
  }
}
