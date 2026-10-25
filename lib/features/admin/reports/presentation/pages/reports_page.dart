import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wordshool/features/admin/shared/presentation/widgets/empty_state.dart';
import 'package:wordshool/features/admin/shared/presentation/widgets/loading_block.dart';
import 'package:wordshool/core/routes/admin_routes.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/di_admin.dart';
import 'package:wordshool/features/admin/reports/data/data_source/reports_service.dart';
import 'package:wordshool/features/admin/shared/data/data_source/categories_service.dart';
import 'package:wordshool/features/admin/shared/data/data_source/questions_service.dart';
import 'package:wordshool/features/admin/shared/domain/models/enums.dart';
import 'package:wordshool/features/admin/reports/domain/models/report.dart';
import 'package:wordshool/core/utils/ist_date.dart';
import 'package:wordshool/features/admin/shared/presentation/widgets/feedback.dart';
import 'package:wordshool/features/admin/shared/presentation/widgets/page.dart';
import 'package:wordshool/features/admin/shared/presentation/widgets/filter_chips.dart';
import 'package:wordshool/features/admin/shared/presentation/widgets/question_editor_dialog.dart';
import 'package:wordshool/features/admin/shared/presentation/widgets/status_chip.dart';

class AdminReportsPage extends StatefulWidget {
  const AdminReportsPage({super.key});

  static const routeName = AdminRoutes.reports;

  @override
  State<AdminReportsPage> createState() => _AdminReportsPageState();
}

class _AdminReportsPageState extends State<AdminReportsPage> {
  final _categoryService = adminGetIt<AdminCategoriesService>();
  final _questionService = adminGetIt<AdminQuestionsService>();
  final _reportService = adminGetIt<AdminReportsService>();
  ReportStatus _status = ReportStatus.open;
  List<AdminReport> _reports = [];
  String? _cursor;
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;
  final Set<String> _busy = {};
  List<String> _subjects = const [];

  @override
  void initState() {
    super.initState();
    _load();
    _categoryService.listCategories().then((result) {
      if (mounted && result is DataSuccess) {
        setState(() => _subjects = [for (final c in result.data!) c.subject]);
      }
    });
  }

  Future<void> _load({bool more = false}) async {
    final status = _status;
    setState(() {
      if (more) {
        _loadingMore = true;
      } else {
        _loading = true;
        _error = null;
      }
    });
    final result = await _reportService.listReports(
        status: status, startAfterId: more ? _cursor : null);
    if (!mounted || status != _status) return;
    setState(() {
      _loading = false;
      _loadingMore = false;
      if (result is DataSuccess) {
        _reports =
            more ? [..._reports, ...result.data!.items] : result.data!.items;
        _cursor = result.data!.nextStartAfterId;
      } else if (more) {
        showAdminError(context, result.error);
      } else {
        _error = result.error?.message;
      }
    });
  }

  Future<void> _openQuestion(AdminReport report) async {
    setState(() => _busy.add(report.id));
    final result = await _questionService.getQuestion(report.questionId);
    if (!mounted) return;
    setState(() => _busy.remove(report.id));
    if (result is! DataSuccess) {
      showAdminError(context, result.error);
      return;
    }
    final question = result.data!;
    if (question.status == QuestionStatus.retired) {
      showAdminError(
        context,
        AppError(
            error: 'retired',
            code: 'retired',
            message: 'This question is retired and can\'t be edited.'),
      );
      return;
    }
    final saved = await QuestionEditorDialog.show(context,
        existing: question, subjects: _subjects);
    if (saved != null && mounted) {
      showSuccess(context,
          '"${saved.answer}" saved. Mark it as checked again in Questions.');
    }
  }

  Future<void> _resolve(AdminReport report, ReportStatus status) async {
    final note = await showDialog<String>(
      context: context,
      builder: (context) => _ResolveDialog(status: status),
    );
    if (note == null || !mounted) return;
    setState(() => _busy.add(report.id));
    final result = await _reportService.resolveReport(
        reportId: report.id, status: status, note: note);
    if (!mounted) return;
    setState(() => _busy.remove(report.id));
    if (result is DataSuccess) {
      showSuccess(
          context,
          status == ReportStatus.fixed
              ? 'Report marked as fixed'
              : 'Report rejected');
      setState(() => _reports.removeWhere((r) => r.id == report.id));
    } else {
      showAdminError(context, result.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminPage(
      title: 'Reports',
      subtitle: 'Problems players found in a puzzle word.',
      help:
          'Open the puzzle or the question to check the report. If something was '
          'wrong, fix the question (a live puzzle can\'t be edited — archive it and '
          'build a corrected one), then press "Mark fixed". If nothing was wrong, press "Reject".',
      actions: [
        OutlinedButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh')),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilterChips<ReportStatus>(
            options: ReportStatus.values,
            selected: _status,
            label: (s) => s.label,
            onSelected: (s) {
              setState(() => _status = s);
              _load();
            },
          ),
          const SizedBox(height: 16),
          _buildList(),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_loading) return const LoadingBlock();
    if (_error != null) {
      return EmptyState(
        icon: Icons.cloud_off,
        title: 'Could not load reports',
        message: _error,
        action:
            OutlinedButton(onPressed: _load, child: const Text('Try again')),
      );
    }
    if (_reports.isEmpty) {
      return EmptyState(
        icon: _status == ReportStatus.open
            ? Icons.celebration_outlined
            : Icons.inbox_outlined,
        title: _status == ReportStatus.open
            ? 'No open reports'
            : 'Nothing here yet',
        message: _status == ReportStatus.open
            ? 'Players haven\'t reported any problems. Nice!'
            : null,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final report in _reports)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ReportCard(
              report: report,
              busy: _busy.contains(report.id),
              onOpenPuzzle: () => context.go(
                  '${AdminRoutes.puzzleDetail(report.puzzleId)}?word=${report.wordId}'),
              onOpenQuestion: () => _openQuestion(report),
              onFixed: () => _resolve(report, ReportStatus.fixed),
              onReject: () => _resolve(report, ReportStatus.rejected),
            ),
          ),
        if (_cursor != null)
          Center(
            child: OutlinedButton.icon(
              onPressed: _loadingMore ? null : () => _load(more: true),
              icon: const Icon(Icons.expand_more),
              label: const Text('Load more'),
            ),
          ),
      ],
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.report,
    required this.busy,
    required this.onOpenPuzzle,
    required this.onOpenQuestion,
    required this.onFixed,
    required this.onReject,
  });

  final AdminReport report;
  final bool busy;
  final VoidCallback onOpenPuzzle;
  final VoidCallback onOpenQuestion;
  final VoidCallback onFixed;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final (background, foreground) = switch (report.reason) {
      ReportReason.wrongAnswer => (MyColors.errorBg, MyColors.errorText),
      ReportReason.typo => (MyColors.warnBg, MyColors.warnText),
      ReportReason.other => (
          MyColors.gameSurfaceElevated,
          MyColors.textSecondary
        ),
    };
    final open = report.status == ReportStatus.open;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Pill(
                    label: report.reason.label,
                    background: background,
                    foreground: foreground,
                    icon: Icons.flag),
                Text(
                  'Puzzle ${report.puzzleId} · word ${report.wordId}',
                  style: textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                if (report.createdAt != null)
                  Text(
                    friendlyIstDateTime(report.createdAt!),
                    style: textTheme.bodySmall
                        ?.copyWith(color: MyColors.navInactive),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              report.message.isEmpty ? '(no message)' : '"${report.message}"',
              style: textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
            ),
            if (!open) ...[
              const SizedBox(height: 8),
              Text(
                '${report.status.label}${report.resolvedAt == null ? '' : ' · ${friendlyIstDateTime(report.resolvedAt!)}'}'
                '${(report.resolutionNote ?? '').isEmpty ? '' : ' — ${report.resolutionNote}'}',
                style: textTheme.bodySmall
                    ?.copyWith(color: MyColors.textSecondary),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: onOpenPuzzle,
                  icon: const Icon(Icons.grid_on, size: 18),
                  label: const Text('Open puzzle'),
                ),
                OutlinedButton.icon(
                  onPressed: busy ? null : onOpenQuestion,
                  icon: const Icon(Icons.quiz_outlined, size: 18),
                  label: const Text('Open question'),
                ),
                if (open) ...[
                  FilledButton.icon(
                    onPressed: busy ? null : onFixed,
                    icon: const Icon(Icons.check),
                    label: const Text('Mark fixed'),
                  ),
                  OutlinedButton.icon(
                    onPressed: busy ? null : onReject,
                    icon: const Icon(Icons.close),
                    label: const Text('Reject'),
                  ),
                ],
                if (busy)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ResolveDialog extends StatefulWidget {
  const _ResolveDialog({required this.status});

  final ReportStatus status;

  @override
  State<_ResolveDialog> createState() => _ResolveDialogState();
}

class _ResolveDialogState extends State<_ResolveDialog> {
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fixed = widget.status == ReportStatus.fixed;
    return AlertDialog(
      title: Text(fixed ? 'Mark as fixed' : 'Reject report'),
      content: SizedBox(
        width: 440,
        child: TextField(
          controller: _note,
          autofocus: true,
          maxLength: 500,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Note (optional)',
            hintText:
                fixed ? 'What did you change?' : 'Why is the puzzle correct?',
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel')),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_note.text.trim()),
          child: Text(fixed ? 'Mark fixed' : 'Reject'),
        ),
      ],
    );
  }
}
