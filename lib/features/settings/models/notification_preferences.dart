import 'package:isar/isar.dart';

part 'notification_preferences.g.dart';

enum BackupReminderCadence { weekly, everyTwoWeeks, monthly }

@collection
class NotificationPreferences {
  NotificationPreferences({
    this.id = 1,
    this.sessionRemindersEnabled = true,
    this.dailySummaryEnabled = true,
    this.deadlineWarningsEnabled = true,
    this.reminderLeadTimeMinutes = 10,
    this.dailySummaryHour = 7,
    this.dailySummaryMinute = 0,
    this.backupReminderEnabled = false,
    this.backupReminderCadence = BackupReminderCadence.weekly,
    this.syncEnabled = false,
    this.autoSyncEnabled = true,
    this.syncOnWifiOnly = false,
  });

  Id id;
  late bool sessionRemindersEnabled;
  late bool dailySummaryEnabled;
  late bool deadlineWarningsEnabled;
  late int reminderLeadTimeMinutes;
  late int dailySummaryHour;
  late int dailySummaryMinute;
  late bool backupReminderEnabled;
  late bool syncEnabled;
  late bool autoSyncEnabled;
  late bool syncOnWifiOnly;

  @Enumerated(EnumType.name)
  late BackupReminderCadence backupReminderCadence;

  NotificationPreferences copyWith({
    int? id,
    bool? sessionRemindersEnabled,
    bool? dailySummaryEnabled,
    bool? deadlineWarningsEnabled,
    int? reminderLeadTimeMinutes,
    int? dailySummaryHour,
    int? dailySummaryMinute,
    bool? backupReminderEnabled,
    BackupReminderCadence? backupReminderCadence,
    bool? syncEnabled,
    bool? autoSyncEnabled,
    bool? syncOnWifiOnly,
  }) {
    return NotificationPreferences(
      id: id ?? this.id,
      sessionRemindersEnabled:
          sessionRemindersEnabled ?? this.sessionRemindersEnabled,
      dailySummaryEnabled: dailySummaryEnabled ?? this.dailySummaryEnabled,
      deadlineWarningsEnabled:
          deadlineWarningsEnabled ?? this.deadlineWarningsEnabled,
      reminderLeadTimeMinutes:
          reminderLeadTimeMinutes ?? this.reminderLeadTimeMinutes,
      dailySummaryHour: dailySummaryHour ?? this.dailySummaryHour,
      dailySummaryMinute: dailySummaryMinute ?? this.dailySummaryMinute,
      backupReminderEnabled: backupReminderEnabled ?? this.backupReminderEnabled,
      backupReminderCadence:
          backupReminderCadence ?? this.backupReminderCadence,
      syncEnabled: syncEnabled ?? this.syncEnabled,
      autoSyncEnabled: autoSyncEnabled ?? this.autoSyncEnabled,
      syncOnWifiOnly: syncOnWifiOnly ?? this.syncOnWifiOnly,
    );
  }
}

extension BackupReminderCadenceX on BackupReminderCadence {
  String get label {
    switch (this) {
      case BackupReminderCadence.weekly:
        return 'Weekly';
      case BackupReminderCadence.everyTwoWeeks:
        return 'Every 2 Weeks';
      case BackupReminderCadence.monthly:
        return 'Monthly';
    }
  }
}
