import '../../goals/data/goal_repository.dart';
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
    required this.settingsRepository,
  });

  final TaskRepository taskRepository;
  final TimetableRepository timetableRepository;
  final PlannedSessionRepository plannedSessionRepository;
  final GoalRepository goalRepository;
  final SettingsRepository settingsRepository;

  Future<ExistingAppStateSnapshot> createSnapshot() async {
    final tasks = await taskRepository.getAllTasks();
    final timetableSlots = await timetableRepository.getAllSlots();
    final plannedSessions = await plannedSessionRepository.getAllSessions();
    final goals = await goalRepository.getAllGoals();
    final milestones = await goalRepository.getAllMilestones();
    final dependencies = await goalRepository.getAllDependencies();
    final preferences = await settingsRepository.getPreferences();

    return ExistingAppStateSnapshot(
      tasks: tasks,
      timetableSlots: timetableSlots,
      plannedSessions: plannedSessions,
      goals: goals,
      milestones: milestones,
      dependencies: dependencies,
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
        warnings.add('Milestone ${milestone.id} references missing goal ${milestone.goalId}.');
      }
    }
    for (final task in snapshot.tasks) {
      if (task.goalId != null && !goalIds.contains(task.goalId)) {
        warnings.add('Task ${task.id} references missing goal ${task.goalId}.');
      }
      if (task.milestoneId != null && !milestoneIds.contains(task.milestoneId)) {
        warnings.add('Task ${task.id} references missing milestone ${task.milestoneId}.');
      }
    }
    for (final session in snapshot.plannedSessions) {
      if (!taskIds.contains(session.taskId)) {
        warnings.add('Session ${session.id} references missing task ${session.taskId}.');
      }
    }
    return warnings;
  }
}
