import 'package:isar/isar.dart';

import '../domain/sync_models.dart';

part 'pending_sync_operation.g.dart';

@collection
class PendingSyncOperationRecord {
  PendingSyncOperationRecord({
    required this.operationId,
    required this.entityType,
    required this.entityId,
    required this.operationType,
    required this.status,
    required this.createdAt,
    required this.lastModifiedAt,
    this.payloadJson,
    this.retryCount = 0,
    this.lastError,
    this.lastAttemptAt,
  });

  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String operationId;

  @Enumerated(EnumType.name)
  late SyncEntityType entityType;

  @Index()
  late String entityId;

  @Enumerated(EnumType.name)
  late SyncOperationType operationType;

  @Enumerated(EnumType.name)
  late SyncOperationStatus status;

  @Index()
  late DateTime createdAt;

  late DateTime lastModifiedAt;
  String? payloadJson;
  late int retryCount;
  String? lastError;
  DateTime? lastAttemptAt;

  String get syncKey => '${entityType.name}::$entityId';
}

