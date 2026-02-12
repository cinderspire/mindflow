import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// RevenueCat configuration
class RevenueCatConfig {
  // TODO: Replace with your actual RevenueCat API keys
  static const String appleApiKey = 'appl_YOUR_REVENUECAT_API_KEY';
  static const String googleApiKey = 'goog_YOUR_REVENUECAT_API_KEY';

  static const String premiumEntitlement = 'premium';
  static const String premiumMonthlyId = 'simon_premium_monthly';
  static const String premiumYearlyId = 'simon_premium_yearly';
}

/// Subscription state
class SubscriptionState {
  final bool isPremium;
  final String? activeSubscriptionId;
  final DateTime? expirationDate;
  final List<Package> availablePackages;
  final bool isLoading;
  final String? error;

  const SubscriptionState({
    this.isPremium = false,
    this.activeSubscriptionId,
    this.expirationDate,
    this.availablePackages = const [],
    this.isLoading = false,
    this.error,
  });

  SubscriptionState copyWith({
    bool? isPremium,
    String? activeSubscriptionId,
    DateTime? expirationDate,
    List<Package>? availablePackages,
    bool? isLoading,
    String? error,
  }) {
    return SubscriptionState(
      isPremium: isPremium ?? this.isPremium,
      activeSubscriptionId: activeSubscriptionId ?? this.activeSubscriptionId,
      expirationDate: expirationDate ?? this.expirationDate,
      availablePackages: availablePackages ?? this.availablePackages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// RevenueCat service notifier
class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  SubscriptionNotifier() : super(const SubscriptionState()) {
    _init();
  }

  Future<void> _init() async {
    state = state.copyWith(isLoading: true);
    try {
      final config = PurchasesConfiguration(
        defaultTargetPlatform == TargetPlatform.iOS
            ? RevenueCatConfig.appleApiKey
            : RevenueCatConfig.googleApiKey,
      );
      await Purchases.configure(config);

      // Check current entitlements
      await refreshPurchaserInfo();

      // Load offerings
      await loadOfferings();
    } catch (e) {
      debugPrint('RevenueCat init error: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refreshPurchaserInfo() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final isPremium = customerInfo
          .entitlements.active.containsKey(RevenueCatConfig.premiumEntitlement);

      EntitlementInfo? activeEntitlement;
      if (isPremium) {
        activeEntitlement =
            customerInfo.entitlements.active[RevenueCatConfig.premiumEntitlement];
      }

      state = state.copyWith(
        isPremium: isPremium,
        activeSubscriptionId: activeEntitlement?.productIdentifier,
        expirationDate: activeEntitlement?.expirationDate != null
            ? DateTime.tryParse(activeEntitlement!.expirationDate!)
            : null,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      debugPrint('Error refreshing purchaser info: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> loadOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      if (offerings.current != null) {
        state = state.copyWith(
          availablePackages: offerings.current!.availablePackages,
        );
      }
    } catch (e) {
      debugPrint('Error loading offerings: $e');
    }
  }

  Future<bool> purchasePackage(Package package) async {
    try {
      state = state.copyWith(isLoading: true);
      final customerInfo = await Purchases.purchasePackage(package);
      final isPremium = customerInfo
          .entitlements.active.containsKey(RevenueCatConfig.premiumEntitlement);

      state = state.copyWith(isPremium: isPremium, isLoading: false);
      return isPremium;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> restorePurchases() async {
    try {
      state = state.copyWith(isLoading: true);
      final customerInfo = await Purchases.restorePurchases();
      final isPremium = customerInfo
          .entitlements.active.containsKey(RevenueCatConfig.premiumEntitlement);
      state = state.copyWith(isPremium: isPremium, isLoading: false);
      return isPremium;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

/// Providers
final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionState>(
  (ref) => SubscriptionNotifier(),
);

final isPremiumProvider = Provider<bool>((ref) {
  return ref.watch(subscriptionProvider).isPremium;
});
