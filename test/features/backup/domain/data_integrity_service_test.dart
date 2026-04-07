import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/backup/domain/backup_models.dart';
import 'package:study_flow/features/backup/domain/data_integrity_service.dart';
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
  group('DataIntegrityService', () {
    const service = DataIntegrityService();

    test('detects orphaned sessions and broken references', () {
      final snapshot = ExistingAppStateSnapshot(
        tasks: [
          Task(
            id: 'task-1',
            title: 'Study',
            type: TaskType.study,
            estimatedDurationMinutes: 60,
            priority: 1,
            goalId: 'missing-goal',
            milestoneId: 'missing-milestone',
            isCompleted: true,
            createdAt: DateTime(2026, 3, 1),
          ),
        ],
        timetableSlots: const <TimetableSlot>[],
        plannedSessions: [
          PlannedSession(
            id: 'session-1',
            taskId: 'missing-task',
            start: DateTime(2026, 3, 16, 9),
            end: DateTime(2026, 3, 16, 10),
          ),
        ],
        goals: const <LearningGoal>[],
        milestones: const <GoalMilestone>[],
        dependencies: [
          TaskDependency(
            id: 'dep-1',
            taskId: 'task-1',
            dependsOnTaskId: 'missing-task',
            createdAt: DateTime(2026, 3, 1),
          ),
        ],
        entityNotes: [
          EntityNote(
            id: 'note-1',
            entityType: EntityAttachmentType.goal,
            entityId: 'missing-goal',
            content: 'Review again before exam.',
            createdAt: DateTime(2026, 3, 1),
          ),
        ],
        entityResources: [
          EntityResource(
            id: 'resource-1',
            entityType: EntityAttachmentType.task,
            entityId: 'missing-task',
            title: 'Reference repo',
            resourceType: EntityResourceType.repo,
            createdAt: DateTime(2026, 3, 1),
          ),
        ],
        preferences: NotificationPreferences(),
      );

      final report = service.scan(snapshot);

      expect(report.hasIssues, isTrue);
      expect(
        report.issues.any((issue) => issue.code == 'orphan_session'),
        isTrue,
      );
      expect(
        report.issues.any((issue) => issue.code == 'task_missing_goal'),
        isTrue,
      );
      expect(
        report.issues.any((issue) => issue.code == 'broken_dependency'),
        isTrue,
      );
      expect(
        report.issues.any((issue) => issue.code == 'orphan_note'),
        isTrue,
      );
      expect(
        report.issues.any((issue) => issue.code == 'orphan_resource'),
        isTrue,
      );
    });
  });
}
