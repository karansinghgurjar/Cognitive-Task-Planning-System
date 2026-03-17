import 'package:isar/isar.dart';

part 'sync_local_state.g.dart';

@collection
class SyncLocalState {
  SyncLocalState({
    this.id = 1,
    required this.deviceId,
    this.lastSyncAt,
    this.lastPullAt,
    this.lastUserId,
    this.lastSyncError,
    this.bootstrapPending = false,
    this.bootstrapMessage,
  });

  Id id;
  late String deviceId;
  DateTime? lastSyncAt;
  DateTime? lastPullAt;
  String? lastUserId;
  String? lastSyncError;
  late bool bootstrapPending;
  String? bootstrapMessage;
}

