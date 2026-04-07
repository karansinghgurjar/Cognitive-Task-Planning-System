import '../../goals/data/goal_repository.dart';
import '../../notes/data/notes_repository.dart';
import '../../notes/data/resources_repository.dart';
import '../../notes/models/entity_note.dart';
import '../../schedule/data/planned_session_repository.dart';
import '../../settings/data/settings_repository.dart';
import '../../tasks/data/task_repository.dart';
import '../../timetable/data/timetable_repository.dart';
import '../domain/backup_models.dart';

class AppStateSnapshotService {
  const AppStateSnapshotService({
    required this.taskRepository,
    required this.timetableRepository,
    required this.plannedSessionRepository,
    required this.goalRepository,
    required this.notesRepository,
    required this.resourcesRepository,
    required this.settingsRepository,
  });

  final TaskRepository taskRepository;
  final TimetableRepository timetableRepository;
  final PlannedSessionRepository plannedSessionRepository;
  final GoalRepository goalRepository;
  final NotesRepository notesRepository;
  final ResourcesRepository resourcesRepository;
  final SettingsRepository settingsRepository;

  Future<ExistingAppStateSnapshot> createSnapshot() async {
    final tasks = await taskRepository.getAllTasks();
    final timetableSlots = await timetableRepository.getAllSlots();
    final plannedSessions = await plannedSessionRepository.getAllSessions();
    final goals = await goalRepository.getAllGoals();
    final milestones = await goalRepository.getAllMilestones();
    final dependencies = await goalRepository.getAllDependencies();
    final entityNotes = await notesRepository.getAllNotes();
    final entityResources = await resourcesRepository.getAllResources();
    final preferences = await settingsRepository.getPreferences();

    return ExistingAppStateSnapshot(
      tasks: tasks,
      timetableSlots: timetableSlots,
      plannedSessions: plannedSessions,
      goals: goals,
      milestones: milestones,
      dependencies: dependencies,
      entityNotes: entityNotes,
      entityResources: entityResources,
      preferences: preferences,
    );
  }

  Future<Map<String, int>> countRecords() async {
    final snapshot = await createSnapshot();
    return snapshot.entityCounts;
  }

  Future<List<String>> basicIntegrityWarnings() async {
    final snapshot = await createSnapshot();
    final warnings = <String>[];
    final goalIds = snapshot.goals.map((item) => item.id).toSet();
    final milestoneIds = snapshot.milestones.map((item) => item.id).toSet();
    final taskIds = snapshot.tasks.map((item) => item.id).toSet();

    for (final milestone in snapshot.milestones) {
      if (!goalIds.contains(milestone.goalId)) {
        warnings.add(
          'Milestone ${milestone.id} references missing goal ${milestone.goalId}.',
        );
      }
    }
    for (final task in snapshot.tasks) {
      if (task.goalId != null && !goalIds.contains(task.goalId)) {
        warnings.add('Task ${task.id} references missing goal ${task.goalId}.');
      }
      if (task.milestoneId != null && !milestoneIds.contains(task.milestoneId)) {
        warnings.add(
          'Task ${task.id} references missing milestone ${task.milestoneId}.',
        );
      }
    }
    for (final session in snapshot.plannedSessions) {
      if (!taskIds.contains(session.taskId)) {
        warnings.add(
          'Session ${session.id} references missing task ${session.taskId}.',
        );
      }
    }
    for (final note in snapshot.entityNotes) {
      if (note.entityType == EntityAttachmentType.task &&
          !taskIds.contains(note.entityId)) {
        warnings.add('Note ${note.id} references missing task ${note.entityId}.');
      }
      if (note.entityType == EntityAttachmentType.goal &&
          !goalIds.contains(note.entityId)) {
        warnings.add('Note ${note.id} references missing goal ${note.entityId}.');
      }
    }
    for (final resource in snapshot.entityResources) {
      if (resource.entityType == EntityAttachmentType.task &&
          !taskIds.contains(resource.entityId)) {
        warnings.add(
          'Resource ${resource.id} references missing task ${resource.entityId}.',
        );
      }
      if (resource.entityType == EntityAttachmentType.goal &&
          !goalIds.contains(resource.entityId)) {
        warnings.add(
          'Resource ${resource.id} references missing goal ${resource.entityId}.',
        );
      }
    }
    return warnings;
  }
}
