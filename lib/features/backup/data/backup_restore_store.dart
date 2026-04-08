import 'package:isar/isar.dart';

import '../../goals/models/goal_milestone.dart';
import '../../goals/models/learning_goal.dart';
import '../../goals/models/task_dependency.dart';
import '../../notes/models/entity_note.dart';
import '../../notes/models/entity_resource.dart';
import '../../review/models/weekly_review.dart';
import '../../routines/models/routine.dart';
import '../../routines/models/routine_group.dart';
import '../../routines/models/routine_occurrence.dart';
import '../../routines/models/routine_template.dart';
import '../../schedule/models/planned_session.dart';
import '../../settings/models/notification_preferences.dart';
import '../../tasks/models/task.dart';
import '../../timetable/models/timetable_slot.dart';
import '../domain/backup_models.dart';

abstract class BackupRestoreStore {
  Future<void> replaceAll(AppBackupBundle bundle);

  Future<void> mergeBundle({
    required List<Task> tasks,
    required List<TimetableSlot> timetableSlots,
    required List<PlannedSession> plannedSessions,
    required List<LearningGoal> goals,
    required List<GoalMilestone> milestones,
    required List<TaskDependency> dependencies,
    required List<EntityNote> entityNotes,
    required List<EntityResource> entityResources,
    required List<Routine> routines,
    required List<RoutineOccurrence> routineOccurrences,
    required List<RoutineTemplate> routineTemplates,
    required List<RoutineGroup> routineGroups,
    required List<WeeklyReview> weeklyReviews,
    NotificationPreferences? preferences,
  });
}

class IsarBackupRestoreStore implements BackupRestoreStore {
  IsarBackupRestoreStore(this._isar);

  final Isar _isar;

  @override
  Future<void> replaceAll(AppBackupBundle bundle) {
    return _isar.writeTxn(() async {
      await _isar.tasks.clear();
      await _isar.timetableSlots.clear();
      await _isar.plannedSessions.clear();
      await _isar.learningGoals.clear();
      await _isar.goalMilestones.clear();
      await _isar.taskDependencys.clear();
      await _isar.entityNotes.clear();
      await _isar.entityResources.clear();
      await _isar.routines.clear();
      await _isar.routineOccurrences.clear();
      await _isar.routineTemplates.clear();
      await _isar.routineGroups.clear();
      await _isar.weeklyReviews.clear();
      await _isar.notificationPreferences.clear();
      await _mergeBundleInCurrentTransaction(
        tasks: bundle.tasks,
        timetableSlots: bundle.timetableSlots,
        plannedSessions: bundle.plannedSessions,
        goals: bundle.goals,
        milestones: bundle.milestones,
        dependencies: bundle.dependencies,
        entityNotes: bundle.entityNotes,
        entityResources: bundle.entityResources,
        routines: bundle.routines,
        routineOccurrences: bundle.routineOccurrences,
        routineTemplates: bundle.routineTemplates,
        routineGroups: bundle.routineGroups,
        weeklyReviews: bundle.weeklyReviews,
        preferences: bundle.preferences,
      );
    });
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
    required List<Routine> routines,
    required List<RoutineOccurrence> routineOccurrences,
    required List<RoutineTemplate> routineTemplates,
    required List<RoutineGroup> routineGroups,
    required List<WeeklyReview> weeklyReviews,
    NotificationPreferences? preferences,
  }) {
    return _isar.writeTxn(() async {
      await _mergeBundleInCurrentTransaction(
        tasks: tasks,
        timetableSlots: timetableSlots,
        plannedSessions: plannedSessions,
        goals: goals,
        milestones: milestones,
        dependencies: dependencies,
        entityNotes: entityNotes,
        entityResources: entityResources,
        routines: routines,
        routineOccurrences: routineOccurrences,
        routineTemplates: routineTemplates,
        routineGroups: routineGroups,
        weeklyReviews: weeklyReviews,
        preferences: preferences,
      );
    });
  }

  Future<void> _mergeBundleInCurrentTransaction({
    required List<Task> tasks,
    required List<TimetableSlot> timetableSlots,
    required List<PlannedSession> plannedSessions,
    required List<LearningGoal> goals,
    required List<GoalMilestone> milestones,
    required List<TaskDependency> dependencies,
    required List<EntityNote> entityNotes,
    required List<EntityResource> entityResources,
    required List<Routine> routines,
    required List<RoutineOccurrence> routineOccurrences,
    required List<RoutineTemplate> routineTemplates,
    required List<RoutineGroup> routineGroups,
    required List<WeeklyReview> weeklyReviews,
    NotificationPreferences? preferences,
  }) async {
    if (tasks.isNotEmpty) {
      await _isar.tasks.putAll(tasks);
    }
    if (timetableSlots.isNotEmpty) {
      await _isar.timetableSlots.putAll(timetableSlots);
    }
    if (plannedSessions.isNotEmpty) {
      await _isar.plannedSessions.putAll(plannedSessions);
    }
    if (goals.isNotEmpty) {
      await _isar.learningGoals.putAll(goals);
    }
    if (milestones.isNotEmpty) {
      await _isar.goalMilestones.putAll(milestones);
    }
    if (dependencies.isNotEmpty) {
      await _isar.taskDependencys.putAll(dependencies);
    }
    if (entityNotes.isNotEmpty) {
      await _isar.entityNotes.putAll(entityNotes);
    }
    if (entityResources.isNotEmpty) {
      await _isar.entityResources.putAll(entityResources);
    }
    if (routines.isNotEmpty) {
      await _isar.routines.putAll(routines);
    }
    if (routineOccurrences.isNotEmpty) {
      await _isar.routineOccurrences.putAll(routineOccurrences);
    }
    if (routineTemplates.isNotEmpty) {
      await _isar.routineTemplates.putAll(routineTemplates);
    }
    if (routineGroups.isNotEmpty) {
      await _isar.routineGroups.putAll(routineGroups);
    }
    if (weeklyReviews.isNotEmpty) {
      await _isar.weeklyReviews.putAll(weeklyReviews);
    }
    if (preferences != null) {
      await _isar.notificationPreferences.put(preferences);
    }
  }
}
