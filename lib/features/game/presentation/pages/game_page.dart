import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wordshool/core/enums/word_tile_type.dart';
import 'package:wordshool/features/game/presentation/bloc/game_bloc/game_bloc.dart';
import 'package:wordshool/features/game/presentation/bloc/word_cubit/word_cubit.dart';
import 'package:wordshool/features/game/presentation/utils/constants.dart';
import 'package:wordshool/features/game/presentation/utils/letter.dart';
import 'package:wordshool/features/game/presentation/utils/word.dart';
import 'package:wordshool/features/game/presentation/widgets/keyboard/keyboard.dart';
import 'package:wordshool/shared/presentations/widgets/glowing_bulb.dart';
import 'package:wordshool/shared/presentations/widgets/shimmer_grid_item.dart';
import 'package:wordshool/shared/presentations/widgets/snackbar.dart';
import 'package:wordshool/shared/presentations/widgets/wordle_tile/tile.dart';
import 'package:wordshool/features/winning/presentation/pages/winning_page.dart';
import 'package:wordshool/features/winning/presentation/pages/params/winning_page_param.dart';

part 'game_page_helper.dart';

class GamePage extends StatefulWidget {
  static const String routeName = '/game';
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with GamePageHelper {
  // Store shake functions for each tile
  final Map<int, VoidCallback> _shakeFunctions = {};

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        final body = state.whenOrNull(
          loaded: (word, userGameState, userSpecificGameData) => _buildContent(),
          error: (message) => _buildLoadingBody(),
          loading: () => _buildLoadingBody(),
          initial: () => _buildLoadingBody(),
        );
        return BlocListener<WordCubit, List<Word>>(
          listener: listenToWord,
          child: Scaffold(
            body: body,
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    return SafeArea(
      child: Column(
        children: [
          SizedBox(height: 10),
          _buildWords(),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 24, top: 16),
              child: _buildIndicator(context),
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: GlowingLightbulbButton(
                size: 24,
                onTap: () {},
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: _buildCustomButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomButton() {
    return BlocBuilder<WordCubit, List<Word>>(
      builder: (context, state) {
        // Collect oranged (WordTileType.orange), greened (WordTileType.green), and disabled (WordTileType.error) letter values from state
        final Set<String> orangedList = <String>{};
        final Set<String> greenedList = <String>{};
        final Set<String> disabledList = <String>{};

        for (final word in state) {
          for (final letter in word.letters) {
            final upperChar = letter.letter.toUpperCase();
            if (letter.type == WordTileType.orange) {
              orangedList.add(upperChar);
            } else if (letter.type == WordTileType.green) {
              greenedList.add(upperChar);
            } else if (letter.type == WordTileType.none) {
              disabledList.add(upperChar);
            }
          }
        }

        return CustomKeyboard(
          onKeyPressed: (value) {
            context.read<WordCubit>().addLetter(Letter(letter: value));
          },
          onEnterPressed: () => onSubmitWord(context),
          onBackspacePressed: () {
            context.read<WordCubit>().removeLastLetter();
          },
          orangedList: orangedList.toList(),
          greenedList: greenedList.toList(),
          disabledList: disabledList.toList(),
        );
      },
    );
  }

  Widget _buildIndicator(BuildContext context) {
    return BlocBuilder<WordCubit, List<Word>>(
      builder: (context, state) {
        // Count completed words
        final completedWords = min(
            state.where((word) => word.isCompleted).length + 1,
            GameConstants.maxWords);
        final maxWords = GameConstants.maxWords;

        return Text(
          '$completedWords / $maxWords',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.7),
              ),
        );
      },
    );
  }

  Widget _buildWords() {
    return BlocBuilder<WordCubit, List<Word>>(
      builder: (context, state) {
        return GridView.builder(
          itemCount: 5 * 5,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            childAspectRatio: 1,
            mainAxisSpacing: 5,
            crossAxisSpacing: 5,
          ),
          shrinkWrap: true,
          itemBuilder: (_, index) {
            final wordIndex =
                index ~/ 5; // Integer division to get word index (0-4)
            final letterIndex =
                index % 5; // Modulo to get letter index within word (0-4)

            final word = state.elementAtOrNull(wordIndex);
            final letter = word?.letters.elementAtOrNull(letterIndex);

            return WordTile(
              tileType: letter?.type ?? WordTileType.none,
              shakeCallBack: (shakeFunction) {
                // Store the shake function for this specific tile
                _shakeFunctions[index] = shakeFunction as VoidCallback;
              },
              value: letter?.letter ?? '',
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingBody() {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          GridView.builder(
            itemCount: 5 * 5,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              childAspectRatio: 1,
              mainAxisSpacing: 5,
              crossAxisSpacing: 5,
            ),
            shrinkWrap: true,
            itemBuilder: (_, index) => ShimmerGridItem(
              baseColor: Colors.grey[800]!,
              highlightColor: Colors.grey[700]!,
            ),
          ),
        ],
      ),
    );
  }
}
