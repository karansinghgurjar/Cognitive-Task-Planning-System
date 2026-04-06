import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/goals/models/learning_goal.dart';
import 'package:study_flow/features/integrations/domain/ics_export_service.dart';
import 'package:study_flow/features/schedule/models/planned_session.dart';
import 'package:study_flow/features/tasks/models/task.dart';

void main() {
  const service = IcsExportService();

  test('generates valid calendar wrapper and event count', () {
    final sessions = [
      PlannedSession(
        id: 'session-1',
        taskId: 'task-1',
        start: DateTime(2026, 4, 7, 9),
        end: DateTime(2026, 4, 7, 10),
      ),
      PlannedSession(
        id: 'session-2',
        taskId: 'task-2',
        start: DateTime(2026, 4, 7, 11),
        end: DateTime(2026, 4, 7, 12),
      ),
    ];
    final tasks = {
      'task-1': Task(
        id: 'task-1',
        title: 'DSA Arrays',
        type: TaskType.study,
        estimatedDurationMinutes: 60,
        priority: 2,
        createdAt: DateTime(2026, 4, 1),
      ),
      'task-2': Task(
        id: 'task-2',
        title: 'Build portfolio project',
        type: TaskType.project,
        estimatedDurationMinutes: 60,
        priority: 2,
        createdAt: DateTime(2026, 4, 1),
      ),
    };

    final ics = service.generateIcsForSessions(
      sessions,
      tasks,
      generatedAt: DateTime.utc(2026, 4, 7, 8),
    );

    expect(ics, startsWith('BEGIN:VCALENDAR\r\n'));
    expect('BEGIN:VEVENT'.allMatches(ics).length, 2);
    expect(ics, contains('END:VCALENDAR'));
    expect(ics, contains('SUMMARY:DSA Arrays Focus Session'));
    expect(ics, contains('SUMMARY:Build portfolio project Focus Session'));
  });

  test('uses stable uid and rich description content', () {
    final session = PlannedSession(
      id: 'session-1',
      taskId: 'task-1',
      start: DateTime(2026, 4, 7, 9, 30),
      end: DateTime(2026, 4, 7, 10, 30),
      status: PlannedSessionStatus.completed,
      completed: true,
    );
    final task = Task(
      id: 'task-1',
      title: 'Revise operating systems',
      description: 'Focus on memory management.',
      type: TaskType.study,
      estimatedDurationMinutes: 60,
      priority: 1,
      goalId: 'goal-1',
      createdAt: DateTime(2026, 4, 1),
    );
    final goal = LearningGoal(
      id: 'goal-1',
      title: 'Semester exam prep',
      goalType: GoalType.examPrep,
      priority: 1,
      createdAt: DateTime(2026, 4, 1),
    );

    final ics = service.generateIcsForSessions(
      [session],
      {'task-1': task},
      goalMap: {'goal-1': goal},
      generatedAt: DateTime.utc(2026, 4, 7, 8),
    );

    expect(ics, contains('UID:planned-session-session-1@cogniplan.local'));
    expect(
      ics,
      contains(
        r'DESCRIPTION:Task: Revise operating systems\nDuration: 60 minutes',
      ),
    );
    expect(ics, contains(r'Status: Completed\nTask Type: Study'));
    expect(ics, contains(r'Goal: Semester exam prep\nGenerated'));
    expect(ics, contains(r'by CogniPlan'));
    expect(ics, contains(r'Task Notes: Focus on memory management.'));
    expect(ics, contains('CATEGORIES:Focus,Study,Exam Prep'));
  });

  test('falls back safely when task metadata is missing', () {
    final session = PlannedSession(
      id: 'session-missing-task',
      taskId: 'missing',
      start: DateTime(2026, 4, 7, 9),
      end: DateTime(2026, 4, 7, 10),
    );

    final ics = service.generateIcsForSessions(
      [session],
      const {},
      generatedAt: DateTime.utc(2026, 4, 7, 8),
    );

    expect(ics, contains('SUMMARY:Untitled Session Focus Session'));
    expect(
      ics,
      contains(r'DESCRIPTION:Task: Untitled Session\nDuration: 60 minutes'),
    );
  });
}
