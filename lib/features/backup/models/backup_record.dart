import 'package:isar/isar.dart';

part 'backup_record.g.dart';

enum BackupRecordType {
  fullJson,
  tasksCsv,
  sessionsCsv,
  goalsCsv,
  analyticsCsv,
  integrityReport,
}

enum BackupRecordStatus { success, failed, cancelled }

@collection
class BackupRecord {
  BackupRecord({
    required this.createdAt,
    required this.backupType,
    required this.recordCount,
    required this.status,
    this.filePath,
  });

  Id id = Isar.autoIncrement;

  late DateTime createdAt;
  String? filePath;

  @Enumerated(EnumType.name)
  late BackupRecordType backupType;

  late int recordCount;

  @Enumerated(EnumType.name)
  late BackupRecordStatus status;
}
