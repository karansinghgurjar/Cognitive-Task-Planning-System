import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/backup/data/backup_restore_store.dart';
import 'package:study_flow/features/backup/data/backup_serialization.dart';
import 'package:study_flow/features/backup/domain/backup_models.dart';
import 'package:study_flow/features/backup/domain/backup_service.dart';
import 'package:study_flow/features/goals/models/goal_milestone.dart';
import 'package:study_flow/features/goals/models/learning_goal.dart';
import 'package:study_flow/features/goals/models/task_dependency.dart';
import 'package:study_flow/features/notes/models/entity_note.dart';
import 'package:study_flow/features/notes/models/entity_resource.dart';
import 'package:study_flow/features/schedule/models/planned_session.dart';
import 'package:study_flow/features/settings/models/notification_preferences.dart';
import 'package:study_flow/features/tasks/models/task.dart';
import 'package:study_flow/features/timetable/models/timetable_slot.dart';

void main() {
  group('BackupService', () {
    test('preview import reports conflicts and counts', () {
      final service = BackupService(
        serialization: const BackupSerialization(),
        restoreStore: _FakeRestoreStore(),
        snapshotLoader: () async => _existingSnapshot(),
        appVersionLoader: () async => '1.0.0',
        platformLoader: () => 'windows',
      );
      final preview = service.previewImport(_importBundle(), _existingSnapshot());

      expect(preview.importCounts['tasks'], 2);
      expect(preview.existingCounts['tasks'], 1);
      expect(preview.conflicts, isNotEmpty);
      expect(preview.recommendedMode, RestoreMode.mergePreferImported);
    });

    test('restore replaceAll sends full bundle to store', () async {
      final store = _FakeRestoreStore();
      final service = BackupService(
        serialization: const BackupSerialization(),
        restoreStore: store,
        snapshotLoader: () async => _existingSnapshot(),
        appVersionLoader: () async => '1.0.0',
        platformLoader: () => 'windows',
      );

      final result = await service.restoreBackup(_importBundle(), RestoreMode.replaceAll);

      expect(store.replacedBundle, isNotNull);
      expect(result.appliedCounts['tasks'], 2);
      expect(result.mode, RestoreMode.replaceAll);
    });

    test('restore mergePreferImported keeps imported collisions', () async {
      final store = _FakeRestoreStore();
      final service = BackupService(
        serialization: const BackupSerialization(),
        restoreStore: store,
        snapshotLoader: () async => _existingSnapshot(),
        appVersionLoader: () async => '1.0.0',
        platformLoader: () => 'windows',
      );

      final result = await service.restoreBackup(
        _importBundle(),
        RestoreMode.mergePreferImported,
      );

      expect(store.mergedTasks.map((task) => task.id), contains('task-existing'));
      expect(store.mergedTasks.map((task) => task.id), contains('task-new'));
      expect(result.appliedCounts['tasks'], 2);
      expect(result.appliedCounts['settings'], 1);
    });

    test('restore mergePreferExisting skips colliding ids', () async {
      final store = _FakeRestoreStore();
      final service = BackupService(
        serialization: const BackupSerialization(),
        restoreStore: store,
        snapshotLoader: () async => _existingSnapshot(),
        appVersionLoader: () async => '1.0.0',
        platformLoader: () => 'windows',
      );

      final result = await service.restoreBackup(
        _importBundle(),
        RestoreMode.mergePreferExisting,
      );

      expect(store.mergedTasks.map((task) => task.id), isNot(contains('task-existing')));
      expect(store.mergedTasks.map((task) => task.id), contains('task-new'));
      expect(result.skippedCounts['tasks'], 1);
      expect(result.skippedCounts['settings'], 1);
    });
  });
}

class _FakeRestoreStore implements BackupRestoreStore {
  AppBackupBundle? replacedBundle;
  List<Task> mergedTasks = const [];
  NotificationPreferences? mergedPreferences;

  @override
  Future<void> replaceAll(AppBackupBundle bundle) async {
    replacedBundle = bundle;
  }

  @override
  Future<void> mergeBundle({
    required List<Task> tasks,
    required List<TimetableSlot> timetableSlots,
    required List<PlannedSession> plannedSessions,
    required List<LearningGoal> goals,
    required List<GoalMilestone> milestones,
    required List<TaskDependency> dependencies,
    required List<EntityNote> entityNotes,
    required List<EntityResource> entityResources,
    NotificationPreferences? preferences,
  }) async {
    mergedTasks = tasks;
    mergedPreferences = preferences;
  }
}

ExistingAppStateSnapshot _existingSnapshot() {
  return ExistingAppStateSnapshot(
    tasks: [
      Task(
        id: 'task-existing',
        title: 'Local Task',
        type: TaskType.study,
        estimatedDurationMinutes: 60,
        priority: 1,
        createdAt: DateTime(2026, 3, 1),
      ),
    ],
    timetableSlots: const [],
    plannedSessions: const [],
    goals: [
      LearningGoal(
        id: 'goal-existing',
        title: 'Local Goal',
        priority: 1,
        createdAt: DateTime(2026, 3, 1),
      ),
    ],
    milestones: const [],
    dependencies: const [],
    entityNotes: const <EntityNote>[],
    entityResources: const <EntityResource>[],
    preferences: NotificationPreferences(),
  );
}

AppBackupBundle _importBundle() {
  return AppBackupBundle(
    metadata: BackupMetadata(
      appVersion: '1.0.0',
      schemaVersion: 1,
      backupFormatVersion: 1,
      createdAt: DateTime(2026, 3, 16, 10),
      platform: 'windows',
      entityCounts: const {
        'tasks': 2,
        'timetableSlots': 0,
        'plannedSessions': 0,
        'goals': 1,
        'milestones': 0,
        'dependencies': 0,
        'settings': 1,
      },
    ),
    tasks: [
      Task(
        id: 'task-existing',
        title: 'Imported override',
        type: TaskType.study,
        estimatedDurationMinutes: 90,
        priority: 1,
        createdAt: DateTime(2026, 3, 2),
      ),
      Task(
        id: 'task-new',
        title: 'Imported new',
        type: TaskType.coding,
        estimatedDurationMinutes: 120,
        priority: 2,
        createdAt: DateTime(2026, 3, 3),
      ),
    ],
    timetableSlots: const [],
    plannedSessions: const [],
    goals: [
      LearningGoal(
        id: 'goal-existing',
        title: 'Imported Goal',
        priority: 1,
        createdAt: DateTime(2026, 3, 2),
      ),
    ],
    milestones: const [],
    dependencies: const [],
    entityNotes: const <EntityNote>[],
    entityResources: const <EntityResource>[],
    preferences: NotificationPreferences(
      backupReminderEnabled: true,
      backupReminderCadence: BackupReminderCadence.monthly,
    ),
    warnings: const ['Duplicate tasks will overwrite in imported-preferred merge.'],
  );
}
