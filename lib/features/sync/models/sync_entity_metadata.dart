import 'package:isar/isar.dart';

import '../domain/sync_models.dart';

part 'sync_entity_metadata.g.dart';

@collection
class SyncEntityMetadata {
  SyncEntityMetadata({
    required this.syncKey,
    required this.entityType,
    required this.entityId,
    required this.lastModifiedAt,
    this.lastSyncedAt,
    this.isDeleted = false,
    this.syncState = SyncState.localOnly,
    this.lastModifiedByDeviceId,
    this.lastConflictSummary,
    this.lastError,
  });

  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String syncKey;

  @Enumerated(EnumType.name)
  late SyncEntityType entityType;

  @Index()
  late String entityId;

  late DateTime lastModifiedAt;
  DateTime? lastSyncedAt;
  late bool isDeleted;

  @Enumerated(EnumType.name)
  late SyncState syncState;

  String? lastModifiedByDeviceId;
  String? lastConflictSummary;
  String? lastError;
}

