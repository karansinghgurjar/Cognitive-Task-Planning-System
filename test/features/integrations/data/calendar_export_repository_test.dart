import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/goals/models/learning_goal.dart';
import 'package:study_flow/features/integrations/data/calendar_export_repository.dart';
import 'package:study_flow/features/integrations/models/calendar_export_options.dart';
import 'package:study_flow/features/schedule/models/planned_session.dart';
import 'package:study_flow/features/tasks/models/task.dart';

void main() {
  test(
    'filters sessions by selected statuses and skips malformed sessions',
    () async {
      final repository = CalendarExportRepository(
        loadSessionsInRange: (_, _) async => [
          PlannedSession(
            id: 'pending',
            taskId: 'task-1',
            start: DateTime(2026, 4, 7, 9),
            end: DateTime(2026, 4, 7, 10),
          ),
          PlannedSession(
            id: 'completed',
            taskId: 'task-2',
            start: DateTime(2026, 4, 7, 11),
            end: DateTime(2026, 4, 7, 12),
            status: PlannedSessionStatus.completed,
            completed: true,
          ),
          PlannedSession(
            id: 'missed',
            taskId: 'task-3',
            start: DateTime(2026, 4, 7, 13),
            end: DateTime(2026, 4, 7, 14),
            status: PlannedSessionStatus.missed,
          ),
          PlannedSession(
            id: 'bad',
            taskId: 'task-4',
            start: DateTime(2026, 4, 7, 15),
            end: DateTime(2026, 4, 7, 15),
          ),
        ],
        loadTasks: () async => [
          Task(
            id: 'task-1',
            title: 'Pending task',
            type: TaskType.study,
            estimatedDurationMinutes: 60,
            priority: 1,
            createdAt: DateTime(2026, 4, 1),
          ),
          Task(
            id: 'task-2',
            title: 'Completed task',
            type: TaskType.project,
            estimatedDurationMinutes: 60,
            priority: 1,
            createdAt: DateTime(2026, 4, 1),
          ),
          Task(
            id: 'task-3',
            title: 'Missed task',
            type: TaskType.reading,
            estimatedDurationMinutes: 60,
            priority: 1,
            createdAt: DateTime(2026, 4, 1),
          ),
        ],
        loadGoals: () async => const <LearningGoal>[],
      );

      final result = await repository.prepareExport(
        CalendarExportOptions.next7Days(
          now: DateTime(2026, 4, 7),
          includeCompletedSessions: true,
        ),
      );

      expect(result.sessions.map((session) => session.id).toList(), [
        'pending',
        'completed',
      ]);
      expect(
        result.warnings,
        contains('1 malformed session was skipped during calendar export.'),
      );
    },
  );

  test('includes missing-task warning when task references are absent', () async {
    final repository = CalendarExportRepository(
      loadSessionsInRange: (_, _) async => [
        PlannedSession(
          id: 'session-1',
          taskId: 'missing-task',
          start: DateTime(2026, 4, 7, 9),
          end: DateTime(2026, 4, 7, 10),
        ),
      ],
      loadTasks: () async => const <Task>[],
      loadGoals: () async => const <LearningGoal>[],
    );

    final result = await repository.prepareExport(
      CalendarExportOptions.next7Days(now: DateTime(2026, 4, 7)),
    );

    expect(result.sessions, hasLength(1));
    expect(
      result.warnings,
      contains(
        '1 session was exported with a fallback title because its task was missing.',
      ),
    );
  });
}
