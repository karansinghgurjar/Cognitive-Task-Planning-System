import 'package:uuid/uuid.dart';

import '../../../goals/models/goal_milestone.dart';
import '../../../goals/models/learning_goal.dart';
import '../../../routines/domain/routine_enums.dart';
import '../../../routines/domain/routine_repeat_rule.dart';
import '../../../routines/models/routine.dart';
import '../../../tasks/models/task.dart';
import '../../domain/models/planning_draft.dart';

abstract class PlanningAssistantGoalStore {
  Future<List<LearningGoal>> getAllGoals();
  Future<void> addGoal(LearningGoal goal);
  Future<void> addMilestone(GoalMilestone milestone);
}

abstract class PlanningAssistantTaskStore {
  Future<List<Task>> getAllTasks();
  Future<void> addTask(Task task);
}

abstract class PlanningAssistantRoutineStore {
  Future<List<Routine>> getAllRoutines();
  Future<void> saveRoutine(Routine routine);
}

class PlanningApplyResult {
  const PlanningApplyResult({
    required this.createdGoalCount,
    required this.createdRoutineCount,
    required this.createdTaskCount,
    required this.duplicateWarnings,
  });

  final int createdGoalCount;
  final int createdRoutineCount;
  final int createdTaskCount;
  final List<String> duplicateWarnings;
}

class PlanningAssistantApplyService {
  PlanningAssistantApplyService({
    required PlanningAssistantGoalStore goalStore,
    required PlanningAssistantTaskStore taskStore,
    required PlanningAssistantRoutineStore routineStore,
    required Future<void> Function() postApplyRefresh,
    Uuid? uuid,
  }) : _goalStore = goalStore,
       _taskStore = taskStore,
       _routineStore = routineStore,
       _postApplyRefresh = postApplyRefresh,
       _uuid = uuid ?? const Uuid();

  final PlanningAssistantGoalStore _goalStore;
  final PlanningAssistantTaskStore _taskStore;
  final PlanningAssistantRoutineStore _routineStore;
  final Future<void> Function() _postApplyRefresh;
  final Uuid _uuid;

  Future<PlanningApplyResult> applyDraft(PlanningDraft draft) async {
    final goals = await _goalStore.getAllGoals();
    final tasks = await _taskStore.getAllTasks();
    final routines = await _routineStore.getAllRoutines();

    final duplicateWarnings = <String>[];
    final goalIdByTitle = <String, String>{
      for (final goal in goals) goal.title.toLowerCase(): goal.id,
    };

    var createdGoalCount = 0;
    for (final goalDraft in draft.goals) {
      final key = goalDraft.title.toLowerCase();
      if (goalIdByTitle.containsKey(key)) {
        duplicateWarnings.add('Skipped duplicate goal "${goalDraft.title}".');
        continue;
      }
      final goal = LearningGoal(
        id: _uuid.v4(),
        title: goalDraft.title,
        description: goalDraft.description,
        goalType: goalDraft.goalType,
        targetDate: goalDraft.targetDate,
        priority: goalDraft.priority,
        estimatedTotalMinutes: goalDraft.estimatedTotalMinutes,
        createdAt: DateTime.now(),
      );
      await _goalStore.addGoal(goal);
      goalIdByTitle[key] = goal.id;
      createdGoalCount += 1;
    }

    final existingRoutineSignatures = routines.map(_routineSignature).toSet();
    var createdRoutineCount = 0;
    for (final routineDraft in draft.routines) {
      final signature = _routineDraftSignature(routineDraft);
      if (existingRoutineSignatures.contains(signature)) {
        duplicateWarnings.add(
          'Skipped duplicate routine "${routineDraft.title}".',
        );
        continue;
      }
      final linkedGoalId = routineDraft.linkedGoalTitle == null
          ? null
          : goalIdByTitle[routineDraft.linkedGoalTitle!.toLowerCase()];
      final routine = Routine(
        id: _uuid.v4(),
        title: routineDraft.title,
        createdAt: DateTime.now(),
        anchorDate: DateTime.now(),
        repeatRule: _repeatRuleFor(routineDraft),
        preferredStartMinuteOfDay: routineDraft.preferredStartMinuteOfDay,
        preferredDurationMinutes: routineDraft.durationMinutes,
        isFlexible: routineDraft.isFlexible,
        autoRescheduleMissed: routineDraft.autoRecovery,
        linkedGoalId: linkedGoalId,
        routineType: routineDraft.routineType,
      );
      await _routineStore.saveRoutine(routine);
      existingRoutineSignatures.add(signature);
      createdRoutineCount += 1;
    }

    final existingTaskKeys = tasks
        .map((task) => _taskSignature(task.title, task.goalId))
        .toSet();
    var createdTaskCount = 0;
    var milestoneSequence = 0;
    for (final taskDraft in draft.tasks) {
      final linkedGoalId = taskDraft.linkedGoalTitle == null
          ? null
          : goalIdByTitle[taskDraft.linkedGoalTitle!.toLowerCase()];
      final signature = _taskSignature(taskDraft.title, linkedGoalId);
      if (existingTaskKeys.contains(signature)) {
        duplicateWarnings.add('Skipped duplicate task "${taskDraft.title}".');
        continue;
      }
      if (taskDraft.milestoneTitle != null && linkedGoalId != null) {
        final milestone = GoalMilestone(
          id: _uuid.v4(),
          goalId: linkedGoalId,
          title: taskDraft.milestoneTitle!,
          sequenceOrder: milestoneSequence,
          estimatedMinutes: taskDraft.estimatedMinutes,
          createdAt: DateTime.now(),
        );
        await _goalStore.addMilestone(milestone);
        milestoneSequence += 1;
      }
      final task = Task(
        id: _uuid.v4(),
        title: taskDraft.title,
        description: taskDraft.explanation,
        type: taskDraft.taskType,
        estimatedDurationMinutes: taskDraft.estimatedMinutes,
        dueDate: taskDraft.dueDate,
        priority: 2,
        goalId: linkedGoalId,
        createdAt: DateTime.now(),
      );
      await _taskStore.addTask(task);
      existingTaskKeys.add(signature);
      createdTaskCount += 1;
    }

    await _postApplyRefresh();

    return PlanningApplyResult(
      createdGoalCount: createdGoalCount,
      createdRoutineCount: createdRoutineCount,
      createdTaskCount: createdTaskCount,
      duplicateWarnings: duplicateWarnings,
    );
  }

  String _routineSignature(Routine routine) {
    return routine.title.toLowerCase();
  }

  String _routineDraftSignature(RoutineDraft routine) {
    return routine.title.toLowerCase();
  }

  String _taskSignature(String title, String? linkedGoalId) {
    return '${title.toLowerCase()}:${linkedGoalId ?? '-'}';
  }

  RoutineRepeatRule _repeatRuleFor(RoutineDraft draft) {
    return RoutineRepeatRule(
      type: draft.repeatType,
      weekdays: draft.repeatType == RoutineRepeatType.selectedWeekdays
          ? draft.preferredDays
          : const <int>[],
    );
  }
}
