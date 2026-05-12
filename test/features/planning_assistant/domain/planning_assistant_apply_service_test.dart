import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/goals/models/goal_milestone.dart';
import 'package:study_flow/features/goals/models/learning_goal.dart';
import 'package:study_flow/features/planning_assistant/application/services/planning_assistant_apply_service.dart';
import 'package:study_flow/features/planning_assistant/domain/models/planning_draft.dart';
import 'package:study_flow/features/routines/domain/routine_enums.dart';
import 'package:study_flow/features/routines/domain/routine_repeat_rule.dart';
import 'package:study_flow/features/routines/models/routine.dart';
import 'package:study_flow/features/tasks/models/task.dart';

void main() {
  group('PlanningAssistantApplyService', () {
    test(
      'applies previewed plan into linked goal, routine, and task structures',
      () async {
        final goalStore = _FakeGoalStore();
        final taskStore = _FakeTaskStore();
        final routineStore = _FakeRoutineStore();
        var refreshCalled = false;
        final service = PlanningAssistantApplyService(
          goalStore: goalStore,
          taskStore: taskStore,
          routineStore: routineStore,
          postApplyRefresh: () async {
            refreshCalled = true;
          },
        );

        final result = await service.applyDraft(_buildDraft());

        expect(result.createdGoalCount, 1);
        expect(result.createdRoutineCount, 1);
        expect(result.createdTaskCount, 1);
        expect(goalStore.goals.single.title, 'Placement Preparation');
        expect(
          routineStore.routines.single.linkedGoalId,
          goalStore.goals.single.id,
        );
        expect(taskStore.tasks.single.goalId, goalStore.goals.single.id);
        expect(refreshCalled, isTrue);
      },
    );

    test(
      'prevents duplicates instead of silently creating a second system',
      () async {
        final existingGoal = LearningGoal(
          id: 'goal-1',
          title: 'Placement Preparation',
          priority: 2,
          createdAt: DateTime(2026, 5, 1),
        );
        final goalStore = _FakeGoalStore(goals: <LearningGoal>[existingGoal]);
        final taskStore = _FakeTaskStore(
          tasks: <Task>[
            Task(
              id: 'task-1',
              title: 'Track Topic Coverage',
              type: TaskType.study,
              estimatedDurationMinutes: 45,
              priority: 2,
              goalId: existingGoal.id,
              createdAt: DateTime(2026, 5, 1),
            ),
          ],
        );
        final routineStore = _FakeRoutineStore(
          routines: <Routine>[
            Routine(
              id: 'routine-1',
              title: 'DSA Practice',
              createdAt: DateTime(2026, 5, 1),
              anchorDate: DateTime(2026, 5, 1),
              repeatRule: RoutineRepeatRule(type: RoutineRepeatType.weekdays),
              preferredStartMinuteOfDay: 20 * 60,
              preferredDurationMinutes: 60,
              linkedGoalId: existingGoal.id,
            ),
          ],
        );
        final service = PlanningAssistantApplyService(
          goalStore: goalStore,
          taskStore: taskStore,
          routineStore: routineStore,
          postApplyRefresh: () async {},
        );

        final result = await service.applyDraft(_buildDraft());

        expect(result.createdGoalCount, 0);
        expect(result.createdRoutineCount, 0);
        expect(result.createdTaskCount, 0);
        expect(result.duplicateWarnings, isNotEmpty);
      },
    );

    test(
      'preserves existing manual structures instead of mutating them',
      () async {
        final existingGoal = LearningGoal(
          id: 'goal-1',
          title: 'Placement Preparation',
          priority: 2,
          createdAt: DateTime(2026, 5, 1),
        );
        final manualRoutine = Routine(
          id: 'routine-1',
          title: 'DSA Practice',
          createdAt: DateTime(2026, 5, 1),
          anchorDate: DateTime(2026, 5, 1),
          repeatRule: RoutineRepeatRule(type: RoutineRepeatType.weekdays),
          preferredStartMinuteOfDay: 22 * 60,
          preferredDurationMinutes: 90,
          linkedGoalId: existingGoal.id,
        );
        final routineStore = _FakeRoutineStore(
          routines: <Routine>[manualRoutine],
        );
        final service = PlanningAssistantApplyService(
          goalStore: _FakeGoalStore(goals: <LearningGoal>[existingGoal]),
          taskStore: _FakeTaskStore(),
          routineStore: routineStore,
          postApplyRefresh: () async {},
        );

        final result = await service.applyDraft(_buildDraft());

        expect(result.createdRoutineCount, 0);
        expect(routineStore.routines.single.preferredStartMinuteOfDay, 22 * 60);
        expect(routineStore.routines.single.preferredDurationMinutes, 90);
      },
    );
  });
}

PlanningDraft _buildDraft() {
  return const PlanningDraft(
    goals: <GoalDraft>[
      GoalDraft(
        title: 'Placement Preparation',
        goalType: GoalType.examPrep,
        priority: 2,
      ),
    ],
    routines: <RoutineDraft>[
      RoutineDraft(
        title: 'DSA Practice',
        routineType: RoutineType.study,
        repeatType: RoutineRepeatType.weekdays,
        isFlexible: false,
        durationMinutes: 60,
        preferredStartMinuteOfDay: 20 * 60,
        preferredDays: <int>[
          DateTime.monday,
          DateTime.tuesday,
          DateTime.wednesday,
          DateTime.thursday,
          DateTime.friday,
        ],
        linkedGoalTitle: 'Placement Preparation',
        explanation:
            'Added evening DSA practice because the user requested placement prep.',
      ),
    ],
    projects: <ProjectDraft>[],
    tasks: <TaskDraft>[
      TaskDraft(
        title: 'Track Topic Coverage',
        taskType: TaskType.study,
        estimatedMinutes: 45,
        linkedGoalTitle: 'Placement Preparation',
        explanation: 'Added a concrete setup task so the system has a tracker.',
      ),
    ],
    loadEstimate: PlanningLoadEstimate(
      weeklyMinutes: 345,
      routineMinutes: 300,
      taskMinutes: 45,
      summary: 'About 5h 45m per week.',
    ),
    warnings: <PlanningWarning>[],
    assumptions: <String>[],
    explanations: <String>['Explainable draft'],
  );
}

class _FakeGoalStore implements PlanningAssistantGoalStore {
  _FakeGoalStore({List<LearningGoal>? goals})
    : goals = goals ?? <LearningGoal>[];

  final List<LearningGoal> goals;
  final List<GoalMilestone> milestones = <GoalMilestone>[];

  @override
  Future<void> addGoal(LearningGoal goal) async {
    goals.add(goal);
  }

  @override
  Future<void> addMilestone(GoalMilestone milestone) async {
    milestones.add(milestone);
  }

  @override
  Future<List<LearningGoal>> getAllGoals() async => goals;
}

class _FakeTaskStore implements PlanningAssistantTaskStore {
  _FakeTaskStore({List<Task>? tasks}) : tasks = tasks ?? <Task>[];

  final List<Task> tasks;

  @override
  Future<void> addTask(Task task) async {
    tasks.add(task);
  }

  @override
  Future<List<Task>> getAllTasks() async => tasks;
}

class _FakeRoutineStore implements PlanningAssistantRoutineStore {
  _FakeRoutineStore({List<Routine>? routines})
    : routines = routines ?? <Routine>[];

  final List<Routine> routines;

  @override
  Future<List<Routine>> getAllRoutines() async => routines;

  @override
  Future<void> saveRoutine(Routine routine) async {
    routines.add(routine);
  }
}
