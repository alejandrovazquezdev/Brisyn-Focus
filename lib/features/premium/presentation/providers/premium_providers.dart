import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../../core/services/purchase_service.dart';
import '../../../../core/services/cloud_sync_service.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

// ============================================
// PURCHASE SERVICE PROVIDERS
// ============================================

/// Purchase service provider (singleton)
final purchaseServiceProvider = Provider<PurchaseService>((ref) {
  return PurchaseService.instance;
});

/// Premium status stream provider
final premiumStatusStreamProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(purchaseServiceProvider);
  return service.premiumStatusStream;
});

/// Current premium status provider
final isPremiumProvider = Provider<bool>((ref) {
  // Watch the stream for updates
  final streamValue = ref.watch(premiumStatusStreamProvider);
  // Fall back to service's current value
  final service = ref.watch(purchaseServiceProvider);
  return streamValue.value ?? service.isPremium;
});

/// Available packages provider
final packagesProvider = Provider<List<Package>>((ref) {
  final service = ref.watch(purchaseServiceProvider);
  return service.packages;
});

/// Monthly package provider
final monthlyPackageProvider = Provider<Package?>((ref) {
  final service = ref.watch(purchaseServiceProvider);
  return service.monthlyPackage;
});

/// Yearly package provider
final yearlyPackageProvider = Provider<Package?>((ref) {
  final service = ref.watch(purchaseServiceProvider);
  return service.yearlyPackage;
});

/// Premium expiration date provider
final premiumExpirationProvider = Provider<DateTime?>((ref) {
  final service = ref.watch(purchaseServiceProvider);
  return service.premiumExpirationDate;
});

/// Subscription will renew provider
final willRenewProvider = Provider<bool>((ref) {
  final service = ref.watch(purchaseServiceProvider);
  return service.willRenew;
});

// ============================================
// CLOUD SYNC SERVICE PROVIDERS
// ============================================

/// Cloud sync service provider
final cloudSyncServiceProvider = Provider<CloudSyncService>((ref) {
  return CloudSyncService();
});

/// Sync status stream provider
final syncStatusStreamProvider = StreamProvider<SyncStatus>((ref) {
  final service = ref.watch(cloudSyncServiceProvider);
  return service.syncStatusStream;
});

/// Current sync status provider
final syncStatusProvider = Provider<SyncStatus>((ref) {
  final streamValue = ref.watch(syncStatusStreamProvider);
  final service = ref.watch(cloudSyncServiceProvider);
  return streamValue.value ?? service.currentStatus;
});

/// Last sync time provider
final lastSyncTimeProvider = Provider<DateTime?>((ref) {
  final service = ref.watch(cloudSyncServiceProvider);
  return service.lastSyncTime;
});

/// Cloud sync enabled provider (premium + logged in)
final cloudSyncEnabledProvider = Provider<bool>((ref) {
  final isPremium = ref.watch(isPremiumProvider);
  final isLoggedIn = ref.watch(isLoggedInProvider);
  return isPremium && isLoggedIn;
});

// ============================================
// PURCHASE STATE NOTIFIER
// ============================================

/// Purchase state for UI
class PurchaseState {
  final bool isLoading;
  final String? error;
  final bool purchaseSuccess;

  const PurchaseState({
    this.isLoading = false,
    this.error,
    this.purchaseSuccess = false,
  });

  PurchaseState copyWith({
    bool? isLoading,
    String? error,
    bool? purchaseSuccess,
  }) {
    return PurchaseState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      purchaseSuccess: purchaseSuccess ?? this.purchaseSuccess,
    );
  }
}

/// Purchase notifier for managing purchase flow
class PurchaseNotifier extends StateNotifier<PurchaseState> {
  final PurchaseService _purchaseService;

  PurchaseNotifier(this._purchaseService) : super(const PurchaseState());

  /// Purchase monthly subscription
  Future<bool> purchaseMonthly() async {
    final package = _purchaseService.monthlyPackage;
    if (package == null) {
      state = state.copyWith(error: 'Monthly package not available');
      return false;
    }
    return _purchasePackage(package);
  }

  /// Purchase yearly subscription
  Future<bool> purchaseYearly() async {
    final package = _purchaseService.yearlyPackage;
    if (package == null) {
      state = state.copyWith(error: 'Yearly package not available');
      return false;
    }
    return _purchasePackage(package);
  }

  /// Purchase a specific package
  Future<bool> _purchasePackage(Package package) async {
    state = state.copyWith(isLoading: true, error: null, purchaseSuccess: false);

    final result = await _purchaseService.purchasePackage(package);

    if (result.success) {
      state = state.copyWith(isLoading: false, purchaseSuccess: true);
      return true;
    } else {
      state = state.copyWith(isLoading: false, error: result.error);
      return false;
    }
  }

  /// Restore purchases
  Future<bool> restorePurchases() async {
    state = state.copyWith(isLoading: true, error: null, purchaseSuccess: false);

    final result = await _purchaseService.restorePurchases();

    if (result.success) {
      state = state.copyWith(isLoading: false, purchaseSuccess: true);
      return true;
    } else {
      state = state.copyWith(isLoading: false, error: result.error);
      return false;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Reset state
  void reset() {
    state = const PurchaseState();
  }
}

/// Purchase notifier provider
final purchaseNotifierProvider = StateNotifierProvider<PurchaseNotifier, PurchaseState>((ref) {
  final service = ref.watch(purchaseServiceProvider);
  return PurchaseNotifier(service);
});

// ============================================
// SYNC STATE NOTIFIER
// ============================================

/// Sync state for UI
class SyncState {
  final bool isSyncing;
  final String? error;
  final DateTime? lastSync;
  final int itemsSynced;

  const SyncState({
    this.isSyncing = false,
    this.error,
    this.lastSync,
    this.itemsSynced = 0,
  });

  SyncState copyWith({
    bool? isSyncing,
    String? error,
    DateTime? lastSync,
    int? itemsSynced,
  }) {
    return SyncState(
      isSyncing: isSyncing ?? this.isSyncing,
      error: error,
      lastSync: lastSync ?? this.lastSync,
      itemsSynced: itemsSynced ?? this.itemsSynced,
    );
  }
}

/// Sync notifier for managing sync operations
class SyncNotifier extends StateNotifier<SyncState> {
  final CloudSyncService _syncService;

  SyncNotifier(this._syncService) : super(const SyncState());

  /// Perform full sync
  Future<bool> performFullSync({
    required String userId,
    required List tasks,
    required List categories,
    required List sessions,
    required Map<String, dynamic> statistics,
    String? email,
    String? displayName,
    bool isPremium = false,
  }) async {
    state = state.copyWith(isSyncing: true, error: null);

    final result = await _syncService.fullSync(
      userId: userId,
      tasks: tasks.cast(),
      categories: categories.cast(),
      sessions: sessions.cast(),
      statistics: statistics,
      email: email,
      displayName: displayName,
      isPremium: isPremium,
    );

    if (result.success) {
      state = state.copyWith(
        isSyncing: false,
        lastSync: DateTime.now(),
        itemsSynced: result.itemsSynced,
      );
      return true;
    } else {
      state = state.copyWith(isSyncing: false, error: result.error);
      return false;
    }
  }

  /// Download all data from cloud
  Future<Map<String, dynamic>> downloadData(String userId) async {
    state = state.copyWith(isSyncing: true, error: null);

    final data = await _syncService.downloadAllData(userId);

    state = state.copyWith(
      isSyncing: false,
      lastSync: DateTime.now(),
    );

    return data;
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Sync notifier provider
final syncNotifierProvider = StateNotifierProvider<SyncNotifier, SyncState>((ref) {
  final service = ref.watch(cloudSyncServiceProvider);
  return SyncNotifier(service);
});
