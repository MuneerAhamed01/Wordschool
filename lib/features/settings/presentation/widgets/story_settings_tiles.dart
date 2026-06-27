import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/core/config/monetization_config.dart';
import 'package:wordshool/core/monetization/iap_products.dart';
import 'package:wordshool/core/monetization/iap_service.dart';
import 'package:wordshool/di.dart';
import 'package:wordshool/features/story_mode/presentation/utils/story_audio_manager.dart';
import 'package:wordshool/shared/presentations/widgets/action_tile.dart';
import 'package:wordshool/shared/presentations/widgets/snackbar.dart';

class StoryAudioSettingTile extends StatefulWidget {
  const StoryAudioSettingTile({super.key});

  @override
  State<StoryAudioSettingTile> createState() => _StoryAudioSettingTileState();
}

class _StoryAudioSettingTileState extends State<StoryAudioSettingTile> {
  bool _muted = false;

  @override
  void initState() {
    super.initState();
    if (getIt.isRegistered<StoryAudioManager>()) {
      _muted = getIt<StoryAudioManager>().isMuted;
    }
  }

  Future<void> _toggle(bool value) async {
    if (!getIt.isRegistered<StoryAudioManager>()) return;
    await getIt<StoryAudioManager>().setMuted(value);
    if (mounted) {
      setState(() => _muted = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!getIt.isRegistered<StoryAudioManager>()) {
      return const SizedBox.shrink();
    }

    return ActionTile(
      title: 'Story audio',
      subtitle: _muted ? 'Muted' : 'Rain & sound effects on',
      icon: _muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
      accentColor: MyColors.gray6,
      trailing: Switch(
        value: !_muted,
        onChanged: (enabled) => _toggle(!enabled),
      ),
      onTap: () => _toggle(!_muted),
    );
  }
}

class DetectiveUpgradeTiles extends StatelessWidget {
  const DetectiveUpgradeTiles({super.key});

  Future<void> _buy(BuildContext context, String productId) async {
    if (!getIt.isRegistered<IapService>()) return;
    await getIt<IapService>().buyProduct(productId: productId);
    if (context.mounted) {
      CustomSnackBar.show(
        context,
        message: 'Purchase started — follow store prompts',
        type: SnackBarType.success,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!getIt<MonetizationConfig>().isMonetizationAndPurchasesEnabled) {
      return const SizedBox.shrink();
    }
    if (!getIt.isRegistered<IapService>()) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        ActionTile(
          title: 'Remove ads',
          subtitle: 'Hide banners and interstitials',
          icon: Icons.block_rounded,
          accentColor: MyColors.lightBlue3,
          onTap: () => _buy(context, IapProducts.removeAds),
        ),
        const SizedBox(height: 10),
        ActionTile(
          title: 'Hint pack (5)',
          subtitle: 'Extra letter reveals in story mode',
          icon: Icons.lightbulb_outline_rounded,
          accentColor: MyColors.streakAccent,
          onTap: () => _buy(context, IapProducts.hintPack5),
        ),
        const SizedBox(height: 10),
        ActionTile(
          title: 'Detective Pro',
          subtitle: 'Ad-free + unlimited hints',
          icon: Icons.workspace_premium_rounded,
          accentColor: MyColors.tileCorrect,
          onTap: () => _buy(context, IapProducts.detectiveProMonthly),
        ),
      ],
    );
  }
}
