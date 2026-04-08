import '../../schedule/models/planned_session.dart';
import '../../timetable/domain/availability_service.dart';
import '../data/routine_occurrence_repository.dart';
import '../domain/routine_date_utils.dart';
import '../models/routine.dart';
import '../models/routine_occurrence.dart';
import 'routine_diagnostics_service.dart';
import 'routine_history_policy_service.dart';
import 'routine_recovery_service.dart';
import 'routine_reminder_service.dart';
import 'routine_scheduler_integration_service.dart';

class RoutinePlannerPipelineResult {
  const RoutinePlannerPipelineResult({
    required this.updatedOccurrences,
    required this.unscheduledOccurrences,
    required this.diagnostics,
  });

  final List<RoutineOccurrence> updatedOccurrences;
  final List<RoutineOccurrence> unscheduledOccurrences;
  final RoutineDiagnosticsSnapshot diagnostics;
}

class RoutinePlannerPipelineService {
  const RoutinePlannerPipelineService({
    required RoutineHistoryPolicyService historyPolicyService,
    required RoutineRecoveryService recoveryService,
    required RoutineSchedulerIntegrationService schedulerIntegrationService,
    required RoutineReminderService reminderService,
    required RoutineDiagnosticsService diagnosticsService,
  }) : _historyPolicyService = historyPolicyService,
       _recoveryService = recoveryService,
       _schedulerIntegrationService = schedulerIntegrationService,
       _reminderService = reminderService,
       _diagnosticsService = diagnosticsService;

  final RoutineHistoryPolicyService _historyPolicyService;
  final RoutineRecoveryService _recoveryService;
  final RoutineSchedulerIntegrationService _schedulerIntegrationService;
  final RoutineReminderService _reminderService;
  final RoutineDiagnosticsService _diagnosticsService;

  Future<RoutinePlannerPipelineResult> run({
    required List<Routine> routines,
    required RoutineOccurrenceRepository occurrenceRepository,
    required Map<int, List<AvailabilityWindow>> weeklyAvailability,
    required List<PlannedSession> plannedSessions,
    required DateTime now,
  }) async {
    final startedAt = DateTime.now();
    final window = _historyPolicyService.activePlanningWindow(now: now);
    final baselineOccurrences = await occurrenceRepository.getOccurrencesInRange(
      window.startDate,
      window.endDate,
    );

    final missedUpdates = _recoveryService.detectMissedOccurrences(
      occurrences: baselineOccurrences,
      now: now,
    );
    if (missedUpdates.isNotEmpty) {
      await occurrenceRepository.saveOccurrences(missedUpdates);
    }

    final refreshedOccurrences = missedUpdates.isEmpty
        ? baselineOccurrences
        : await occurrenceRepository.getOccurrencesInRange(
            window.startDate,
            window.endDate,
          );

    final integration = _schedulerIntegrationService.integrate(
      routines: routines,
      occurrences: refreshedOccurrences,
      weeklyAvailability: weeklyAvailability,
      plannedSessions: plannedSessions,
      startDate: window.startDate,
      endDate: window.endDate,
      now: now,
    );

    if (integration.updatedOccurrences.isNotEmpty) {
      await occurrenceRepository.saveOccurrences(integration.updatedOccurrences);
    }

    final finalOccurrences = integration.updatedOccurrences.isEmpty
        ? refreshedOccurrences
        : await occurrenceRepository.getOccurrencesInRange(
            window.startDate,
            window.endDate,
          );
    final reminderOutcome = await _reminderService.syncRoutineReminders(
      routines: routines,
      occurrences: finalOccurrences,
      now: now,
    );

    final diagnostics = _diagnosticsService.summarize(
      startedAt: startedAt,
      finishedAt: DateTime.now(),
      scannedOccurrences: refreshedOccurrences.length,
      missedMarked: missedUpdates.length,
      recoverySuggestions: _recoveryService
          .buildRecoverySuggestions(
            routines: routines,
            occurrences: finalOccurrences,
            now: now,
          )
          .length,
      autoScheduled: integration.updatedOccurrences
          .where((occurrence) => occurrence.isAutoScheduled)
          .length,
      unscheduled: integration.unscheduledOccurrences.length,
      remindersScheduled: reminderOutcome.scheduledCount,
      remindersCancelled: reminderOutcome.cancelledCount,
      notes: [
        'Planning window ${normalizeDate(window.startDate)} to ${normalizeDate(window.endDate)}',
      ],
    );

    return RoutinePlannerPipelineResult(
      updatedOccurrences: integration.updatedOccurrences,
      unscheduledOccurrences: integration.unscheduledOccurrences,
      diagnostics: diagnostics,
    );
  }
}
