import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:wordshool/core/analytics/analytics_events.dart';
import 'package:wordshool/core/analytics/analytics_service.dart';
import 'package:wordshool/core/monetization/iap_products.dart';
import 'package:wordshool/core/monetization/story_entitlements.dart';
import 'package:wordshool/shared/data/data_source/user_game_state_service.dart';
import 'package:wordshool/shared/domains/usercases/get_current_user_usecase.dart';

class IapService {
  IapService({
    required UserGameStateDataSource userGameStateDataSource,
    required AnalyticsService analytics,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required StoryEntitlementsService entitlementsService,
  })  : _userGameStateDataSource = userGameStateDataSource,
        _analytics = analytics,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _entitlementsService = entitlementsService;

  final UserGameStateDataSource _userGameStateDataSource;
  final AnalyticsService _analytics;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final StoryEntitlementsService _entitlementsService;
  final InAppPurchase _iap = InAppPurchase.instance;

  StreamSubscription<List<PurchaseDetails>>? _subscription;
  bool _available = false;

  Future<void> initialize() async {
    _available = await _iap.isAvailable();
    if (!_available) return;

    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (error) => debugPrint('IAP stream error: $error'),
    );
  }

  Future<void> restorePurchases() => _iap.restorePurchases();

  Future<void> buyProduct({
    required String productId,
    String placement = AnalyticsPlacements.settingsUpgrade,
  }) async {
    if (!_available) return;

    final user = await _getCurrentUserUseCase();
    if (user == null) return;

    await _analytics.logPurchaseStarted(
      productId: productId,
      placement: placement,
    );

    final response = await _iap.queryProductDetails(IapProducts.all.toSet());
    final product = response.productDetails
        .where((item) => item.id == productId)
        .firstOrNull;
    if (product == null) {
      await _analytics.logPurchaseFailed(
        productId: productId,
        reason: 'product_not_found',
      );
      return;
    }

    final purchaseParam = PurchaseParam(productDetails: product);
    if (productId == IapProducts.hintPack5) {
      await _iap.buyConsumable(purchaseParam: purchaseParam);
    } else {
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    }
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.error) {
        await _analytics.logPurchaseFailed(
          productId: purchase.productID,
          reason: purchase.error?.message ?? 'unknown',
        );
        continue;
      }

      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        await _applyPurchase(purchase.productID);
        await _analytics.logPurchaseCompleted(
          productId: purchase.productID,
          productType: _productType(purchase.productID),
        );
      }

      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  Future<void> _applyPurchase(String productId) async {
    final user = await _getCurrentUserUseCase();
    if (user == null) return;

    await _userGameStateDataSource.applyMonetizationPurchase(
      user.id,
      productId: productId,
    );
    await _entitlementsService.refresh();
  }

  String _productType(String productId) {
    if (productId == IapProducts.hintPack5) return 'consumable';
    if (productId == IapProducts.detectiveProMonthly) return 'subscription';
    return 'non_consumable';
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
  }
}
