import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/ai_planning/domain/ai_plan_import_service.dart';
import 'package:study_flow/features/ai_planning/domain/ai_planning_models.dart';
import 'package:study_flow/features/goals/models/goal_milestone.dart';
import 'package:study_flow/features/goals/models/learning_goal.dart';
import 'package:study_flow/features/goals/models/task_dependency.dart';
import 'package:study_flow/features/tasks/models/task.dart';

void main() {
  group('AiPlanImportService', () {
    late _InMemoryGoalStore goalStore;
    late _InMemoryTaskStore taskStore;
    late AiPlanImportService service;

    setUp(() {
      goalStore = _InMemoryGoalStore();
      taskStore = _InMemoryTaskStore();
      service = AiPlanImportService(
        goalRepository: goalStore,
        taskRepository: taskStore,
      );
    });

    test(
      'imports a generated plan into goals, milestones, tasks, and dependencies',
      () async {
        await service.importApprovedPlan(
          _sampleResult(),
          const ImportOptions(),
        );

        expect(goalStore.goals, hasLength(1));
        expect(goalStore.goals.single.title, 'Learn Flutter');
        expect(goalStore.milestones.map((item) => item.title), [
          'Dart basics',
          'Flutter widgets and layout',
        ]);
        expect(taskStore.tasks, hasLength(2));
        expect(
          taskStore.tasks.map((item) => item.goalId),
          everyElement(goalStore.goals.single.id),
        );
        expect(goalStore.dependencies, hasLength(1));
      },
    );

    test(
      'avoids duplicating milestones and tasks when importing into an existing goal',
      () async {
        await service.importApprovedPlan(
          _sampleResult(),
          const ImportOptions(),
        );
        final existingGoal = goalStore.goals.single;

        await service.importApprovedPlan(
          _sampleResult(),
          ImportOptions(existingGoalId: existingGoal.id),
        );

        expect(goalStore.goals, hasLength(1));
        expect(goalStore.milestones, hasLength(2));
        expect(taskStore.tasks, hasLength(2));
        expect(goalStore.dependencies, hasLength(1));
      },
    );
  });
}

class _InMemoryGoalStore implements AiPlanGoalStore {
  final List<LearningGoal> goals = [];
  final List<GoalMilestone> milestones = [];
  final List<TaskDependency> dependencies = [];

  @override
  Future<void> addDependency(TaskDependency dependency) async {
    dependencies.add(dependency);
  }

  @override
  Future<void> addGoal(LearningGoal goal) async {
    goals.add(goal);
  }

  @override
  Future<void> addMilestone(GoalMilestone milestone) async {
    milestones.add(milestone);
  }

  @override
  Future<List<TaskDependency>> getAllDependencies() async {
    return List<TaskDependency>.from(dependencies);
  }

  @override
  Future<LearningGoal?> getGoalById(String id) async {
    for (final goal in goals) {
      if (goal.id == id) {
        return goal;
      }
    }
    return null;
  }

  @override
  Future<List<GoalMilestone>> getMilestonesForGoal(String goalId) async {
    return milestones.where((item) => item.goalId == goalId).toList();
  }

  @override
  Future<void> updateGoal(LearningGoal goal) async {
    final index = goals.indexWhere((item) => item.id == goal.id);
    if (index >= 0) {
      goals[index] = goal;
    }
  }

  @override
  Future<void> updateMilestone(GoalMilestone milestone) async {
    final index = milestones.indexWhere((item) => item.id == milestone.id);
    if (index >= 0) {
      milestones[index] = milestone;
    }
  }
}

class _InMemoryTaskStore implements AiPlanTaskStore {
  final List<Task> tasks = [];

  @override
  Future<void> addTask(Task task) async {
    tasks.add(task);
  }

  @override
  Future<List<Task>> getAllTasks() async {
    return List<Task>.from(tasks);
  }

  @override
  Future<void> updateTask(Task task) async {
    final index = tasks.indexWhere((item) => item.id == task.id);
    if (index >= 0) {
      tasks[index] = task;
    }
  }
}

AiPlanResult _sampleResult() {
  const request = NaturalLanguagePlanRequest(
    prompt: 'Learn Flutter for app development',
    priority: 2,
  );
  const parsed = ParsedGoalPrompt(
    originalPrompt: 'Learn Flutter for app development',
    normalizedPrompt: 'learn flutter for app development',
    titleCandidate: 'Learn Flutter',
    inferredGoalType: GoalType.learning,
    keywords: ['flutter'],
    topicTokens: ['flutter'],
    isRevision: false,
    isFromScratch: true,
    isAdvanced: false,
    isExam: false,
    isInterview: false,
    isProject: false,
    isUrgent: false,
  );
  const goal = GoalDraft(
    title: 'Learn Flutter',
    goalType: GoalType.learning,
    priority: 2,
    estimatedTotalMinutes: 180,
  );
  const milestones = [
    MilestoneDraft(
      id: 'milestone-1',
      title: 'Dart basics',
      sequenceOrder: 1,
      estimatedMinutes: 90,
    ),
    MilestoneDraft(
      id: 'milestone-2',
      title: 'Flutter widgets and layout',
      sequenceOrder: 2,
      estimatedMinutes: 90,
    ),
  ];
  const tasks = [
    TaskDraft(
      id: 'task-1',
      title: 'Set up Dart syntax and types practice',
      type: TaskType.coding,
      estimatedMinutes: 60,
      milestoneDraftId: 'milestone-1',
    ),
    TaskDraft(
      id: 'task-2',
      title: 'Build layout practice screens',
      type: TaskType.coding,
      estimatedMinutes: 120,
      milestoneDraftId: 'milestone-2',
    ),
  ];
  const dependencies = [
    DependencyDraft(
      taskDraftId: 'task-2',
      dependsOnTaskDraftId: 'task-1',
      reason: 'Widgets follow Dart basics.',
    ),
  ];

  return const AiPlanResult(
    request: request,
    parsedPrompt: parsed,
    goal: goal,
    milestones: milestones,
    tasks: tasks,
    dependencies: dependencies,
    durationEstimates: [],
    suggestions: [],
    warnings: [],
    explanationSummary: 'Generated from the Flutter roadmap.',
    suggestedWeeklyMinutes: 180,
    suggestedCadence: '3 sessions per week.',
  );
}
