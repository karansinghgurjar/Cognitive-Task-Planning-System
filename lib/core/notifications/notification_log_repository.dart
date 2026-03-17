import 'package:isar/isar.dart';

import 'notification_log.dart';

class NotificationLogRepository {
  NotificationLogRepository(this._isar);

  final Isar _isar;

  Future<bool> wasSentToday({
    required String type,
    required String entityId,
    required DateTime now,
  }) async {
    final key = buildUniqueKey(type: type, entityId: entityId, now: now);
    final entry = await _isar.notificationLogEntrys
        .filter()
        .uniqueKeyEqualTo(key)
        .findFirst();
    return entry != null;
  }

  Future<void> markSent({
    required String type,
    required String entityId,
    required DateTime now,
  }) {
    final entry = NotificationLogEntry(
      uniqueKey: buildUniqueKey(type: type, entityId: entityId, now: now),
      type: type,
      entityId: entityId,
      dateKey: _dateKey(now),
      sentAt: now,
    );

    return _isar.writeTxn(() async {
      await _isar.notificationLogEntrys.put(entry);
    });
  }

  static String buildUniqueKey({
    required String type,
    required String entityId,
    required DateTime now,
  }) {
    return '$type|$entityId|${_dateKey(now)}';
  }

  static String _dateKey(DateTime now) {
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }
}
