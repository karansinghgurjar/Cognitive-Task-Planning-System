import 'package:isar/isar.dart';

import '../../sync/data/sync_mutation_recorder.dart';
import '../../sync/domain/sync_models.dart';
import '../models/notification_preferences.dart';

class SettingsRepository {
  SettingsRepository(
    this._isar, {
    SyncMutationRecorder syncMutationRecorder = const NoopSyncMutationRecorder(),
  }) : _syncMutationRecorder = syncMutationRecorder;

  static const defaultPreferencesId = 1;

  final Isar _isar;
  final SyncMutationRecorder _syncMutationRecorder;

  Future<NotificationPreferences> getPreferences() async {
    final existing = await _isar.notificationPreferences.get(
      defaultPreferencesId,
    );
    if (existing != null) {
      return existing;
    }

    final defaults = NotificationPreferences(id: defaultPreferencesId);
    await _isar.writeTxn(() async {
      await _isar.notificationPreferences.put(defaults);
    });
    return defaults;
  }

  Stream<NotificationPreferences> watchPreferences() async* {
    yield await getPreferences();
    yield* _isar.notificationPreferences
        .watchObject(defaultPreferencesId, fireImmediately: false)
        .asyncMap((value) async => value ?? getPreferences());
  }

  Future<void> updatePreferences(NotificationPreferences preferences) async {
    await _isar.writeTxn(() async {
      await _isar.notificationPreferences.put(preferences);
    });
    await _syncMutationRecorder.recordUpsert(
      entityType: SyncEntityType.notificationPreferences,
      entityId: 'preferences',
      entity: preferences,
      operationType: SyncOperationType.update,
    );
  }
}
