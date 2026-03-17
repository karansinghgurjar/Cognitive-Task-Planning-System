import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/sync_models.dart';
import 'auth_sync_service.dart';

abstract class RemoteSyncRepository {
  bool get isConfigured;

  Future<void> pushChanges(List<SyncEntityEnvelope> changes);

  Future<List<SyncEntityEnvelope>> pullChanges({
    required String userId,
    DateTime? since,
  });

  Future<int> countRemoteEntities(String userId);

  Future<void> replaceAll({
    required String userId,
    required List<SyncEntityEnvelope> entities,
  });
}

class SupabaseRemoteSyncRepository implements RemoteSyncRepository {
  SupabaseRemoteSyncRepository({
    AuthSyncService authService = const AuthSyncService(),
  });

  static const _table = 'sync_entities';

  SupabaseClient get _client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      throw StateError(
        'Sync backend is configured but not initialized. Restart the app or continue using local-only mode.',
      );
    }
  }

  @override
  bool get isConfigured => AuthSyncService.isConfigured;

  @override
  Future<void> pushChanges(List<SyncEntityEnvelope> changes) async {
    if (!isConfigured || changes.isEmpty) {
      return;
    }

    final rows = changes.map((change) => _toRow(change)).toList();
    await _client
        .from(_table)
        .upsert(rows, onConflict: 'user_id,entity_type,entity_id');
  }

  @override
  Future<List<SyncEntityEnvelope>> pullChanges({
    required String userId,
    DateTime? since,
  }) async {
    if (!isConfigured) {
      return const [];
    }

    dynamic query = _client.from(_table).select().eq('user_id', userId);
    if (since != null) {
      query = query.gt('last_modified_at', since.toUtc().toIso8601String());
    }
    final result = await query.order('last_modified_at');
    final rows = (result as List).cast<Map<String, dynamic>>();
    return rows.map(_fromRow).toList();
  }

  @override
  Future<int> countRemoteEntities(String userId) async {
    if (!isConfigured) {
      return 0;
    }
    final result = await _client
        .from(_table)
        .select('entity_id')
        .eq('user_id', userId)
        .eq('is_deleted', false);
    return (result as List).length;
  }

  @override
  Future<void> replaceAll({
    required String userId,
    required List<SyncEntityEnvelope> entities,
  }) async {
    if (!isConfigured) {
      return;
    }

    await _client.from(_table).delete().eq('user_id', userId);
    await pushChanges(entities);
  }

  Map<String, dynamic> _toRow(SyncEntityEnvelope envelope) {
    return {
      'user_id': envelope.userId,
      'entity_type': envelope.entityType.name,
      'entity_id': envelope.entityId,
      'payload': envelope.data,
      'is_deleted': envelope.isDeleted,
      'last_modified_at': envelope.lastModifiedAt.toUtc().toIso8601String(),
      'last_modified_by_device_id': envelope.lastModifiedByDeviceId,
    };
  }

  SyncEntityEnvelope _fromRow(Map<String, dynamic> row) {
    return SyncEntityEnvelope(
      entityType: SyncEntityType.values.byName(row['entity_type'] as String),
      entityId: row['entity_id'] as String,
      userId: row['user_id'] as String,
      data: (row['payload'] as Map?)?.cast<String, dynamic>(),
      isDeleted: row['is_deleted'] as bool? ?? false,
      lastModifiedAt: DateTime.parse(
        row['last_modified_at'] as String,
      ).toLocal(),
      lastModifiedByDeviceId:
          row['last_modified_by_device_id'] as String? ?? 'remote',
    );
  }
}
