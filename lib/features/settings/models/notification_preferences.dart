import 'package:isar/isar.dart';

part 'notification_preferences.g.dart';

enum BackupReminderCadence { weekly, everyTwoWeeks, monthly }

enum AppThemePreference { system, light, dark }

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
    this.themePreference = AppThemePreference.system,
    this.defaultPlanningHorizonDays = 7,
    this.routineGenerationHorizonDays = 30,
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
  late int defaultPlanningHorizonDays;
  late int routineGenerationHorizonDays;

  @Enumerated(EnumType.name)
  late BackupReminderCadence backupReminderCadence;

  @Enumerated(EnumType.name)
  late AppThemePreference themePreference;

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
    AppThemePreference? themePreference,
    int? defaultPlanningHorizonDays,
    int? routineGenerationHorizonDays,
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
      themePreference: themePreference ?? this.themePreference,
      defaultPlanningHorizonDays:
          defaultPlanningHorizonDays ?? this.defaultPlanningHorizonDays,
      routineGenerationHorizonDays:
          routineGenerationHorizonDays ?? this.routineGenerationHorizonDays,
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

extension AppThemePreferenceX on AppThemePreference {
  String get label {
    switch (this) {
      case AppThemePreference.system:
        return 'System';
      case AppThemePreference.light:
        return 'Light';
      case AppThemePreference.dark:
        return 'Dark';
    }
  }
}
