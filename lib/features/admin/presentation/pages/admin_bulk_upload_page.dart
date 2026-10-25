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
import 'package:wordshool/features/admin/domain/models/admin_results.dart';
import 'package:wordshool/features/admin/domain/utils/bulk_import.dart';
import 'package:wordshool/features/admin/presentation/pages/admin_puzzles_page.dart';
import 'package:wordshool/features/admin/presentation/pages/admin_questions_page.dart';
import 'package:wordshool/features/admin/presentation/utils/text_file.dart';
import 'package:wordshool/features/admin/presentation/widgets/admin_feedback.dart';
import 'package:wordshool/features/admin/presentation/widgets/admin_page.dart';
import 'package:wordshool/features/admin/presentation/widgets/status_chip.dart';

enum _Stage { choose, checking, preview, uploading, done }

class _UploadResult {
  const _UploadResult(this.ok, this.message);

  final bool ok;
  final String message;
}

/// Bulk upload (CW-036): questions from a spreadsheet (CSV / pasted cells) or
/// JSON, puzzles from JSON. Shows a checked preview, then saves item by item.
class AdminBulkUploadPage extends StatefulWidget {
  const AdminBulkUploadPage({super.key});

  static const routeName = '/bulk-upload';

  @override
  State<AdminBulkUploadPage> createState() => _AdminBulkUploadPageState();
}

class _AdminBulkUploadPageState extends State<AdminBulkUploadPage> {
  final _api = adminGetIt<AdminApiService>();
  final _paste = TextEditingController();

  _Stage _stage = _Stage.choose;
  String? _fileName;
  String? _fileError;
  ImportKind? _kind;
  List<ImportRow<AdminQuestion>> _questionRows = [];
  List<ImportRow<AdminPuzzle>> _puzzleRows = [];
  final Map<ImportRow<Object?>, _UploadResult> _results = {};
  int _uploaded = 0;

  List<ImportRow<Object?>> get _rows =>
      _kind == ImportKind.puzzles ? _puzzleRows : _questionRows;

  List<ImportRow<Object?>> get _toUpload => _rows
      .where((r) =>
          r.ok &&
          (r.action == ImportAction.create || r.action == ImportAction.update))
      .toList();

  @override
  void dispose() {
    _paste.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _stage = _Stage.choose;
      _fileName = null;
      _fileError = null;
      _kind = null;
      _questionRows = [];
      _puzzleRows = [];
      _results.clear();
      _uploaded = 0;
    });
  }

  Future<void> _chooseFile(String accept) async {
    try {
      final file = await pickTextFile(accept: accept);
      if (file == null) return;
      await _check(file.name, file.text);
    } catch (e) {
      setState(() => _fileError = 'Could not read the file: $e');
    }
  }

  Future<void> _check(String name, String text) async {
    setState(() {
      _stage = _Stage.checking;
      _fileName = name;
      _fileError = null;
    });
    try {
      final kind = detectKind(name, text);
      if (kind == ImportKind.questions) {
        final rows = text.trimLeft().startsWith('{')
            ? parseQuestionsJson(text)
            : parseQuestionsCsv(text);
        final existing = await _api.listAllQuestions();
        if (existing is! DataSuccess) {
          throw ImportFileError(
              existing.error?.message ?? 'Could not load questions.');
        }
        planQuestionImport(rows, existing.data!);
        _questionRows = rows;
      } else {
        _puzzleRows = await _planPuzzles(parsePuzzlesJson(text));
      }
      if (!mounted) return;
      setState(() {
        _kind = kind;
        _stage = _Stage.preview;
      });
    } on ImportFileError catch (e) {
      if (!mounted) return;
      setState(() {
        _stage = _Stage.choose;
        _fileError = e.message;
      });
    }
  }

  Future<List<ImportRow<AdminPuzzle>>> _planPuzzles(
      List<ImportRow<AdminPuzzle>> rows) async {
    final results = await Future.wait([
      _api.listCategories(),
      _api.listAllQuestions(status: QuestionStatus.verified),
    ]);
    final failed = results.where((r) => r is! DataSuccess).firstOrNull;
    if (failed != null) {
      throw ImportFileError(failed.error?.message ?? 'Could not load data.');
    }
    final categories = {
      for (final c in results[0].data as List<AdminCategory>) c.id: c
    };
    final verified = {
      for (final q in results[1].data as List<AdminQuestion>) q.id!: q
    };

    final existingByCategory = <String, List<AdminPuzzleSummary>>{};
    for (final row in rows) {
      final puzzle = row.item;
      if (puzzle == null) {
        row.action = ImportAction.skip;
        continue;
      }
      final category = categories[puzzle.categoryId];
      if (category == null) {
        row.problems.add(
            'Category "${puzzle.categoryId}" doesn\'t exist. Add it in Categories first.');
        row.action = ImportAction.skip;
        continue;
      }
      linkPuzzleQuestions(row, verified, subject: category.subject);
      if (!existingByCategory.containsKey(category.id)) {
        final page =
            await _api.listPuzzles(categoryId: category.id, limit: 100);
        if (page is! DataSuccess) {
          throw ImportFileError(
              page.error?.message ?? 'Could not load puzzles.');
        }
        existingByCategory[category.id] = page.data!.items;
      }
      planPuzzleImport(row, existingByCategory[category.id]!);
    }
    return rows;
  }

  Future<void> _upload() async {
    final rows = _toUpload;
    setState(() {
      _stage = _Stage.uploading;
      _uploaded = 0;
      _results.clear();
    });
    for (final row in rows) {
      final DataState<Object?> result;
      final item = row.item;
      if (item is AdminQuestion) {
        result = await _api.saveQuestion(item);
      } else {
        result = await _api.savePuzzle(item! as AdminPuzzle);
      }
      if (!mounted) return;
      setState(() {
        _uploaded++;
        if (result is DataSuccess) {
          final saved = result.data as SaveResult;
          _results[row] = _UploadResult(
            true,
            row.action == ImportAction.update
                ? 'Updated'
                : 'Added as ${saved.id}',
          );
        } else {
          _results[row] =
              _UploadResult(false, result.error?.message ?? 'Failed');
        }
      });
    }
    setState(() => _stage = _Stage.done);
    final failed = _results.values.where((r) => !r.ok).length;
    if (failed == 0) {
      showSuccess(context, 'All ${rows.length} saved');
    } else {
      showAdminError(
        context,
        AppError(
            error: 'upload',
            code: 'upload',
            message:
                '$failed of ${rows.length} could not be saved — see the list.'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminPage(
      title: 'Bulk upload',
      subtitle:
          'Add many questions or puzzles at once instead of typing each one.',
      actions: [
        if (_stage == _Stage.preview || _stage == _Stage.done)
          OutlinedButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.restart_alt),
              label: const Text('Start over')),
      ],
      child: switch (_stage) {
        _Stage.choose => _buildChoose(),
        _Stage.checking => Column(
            children: [
              const LoadingBlock(),
              Text('Checking $_fileName…',
                  style: const TextStyle(color: MyColors.textSecondary)),
            ],
          ),
        _ => _buildPreview(),
      },
    );
  }

  Widget _buildChoose() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_fileError != null) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: MyColors.errorBg,
                borderRadius: BorderRadius.circular(12)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.error_outline, color: MyColors.errorText),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${_fileName == null ? '' : '$_fileName: '}$_fileError',
                    style: const TextStyle(color: MyColors.errorText),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        LayoutBuilder(
          builder: (context, constraints) {
            final questions = _ChoiceCard(
              icon: Icons.table_chart_outlined,
              title: 'Questions',
              steps: const [
                'Download the spreadsheet template.',
                'Fill one question per row in Excel or Google Sheets.',
                'Save as CSV (File → Download → .csv) and choose it here.',
              ],
              note:
                  'JSON files from content/questions/ work too. New questions arrive as '
                  '"Needs checking"; questions already in the bank are matched on answer + subject.',
              actions: [
                OutlinedButton.icon(
                  onPressed: canUseFiles
                      ? () => downloadTextFile(
                          'psc-questions-template.csv', questionCsvTemplate(),
                          mimeType: 'text/csv')
                      : null,
                  icon: const Icon(Icons.download),
                  label: const Text('Download template'),
                ),
                FilledButton.icon(
                  onPressed: canUseFiles
                      ? () => _chooseFile('.csv,.tsv,.txt,.json')
                      : null,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Choose questions file'),
                ),
              ],
            );
            final puzzles = _ChoiceCard(
              icon: Icons.grid_on_outlined,
              title: 'Puzzles',
              steps: const [
                'Use a puzzle file from content/puzzles/ (JSON).',
                'Its questions must already be in the bank and checked.',
                'Choose the file to check it before anything is saved.',
              ],
              note:
                  'Words are linked to checked questions by answer, so "TODO" question ids are fine. '
                  'A puzzle with the same id or title is updated (if still a draft).',
              actions: [
                FilledButton.icon(
                  onPressed: canUseFiles ? () => _chooseFile('.json') : null,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Choose puzzle file'),
                ),
              ],
            );
            if (constraints.maxWidth < 760) {
              return Column(
                  children: [questions, const SizedBox(height: 16), puzzles]);
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: questions),
                const SizedBox(width: 16),
                Expanded(child: puzzles)
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        Card(
          child: ExpansionTile(
            shape: const Border(),
            leading: const Icon(Icons.content_paste),
            title: const Text('Or paste instead'),
            subtitle: const Text(
                'Copy cells from Google Sheets (with the header row), or paste JSON'),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              TextField(
                controller: _paste,
                minLines: 6,
                maxLines: 14,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                decoration: const InputDecoration(
                    hintText: 'answer\tclue_easy\tfact_en\t…'),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () {
                    if (_paste.text.trim().isEmpty) return;
                    _check('Pasted text', _paste.text);
                  },
                  child: const Text('Check pasted text'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreview() {
    final rows = _rows;
    final counts = {
      for (final a in ImportAction.values)
        a: rows.where((r) => r.action == a).length
    };
    final toUpload = _toUpload.length;
    final textTheme = Theme.of(context).textTheme;
    final isQuestions = _kind == ImportKind.questions;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_fileName · ${rows.length} ${isQuestions ? 'question' : 'puzzle'}${rows.length == 1 ? '' : 's'}',
                  style: textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final action in ImportAction.values)
                      if (counts[action]! > 0)
                        _actionPill(action, count: counts[action]),
                  ],
                ),
                const SizedBox(height: 16),
                if (_stage == _Stage.preview)
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      FilledButton.icon(
                        onPressed: toUpload == 0 ? null : _upload,
                        icon: const Icon(Icons.cloud_upload_outlined),
                        label: Text(toUpload == 0
                            ? 'Nothing to upload'
                            : 'Upload $toUpload'),
                      ),
                      if (counts[ImportAction.skip]! > 0)
                        Text(
                          'Rows with errors are skipped. Fix them in the file and upload it again.',
                          style: textTheme.bodySmall
                              ?.copyWith(color: MyColors.warnText),
                        ),
                    ],
                  ),
                if (_stage == _Stage.uploading) ...[
                  Text('Saving $_uploaded of $toUpload…'),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                      value: toUpload == 0 ? null : _uploaded / toUpload,
                      minHeight: 8),
                ],
                if (_stage == _Stage.done)
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      FilledButton.icon(
                        onPressed: () => context.go(isQuestions
                            ? AdminQuestionsPage.routeName
                            : AdminPuzzlesPage.routeName),
                        icon: const Icon(Icons.arrow_forward),
                        label: Text(isQuestions
                            ? 'Go to Questions to check them'
                            : 'Go to Puzzles'),
                      ),
                      OutlinedButton(
                          onPressed: _reset,
                          child: const Text('Upload another file')),
                    ],
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _RowTile(
                row: row, result: _results[row], pill: _actionPill(row.action)),
          ),
      ],
    );
  }

  Widget _actionPill(ImportAction action, {int? count}) {
    final (background, foreground, icon) = switch (action) {
      ImportAction.create => (
          MyColors.successBg,
          MyColors.successText,
          Icons.add_circle_outline
        ),
      ImportAction.update => (MyColors.infoBg, MyColors.infoText, Icons.sync),
      ImportAction.unchanged => (
          MyColors.gameSurfaceElevated,
          MyColors.textSecondary,
          Icons.check
        ),
      ImportAction.skip => (
          MyColors.errorBg,
          MyColors.errorText,
          Icons.error_outline
        ),
    };
    return Pill(
      label:
          count == null ? action.label : '$count ${action.label.toLowerCase()}',
      background: background,
      foreground: foreground,
      icon: icon,
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.icon,
    required this.title,
    required this.steps,
    required this.note,
    required this.actions,
  });

  final IconData icon;
  final String title;
  final List<String> steps;
  final String note;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                      color: MyColors.successBg,
                      borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: MyColors.successText),
                ),
                const SizedBox(width: 12),
                Text(title,
                    style: textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 16),
            for (var i = 0; i < steps.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 11,
                      backgroundColor: MyColors.gameSurfaceElevated,
                      child: Text('${i + 1}',
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w800)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(steps[i])),
                  ],
                ),
              ),
            const SizedBox(height: 4),
            Text(note,
                style: textTheme.bodySmall
                    ?.copyWith(color: MyColors.textSecondary, height: 1.4)),
            const SizedBox(height: 16),
            Wrap(spacing: 8, runSpacing: 8, children: actions),
          ],
        ),
      ),
    );
  }
}

class _RowTile extends StatelessWidget {
  const _RowTile({required this.row, required this.result, required this.pill});

  final ImportRow<Object?> row;
  final _UploadResult? result;
  final Widget pill;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: MyColors.gameSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: row.ok ? MyColors.gameBorderSubtle : MyColors.gridWrongBg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              pill,
              Text(row.label,
                  style: textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w800)),
              if (result != null)
                Pill(
                  label: result!.ok ? result!.message : 'Failed',
                  background:
                      result!.ok ? MyColors.successBg : MyColors.errorBg,
                  foreground:
                      result!.ok ? MyColors.successText : MyColors.errorText,
                  icon:
                      result!.ok ? Icons.cloud_done_outlined : Icons.cloud_off,
                ),
            ],
          ),
          if (row.note != null && row.ok) ...[
            const SizedBox(height: 6),
            Text(row.note!,
                style: textTheme.bodySmall
                    ?.copyWith(color: MyColors.textSecondary)),
          ],
          if (!row.ok) ...[
            const SizedBox(height: 8),
            ProblemList(problems: row.problems),
          ],
          if (result != null && !result!.ok) ...[
            const SizedBox(height: 8),
            ProblemList(problems: [result!.message]),
          ],
        ],
      ),
    );
  }
}
