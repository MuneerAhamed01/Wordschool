import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/di_admin.dart';
import 'package:wordshool/features/admin/data/admin_api_service.dart';
import 'package:wordshool/features/admin/domain/models/admin_enums.dart';
import 'package:wordshool/features/admin/domain/models/admin_question.dart';
import 'package:wordshool/features/admin/domain/utils/question_text.dart';
import 'package:wordshool/features/admin/presentation/widgets/admin_feedback.dart';
import 'package:wordshool/features/admin/presentation/widgets/admin_page.dart';
import 'package:wordshool/shared/domains/entities/localized_text.dart';

/// Add or edit a question. Saves through `adminSaveQuestion` and returns the
/// saved question (with its id), or null when cancelled.
class QuestionEditorDialog extends StatefulWidget {
  const QuestionEditorDialog({
    super.key,
    this.existing,
    required this.subjects,
    this.initialSubject,
  });

  final AdminQuestion? existing;

  /// Suggestions for the subject field (snake_case).
  final List<String> subjects;
  final String? initialSubject;

  static Future<AdminQuestion?> show(
    BuildContext context, {
    AdminQuestion? existing,
    required List<String> subjects,
    String? initialSubject,
  }) {
    return showDialog<AdminQuestion>(
      context: context,
      barrierDismissible: false,
      builder: (context) => QuestionEditorDialog(
        existing: existing,
        subjects: subjects,
        initialSubject: initialSubject,
      ),
    );
  }

  @override
  State<QuestionEditorDialog> createState() => _QuestionEditorDialogState();
}

class _ClueFields {
  _ClueFields({String en = '', String? ml, this.level = Difficulty.easy})
      : en = TextEditingController(text: en),
        ml = TextEditingController(text: ml);

  final TextEditingController en;
  final TextEditingController ml;
  Difficulty level;

  void dispose() {
    en.dispose();
    ml.dispose();
  }
}

class _QuestionEditorDialogState extends State<QuestionEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final AdminQuestion? q = widget.existing;
  late final _answer = TextEditingController(text: q?.answer);
  late final _displayEn = TextEditingController(text: q?.answerDisplay.en);
  late final _displayMl = TextEditingController(text: q?.answerDisplay.ml);
  late final _factEn = TextEditingController(text: q?.fact.en);
  late final _factMl = TextEditingController(text: q?.fact.ml);
  late final _subject =
      TextEditingController(text: q?.subject ?? widget.initialSubject);
  late final _topic = TextEditingController(text: q?.topic);
  late final _tags = TextEditingController(text: q?.examTags.join(', '));
  late final _sourceRef = TextEditingController(text: q?.source.ref);
  late Difficulty _difficulty = q?.difficulty ?? Difficulty.medium;
  late SourceType _sourceType = q?.source.type ?? SourceType.pyq;
  late final List<_ClueFields> _clues = q == null || q!.clues.isEmpty
      ? [_ClueFields()]
      : [
          for (final c in q!.clues)
            _ClueFields(en: c.en, ml: c.ml, level: c.level)
        ];
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [
      _answer,
      _displayEn,
      _displayMl,
      _factEn,
      _factMl,
      _subject,
      _topic,
      _tags,
      _sourceRef,
    ]) {
      c.dispose();
    }
    for (final clue in _clues) {
      clue.dispose();
    }
    super.dispose();
  }

  AdminQuestion _build() {
    final answer = normalizeAnswer(_answer.text);
    final displayEn =
        _displayEn.text.trim().isEmpty ? _answer.text.trim() : _displayEn.text;
    return AdminQuestion(
      id: q?.id,
      answer: answer,
      answerDisplay: LocalizedText(en: displayEn, ml: _displayMl.text),
      clues: [
        for (final clue in _clues)
          QuestionClue(
              en: clue.en.text.trim(),
              ml: clue.ml.text.trim(),
              level: clue.level),
      ],
      fact: LocalizedText(en: _factEn.text, ml: _factMl.text),
      subject: toSnake(_subject.text),
      topic: toSnake(_topic.text),
      examTags: parseTags(_tags.text),
      difficulty: _difficulty,
      source: QuestionSource(type: _sourceType, ref: _sourceRef.text),
      status: q?.status ?? QuestionStatus.draft,
      usedInPuzzles: q?.usedInPuzzles ?? const [],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final question = _build();
    setState(() => _saving = true);
    final result = await adminGetIt<AdminApiService>().saveQuestion(question);
    if (!mounted) return;
    setState(() => _saving = false);
    if (result is DataSuccess) {
      Navigator.of(context).pop(
        question.copyWith(
          id: result.data!.id,
          status: QuestionStatus.draft,
          updatedAt: DateTime.now(),
        ),
      );
    } else {
      showAdminError(context, result.error);
    }
  }

  String? _required(String? value, String message) =>
      (value ?? '').trim().isEmpty ? message : null;

  @override
  Widget build(BuildContext context) {
    final isNew = q == null;
    final width = MediaQuery.sizeOf(context).width;
    return Dialog(
      insetPadding: EdgeInsets.all(width < 700 ? 12 : 32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      isNew ? 'Add question' : 'Edit question',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed:
                        _saving ? null : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: Form(
                key: _formKey,
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                  children: [
                    if (q?.isVerified ?? false) ...[
                      const HelpCard(
                        icon: Icons.info_outline,
                        text: 'This question is checked. Saving any change '
                            'sets it back to "Needs checking".',
                      ),
                      const SizedBox(height: 16),
                    ],
                    const _Section('1. Answer'),
                    _AnswerField(controller: _answer),
                    const SizedBox(height: 12),
                    _Pair(
                      left: TextFormField(
                        controller: _displayEn,
                        maxLength: 60,
                        decoration: const InputDecoration(
                          labelText: 'How players see it (English)',
                          hintText: 'Kumaran Asan',
                          helperText: 'Leave empty to use the answer',
                        ),
                      ),
                      right: TextFormField(
                        controller: _displayMl,
                        maxLength: 60,
                        decoration: const InputDecoration(
                          labelText: 'How players see it (Malayalam)',
                          hintText: 'കുമാരനാശാൻ',
                        ),
                      ),
                    ),
                    const _Section('2. Clues',
                        help:
                            'Add 1 to 5 clues. Easy clues help players most.'),
                    for (var i = 0; i < _clues.length; i++) _buildClue(i),
                    if (_clues.length < 5)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () => setState(() => _clues
                              .add(_ClueFields(level: Difficulty.medium))),
                          icon: const Icon(Icons.add),
                          label: const Text('Add another clue'),
                        ),
                      ),
                    const _Section('3. Fact',
                        help:
                            'Shown to players after the puzzle. One or two sentences.'),
                    TextFormField(
                      controller: _factEn,
                      maxLength: 1000,
                      maxLines: 3,
                      minLines: 2,
                      decoration:
                          const InputDecoration(labelText: 'Fact (English) *'),
                      validator: (v) => _required(v, 'Enter the fact'),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _factMl,
                      maxLength: 1000,
                      maxLines: 3,
                      minLines: 1,
                      decoration:
                          const InputDecoration(labelText: 'Fact (Malayalam)'),
                    ),
                    const _Section('4. Subject and level'),
                    _Pair(
                      left: _SubjectField(
                          controller: _subject, subjects: widget.subjects),
                      right: TextFormField(
                        controller: _topic,
                        decoration: const InputDecoration(
                          labelText: 'Topic (optional)',
                          hintText: 'renaissance',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _tags,
                      decoration: const InputDecoration(
                        labelText: 'Exams (optional)',
                        hintText: 'LDC, LGS, Degree level',
                        helperText: 'Separate with commas',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Difficulty',
                        style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 8),
                    SegmentedButton<Difficulty>(
                      segments: [
                        for (final d in Difficulty.values)
                          ButtonSegment(value: d, label: Text(d.label)),
                      ],
                      selected: {_difficulty},
                      onSelectionChanged: (s) =>
                          setState(() => _difficulty = s.first),
                    ),
                    const _Section('5. Source',
                        help:
                            'Where you checked this fact. Needed before it can be marked as checked.'),
                    _Pair(
                      left: DropdownButtonFormField<SourceType>(
                        value: _sourceType,
                        decoration:
                            const InputDecoration(labelText: 'Source type'),
                        items: [
                          for (final s in SourceType.values)
                            DropdownMenuItem(value: s, child: Text(s.label)),
                        ],
                        onChanged: (s) =>
                            setState(() => _sourceType = s ?? _sourceType),
                      ),
                      right: TextFormField(
                        controller: _sourceRef,
                        maxLength: 300,
                        decoration: InputDecoration(
                          labelText: 'Reference *',
                          hintText: switch (_sourceType) {
                            SourceType.pyq => 'LDC 2019 Kollam, Q.42',
                            SourceType.book => 'Kerala Charithram, p. 112',
                            SourceType.website => 'https://…',
                            SourceType.other => 'Where the fact comes from',
                          },
                        ),
                        validator: (v) =>
                            _required(v, 'Say where the fact comes from'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed:
                        _saving ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.save_outlined),
                    label: Text(isNew ? 'Add question' : 'Save changes'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClue(int index) {
    final clue = _clues[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: MyColors.gameBorderSubtle),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text('Clue ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(width: 12),
              DropdownButton<Difficulty>(
                value: clue.level,
                underline: const SizedBox.shrink(),
                items: [
                  for (final d in Difficulty.values)
                    DropdownMenuItem(value: d, child: Text(d.label)),
                ],
                onChanged: (d) => setState(() => clue.level = d ?? clue.level),
              ),
              const Spacer(),
              if (_clues.length > 1)
                IconButton(
                  tooltip: 'Remove clue',
                  onPressed: () =>
                      setState(() => _clues.removeAt(index).dispose()),
                  icon: const Icon(Icons.delete_outline),
                ),
            ],
          ),
          TextFormField(
            controller: clue.en,
            maxLength: 300,
            decoration: const InputDecoration(
              labelText: 'Clue (English) *',
              hintText: 'Kumaran ___, poet of "Veena Poovu"',
            ),
            validator: (v) => _required(v, 'Enter the clue or remove it'),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: clue.ml,
            maxLength: 300,
            decoration: const InputDecoration(labelText: 'Clue (Malayalam)'),
          ),
        ],
      ),
    );
  }
}

class _AnswerField extends StatelessWidget {
  const _AnswerField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Answer in the grid *',
            hintText: 'Vaikom',
            helperText:
                'English letters only. Spaces, dots and dashes are removed.',
          ),
          validator: (v) => answerProblem(v ?? ''),
        ),
        const SizedBox(height: 8),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            final answer = normalizeAnswer(value.text);
            if (answer.isEmpty) return const SizedBox.shrink();
            final ok = answerProblem(value.text) == null;
            return Wrap(
              spacing: 3,
              runSpacing: 3,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (final letter in answer.split(''))
                  Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: ok ? MyColors.tileCorrect : MyColors.gridWrongBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(letter,
                        style: const TextStyle(fontWeight: FontWeight.w900)),
                  ),
                const SizedBox(width: 8),
                Text(
                  '${answer.length} letters',
                  style: const TextStyle(color: MyColors.textSecondary),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _SubjectField extends StatefulWidget {
  const _SubjectField({required this.controller, required this.subjects});

  final TextEditingController controller;
  final List<String> subjects;

  @override
  State<_SubjectField> createState() => _SubjectFieldState();
}

class _SubjectFieldState extends State<_SubjectField> {
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<String>(
      textEditingController: widget.controller,
      focusNode: _focusNode,
      optionsBuilder: (value) {
        final query = toSnake(value.text);
        return widget.subjects.where((s) => query.isEmpty || s.contains(query));
      },
      fieldViewBuilder: (context, controller, focusNode, onSubmit) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: const InputDecoration(
            labelText: 'Subject *',
            hintText: 'kerala_history',
            helperText: 'Usually the category, e.g. kerala_history',
          ),
          validator: (v) => toSnake(v ?? '').isEmpty ? 'Enter a subject' : null,
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            color: MyColors.gameSurfaceElevated,
            elevation: 6,
            borderRadius: BorderRadius.circular(12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240, maxWidth: 320),
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                children: [
                  for (final option in options)
                    ListTile(
                      dense: true,
                      title: Text(option),
                      onTap: () => onSelected(option),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title, {this.help});

  final String title;
  final String? help;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          if (help != null)
            Text(help!,
                style: textTheme.bodySmall
                    ?.copyWith(color: MyColors.textSecondary)),
        ],
      ),
    );
  }
}

/// Two fields side by side on wide screens, stacked on narrow ones.
class _Pair extends StatelessWidget {
  const _Pair({required this.left, required this.right});

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 560) {
          return Column(children: [left, const SizedBox(height: 12), right]);
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: left),
            const SizedBox(width: 12),
            Expanded(child: right),
          ],
        );
      },
    );
  }
}
