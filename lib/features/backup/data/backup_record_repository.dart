import 'package:isar/isar.dart';

import '../models/backup_record.dart';

class BackupRecordRepository {
  BackupRecordRepository(this._isar);

  final Isar _isar;

  Future<List<BackupRecord>> getAllRecords() async {
    final records = await _isar.backupRecords.where().findAll();
    records.sort((left, right) => right.createdAt.compareTo(left.createdAt));
    return records;
  }

  Stream<List<BackupRecord>> watchAllRecords() {
    return _isar.backupRecords.watchLazy(fireImmediately: true).asyncMap((_) {
      return getAllRecords();
    });
  }

  Future<void> addRecord(BackupRecord record) {
    return _isar.writeTxn(() async {
      await _isar.backupRecords.put(record);
    });
  }
}
