import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/core/utils/game_layout_metrics.dart';
import 'package:wordshool/core/enums/game_mode.dart';
import 'package:wordshool/core/enums/word_tile_type.dart';
import 'package:wordshool/core/analytics/analytics_service.dart';
import 'package:wordshool/di.dart';
import 'package:wordshool/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:wordshool/features/game/presentation/bloc/game_bloc/game_bloc.dart';
import 'package:wordshool/features/game/presentation/bloc/word_cubit/word_cubit.dart';
import 'package:wordshool/features/game/presentation/utils/constants.dart';
import 'package:wordshool/features/game/presentation/utils/letter.dart';
import 'package:wordshool/features/game/presentation/utils/word.dart';
import 'package:wordshool/features/game/presentation/widgets/game_result_footer.dart';
import 'package:wordshool/features/game/presentation/widgets/game_result_hero.dart';
import 'package:wordshool/features/game/presentation/widgets/keyboard/keyboard.dart';
import 'package:wordshool/features/settings/presentation/pages/settings_page.dart';
import 'package:wordshool/features/winning/presentation/pages/params/winning_page_param.dart';
import 'package:wordshool/features/winning/presentation/pages/winning_page.dart';
import 'package:wordshool/shared/domains/entities/user_game_state/user_game_data.dart';
import 'package:wordshool/shared/presentations/widgets/game_scaffold.dart';
import 'package:wordshool/shared/presentations/widgets/info_banner.dart';
import 'package:wordshool/shared/presentations/widgets/shimmer_grid_item.dart';
import 'package:wordshool/shared/presentations/widgets/snackbar.dart';
import 'package:wordshool/shared/presentations/widgets/streak_chip.dart';
import 'package:wordshool/shared/presentations/widgets/wordle_tile/tile.dart';

part 'game_page_helper.dart';

class GamePage extends StatefulWidget {
  static const String routeName = '/game';

  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with GamePageHelper {
  final Map<int, VoidCallback> _shakeFunctions = {};
  String? _lastRestoredKey;
  bool _gameStartedLogged = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        _scheduleRestoreIfNeeded(context, state);

        return BlocListener<GameBloc, GameState>(
          listenWhen: (prev, curr) =>
              prev.userSpecificGameData?.id != curr.userSpecificGameData?.id ||
              prev.userSpecificGameData?.guessedWords.length !=
                  curr.userSpecificGameData?.guessedWords.length ||
              prev.todayWord != curr.todayWord ||
              (!_gameStartedLogged && curr.maybeMap(loaded: (_) => true, orElse: () => false)),
          listener: (context, state) {
            _tryRestoreGuesses(context, state);
            _trackGameStartedIfNeeded(state);
          },
          child: BlocListener<WordCubit, List<Word>>(
            listener: listenToWord,
            child: GameScaffold(
              appBar: _buildAppBar(context, state),
              body: state.whenOrNull(
                    loaded: (word, gameDateId, gameMode, userGameState,
                            userSpecificGameData) =>
                        _buildContent(
                      word,
                      gameMode,
                      userSpecificGameData,
                      state.userGameState?.streak,
                    ),
                    error: (message) => _buildError(message),
                    loading: () => _buildLoading(),
                    initial: () => _buildLoading(),
                  ) ??
                  _buildLoading(),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, GameState state) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close_rounded),
        onPressed: () => context.go(DashboardPage.routeName),
      ),
      title: Text(_titleForState(state)),
      actions: [
        if (state.userGameState != null && !state.isArchiveMode)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Center(child: StreakChip(streak: state.userGameState!.streak)),
          ),
        IconButton(
          onPressed: () => context.push(SettingsPage.routeName),
          icon: const Icon(Icons.settings_outlined),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  String _titleForState(GameState state) {
    if (state.isArchiveMode) return state.gameDateId;
    return 'WordSchool';
  }

  void _scheduleRestoreIfNeeded(BuildContext context, GameState state) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _tryRestoreGuesses(context, state);
    });
  }

  void _trackGameStartedIfNeeded(GameState state) {
    if (_gameStartedLogged) return;

    state.maybeMap(
      loaded: (loaded) {
        final data = loaded.userSpecificGameData;
        if (data == null) return;

        _gameStartedLogged = true;
        getIt<AnalyticsService>().logGameStarted(
          gameMode: loaded.gameMode.analyticsName,
          isResume: data.guessedWords.isNotEmpty || data.isCompleted,
        );
      },
      orElse: () {},
    );
  }

  void _tryRestoreGuesses(BuildContext context, GameState state) {
    final data = state.userSpecificGameData;
    final todayWord = state.todayWord;
    if (data == null || todayWord.isEmpty) return;

    final words = data.guessedWords;
    if (words.isEmpty) return;

    final key = '${data.id}:${words.length}:$todayWord';
    if (_lastRestoredKey == key) return;
    _lastRestoredKey = key;

    context.read<WordCubit>().restoreGuesses(
          todayWord: todayWord,
          words: words,
        );
  }

  Widget _buildContent(
    String word,
    GameMode gameMode,
    UserGameDataEntity? userGameData,
    int? streak,
  ) {
    final isCompleted = userGameData?.isCompleted ?? false;
    final isWin = userGameData?.isCorrect ?? false;
    final guessCount = userGameData?.guessedWords.length ?? 0;
    final isArchiveMode = gameMode == GameMode.archive;

    return LayoutBuilder(
      builder: (context, constraints) {
        final flags = GameLayoutFlags(
          hasBanner: isArchiveMode,
          hasHero: isCompleted,
          hasFooter: isCompleted,
          hasKeyboard: !isCompleted,
          hasGuessCounter: !isCompleted,
          heroShowsAnswerTiles: isCompleted && !isWin,
          footerHasTwoButtons: isCompleted && !isArchiveMode,
        );
        final metrics = GameLayoutMetrics.compute(
          maxWidth: constraints.maxWidth,
          maxHeight: constraints.maxHeight,
          flags: flags,
        );

        return GameLayoutScope(
          metrics: metrics,
          child: Column(
            children: [
              if (isArchiveMode)
                const InfoBanner(
                  message:
                      'Archive mode — progress here does not affect your streak',
                  icon: Icons.history_rounded,
                  tone: InfoBannerTone.info,
                ),
              if (isCompleted)
                GameResultHero(
                  isWin: isWin,
                  answerWord: word,
                  guessCount: guessCount,
                  streak: streak,
                  isArchiveMode: isArchiveMode,
                ),
              SizedBox(height: metrics.isCompact ? 4 : 8),
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: _buildBoard(
                    metrics: metrics,
                    isReadOnly: isCompleted,
                  ),
                ),
              ),
              if (isCompleted)
                GameResultFooter(
                  isWin: isWin,
                  isArchiveMode: isArchiveMode,
                )
              else ...[
                _buildGuessCounter(metrics),
                SizedBox(height: metrics.isCompact ? 4 : 8),
                _buildKeyboard(metrics),
                SizedBox(height: metrics.isCompact ? 4 : 8),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildBoard({
    required GameLayoutMetrics metrics,
    required bool isReadOnly,
  }) {
    return BlocBuilder<WordCubit, List<Word>>(
      builder: (context, words) {
        final boardSide = metrics.boardSide;
        return SizedBox(
          width: boardSide,
          height: boardSide,
          child: GridView.builder(
            itemCount: 25,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: metrics.tileSpacing,
              crossAxisSpacing: metrics.tileSpacing,
              childAspectRatio: 1,
            ),
            itemBuilder: (_, index) {
              final wordIndex = index ~/ 5;
              final letterIndex = index % 5;
              final word = words.elementAtOrNull(wordIndex);
              final letter = word?.letters.elementAtOrNull(letterIndex);

              return WordTile(
                tileType: letter?.type ?? WordTileType.none,
                value: letter?.letter ?? '',
                fontSize: metrics.tileFontSize,
                revealDelay: isReadOnly
                    ? Duration.zero
                    : Duration(milliseconds: 100 * letterIndex),
                instantReveal: isReadOnly,
                shakeCallBack: (fn) {
                  _shakeFunctions[index] = fn as VoidCallback;
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildGuessCounter(GameLayoutMetrics metrics) {
    return BlocBuilder<WordCubit, List<Word>>(
      builder: (context, words) {
        final done = words.where((w) => w.isCompleted).length;
        return Padding(
          padding: EdgeInsets.symmetric(
            vertical: metrics.isCompact ? 6 : 12,
          ),
          child: Text(
            'Guess ${(done + 1).clamp(1, GameConstants.maxWords)} of ${GameConstants.maxWords}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: MyColors.textMuted,
                  fontWeight: FontWeight.w600,
                  fontSize: metrics.isCompact ? 13 : null,
                ),
          ),
        );
      },
    );
  }

  Widget _buildKeyboard(GameLayoutMetrics metrics) {
    return BlocBuilder<WordCubit, List<Word>>(
      builder: (context, words) {
        final orange = <String>{};
        final green = <String>{};
        final absent = <String>{};

        for (final word in words) {
          for (final letter in word.letters) {
            final c = letter.letter.toUpperCase();
            if (letter.type == WordTileType.orange) orange.add(c);
            if (letter.type == WordTileType.green) green.add(c);
            if (letter.type == WordTileType.none) absent.add(c);
          }
        }

        return CustomKeyboard(
          keyHeight: metrics.keyHeight,
          keyFontSize: metrics.keyFontSize,
          onKeyPressed: (v) =>
              context.read<WordCubit>().addLetter(Letter(letter: v)),
          onEnterPressed: () => onSubmitWord(context),
          onBackspacePressed: () =>
              context.read<WordCubit>().removeLastLetter(),
          orangedList: orange.toList(),
          greenedList: green.toList(),
          disabledList: absent.toList(),
        );
      },
    );
  }

  Widget _buildLoading() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
      ),
      itemCount: 25,
      itemBuilder: (_, __) => ShimmerGridItem(
        baseColor: MyColors.gameSurface,
        highlightColor: MyColors.gameBorder,
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}
