import 'package:isar/isar.dart';

part 'sync_run_record.g.dart';

enum SyncRunStatus { success, failed, skipped }

@collection
class SyncRunRecord {
  SyncRunRecord({
    required this.startedAt,
    required this.finishedAt,
    required this.status,
    required this.pushedCount,
    required this.pulledCount,
    required this.conflictCount,
    this.errorSummary,
  });

  Id isarId = Isar.autoIncrement;

  @Index()
  late DateTime startedAt;

  late DateTime finishedAt;

  @Enumerated(EnumType.name)
  late SyncRunStatus status;

  late int pushedCount;
  late int pulledCount;
  late int conflictCount;
  String? errorSummary;
}

