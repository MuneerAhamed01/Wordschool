import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wordshool/config/themes/app_theme.dart';
import 'package:wordshool/features/story_mode/data/models/detective_case.dart';
import 'package:wordshool/features/story_mode/data/models/detective_clue.dart';
import 'package:wordshool/features/story_mode/domain/entities/clue_type.dart';
import 'package:wordshool/features/story_mode/presentation/bloc/story_case_bloc/story_case_bloc.dart';
import 'package:wordshool/features/story_mode/presentation/bloc/story_flow_bloc/story_flow_bloc.dart';
import 'package:wordshool/features/story_mode/presentation/pages/case_intro_page.dart';
import 'package:wordshool/features/story_mode/presentation/pages/case_resolution_page.dart';
import 'package:wordshool/features/story_mode/presentation/pages/investigate_prompt_page.dart';
import 'package:wordshool/features/story_mode/presentation/pages/story_hint_page.dart';
import 'package:wordshool/features/story_mode/presentation/pages/story_home_page.dart';
import 'package:wordshool/features/story_mode/presentation/pages/story_reaction_page.dart';
import 'package:wordshool/features/story_mode/presentation/routing/story_flow_gating.dart';
import 'package:wordshool/features/story_mode/presentation/routing/story_flow_redirect.dart';
import 'package:wordshool/features/story_mode/presentation/widgets/story_mode_widgets.dart';

import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/story_mode/domain/repositories/story_case_repository.dart';
import 'package:wordshool/features/story_mode/domain/usecases/load_today_detective_case.dart';
import 'package:wordshool/features/story_mode/domain/usecases/today_detective_case_result.dart';
import 'package:wordshool/shared/domains/repostiories/session_repository.dart';
import 'package:wordshool/shared/domains/usercases/get_current_user_usecase.dart';

class FakeLoadTodayDetectiveCaseUseCase extends LoadTodayDetectiveCaseUseCase {
  FakeLoadTodayDetectiveCaseUseCase(this._result)
      : super(
          storyCaseRepository: _UnusedStoryCaseRepository(),
          getCurrentUserUseCase: _UnusedGetCurrentUserUseCase(),
        );

  final DataState<TodayDetectiveCaseResult> _result;

  @override
  Future<DataState<TodayDetectiveCaseResult>> call({void param}) async {
    return _result;
  }
}

class _UnusedStoryCaseRepository implements StoryCaseRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _UnusedGetCurrentUserUseCase extends GetCurrentUserUseCase {
  _UnusedGetCurrentUserUseCase()
      : super(sessionRepository: _UnusedSessionRepository());
}

class _UnusedSessionRepository implements SessionRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

DetectiveCaseModel sampleDetectiveCase() {
  return DetectiveCaseModel(
    id: '2026-06-18',
    title: 'The Midnight Ledger',
    introduction: 'Rain hammers the precinct windows.',
    clues: const [
      DetectiveClueModel(
        index: 0,
        type: ClueType.location,
        hint: 'Hint 0',
        answer: 'STUDY',
        reaction: 'Reaction 0',
        investigatePrompt: 'Investigate 0',
      ),
      DetectiveClueModel(
        index: 1,
        type: ClueType.weapon,
        hint: 'Hint 1',
        answer: 'KNIFE',
        reaction: 'Reaction 1',
        investigatePrompt: 'Investigate 1',
      ),
      DetectiveClueModel(
        index: 2,
        type: ClueType.suspect,
        hint: 'Hint 2',
        answer: 'HEIRS',
        reaction: 'Reaction 2',
        investigatePrompt: 'Investigate 2',
      ),
    ],
    resolution: 'Case closed.',
    createdAt: DateTime.utc(2026, 6, 18),
  );
}

class TestStoryWordlePage extends StatelessWidget {
  const TestStoryWordlePage({super.key, required this.clueIndex});

  final int clueIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final flowBloc = context.read<StoryFlowBloc>();
            flowBloc.add(MarkClueResolved(clueIndex));
            await flowBloc.stream.firstWhere(
              (state) => state.maybeMap(
                ready: (ready) => ready.completedClues[clueIndex],
                orElse: () => false,
              ),
            );
            if (context.mounted) {
              context.push(StoryFlowGating.clueReactionPath(clueIndex));
            }
          },
          child: const Text('Solve clue'),
        ),
      ),
    );
  }
}

GoRouter buildStoryTestRouter({
  required StoryCaseBloc storyCaseBloc,
  required StoryFlowBloc storyFlowBloc,
}) {
  return GoRouter(
    initialLocation: StoryHomePage.routeName,
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return MultiBlocProvider(
            providers: [
              BlocProvider.value(value: storyCaseBloc),
              BlocProvider.value(value: storyFlowBloc),
            ],
            child: StoryModeShell(child: child),
          );
        },
        routes: [
          GoRoute(
            path: StoryHomePage.routeName,
            builder: (context, state) => const StoryHomePage(),
            routes: [
              GoRoute(
                path: 'intro',
                builder: (context, state) => const CaseIntroPage(),
              ),
              GoRoute(
                path: 'clue/:index/hint',
                redirect: (context, state) =>
                    redirectStoryClueRoute(storyFlowBloc, state),
                builder: (context, state) => StoryHintPage(
                  clueIndex: int.parse(state.pathParameters['index']!),
                ),
              ),
              GoRoute(
                path: 'clue/:index/investigate',
                redirect: (context, state) =>
                    redirectStoryClueRoute(storyFlowBloc, state),
                builder: (context, state) => InvestigatePromptPage(
                  clueIndex: int.parse(state.pathParameters['index']!),
                ),
              ),
              GoRoute(
                path: 'clue/:index/wordle',
                redirect: (context, state) =>
                    redirectStoryWordleRoute(storyFlowBloc, state),
                builder: (context, state) => TestStoryWordlePage(
                  clueIndex: int.parse(state.pathParameters['index']!),
                ),
              ),
              GoRoute(
                path: 'clue/:index/reaction',
                redirect: (context, state) =>
                    redirectStoryReactionRoute(storyFlowBloc, state),
                builder: (context, state) => StoryReactionPage(
                  clueIndex: int.parse(state.pathParameters['index']!),
                ),
              ),
              GoRoute(
                path: 'resolution',
                redirect: (context, state) =>
                    redirectStoryResolution(storyFlowBloc),
                builder: (context, state) => const CaseResolutionGate(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

void main() {
  group('Story flow navigation', () {
    testWidgets('walks through three-clue active flow', (tester) async {
      final detectiveCase = sampleDetectiveCase();
      final storyCaseBloc = StoryCaseBloc(
        loadTodayDetectiveCaseUseCase: FakeLoadTodayDetectiveCaseUseCase(
          DataSuccess(
            data: TodayDetectiveCaseResult(detectiveCase: detectiveCase),
          ),
        ),
      );

      final storyFlowBloc = StoryFlowBloc();

      final router = buildStoryTestRouter(
        storyCaseBloc: storyCaseBloc,
        storyFlowBloc: storyFlowBloc,
      );

      await tester.pumpWidget(
        MaterialApp.router(
          theme: AppTheme.gameDark(),
          routerConfig: router,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Begin investigation'), findsOneWidget);
      await tester.tap(find.text('Begin investigation'));
      await tester.pumpAndSettle();

      expect(find.text('Case Introduction'), findsOneWidget);
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      for (var clue = 0; clue < 3; clue++) {
        expect(find.text('Hint $clue'), findsOneWidget);
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        expect(find.text('Investigate $clue'), findsOneWidget);
        await tester.tap(find.text('Investigate'));
        await tester.pumpAndSettle();

        expect(find.text('Solve clue'), findsOneWidget);
        await tester.tap(find.text('Solve clue'));
        await tester.pumpAndSettle();

        expect(find.text('Reaction $clue'), findsOneWidget);
        await tester.tap(
          find.text(
            clue == StoryFlowGating.maxClueIndex ? 'Close the case' : 'Next clue',
          ),
        );
        await tester.pumpAndSettle();
      }

      expect(find.text('Case Resolution'), findsOneWidget);
      expect(find.textContaining('Case closed.'), findsOneWidget);
    });

    testWidgets('redirects blocked clue hint to current clue', (tester) async {
      final detectiveCase = sampleDetectiveCase();
      final storyCaseBloc = StoryCaseBloc(
        loadTodayDetectiveCaseUseCase: FakeLoadTodayDetectiveCaseUseCase(
          DataSuccess(
            data: TodayDetectiveCaseResult(detectiveCase: detectiveCase),
          ),
        ),
      );

      final storyFlowBloc = StoryFlowBloc();

      final router = buildStoryTestRouter(
        storyCaseBloc: storyCaseBloc,
        storyFlowBloc: storyFlowBloc,
      );

      await tester.pumpWidget(
        MaterialApp.router(
          theme: AppTheme.gameDark(),
          routerConfig: router,
        ),
      );

      router.go(StoryFlowGating.clueHintPath(2));
      await tester.pumpAndSettle();

      expect(find.text('Hint 0'), findsOneWidget);
      expect(find.text('Hint 2'), findsNothing);
    });
  });
}
