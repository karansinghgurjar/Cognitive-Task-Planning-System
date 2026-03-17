import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/backup/data/backup_serialization.dart';
import 'package:study_flow/features/backup/domain/backup_models.dart';
import 'package:study_flow/features/goals/models/goal_milestone.dart';
import 'package:study_flow/features/goals/models/learning_goal.dart';
import 'package:study_flow/features/goals/models/task_dependency.dart';
import 'package:study_flow/features/schedule/models/planned_session.dart';
import 'package:study_flow/features/settings/models/notification_preferences.dart';
import 'package:study_flow/features/tasks/models/task.dart';
import 'package:study_flow/features/timetable/models/timetable_slot.dart';

void main() {
  group('BackupSerialization', () {
    const serialization = BackupSerialization();

    test('round-trips full backup bundle', () {
      final bundle = _sampleBundle();
      final json = serialization.encodeBundle(bundle);
      final validation = serialization.decodeBundle(json);

      expect(validation.isValid, isTrue);
      expect(validation.bundle, isNotNull);
      expect(validation.bundle!.tasks, hasLength(1));
      expect(validation.bundle!.goals.single.title, 'Learn Flutter');
      expect(
        validation.bundle!.preferences.backupReminderCadence,
        BackupReminderCadence.everyTwoWeeks,
      );
    });

    test('fails validation when required collections are missing', () {
      const json = '{"backupFormatVersion":1,"metadata":{"appVersion":"1.0.0","schemaVersion":1,"createdAt":"2026-03-16T10:00:00.000","platform":"windows","entityCounts":{}},"collections":{"tasks":[]}}';
      final validation = serialization.decodeBundle(json);

      expect(validation.isValid, isFalse);
      expect(validation.errors, isNotEmpty);
    });

    test('normalizes dangling references with warnings', () {
      const json = '''
{
  "backupFormatVersion": 1,
  "metadata": {
    "appVersion": "1.0.0",
    "schemaVersion": 1,
    "createdAt": "2026-03-16T10:00:00.000",
    "platform": "windows",
    "entityCounts": {"tasks": 1}
  },
  "collections": {
    "tasks": [
      {
        "id": "task-1",
        "title": "Study",
        "type": "study",
        "estimatedDurationMinutes": 60,
        "priority": 1,
        "goalId": "missing-goal",
        "createdAt": "2026-03-01T10:00:00.000",
        "isCompleted": false
      }
    ],
    "timetableSlots": [],
    "plannedSessions": [
      {
        "id": "session-1",
        "taskId": "missing-task",
        "start": "2026-03-16T10:00:00.000",
        "end": "2026-03-16T11:00:00.000",
        "status": "pending",
        "completed": false,
        "actualMinutesFocused": 0
      }
    ],
    "goals": [],
    "milestones": [
      {
        "id": "milestone-1",
        "goalId": "missing-goal",
        "title": "Start",
        "sequenceOrder": 1,
        "estimatedMinutes": 30,
        "createdAt": "2026-03-01T10:00:00.000",
        "isCompleted": false
      }
    ],
    "dependencies": [
      {
        "id": "dep-1",
        "taskId": "task-1",
        "dependsOnTaskId": "missing-task",
        "createdAt": "2026-03-01T10:00:00.000"
      }
    ],
    "settings": {
      "sessionRemindersEnabled": true,
      "dailySummaryEnabled": true,
      "deadlineWarningsEnabled": true,
      "reminderLeadTimeMinutes": 10,
      "dailySummaryHour": 7,
      "dailySummaryMinute": 0,
      "backupReminderEnabled": false,
      "backupReminderCadence": "weekly"
    }
  }
}
''';

      final validation = serialization.decodeBundle(json);

      expect(validation.isValid, isTrue);
      expect(validation.bundle!.milestones, isEmpty);
      expect(validation.bundle!.plannedSessions, isEmpty);
      expect(validation.bundle!.dependencies, isEmpty);
      expect(validation.bundle!.tasks.single.goalId, isNull);
      expect(validation.warnings, isNotEmpty);
    });
  });
}

AppBackupBundle _sampleBundle() {
  return AppBackupBundle(
    metadata: BackupMetadata(
      appVersion: '1.0.0',
      schemaVersion: 1,
      backupFormatVersion: 1,
      createdAt: DateTime(2026, 3, 16, 10),
      platform: 'windows',
      entityCounts: const {
        'tasks': 1,
        'timetableSlots': 1,
        'plannedSessions': 1,
        'goals': 1,
        'milestones': 1,
        'dependencies': 1,
        'settings': 1,
      },
    ),
    tasks: [
      Task(
        id: 'task-1',
        title: 'Intro',
        type: TaskType.study,
        estimatedDurationMinutes: 60,
        priority: 1,
        goalId: 'goal-1',
        milestoneId: 'milestone-1',
        createdAt: DateTime(2026, 3, 1, 10),
      ),
    ],
    timetableSlots: [
      TimetableSlot(
        id: 'slot-1',
        weekday: 1,
        startHour: 18,
        startMinute: 0,
        endHour: 20,
        endMinute: 0,
        isBusy: false,
        label: 'Study Window',
      ),
    ],
    plannedSessions: [
      PlannedSession(
        id: 'session-1',
        taskId: 'task-1',
        start: DateTime(2026, 3, 16, 18),
        end: DateTime(2026, 3, 16, 19),
      ),
    ],
    goals: [
      LearningGoal(
        id: 'goal-1',
        title: 'Learn Flutter',
        priority: 1,
        createdAt: DateTime(2026, 3, 1, 10),
      ),
    ],
    milestones: [
      GoalMilestone(
        id: 'milestone-1',
        goalId: 'goal-1',
        title: 'Basics',
        sequenceOrder: 1,
        estimatedMinutes: 60,
        createdAt: DateTime(2026, 3, 1, 10),
      ),
    ],
    dependencies: [
      TaskDependency(
        id: 'dependency-1',
        taskId: 'task-1',
        dependsOnTaskId: 'task-1',
        createdAt: DateTime(2026, 3, 1, 10),
      ),
    ],
    preferences: NotificationPreferences(
      backupReminderEnabled: true,
      backupReminderCadence: BackupReminderCadence.everyTwoWeeks,
    ),
  );
}
