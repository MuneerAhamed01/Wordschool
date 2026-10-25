import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/core/routes/app_routes.dart';
import 'package:wordshool/features/crossword/revise/presentation/bloc/revise_bloc.dart';
import 'package:wordshool/features/crossword/revise/presentation/widgets/revision_card.dart';
import 'package:wordshool/shared/presentations/widgets/game_scaffold.dart';
import 'package:wordshool/shared/presentations/widgets/skeleton_box.dart';
import 'package:wordshool/shared/presentations/widgets/snackbar.dart';
import 'package:wordshool/shared/presentations/widgets/state_message.dart';

/// Revise tab: My mistakes (`design/screens/psc-crossword.md#5-revise`,
/// CW-050). The [ReviseBloc] comes from the router.
class RevisePage extends StatelessWidget {
  static const String routeName = AppRoutes.revise;
  const RevisePage({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ReviseBloc>();
    return GameScaffold(
      body: BlocConsumer<ReviseBloc, ReviseState>(
        listenWhen: (a, b) => b is ReviseLoaded && b.error != null,
        listener: (context, state) => CustomSnackBar.show(context,
            message: (state as ReviseLoaded).error!, type: SnackBarType.error),
        builder: (context, state) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTitle(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  bloc.add(const ReviseRequested());
                  await bloc.stream.firstWhere((s) => s is! ReviseLoading);
                },
                child: _buildBody(bloc, state),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Text(
        'My mistakes',
        style: TextStyle(
            color: MyColors.white, fontWeight: FontWeight.w800, fontSize: 24),
      ),
    );
  }

  Widget _buildBody(ReviseBloc bloc, ReviseState state) {
    return switch (state) {
      ReviseLoading() => _buildSkeleton(),
      ReviseFailed(:final message) => StateMessage.error(
          message: message,
          onAction: () => bloc.add(const ReviseRequested()),
        ),
      ReviseLoaded(:final items) when items.isEmpty => _buildEmpty(),
      ReviseLoaded() => _buildList(bloc, state),
    };
  }

  Widget _buildSkeleton() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (var i = 0; i < 4; i++) ...[
          const SkeletonBox(height: 150),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _buildEmpty() {
    return ListView(
      children: const [
        SizedBox(height: 80),
        StateMessage(
          icon: Icons.menu_book_outlined,
          title: 'Nothing to revise',
          message: 'Mistakes from puzzles show up here.',
        ),
      ],
    );
  }

  Widget _buildList(ReviseBloc bloc, ReviseLoaded state) {
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.extentAfter < 300) bloc.add(const ReviseMoreRequested());
        return false;
      },
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        itemCount: state.items.length + (state.hasMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          if (i == state.items.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final item = state.items[i];
          return RevisionCard(
            key: ValueKey('revise-${item.questionId}'),
            item: item,
            saving: state.saving.contains(item.questionId),
            onLearned: () => bloc.add(ReviseItemLearned(item.questionId)),
          );
        },
      ),
    );
  }
}
