import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/core/routes/app_routes.dart';
import 'package:wordshool/features/crossword/home/domain/entities/daily.dart';
import 'package:wordshool/features/crossword/home/domain/entities/home.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/progress.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/puzzle.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/result_args.dart';
import 'package:wordshool/features/crossword/leaderboard/domain/entities/leaderboard.dart';
import 'package:wordshool/shared/domains/entities/paged.dart';
import 'package:wordshool/features/crossword/revise/domain/entities/revision_item.dart';
import 'package:wordshool/features/crossword/home/presentation/bloc/home_bloc.dart';
import 'package:wordshool/features/crossword/leaderboard/presentation/bloc/leaderboard_bloc.dart';
import 'package:wordshool/features/crossword/puzzle/presentation/bloc/puzzle_bloc.dart';
import 'package:wordshool/features/crossword/revise/presentation/bloc/revise_bloc.dart';
import 'package:wordshool/features/crossword/home/presentation/pages/home_page.dart';
import 'package:wordshool/features/crossword/leaderboard/presentation/pages/leaderboard_page.dart';
import 'package:wordshool/features/crossword/puzzle/presentation/pages/puzzle_page.dart';
import 'package:wordshool/features/crossword/result/presentation/pages/result_page.dart';
import 'package:wordshool/features/crossword/revise/presentation/pages/revise_page.dart';
import 'package:wordshool/shared/domains/entities/localized_text.dart';

import 'crossword_fakes.dart';
import 'fixtures_entities.dart';

/// Phone at the narrowest supported width (CLAUDE.md: works at 360 px).
Future<void> _phone(WidgetTester tester) async {
  tester.view.physicalSize = const Size(360 * 3, 740 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

Widget _routerApp(GoRouter router) => MaterialApp.router(
      theme: ThemeData.dark(useMaterial3: true),
      routerConfig: router,
    );

void main() {
  late FakeCrosswordRepository repo;
  late FakeUseCases uc;

  setUp(() {
    repo = FakeCrosswordRepository();
    uc = FakeUseCases(repo);
  });

  GoRouter puzzleRouter(PuzzleBloc bloc) => GoRouter(
        initialLocation: '/start',
        routes: [
          GoRoute(
            path: '/start',
            builder: (context, _) => Scaffold(
              body: TextButton(
                onPressed: () =>
                    context.push(AppRoutes.puzzleOf(repo.puzzle.id)),
                child: const Text('go'),
              ),
            ),
          ),
          GoRoute(
            path: PuzzlePage.routeName,
            builder: (_, __) => BlocProvider.value(
              value: bloc,
              child: PuzzlePage(puzzleId: repo.puzzle.id, config: FakeConfig()),
            ),
            routes: [
              GoRoute(
                path: 'result',
                builder: (_, state) => ResultPage(
                  args: state.extra as ResultArgs?,
                  config: FakeConfig(),
                ),
              ),
            ],
          ),
          GoRoute(path: '/home', builder: (_, __) => const Text('HOME')),
          GoRoute(path: '/revise', builder: (_, __) => const Text('REVISE')),
          GoRoute(
              path: '/crossword/category/:id',
              builder: (_, __) => const Text('CATEGORY')),
        ],
      );

  testWidgets('puzzle screen at 360 px: type, check, submit → results',
      (tester) async {
    await _phone(tester);
    final bloc = uc.puzzleBloc()..add(PuzzleOpened(repo.puzzle.id));
    await tester.pumpWidget(_routerApp(puzzleRouter(bloc)));
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();

    expect(find.text('Kerala Renaissance and Trade'), findsOne);
    expect(find.text('1 ACROSS · 7 LETTERS'), findsOne);
    expect(find.text('0 of 31 letters filled'), findsOne);

    for (final ch in 'MUZIRIX'.split('')) {
      await tester.tap(find.byKey(ValueKey('key-$ch')));
    }
    await tester.pump();
    expect(find.text('7 of 31 letters filled'), findsOne);
    await tester.tap(find.byKey(const ValueKey('key-Check answers')));
    await tester.pump();
    expect(find.text('1 to fix'), findsOne);

    // Chips jump between words; the clue bar follows.
    await tester.tap(find.text('2D'));
    await tester.pump();
    expect(find.text('2 DOWN · 6 LETTERS'), findsOne);

    // Finish from the menu → Results.
    await tester.tap(find.byTooltip('More').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Finish puzzle'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();
    expect(repo.submits, hasLength(1));
    expect(find.text('Puzzle complete'), findsOne);
    expect(find.text('5/7'), findsOne);
    expect(find.text('+21'), findsOne);
    expect(find.text('Mistakes to revise'), findsOne);
    await tester.scrollUntilVisible(find.text('Revealed'), 200); // 3D
    await tester.scrollUntilVisible(
        find.byKey(const ValueKey('revise-mistakes')), 200);
    expect(find.text('Revise 2 mistakes'), findsOne);
    expect(tester.takeException(), isNull);
  });

  testWidgets('back saves progress and leaves at once', (tester) async {
    await _phone(tester);
    final bloc = uc.puzzleBloc()..add(PuzzleOpened(repo.puzzle.id));
    await tester.pumpWidget(_routerApp(puzzleRouter(bloc)));
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('key-M')));
    await tester.pump();
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(repo.saves.single.create, isTrue);
    expect(find.text('go'), findsOne);
  });

  testWidgets('results opened without args offer a way home', (tester) async {
    await _phone(tester);
    await tester.pumpWidget(
        MaterialApp(home: ResultPage(args: null, config: FakeConfig())));
    expect(find.text('Result not available'), findsOne);
  });

  testWidgets('home at 360 px: daily in progress, categories, mistakes',
      (tester) async {
    await _phone(tester);
    final puzzle = repo.puzzle;
    repo.home = _homeData(puzzle);
    final bloc = CrosswordHomeBloc(
        loadHome: uc.loadHome,
        loadProgress: uc.loadHomeProgress,
        countRevision: uc.countRevision)
      ..add(const CrosswordHomeRequested());
    await tester.pumpWidget(MaterialApp(
      home: BlocProvider.value(
        value: bloc,
        child: const HomePage(),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('PSC Crossword'), findsOne);
    expect(find.text('Continue · 4 / 31'), findsOne);
    expect(find.text('Kerala History'), findsOne);
    expect(find.text('0 / 42'), findsOne);
    expect(find.text('My mistakes'), findsOne);
    expect(tester.takeException(), isNull);
  });

  testWidgets('home without a daily puzzle', (tester) async {
    await _phone(tester);
    repo.home = DataSuccess(
        data: const CrosswordHomeEntity(
            todayId: '2026-10-22', categories: [exampleCategory]));
    final bloc = CrosswordHomeBloc(
        loadHome: uc.loadHome,
        loadProgress: uc.loadHomeProgress,
        countRevision: uc.countRevision)
      ..add(const CrosswordHomeRequested());
    await tester.pumpWidget(MaterialApp(
      home: BlocProvider.value(value: bloc, child: const HomePage()),
    ));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text("Today's puzzle is on its way"), findsOne);
  });

  testWidgets('revise at 360 px: mark as learned removes the card',
      (tester) async {
    await _phone(tester);
    repo.revisionPages = [
      Paged(items: [
        RevisionItemEntity(
          questionId: 'q-vaikom',
          answer: 'VAIKOM',
          answerDisplay: const LocalizedText(en: 'Vaikom'),
          clue: const LocalizedText(en: 'Temple-road satyagraha'),
          fact: const LocalizedText(en: 'Held in 1924–25.'),
          subject: 'kerala_history',
          wrongCount: 2,
          lastWrongAt: DateTime.utc(2026, 10, 22),
        ),
      ], hasMore: false),
    ];
    final bloc =
        ReviseBloc(loadItems: uc.loadRevision, setMastered: uc.setMastered)
          ..add(const ReviseRequested());
    await tester.pumpWidget(MaterialApp(
      home: BlocProvider.value(value: bloc, child: const RevisePage()),
    ));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Temple-road satyagraha'), findsOne);
    expect(find.text('Missed 2 times'), findsOne);
    expect(find.text('Kerala history'), findsOne);
    await tester.tap(find.text('Mark as learned'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(repo.mastered, ['q-vaikom']);
    expect(find.text('Nothing to revise'), findsOne);
  });

  testWidgets('ranks at 360 px: own row pinned when outside the top',
      (tester) async {
    await _phone(tester);
    repo.leaderboard = const LeaderboardEntity(
      boardId: 'crossword-2026-W43',
      top: [
        LeaderboardEntryEntity(
            uid: 'bob', displayName: 'Bob', points: 320, puzzlesSolved: 8),
      ],
      me: LeaderboardEntryEntity(
          uid: 'alice', displayName: 'Alice', points: 40, puzzlesSolved: 1),
      myRank: 57,
    );
    final bloc =
        LeaderboardBloc(loadLeaderboard: uc.loadLeaderboard, myUid: 'alice')
          ..add(const LeaderboardRequested());
    await tester.pumpWidget(MaterialApp(
      home: BlocProvider.value(value: bloc, child: const LeaderboardPage()),
    ));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Bob'), findsOne);
    expect(find.text('Alice (you)'), findsOne);
    expect(find.text('57'), findsOne);
  });
}

DataState<CrosswordHomeEntity> _homeData(CrosswordPuzzleEntity puzzle) {
  final letters = List.filled(puzzle.layout.length, '.');
  for (var i = 0; i < puzzle.layout.length; i++) {
    if (puzzle.layout[i] == '#') letters[i] = '#';
  }
  letters.setRange(0, 4, ['M', 'U', 'Z', 'I']);
  return DataSuccess(
      data: CrosswordHomeEntity(
    todayId: '2026-10-22',
    daily: CrosswordDailyEntity(
      dateId: '2026-10-22',
      puzzleId: puzzle.id,
      categoryId: puzzle.categoryId,
      title: puzzle.title,
      difficulty: puzzle.difficulty,
      wordCount: 7,
      xpReward: 50,
      estimatedMinutes: 6,
    ),
    categories: const [exampleCategory],
    progress: HomeProgressEntity(
      dailyProgress:
          CrosswordProgressEntity(puzzleId: puzzle.id, letters: letters.join()),
    ),
    revisionCount: 3,
  ));
}
