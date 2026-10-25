import 'package:flutter/material.dart';
import 'package:wordshool/features/admin/shared/presentation/widgets/empty_state.dart';
import 'package:wordshool/features/admin/shared/presentation/widgets/loading_block.dart';
import 'package:wordshool/core/routes/admin_routes.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/di_admin.dart';
import 'package:wordshool/features/admin/shared/data/data_source/categories_service.dart';
import 'package:wordshool/features/admin/shared/data/data_source/questions_service.dart';
import 'package:wordshool/features/admin/shared/domain/models/enums.dart';
import 'package:wordshool/features/admin/shared/domain/models/question.dart';
import 'package:wordshool/features/admin/shared/domain/utils/question_text.dart';
import 'package:wordshool/features/admin/shared/presentation/widgets/feedback.dart';
import 'package:wordshool/features/admin/shared/presentation/widgets/page.dart';
import 'package:wordshool/features/admin/shared/presentation/widgets/filter_chips.dart';
import 'package:wordshool/features/admin/shared/presentation/widgets/question_editor_dialog.dart';
import 'package:wordshool/features/admin/shared/presentation/widgets/status_chip.dart';

class AdminQuestionsPage extends StatefulWidget {
  const AdminQuestionsPage({super.key});

  static const routeName = AdminRoutes.questions;

  @override
  State<AdminQuestionsPage> createState() => _AdminQuestionsPageState();
}

class _AdminQuestionsPageState extends State<AdminQuestionsPage> {
  final _categoryService = adminGetIt<AdminCategoriesService>();
  final _questionService = adminGetIt<AdminQuestionsService>();
  final _search = TextEditingController();

  List<String> _subjects = const [];
  String? _subject;
  QuestionStatus? _status;

  List<AdminQuestion> _questions = [];
  String? _cursor;
  bool _loading = true;
  bool _loadingMore = false;
  String? _loadError;
  final Set<String> _verifying = {};

  @override
  void initState() {
    super.initState();
    _loadSubjects();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _loadSubjects() async {
    final result = await _categoryService.listCategories();
    if (!mounted || result is! DataSuccess) return;
    setState(() {
      _subjects = {for (final c in result.data!) c.subject, ..._subjects}
          .toList()
        ..sort();
    });
  }

  Future<void> _load({bool more = false}) async {
    setState(() {
      if (more) {
        _loadingMore = true;
      } else {
        _loading = true;
        _loadError = null;
      }
    });
    final result = await _questionService.listQuestions(
      subject: _subject,
      status: _status,
      startAfterId: more ? _cursor : null,
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      _loadingMore = false;
      if (result is DataSuccess) {
        final page = result.data!;
        _questions = more ? [..._questions, ...page.items] : page.items;
        _cursor = page.nextStartAfterId;
        _subjects = {..._subjects, for (final q in page.items) q.subject}
            .toList()
          ..sort();
      } else if (more) {
        showAdminError(context, result.error);
      } else {
        _loadError = result.error?.message;
      }
    });
  }

  void _setFilter(
      {String? subject,
      QuestionStatus? status,
      bool clearSubject = false,
      bool clearStatus = false}) {
    setState(() {
      if (subject != null || clearSubject) _subject = subject;
      if (status != null || clearStatus) _status = status;
    });
    _load();
  }

  Future<void> _edit([AdminQuestion? question]) async {
    final saved = await QuestionEditorDialog.show(
      context,
      existing: question,
      subjects: _subjects,
      initialSubject: _subject,
    );
    if (saved == null || !mounted) return;
    showSuccess(
      context,
      question == null
          ? '"${saved.answer}" added. Mark it as checked when the fact is confirmed.'
          : '"${saved.answer}" saved',
    );
    setState(() {
      final index = _questions.indexWhere((q) => q.id == saved.id);
      if (index >= 0) {
        _questions[index] = saved;
      } else {
        _questions.insert(0, saved);
      }
    });
  }

  Future<void> _verify(AdminQuestion question) async {
    if (question.source.isPlaceholder) {
      showAdminError(
        context,
        AppError(
          error: 'todo-source',
          code: 'todo-source',
          message:
              'Add the real source for "${question.answer}" before marking it as checked.',
        ),
      );
      return _edit(question);
    }
    final confirmed = await confirmAction(
      context,
      title: 'Mark "${question.answer}" as checked?',
      message: 'Only do this after confirming the answer, clues and fact '
          'against the source:\n\n${question.source.type.label}: ${question.source.ref}',
      confirmLabel: 'Yes, it is correct',
    );
    if (!confirmed || !mounted) return;
    setState(() => _verifying.add(question.id!));
    final result = await _questionService.verifyQuestion(question.id!);
    if (!mounted) return;
    setState(() => _verifying.remove(question.id));
    if (result is DataSuccess) {
      showSuccess(context,
          '"${question.answer}" is checked and can be used in puzzles');
      setState(() {
        final index = _questions.indexWhere((q) => q.id == question.id);
        if (index >= 0) {
          _questions[index] =
              question.copyWith(status: QuestionStatus.verified);
        }
      });
    } else {
      showAdminError(context, result.error);
    }
  }

  List<AdminQuestion> get _visible {
    final query = _search.text.trim().toLowerCase();
    if (query.isEmpty) return _questions;
    return _questions.where((q) {
      return q.answer.toLowerCase().contains(query) ||
          q.answerDisplay.en.toLowerCase().contains(query) ||
          q.clues.any((c) => c.en.toLowerCase().contains(query)) ||
          q.fact.en.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AdminPage(
      title: 'Questions',
      subtitle: 'The fact bank behind every crossword word.',
      help: 'New and edited questions show "Needs checking". After you confirm '
          'a fact against its source, press "Mark as checked". Only checked '
          'questions can be used in puzzles.',
      actions: [
        FilledButton.icon(
          onPressed: () => _edit(),
          icon: const Icon(Icons.add),
          label: const Text('Add question'),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildFilters(),
          const SizedBox(height: 16),
          _buildList(),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 260,
          child: DropdownButtonFormField<String?>(
            value: _subject,
            isExpanded: true,
            decoration:
                const InputDecoration(labelText: 'Subject', isDense: true),
            items: [
              const DropdownMenuItem<String?>(
                  value: null, child: Text('All subjects')),
              for (final s in _subjects)
                DropdownMenuItem<String?>(value: s, child: Text(humanize(s))),
            ],
            onChanged: (s) => _setFilter(subject: s, clearSubject: s == null),
          ),
        ),
        FilterChips<QuestionStatus?>(
          options: const [null, ...QuestionStatus.values],
          selected: _status,
          label: (s) => s?.label ?? 'All',
          onSelected: (s) => _setFilter(status: s, clearStatus: s == null),
        ),
        SizedBox(
          width: 260,
          child: TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              isDense: true,
              prefixIcon: Icon(Icons.search),
              hintText: 'Search loaded questions',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildList() {
    if (_loading) return const LoadingBlock();
    if (_loadError != null) {
      return EmptyState(
        icon: Icons.cloud_off,
        title: 'Could not load questions',
        message: _loadError,
        action:
            OutlinedButton(onPressed: _load, child: const Text('Try again')),
      );
    }
    final visible = _visible;
    if (visible.isEmpty) {
      final filtered =
          _subject != null || _status != null || _search.text.isNotEmpty;
      return EmptyState(
        icon: Icons.quiz_outlined,
        title: filtered ? 'No questions match' : 'No questions yet',
        message: filtered
            ? 'Try another subject or status.'
            : 'Add one here, or use Bulk upload to add many at once.',
        action: filtered
            ? null
            : FilledButton.icon(
                onPressed: () => _edit(),
                icon: const Icon(Icons.add),
                label: const Text('Add question')),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final question in visible)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _QuestionCard(
              question: question,
              verifying: _verifying.contains(question.id),
              onEdit: question.status == QuestionStatus.retired
                  ? null
                  : () => _edit(question),
              onVerify: question.status == QuestionStatus.draft
                  ? () => _verify(question)
                  : null,
            ),
          ),
        if (_cursor != null)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: OutlinedButton.icon(
                onPressed: _loadingMore ? null : () => _load(more: true),
                icon: _loadingMore
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.expand_more),
                label: const Text('Load more'),
              ),
            ),
          ),
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.question,
    required this.verifying,
    required this.onEdit,
    required this.onVerify,
  });

  final AdminQuestion question;
  final bool verifying;
  final VoidCallback? onEdit;
  final VoidCallback? onVerify;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final clue = question.firstClue?.en ?? '';
    final used = question.usedInPuzzles.length;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 16,
            runSpacing: 12,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 10,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          question.answer,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                        if (question.answerDisplay.en.toUpperCase() !=
                            question.answer)
                          Text(question.answerDisplay.en,
                              style: textTheme.bodyMedium),
                        QuestionStatusChip(status: question.status),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      clue,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium
                          ?.copyWith(color: MyColors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        Pill(
                          label: humanize(question.subject),
                          background: MyColors.gameSurfaceElevated,
                          foreground: MyColors.textSecondary,
                          icon: Icons.folder_outlined,
                        ),
                        DifficultyChip(difficulty: question.difficulty),
                        Pill(
                          label: '${question.answer.length} letters',
                          background: MyColors.gameSurfaceElevated,
                          foreground: MyColors.textSecondary,
                        ),
                        if (used > 0)
                          Pill(
                            label: 'In $used puzzle${used == 1 ? '' : 's'}',
                            background: MyColors.infoBg,
                            foreground: MyColors.infoText,
                            icon: Icons.grid_on,
                          ),
                        if (question.source.isPlaceholder)
                          const Pill(
                            label: 'Source missing',
                            background: MyColors.errorBg,
                            foreground: MyColors.errorText,
                            icon: Icons.link_off,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onVerify != null)
                    FilledButton.icon(
                      onPressed: verifying ? null : onVerify,
                      icon: verifying
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.verified_outlined),
                      label: const Text('Mark as checked'),
                    ),
                  if (onEdit != null) ...[
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit'),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
