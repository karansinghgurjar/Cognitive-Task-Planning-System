import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/isar_providers.dart';
import '../../settings/providers/settings_providers.dart';
import '../data/auth_sync_service.dart';
import '../data/local_sync_store.dart';
import '../data/remote_sync_repository.dart';
import '../data/sync_mutation_recorder.dart';
import '../data/sync_queue_repository.dart';
import '../data/sync_run_repository.dart';
import '../data/sync_state_repository.dart';
import '../domain/bootstrap_sync_service.dart';
import '../domain/conflict_resolution_service.dart';
import '../domain/sync_engine_service.dart';
import '../domain/sync_models.dart';
import '../models/pending_sync_operation.dart';
import '../models/sync_entity_metadata.dart';
import '../models/sync_local_state.dart';
import '../models/sync_run_record.dart';

final authSyncServiceProvider = Provider<AuthSyncService>((ref) {
  return const AuthSyncService();
});

final connectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

final connectivityResultsProvider = StreamProvider<List<ConnectivityResult>>((
  ref,
) async* {
  final connectivity = ref.watch(connectivityProvider);
  yield await connectivity.checkConnectivity();
  yield* connectivity.onConnectivityChanged;
});

final isOnlineProvider = Provider<bool>((ref) {
  final results = ref.watch(connectivityResultsProvider).valueOrNull;
  if (results == null || results.isEmpty) {
    return true;
  }
  return results.any((result) => result != ConnectivityResult.none);
});

final isPreferredSyncConnectionProvider = Provider<bool>((ref) {
  final results = ref.watch(connectivityResultsProvider).valueOrNull;
  final preferences = ref.watch(notificationPreferencesProvider).valueOrNull;
  if (results == null || results.isEmpty) {
    return true;
  }
  if (preferences == null || !preferences.syncOnWifiOnly) {
    return results.any((result) => result != ConnectivityResult.none);
  }
  return results.any(
    (result) =>
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet,
  );
});

final syncQueueRepositoryProvider = FutureProvider<SyncQueueRepository>((
  ref,
) async {
  final isar = await ref.watch(isarInstanceProvider.future);
  return SyncQueueRepository(isar);
});

final syncStateRepositoryProvider = FutureProvider<SyncStateRepository>((
  ref,
) async {
  final isar = await ref.watch(isarInstanceProvider.future);
  return SyncStateRepository(isar);
});

final syncRunRepositoryProvider = FutureProvider<SyncRunRepository>((
  ref,
) async {
  final isar = await ref.watch(isarInstanceProvider.future);
  return SyncRunRepository(isar);
});

final localSyncStoreProvider = FutureProvider<LocalSyncStore>((ref) async {
  final isar = await ref.watch(isarInstanceProvider.future);
  return LocalSyncStore(isar);
});

final remoteSyncRepositoryProvider = Provider<RemoteSyncRepository>((ref) {
  return SupabaseRemoteSyncRepository(
    authService: ref.read(authSyncServiceProvider),
  );
});

final conflictResolutionServiceProvider = Provider<ConflictResolutionService>((
  ref,
) {
  return const ConflictResolutionService();
});

final bootstrapSyncServiceProvider = Provider<BootstrapSyncService>((ref) {
  return const BootstrapSyncService();
});

final syncMutationRecorderProvider = FutureProvider<SyncMutationRecorder>((
  ref,
) async {
  final queue = await ref.watch(syncQueueRepositoryProvider.future);
  final state = await ref.watch(syncStateRepositoryProvider.future);
  return LocalSyncMutationRecorder(
    queueRepository: queue,
    stateRepository: state,
  );
});

final syncAccountProvider = StreamProvider<SyncAccountSummary>((ref) {
  return ref.watch(authSyncServiceProvider).watchAccount();
});

final watchPendingSyncOperationsProvider =
    StreamProvider<List<PendingSyncOperationRecord>>((ref) async* {
      final repository = await ref.watch(syncQueueRepositoryProvider.future);
      yield* repository.watchPendingOperations();
    });

final watchAllSyncOperationsProvider =
    StreamProvider<List<PendingSyncOperationRecord>>((ref) async* {
      final repository = await ref.watch(syncQueueRepositoryProvider.future);
      yield* repository.watchAllOperations();
    });

final watchSyncConflictsProvider = StreamProvider<List<SyncEntityMetadata>>((
  ref,
) async* {
  final repository = await ref.watch(syncStateRepositoryProvider.future);
  yield* repository.watchConflictMetadata();
});

final syncLocalStateProvider = StreamProvider<SyncLocalState>((ref) async* {
  final repository = await ref.watch(syncStateRepositoryProvider.future);
  yield* repository.watchLocalState();
});

final watchSyncRunsProvider = StreamProvider<List<SyncRunRecord>>((ref) async* {
  final repository = await ref.watch(syncRunRepositoryProvider.future);
  yield* repository.watchRecentRuns();
});

final syncEngineServiceProvider = FutureProvider<SyncEngineService>((
  ref,
) async {
  final queue = await ref.watch(syncQueueRepositoryProvider.future);
  final state = await ref.watch(syncStateRepositoryProvider.future);
  final localStore = await ref.watch(localSyncStoreProvider.future);
  final runRepository = await ref.watch(syncRunRepositoryProvider.future);
  return SyncEngineService(
    authService: ref.read(authSyncServiceProvider),
    queueRepository: queue,
    stateRepository: state,
    localSyncStore: localStore,
    remoteSyncRepository: ref.read(remoteSyncRepositoryProvider),
    syncRunRepository: runRepository,
    conflictResolutionService: ref.read(conflictResolutionServiceProvider),
    bootstrapSyncService: ref.read(bootstrapSyncServiceProvider),
    isOnline: () async => ref.read(isOnlineProvider),
  );
});

final syncStatusSummaryProvider = Provider<AsyncValue<SyncStatusSummary>>((
  ref,
) {
  final accountAsync = ref.watch(syncAccountProvider);
  final queueAsync = ref.watch(watchAllSyncOperationsProvider);
  final conflictsAsync = ref.watch(watchSyncConflictsProvider);
  final localStateAsync = ref.watch(syncLocalStateProvider);
  final preferencesAsync = ref.watch(notificationPreferencesProvider);
  final online = ref.watch(isOnlineProvider);

  return switch ((
    accountAsync,
    queueAsync,
    conflictsAsync,
    localStateAsync,
    preferencesAsync,
  )) {
    (
      AsyncData(value: final account),
      AsyncData(value: final operations),
      AsyncData(value: final conflicts),
      AsyncData(value: final localState),
      AsyncData(value: final preferences),
    ) =>
      AsyncData(
        SyncStatusSummary(
          isConfigured: account.isConfigured,
          isSignedIn: account.isSignedIn,
          isSyncEnabled: preferences.syncEnabled,
          isOnline: online,
          pendingCount: operations
              .where((item) => item.status == SyncOperationStatus.pending)
              .length,
          failedCount: operations
              .where((item) => item.status == SyncOperationStatus.failed)
              .length,
          conflictCount: conflicts.length,
          autoSyncEnabled: preferences.autoSyncEnabled,
          lastSyncAt: localState.lastSyncAt,
          lastSyncError: localState.lastSyncError,
          email: account.email,
          deviceId: localState.deviceId,
        ),
      ),
    (AsyncError(:final error, :final stackTrace), _, _, _, _) => AsyncError(
      error,
      stackTrace,
    ),
    (_, AsyncError(:final error, :final stackTrace), _, _, _) => AsyncError(
      error,
      stackTrace,
    ),
    (_, _, AsyncError(:final error, :final stackTrace), _, _) => AsyncError(
      error,
      stackTrace,
    ),
    (_, _, _, AsyncError(:final error, :final stackTrace), _) => AsyncError(
      error,
      stackTrace,
    ),
    (_, _, _, _, AsyncError(:final error, :final stackTrace)) => AsyncError(
      error,
      stackTrace,
    ),
    _ => const AsyncLoading(),
  };
});

final bootstrapPlanProvider = FutureProvider<BootstrapPlan>((ref) async {
  final engine = await ref.watch(syncEngineServiceProvider.future);
  return engine.prepareBootstrapPlan();
});

final syncActionControllerProvider =
    AsyncNotifierProvider<SyncActionController, SyncResult?>(
      SyncActionController.new,
    );

class SyncActionController extends AsyncNotifier<SyncResult?> {
  Timer? _debounceTimer;

  @override
  SyncResult? build() {
    ref.onDispose(() {
      _debounceTimer?.cancel();
    });
    return null;
  }

  Future<void> signIn({required String email, required String password}) async {
    await _run(() async {
      await ref
          .read(authSyncServiceProvider)
          .signIn(email: email, password: password);
      _invalidateSyncState();
    }, preserveValue: true);
  }

  Future<void> signUp({required String email, required String password}) async {
    await _run(() async {
      await ref
          .read(authSyncServiceProvider)
          .signUp(email: email, password: password);
      _invalidateSyncState();
    }, preserveValue: true);
  }

  Future<void> signOut() async {
    await _run(() async {
      await ref.read(authSyncServiceProvider).signOut();
      _invalidateSyncState();
    }, preserveValue: true);
  }

  Future<SyncResult> syncNow() async {
    return _runResult(() async {
      final engine = await ref.read(syncEngineServiceProvider.future);
      final result = await engine.syncNow();
      ref.invalidate(syncLocalStateProvider);
      ref.invalidate(watchAllSyncOperationsProvider);
      ref.invalidate(watchSyncConflictsProvider);
      ref.invalidate(watchSyncRunsProvider);
      ref.invalidate(bootstrapPlanProvider);
      debugPrint(
        'Sync result: pushed=${result.pushedCount} pulled=${result.pulledCount} conflicts=${result.conflicts.length} errors=${result.errors.length}',
      );
      return result;
    });
  }

  Future<SyncResult> retryFailed() async {
    return _runResult(() async {
      final engine = await ref.read(syncEngineServiceProvider.future);
      final result = await engine.retryFailedChanges();
      ref.invalidate(watchAllSyncOperationsProvider);
      ref.invalidate(watchSyncRunsProvider);
      return result;
    });
  }

  Future<SyncResult> applyBootstrapChoice(BootstrapChoice choice) async {
    return _runResult(() async {
      final engine = await ref.read(syncEngineServiceProvider.future);
      final result = await engine.applyBootstrapChoice(choice);
      ref.invalidate(bootstrapPlanProvider);
      ref.invalidate(syncLocalStateProvider);
      ref.invalidate(watchSyncRunsProvider);
      return result;
    });
  }

  void scheduleAutoSync() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 20), () {
      final summary = ref.read(syncStatusSummaryProvider).valueOrNull;
      final preferredConnection = ref.read(isPreferredSyncConnectionProvider);
      if (summary == null || !summary.isConfigured || !summary.isSignedIn) {
        return;
      }
      if (!summary.isSyncEnabled ||
          !summary.autoSyncEnabled ||
          !summary.isOnline ||
          !preferredConnection) {
        return;
      }
      unawaited(syncNow());
    });
  }

  Future<void> _run(
    Future<void> Function() action, {
    required bool preserveValue,
  }) async {
    _ensureIdle();
    final previous = state.valueOrNull;
    state = const AsyncLoading();
    try {
      await action();
      state = AsyncData(preserveValue ? previous : null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<SyncResult> _runResult(Future<SyncResult> Function() action) async {
    _ensureIdle();
    state = const AsyncLoading();
    try {
      final result = await action();
      state = AsyncData(result);
      return result;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  void _ensureIdle() {
    if (state.isLoading) {
      throw StateError('Another sync action is already in progress.');
    }
  }

  void _invalidateSyncState() {
    ref.invalidate(syncAccountProvider);
    ref.invalidate(syncLocalStateProvider);
    ref.invalidate(watchAllSyncOperationsProvider);
    ref.invalidate(watchSyncConflictsProvider);
    ref.invalidate(watchSyncRunsProvider);
    ref.invalidate(bootstrapPlanProvider);
  }
}
