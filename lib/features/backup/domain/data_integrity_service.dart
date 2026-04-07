import '../../schedule/domain/task_progress_service.dart';
import '../../notes/models/entity_note.dart';
import '../domain/backup_models.dart';

class DataIntegrityService {
  const DataIntegrityService({
    this.taskProgressService = const TaskProgressService(),
  });

  final TaskProgressService taskProgressService;

  DataIntegrityReport scan(ExistingAppStateSnapshot snapshot) {
    final issues = <DataIntegrityIssue>[];
    final goalIds = snapshot.goals.map((item) => item.id).toSet();
    final milestoneIds = snapshot.milestones.map((item) => item.id).toSet();
    final taskIds = snapshot.tasks.map((item) => item.id).toSet();

    for (final milestone in snapshot.milestones) {
      if (!goalIds.contains(milestone.goalId)) {
        issues.add(
          DataIntegrityIssue(
            code: 'orphan_milestone',
            message:
                'Milestone ${milestone.id} references missing goal ${milestone.goalId}.',
            severity: DataIntegritySeverity.error,
            relatedEntityId: milestone.id,
            suggestedRepair: 'Delete the orphan milestone or relink it to a goal.',
          ),
        );
      }
    }

    for (final task in snapshot.tasks) {
      if (task.goalId != null && !goalIds.contains(task.goalId)) {
        issues.add(
          DataIntegrityIssue(
            code: 'task_missing_goal',
            message: 'Task ${task.id} references missing goal ${task.goalId}.',
            severity: DataIntegritySeverity.warning,
            relatedEntityId: task.id,
            suggestedRepair: 'Clear the goal link or restore the missing goal.',
          ),
        );
      }
      if (task.milestoneId != null && !milestoneIds.contains(task.milestoneId)) {
        issues.add(
          DataIntegrityIssue(
            code: 'task_missing_milestone',
            message:
                'Task ${task.id} references missing milestone ${task.milestoneId}.',
            severity: DataIntegritySeverity.warning,
            relatedEntityId: task.id,
            suggestedRepair: 'Clear the milestone link or restore the missing milestone.',
          ),
        );
      }
      if (task.isCompleted &&
          taskProgressService.getCompletedMinutesForTask(
                task,
                snapshot.plannedSessions,
              ) ==
              0) {
        issues.add(
          DataIntegrityIssue(
            code: 'completed_task_without_progress',
            message:
                'Task ${task.id} is marked complete but has no completed focus history.',
            severity: DataIntegritySeverity.info,
            relatedEntityId: task.id,
            suggestedRepair: 'Review the task completion state and session history.',
          ),
        );
      }
    }

    for (final session in snapshot.plannedSessions) {
      if (!taskIds.contains(session.taskId)) {
        issues.add(
          DataIntegrityIssue(
            code: 'orphan_session',
            message:
                'Planned session ${session.id} references missing task ${session.taskId}.',
            severity: DataIntegritySeverity.error,
            relatedEntityId: session.id,
            suggestedRepair: 'Delete the orphan session or restore the missing task.',
          ),
        );
      }
    }

    for (final dependency in snapshot.dependencies) {
      if (!taskIds.contains(dependency.taskId) ||
          !taskIds.contains(dependency.dependsOnTaskId)) {
        issues.add(
          DataIntegrityIssue(
            code: 'broken_dependency',
            message:
                'Dependency ${dependency.id} references missing tasks and is no longer valid.',
            severity: DataIntegritySeverity.error,
            relatedEntityId: dependency.id,
            suggestedRepair: 'Delete the broken dependency or restore the missing tasks.',
          ),
        );
      }
    }

    for (final note in snapshot.entityNotes) {
      final exists = switch (note.entityType) {
        EntityAttachmentType.task => taskIds.contains(note.entityId),
        EntityAttachmentType.goal => goalIds.contains(note.entityId),
      };
      if (!exists) {
        issues.add(
          DataIntegrityIssue(
            code: 'orphan_note',
            message:
                'Note ${note.id} references missing ${note.entityType.name} ${note.entityId}.',
            severity: DataIntegritySeverity.warning,
            relatedEntityId: note.id,
            suggestedRepair:
                'Delete the orphan note or restore the missing entity.',
          ),
        );
      }
    }

    for (final resource in snapshot.entityResources) {
      final exists = switch (resource.entityType) {
        EntityAttachmentType.task => taskIds.contains(resource.entityId),
        EntityAttachmentType.goal => goalIds.contains(resource.entityId),
      };
      if (!exists) {
        issues.add(
          DataIntegrityIssue(
            code: 'orphan_resource',
            message:
                'Resource ${resource.id} references missing ${resource.entityType.name} ${resource.entityId}.',
            severity: DataIntegritySeverity.warning,
            relatedEntityId: resource.id,
            suggestedRepair:
                'Delete the orphan resource or restore the missing entity.',
          ),
        );
      }
    }

    return DataIntegrityReport(scannedAt: DateTime.now(), issues: issues);
  }
}



