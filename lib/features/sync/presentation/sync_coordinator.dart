import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/providers/settings_providers.dart';
import '../providers/sync_providers.dart';

class SyncCoordinator extends ConsumerStatefulWidget {
  const SyncCoordinator({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<SyncCoordinator> createState() => _SyncCoordinatorState();
}

class _SyncCoordinatorState extends ConsumerState<SyncCoordinator>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerSyncIfAppropriate();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _triggerSyncIfAppropriate();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      watchPendingSyncOperationsProvider,
      (_, next) {
        if ((next.valueOrNull?.length ?? 0) > 0) {
          ref.read(syncActionControllerProvider.notifier).scheduleAutoSync();
        }
      },
    );
    return widget.child;
  }

  void _triggerSyncIfAppropriate() {
    final preferences = ref.read(notificationPreferencesProvider).valueOrNull;
    final summary = ref.read(syncStatusSummaryProvider).valueOrNull;
    final preferredConnection = ref.read(isPreferredSyncConnectionProvider);
    if (preferences == null || summary == null) {
      return;
    }
    if (!preferences.syncEnabled || !preferences.autoSyncEnabled) {
      return;
    }
    if (!summary.isConfigured ||
        !summary.isSignedIn ||
        !summary.isOnline ||
        !preferredConnection) {
      return;
    }
    ref.read(syncActionControllerProvider.notifier).scheduleAutoSync();
  }
}

