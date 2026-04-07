import '../../analytics/domain/analytics_models.dart';
import '../../goals/models/goal_milestone.dart';
import '../../goals/models/learning_goal.dart';
import '../../goals/models/task_dependency.dart';
import '../../notes/models/entity_note.dart';
import '../../notes/models/entity_resource.dart';
import '../../recommendations/domain/recommendation_models.dart';
import '../../schedule/models/planned_session.dart';
import '../../settings/models/notification_preferences.dart';
import '../../tasks/models/task.dart';
import '../../timetable/models/timetable_slot.dart';

class BackupMetadata {
  const BackupMetadata({
    required this.appVersion,
    required this.schemaVersion,
    required this.backupFormatVersion,
    required this.createdAt,
    required this.platform,
    required this.entityCounts,
  });

  final String appVersion;
  final int schemaVersion;
  final int backupFormatVersion;
  final DateTime createdAt;
  final String platform;
  final Map<String, int> entityCounts;
}

class AppBackupBundle {
  const AppBackupBundle({
    required this.metadata,
    required this.tasks,
    required this.timetableSlots,
    required this.plannedSessions,
    required this.goals,
    required this.milestones,
    required this.dependencies,
    required this.entityNotes,
    required this.entityResources,
    required this.preferences,
    this.warnings = const [],
  });

  final BackupMetadata metadata;
  final List<Task> tasks;
  final List<TimetableSlot> timetableSlots;
  final List<PlannedSession> plannedSessions;
  final List<LearningGoal> goals;
  final List<GoalMilestone> milestones;
  final List<TaskDependency> dependencies;
  final List<EntityNote> entityNotes;
  final List<EntityResource> entityResources;
  final NotificationPreferences preferences;
  final List<String> warnings;
}

class ExistingAppStateSnapshot {
  const ExistingAppStateSnapshot({
    required this.tasks,
    required this.timetableSlots,
    required this.plannedSessions,
    required this.goals,
    required this.milestones,
    required this.dependencies,
    required this.entityNotes,
    required this.entityResources,
    required this.preferences,
  });

  final List<Task> tasks;
  final List<TimetableSlot> timetableSlots;
  final List<PlannedSession> plannedSessions;
  final List<LearningGoal> goals;
  final List<GoalMilestone> milestones;
  final List<TaskDependency> dependencies;
  final List<EntityNote> entityNotes;
  final List<EntityResource> entityResources;
  final NotificationPreferences preferences;

  Map<String, int> get entityCounts => {
    'tasks': tasks.length,
    'timetableSlots': timetableSlots.length,
    'plannedSessions': plannedSessions.length,
    'goals': goals.length,
    'milestones': milestones.length,
    'dependencies': dependencies.length,
    'entityNotes': entityNotes.length,
    'entityResources': entityResources.length,
    'settings': 1,
  };
}

class BackupValidationResult {
  const BackupValidationResult({
    required this.isValid,
    this.bundle,
    this.warnings = const [],
    this.errors = const [],
  });

  final bool isValid;
  final AppBackupBundle? bundle;
  final List<String> warnings;
  final List<String> errors;
}

class ImportConflict {
  const ImportConflict({
    required this.collection,
    required this.entityId,
    required this.description,
  });

  final String collection;
  final String entityId;
  final String description;
}

enum RestoreMode { replaceAll, mergePreferImported, mergePreferExisting }

class ImportPreview {
  const ImportPreview({
    required this.metadata,
    required this.importCounts,
    required this.existingCounts,
    required this.conflicts,
    required this.warnings,
    required this.recommendedMode,
    required this.summary,
  });

  final BackupMetadata metadata;
  final Map<String, int> importCounts;
  final Map<String, int> existingCounts;
  final List<ImportConflict> conflicts;
  final List<String> warnings;
  final RestoreMode recommendedMode;
  final String summary;
}

class LoadedBackupImport {
  const LoadedBackupImport({
    required this.sourcePath,
    required this.bundle,
    required this.preview,
  });

  final String sourcePath;
  final AppBackupBundle bundle;
  final ImportPreview preview;
}

class ExportResult {
  const ExportResult({
    required this.success,
    required this.filePath,
    required this.bytesWritten,
    required this.message,
    this.warnings = const [],
  });

  final bool success;
  final String? filePath;
  final int bytesWritten;
  final String message;
  final List<String> warnings;
}

class RestoreResult {
  const RestoreResult({
    required this.mode,
    required this.appliedCounts,
    required this.skippedCounts,
    required this.warnings,
  });

  final RestoreMode mode;
  final Map<String, int> appliedCounts;
  final Map<String, int> skippedCounts;
  final List<String> warnings;
}

enum DataIntegritySeverity { info, warning, error }

class DataIntegrityIssue {
  const DataIntegrityIssue({
    required this.code,
    required this.message,
    required this.severity,
    this.relatedEntityId,
    this.suggestedRepair,
  });

  final String code;
  final String message;
  final DataIntegritySeverity severity;
  final String? relatedEntityId;
  final String? suggestedRepair;
}

class DataIntegrityReport {
  const DataIntegrityReport({
    required this.scannedAt,
    required this.issues,
  });

  final DateTime scannedAt;
  final List<DataIntegrityIssue> issues;

  bool get hasIssues => issues.isNotEmpty;
}

class BackupRecordSummary {
  const BackupRecordSummary({
    required this.lastBackupAt,
    required this.totalBackups,
  });

  final DateTime? lastBackupAt;
  final int totalBackups;
}

class CsvAnalyticsSnapshot {
  const CsvAnalyticsSnapshot({
    required this.rangeLabel,
    required this.plannedMinutes,
    required this.completedMinutes,
    required this.completionRate,
    required this.currentFocusStreak,
    required this.longestFocusStreak,
    required this.goalAnalytics,
    required this.insights,
    required this.burnoutRisk,
  });

  final String rangeLabel;
  final int plannedMinutes;
  final int completedMinutes;
  final double completionRate;
  final int currentFocusStreak;
  final int longestFocusStreak;
  final List<GoalAnalytics> goalAnalytics;
  final List<ProductivityInsight> insights;
  final DeadlineRiskLevel burnoutRisk;
}
