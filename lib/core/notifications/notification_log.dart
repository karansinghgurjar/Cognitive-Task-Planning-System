import 'package:isar/isar.dart';

part 'notification_log.g.dart';

@collection
class NotificationLogEntry {
  NotificationLogEntry({
    required this.uniqueKey,
    required this.type,
    required this.entityId,
    required this.dateKey,
    required this.sentAt,
  });

  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uniqueKey;

  late String type;
  late String entityId;
  late String dateKey;
  late DateTime sentAt;
}
