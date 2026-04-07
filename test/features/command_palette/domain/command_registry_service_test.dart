import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/command_palette/domain/command_models.dart';
import 'package:study_flow/features/command_palette/domain/command_registry_service.dart';
import 'package:study_flow/features/focus_session/domain/focus_session_state.dart';

void main() {
  group('CommandRegistryService', () {
    const service = CommandRegistryService();

    test('includes the core navigation and action commands', () {
      const context = CommandContext(
        tasks: [],
        goals: [],
        activeFocusSession: null,
        missedSessionCount: 0,
        isGeneratingSchedule: false,
        isRecoveringSchedule: false,
      );

      final commands = service.getCommands(context);
      final ids = commands.map((command) => command.id).toSet();

      expect(ids, contains(AppCommandId.openToday));
      expect(ids, contains(AppCommandId.openTasks));
      expect(ids, contains(AppCommandId.openGoals));
      expect(ids, contains(AppCommandId.openAnalytics));
      expect(ids, contains(AppCommandId.openWeeklyReview));
      expect(ids, contains(AppCommandId.quickCapture));
      expect(ids, contains(AppCommandId.generateSchedule));
    });

    test('disables resume focus when no active focus session exists', () {
      const context = CommandContext(
        tasks: [],
        goals: [],
        activeFocusSession: null,
        missedSessionCount: 0,
        isGeneratingSchedule: false,
        isRecoveringSchedule: false,
      );

      final command = service
          .getCommands(context)
          .firstWhere((item) => item.id == AppCommandId.resumeFocus);

      expect(command.isEnabled, isFalse);
    });

    test('enables resume focus and recover when context supports them', () {
      final context = CommandContext(
        tasks: const [],
        goals: const [],
        activeFocusSession: FocusSessionState(
          plannedSessionId: 'session-1',
          taskId: 'task-1',
          taskTitle: 'Arrays practice',
          plannedStart: DateTime(2026, 4, 7, 9),
          plannedEnd: DateTime(2026, 4, 7, 10),
          plannedDurationMinutes: 60,
          remainingSeconds: 1200,
          elapsedSeconds: 2400,
          isRunning: true,
          isPaused: false,
          startedAt: DateTime(2026, 4, 7, 9),
          lastResumedAt: DateTime(2026, 4, 7, 9, 30),
        ),
        missedSessionCount: 2,
        isGeneratingSchedule: false,
        isRecoveringSchedule: false,
      );

      final commands = service.getCommands(context);
      final resume = commands.firstWhere(
        (item) => item.id == AppCommandId.resumeFocus,
      );
      final recover = commands.firstWhere(
        (item) => item.id == AppCommandId.recoverMissedSessions,
      );

      expect(resume.isEnabled, isTrue);
      expect(recover.isEnabled, isTrue);
    });
  });
}
