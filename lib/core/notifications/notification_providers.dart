import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/isar_providers.dart';
import 'notification_log_repository.dart';
import 'notification_service.dart';
import 'notification_sync_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final service = NotificationService();
  ref.onDispose(() {
    unawaited(service.dispose());
  });
  return service;
});

final notificationLogRepositoryProvider =
    FutureProvider<NotificationLogRepository>((ref) async {
      final isar = await ref.watch(isarInstanceProvider.future);
      return NotificationLogRepository(isar);
    });

final notificationSyncServiceProvider = FutureProvider<NotificationSyncService>(
  (ref) async {
    final logRepository = await ref.watch(
      notificationLogRepositoryProvider.future,
    );
    final notificationService = ref.watch(notificationServiceProvider);
    return NotificationSyncService(
      notificationService: notificationService,
      notificationLogRepository: logRepository,
    );
  },
);
