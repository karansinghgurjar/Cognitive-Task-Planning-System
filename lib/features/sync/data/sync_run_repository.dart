// ignore_for_file: annotate_overrides

import 'package:isar/isar.dart';

import '../domain/sync_store_contracts.dart';
import '../models/sync_run_record.dart';

class SyncRunRepository implements SyncRunStore {
  SyncRunRepository(this._isar);

  final Isar _isar;

  Future<void> addRun(SyncRunRecord run) {
    return _isar.writeTxn(() async {
      await _isar.syncRunRecords.put(run);
    });
  }

  Future<List<SyncRunRecord>> getRecentRuns() async {
    final runs = await _isar.syncRunRecords.where().findAll();
    runs.sort((left, right) => right.startedAt.compareTo(left.startedAt));
    return runs.take(20).toList();
  }

  Stream<List<SyncRunRecord>> watchRecentRuns() {
    return _isar.syncRunRecords.watchLazy(fireImmediately: true).asyncMap((_) {
      return getRecentRuns();
    });
  }
}
