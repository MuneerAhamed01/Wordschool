import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/core/config/monetization_config.dart';
import 'package:wordshool/core/monetization/ad_service.dart';
import 'package:wordshool/core/monetization/story_entitlements.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/di.dart';
import 'package:wordshool/features/story_mode/domain/usecases/consume_hint.dart';
import 'package:wordshool/features/story_mode/presentation/analytics/story_analytics.dart';
import 'package:wordshool/features/story_mode/presentation/routing/story_flow_gating.dart';
import 'package:wordshool/features/story_mode/presentation/utils/clue_type_labels.dart';
import 'package:wordshool/features/story_mode/presentation/utils/story_hint_reveal.dart';
import 'package:wordshool/features/story_mode/presentation/widgets/story_mode_widgets.dart';
import 'package:wordshool/shared/presentations/widgets/app_button.dart';

class StoryHintPage extends StatefulWidget {
  const StoryHintPage({super.key, required this.clueIndex});

  final int clueIndex;

  @override
  State<StoryHintPage> createState() => _StoryHintPageState();
}

class _StoryHintPageState extends State<StoryHintPage> {
  final Set<int> _revealedLetterIndices = {};
  bool _loadingExtraHint = false;
  String? _statusMessage;

  bool get _monetizationEnabled =>
      getIt<MonetizationConfig>().isMonetizationAndPurchasesEnabled;

  Future<void> _requestExtraHint(String answer) async {
    if (_loadingExtraHint) return;

    final nextIndex =
        StoryHintReveal.nextUnrevealedIndex(_revealedLetterIndices);
    if (nextIndex < 0) {
      setState(() => _statusMessage = 'All letters already revealed.');
      return;
    }

    setState(() {
      _loadingExtraHint = true;
      _statusMessage = null;
    });

    String analyticsSource = 'free';
    var granted = false;

    if (!_monetizationEnabled) {
      granted = true;
    } else {
      await getIt<StoryEntitlementsService>().refresh();
      final entitlements = getIt<StoryEntitlementsService>();

      if (entitlements.isDetectivePro) {
        granted = true;
        analyticsSource = 'pro';
      } else if (entitlements.hasHintAllowance) {
        final result = await getIt<ConsumeHintUseCase>()();
        if (result is DataSuccess<ConsumeHintResult> && result.data!.consumed) {
          granted = true;
          analyticsSource =
              result.data!.source == HintConsumptionSource.hintPack
                  ? 'iap'
                  : 'pro';
          await getIt<StoryEntitlementsService>().refresh();
        }
      } else if (getIt.isRegistered<AdService>()) {
        granted = await getIt<AdService>().showRewardedForHint();
        analyticsSource = 'rewarded';
      }
    }

    if (!mounted) return;

    if (!granted) {
      setState(() {
        _loadingExtraHint = false;
        _statusMessage = 'Could not unlock an extra hint. Try again.';
      });
      return;
    }

    await StoryAnalytics.hintUsed(source: analyticsSource);

    setState(() {
      _revealedLetterIndices.add(nextIndex);
      _loadingExtraHint = false;
      _statusMessage = StoryHintReveal.revealLabel(answer, nextIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return StoryFlowGate(
      clueIndex: widget.clueIndex,
      builder: (context, detectiveCase, flowState) {
        final clue = detectiveCase.clues[widget.clueIndex];
        final answer = clue.answer.trim().toUpperCase();
        final allRevealed = _revealedLetterIndices.length >= answer.length;
        final extraHintHelpText = _monetizationEnabled
            ? 'Reveal one letter at a time using a hint pack, Detective Pro, or a short video.'
            : 'Reveal one letter at a time — free while Story Mode is in early access.';

        return StoryNarrativeScaffold(
          title: clueTypeLabel(clue.type),
          body: clue.hint,
          bodyWidget: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Text(
                'Need more help?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                extraHintHelpText,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: MyColors.textMuted,
                    ),
              ),
              if (_statusMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _statusMessage!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: MyColors.streakAccent,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
              if (_revealedLetterIndices.isNotEmpty) ...[
                const SizedBox(height: 12),
                ..._revealedLetterIndices.map(
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      StoryHintReveal.revealLabel(answer, index),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              AppButton(
                label: allRevealed
                    ? 'All letters revealed'
                    : _loadingExtraHint
                        ? 'Unlocking…'
                        : 'Reveal a letter',
                variant: ButtonVariant.secondary,
                onTap: allRevealed || _loadingExtraHint
                    ? null
                    : () => _requestExtraHint(answer),
              ),
            ],
          ),
          continueLabel: 'Continue',
          onContinue: () {
            context.push(StoryFlowGating.clueInvestigatePath(widget.clueIndex));
          },
        );
      },
    );
  }
}
