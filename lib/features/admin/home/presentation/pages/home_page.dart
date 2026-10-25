import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wordshool/features/admin/shared/presentation/widgets/help_card.dart';
import 'package:wordshool/core/routes/admin_routes.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/di_admin.dart';
import 'package:wordshool/features/admin/home/data/data_source/access_service.dart';
import 'package:wordshool/features/admin/shared/data/data_source/auth_service.dart';
import 'package:wordshool/features/admin/shared/presentation/sections.dart';
import 'package:wordshool/features/admin/shared/presentation/widgets/page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  static const routeName = AdminRoutes.home;

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  late Future<DataState<void>> _access;

  @override
  void initState() {
    super.initState();
    _access = adminGetIt<AdminAccessService>().checkAccess();
  }

  @override
  Widget build(BuildContext context) {
    final name = adminGetIt<AdminAuthService>().currentUser?.displayName;
    final firstName = (name ?? '').split(' ').first;
    return AdminPage(
      title: firstName.isEmpty ? 'Welcome' : 'Welcome, $firstName',
      subtitle: 'Everything players see in PSC Crossword is managed here.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FutureBuilder<DataState<void>>(
            future: _access,
            builder: (context, snapshot) => _ConnectionCard(
              result: snapshot.data,
              onRetry: () => setState(() {
                _access = adminGetIt<AdminAccessService>().checkAccess();
              }),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'How it works',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            'Follow these steps from left to right. Each card opens that section.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: MyColors.textSecondary),
          ),
          const SizedBox(height: 16),
          const _Steps(),
          const SizedBox(height: 20),
          const HelpCard(
            icon: Icons.upload_file_outlined,
            text: 'Have many questions ready in a spreadsheet? Use Bulk upload '
                'to add them all at once instead of typing each one.',
          ),
        ],
      ),
    );
  }
}

class _ConnectionCard extends StatelessWidget {
  const _ConnectionCard({required this.result, required this.onRetry});

  final DataState<void>? result;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final loading = result == null;
    final ok = result is DataSuccess;
    final background = loading
        ? MyColors.gameSurface
        : ok
            ? MyColors.successBg
            : MyColors.errorBg;
    final foreground = loading
        ? MyColors.textSecondary
        : ok
            ? MyColors.successText
            : MyColors.errorText;
    final text = loading
        ? 'Connecting to the server…'
        : ok
            ? 'Connected. You have admin access.'
            : result?.error?.message ?? 'Could not reach the server.';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          if (loading)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Icon(ok ? Icons.check_circle : Icons.error_outline,
                color: foreground, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: TextStyle(color: foreground))),
          if (!loading && !ok)
            TextButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    );
  }
}

class _Step {
  const _Step(this.section, this.title, this.body);

  final AdminSection section;
  final String title;
  final String body;
}

class _Steps extends StatelessWidget {
  const _Steps();

  static const _steps = [
    _Step(AdminSection.categories, 'Pick a category',
        'Check the topic exists, e.g. "Kerala History". Add one if not.'),
    _Step(AdminSection.questions, 'Add and check questions',
        'Type each fact with its source, then press "Mark as checked".'),
    _Step(AdminSection.puzzles, 'Build a crossword',
        'Place checked questions on a grid. Mistakes are shown in red.'),
    _Step(AdminSection.puzzles, 'Review and publish',
        'Send the puzzle for review, then publish it or pick a date.'),
    _Step(AdminSection.schedule, 'Fill the calendar',
        'Choose the "Puzzle of the day" for each of the next days.'),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1000
            ? 5
            : constraints.maxWidth >= 640
                ? 3
                : 1;
        final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (var i = 0; i < _steps.length; i++)
              SizedBox(
                width: width,
                child: _StepCard(number: i + 1, step: _steps[i]),
              ),
          ],
        );
      },
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.number, required this.step});

  final int number;
  final _Step step;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go(step.section.path),
        child: Container(
          constraints: const BoxConstraints(minHeight: 168),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: MyColors.tileCorrect,
                    child: Text(
                      '$number',
                      style: const TextStyle(
                        color: MyColors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(step.section.icon, color: MyColors.navInactive),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                step.title,
                style:
                    textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                step.body,
                style: textTheme.bodySmall
                    ?.copyWith(color: MyColors.textSecondary, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
