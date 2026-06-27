import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Controls ads and in-app purchases. Off by default until the app is stable.
///
/// Set `IS_MONIT_PURCH=true` in `.env` to enable monetization (see `.env.example`).
class MonetizationConfig {
  const MonetizationConfig({
    required this.isMonetizationAndPurchasesEnabled,
  });

  /// When `false`, ads and IAP are fully disabled; hints and story mode stay free.
  final bool isMonetizationAndPurchasesEnabled;

  factory MonetizationConfig.fromEnv() {
    final raw = dotenv.maybeGet('IS_MONIT_PURCH')?.trim().toLowerCase();
    final enabled = raw == 'true' || raw == '1' || raw == 'yes';
    return MonetizationConfig(isMonetizationAndPurchasesEnabled: enabled);
  }
}
