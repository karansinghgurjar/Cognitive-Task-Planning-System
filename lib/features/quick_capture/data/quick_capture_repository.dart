import 'package:isar/isar.dart';

import '../models/quick_capture_item.dart';

class QuickCaptureRepository {
  QuickCaptureRepository(this._isar);

  final Isar _isar;

  Future<void> addCapture(QuickCaptureItem item) async {
    final itemToStore = item.copyWith(updatedAt: item.updatedAt ?? item.createdAt);
    await _isar.writeTxn(() async {
      await _isar.quickCaptureItems.put(itemToStore);
    });
  }

  Future<void> updateCapture(QuickCaptureItem item) async {
    final itemToStore = item.copyWith(updatedAt: item.updatedAt ?? DateTime.now());
    await _isar.writeTxn(() async {
      await _isar.quickCaptureItems.put(itemToStore);
    });
  }

  Future<void> deleteCapture(String id) async {
    final item = await _isar.quickCaptureItems.filter().idEqualTo(id).findFirst();
    if (item == null) {
      return;
    }

    await _isar.writeTxn(() async {
      await _isar.quickCaptureItems.delete(item.isarId);
    });
  }

  Future<void> markProcessed(
    String id, {
    String? linkedEntityId,
    QuickCaptureProcessedEntityType? processedEntityType,
  }) async {
    final item = await _isar.quickCaptureItems.filter().idEqualTo(id).findFirst();
    if (item == null) {
      return;
    }

    final now = DateTime.now();
    await updateCapture(
      item.copyWith(
        isProcessed: true,
        processedAt: now,
        linkedEntityId: linkedEntityId,
        processedEntityType: processedEntityType,
        updatedAt: now,
      ),
    );
  }

  Future<List<QuickCaptureItem>> getAllCaptures() async {
    final captures = await _isar.quickCaptureItems.where().findAll();
    captures.sort(_compareCaptures);
    return captures;
  }

  Stream<List<QuickCaptureItem>> watchAllCaptures() {
    return _isar.quickCaptureItems.watchLazy(fireImmediately: true).asyncMap((_) {
      return getAllCaptures();
    });
  }

  Future<List<QuickCaptureItem>> getUnprocessedCaptures() async {
    final captures = await _isar.quickCaptureItems.where().findAll();
    final unprocessed = captures.where((item) => !item.isProcessed && !item.isArchived).toList();
    unprocessed.sort(_compareCaptures);
    return unprocessed;
  }

  Stream<List<QuickCaptureItem>> watchUnprocessedCaptures() {
    return _isar.quickCaptureItems.watchLazy(fireImmediately: true).asyncMap((_) {
      return getUnprocessedCaptures();
    });
  }

  int _compareCaptures(QuickCaptureItem left, QuickCaptureItem right) {
    return (right.updatedAt ?? right.createdAt).compareTo(left.updatedAt ?? left.createdAt);
  }
}
