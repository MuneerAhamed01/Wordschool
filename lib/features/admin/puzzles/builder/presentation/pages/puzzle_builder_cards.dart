part of 'puzzle_builder_page.dart';

/// The builder's cards (grid, details, question picker, placing, words).
extension _BuilderCards on _AdminPuzzleBuilderPageState {
  Widget _buildGridCard(List<GridProblem> problems) {
    final selected = _selected == null ? null : _draft.placements[_selected!];
    final letters = _draft.letters;
    final rowsCols = [for (var i = minGridSize; i <= maxGridSize; i++) i];
    return BuilderPanel(
      title: 'Grid',
      trailing: Wrap(
        spacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizeDropdown(
            label: 'Rows',
            value: _draft.rows,
            options: rowsCols,
            onChanged: (v) => _resize(rows: v),
          ),
          SizeDropdown(
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
              GridLegend(
                  color: MyColors.gameSurface,
                  label: 'Empty — becomes a black square'),
              GridLegend(color: MyColors.gridWordBg, label: 'Selected word'),
              GridLegend(color: MyColors.gridWrongBg, label: 'Needs fixing'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    return BuilderPanel(
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
            onChanged: _isNew ? (id) => _update(() => _categoryId = id) : null,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _titleEn,
            maxLength: 80,
            onChanged: (_) => _update(() => _dirty = true),
            decoration: const InputDecoration(
                labelText: 'Title (English) *',
                hintText: 'Kerala Renaissance and Trade'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _titleMl,
            maxLength: 80,
            onChanged: (_) => _update(() => _dirty = true),
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
                onSelectionChanged: (s) => _update(() {
                  _difficulty = s.first;
                  _dirty = true;
                }),
              ),
              SizedBox(
                width: 140,
                child: TextField(
                  controller: _xp,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _update(() => _dirty = true),
                  decoration: const InputDecoration(
                      labelText: 'XP reward', helperText: '1–1000'),
                ),
              ),
              SizedBox(
                width: 140,
                child: TextField(
                  controller: _minutes,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _update(() => _dirty = true),
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
    return BuilderPanel(
      title: 'Add a word',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _search,
            onChanged: (_) => _update(() {}),
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
              onChanged: (v) => _update(() => _onlyCategorySubject = v),
              title: Text('Only "${humanize(subject)}" questions'),
            ),
          const SizedBox(height: 4),
          if (_verified.isEmpty)
            EmptyState(
              icon: Icons.quiz_outlined,
              title: 'No checked questions yet',
              message: 'Only questions marked as checked can go into a puzzle.',
              action: OutlinedButton(
                  onPressed: () => context.go(AdminRoutes.questions),
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
    return BuilderPanel(
      title: 'Place ${question.answer}',
      trailing: TextButton(
          onPressed: () => _update(() => _placing = null),
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
                _update(() => _placingDirection = s.first),
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
    return BuilderPanel(
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
                    onTap: () => _update(() {
                      _placing = null;
                      _selected = index;
                    }),
                  ),
              ],
            ),
    );
  }
}
