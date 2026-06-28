import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wordshool/core/config/monetization_config.dart';
import 'package:wordshool/core/monetization/ad_service.dart';
import 'package:wordshool/di.dart';
import 'package:wordshool/features/story_mode/presentation/analytics/story_analytics.dart';
import 'package:wordshool/features/story_mode/presentation/bloc/story_flow_bloc/story_flow_bloc.dart';
import 'package:wordshool/features/story_mode/presentation/pages/story_home_page.dart';
import 'package:wordshool/features/story_mode/presentation/routing/story_flow_gating.dart';
import 'package:wordshool/features/story_mode/presentation/utils/story_share_formatter.dart';
import 'package:wordshool/features/story_mode/presentation/widgets/case_score_breakdown.dart';
import 'package:wordshool/features/story_mode/presentation/widgets/story_mode_widgets.dart';
import 'package:wordshool/shared/presentations/widgets/app_button.dart';

class CaseResolutionPage extends StatefulWidget {
  static const String routeName = '/story/resolution';

  const CaseResolutionPage({super.key});

  @override
  State<CaseResolutionPage> createState() => _CaseResolutionPageState();
}

class _CaseResolutionPageState extends State<CaseResolutionPage> {
  bool _interstitialShown = false;
  bool _analyticsLogged = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeShowInterstitial();
      _logCaseCompletedAnalytics();
    });
  }

  void _logCaseCompletedAnalytics() {
    if (_analyticsLogged || !mounted) return;
    final flowState = context.read<StoryFlowBloc>().state;
    if (flowState is! StoryFlowReady) return;
    final progress = flowState.progress;
    if (progress?.outcome == null || progress?.completedAt == null) return;

    _analyticsLogged = true;
    StoryAnalytics.caseCompleted(
      outcome: progress!.outcome!,
      score: progress.totalScore,
    );
  }

  Future<void> _maybeShowInterstitial() async {
    if (_interstitialShown ||
        !getIt<MonetizationConfig>().isMonetizationAndPurchasesEnabled ||
        !getIt.isRegistered<AdService>()) {
      return;
    }
    _interstitialShown = true;
    await getIt<AdService>().showInterstitialIfAllowed();
  }

  Future<void> _shareResults(StoryFlowReady readyState) async {
    final progress = readyState.progress;
    if (progress == null) return;

    await StoryAnalytics.shareTapped();
    final text = StoryShareFormatter.format(
      detectiveCase: readyState.detectiveCase,
      progress: progress,
    );
    await Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoryFlowBloc, StoryFlowState>(
      builder: (context, flowState) {
        return flowState.maybeMap(
          ready: (readyState) {
            final progress = readyState.progress;

            return StoryNarrativeScaffold(
              title: 'Case Resolution',
              panelLabel: 'VERDICT',
              headline: readyState.detectiveCase.title,
              body: readyState.detectiveCase.resolution,
              bodyWidget: progress == null
                  ? null
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 32),
                        CaseScoreBreakdown(
                          detectiveCase: readyState.detectiveCase,
                          progress: progress,
                        ),
                        const SizedBox(height: 20),
                        AppButton(
                          label: 'Share results',
                          variant: ButtonVariant.secondary,
                          icon: Icons.share_rounded,
                          onTap: () => _shareResults(readyState),
                        ),
                      ],
                    ),
              continueLabel: 'Return to case file',
              onContinue: () => context.go(StoryHomePage.routeName),
            );
          },
          orElse: () => const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

class CaseResolutionGate extends StatelessWidget {
  const CaseResolutionGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoryFlowBloc, StoryFlowState>(
      builder: (context, flowState) {
        if (!StoryFlowGating.canAccessResolution(flowState)) {
          return const Center(child: CircularProgressIndicator());
        }
        return const CaseResolutionPage();
      },
    );
  }
}
