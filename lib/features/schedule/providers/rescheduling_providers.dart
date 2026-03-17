import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

import '../../focus_session/providers/focus_session_providers.dart';
import '../../../core/database/isar_providers.dart';
import '../../goals/data/goal_repository.dart';
import '../../tasks/providers/task_providers.dart';
import '../../timetable/providers/timetable_providers.dart';
import '../domain/missed_session_service.dart';
import '../domain/rescheduling_models.dart';
import '../domain/rescheduling_service.dart';
import '../models/planned_session.dart';
import 'schedule_providers.dart';

final missedSessionServiceProvider = Provider<MissedSessionService>((ref) {
  return const MissedSessionService();
});

final reschedulingServiceProvider = Provider<ReschedulingService>((ref) {
  return ReschedulingService(
    scheduleGeneratorService: ref.read(scheduleGeneratorServiceProvider),
  );
});

final detectedMissedSessionsProvider = FutureProvider<List<PlannedSession>>((
  ref,
) async {
  final repository = await ref.watch(plannedSessionRepositoryProvider.future);
  final sessions = await repository.getAllSessions();
  final now = DateTime.now();
  return ref
      .read(missedSessionServiceProvider)
      .detectMissedSessions(sessions, now);
});

final reschedulingControllerProvider =
    AsyncNotifierProvider<ReschedulingController, ReschedulingResult?>(
      ReschedulingController.new,
    );

class ReschedulingController extends AsyncNotifier<ReschedulingResult?> {
  @override
  ReschedulingResult? build() {
    return null;
  }

  Future<ReschedulingResult> recoverAndRescheduleNext7Days() async {
    _ensureIdle();
    state = const AsyncLoading();

    try {
      final now = DateTime.now();
      final horizonEnd = DateTime(
        now.year,
        now.month,
        now.day,
      ).add(const Duration(days: 7));

      final taskRepository = await ref.read(taskRepositoryProvider.future);
      final timetableRepository = await ref.read(
        timetableRepositoryProvider.future,
      );
      final goalRepository = GoalRepository(
        await ref.read(isarInstanceProvider.future),
      );
      final sessionRepository = await ref.read(
        plannedSessionRepositoryProvider.future,
      );

      final tasks = await taskRepository.getAllTasks();
      final dependencies = await goalRepository.getAllDependencies();
      final slots = await timetableRepository.getAllSlots();
      final sessions = await sessionRepository.getAllSessions();
      final weeklyAvailability = ref
          .read(availabilityServiceProvider)
          .computeWeeklyAvailability(slots);

      final missedSessions = ref
          .read(missedSessionServiceProvider)
          .detectMissedSessions(sessions, now);

      if (missedSessions.isNotEmpty) {
        await sessionRepository.updateSessions(missedSessions);
      }

      final activeSessionId = ref
          .read(focusSessionControllerProvider)
          ?.plannedSessionId;

      final mergedSessions = _mergeSessions(
        originalSessions: sessions,
        updatedSessions: missedSessions,
      );

      final result = ref
          .read(reschedulingServiceProvider)
          .recoverAndReschedule(
            tasks: tasks,
            sessions: mergedSessions,
            missedSessions: missedSessions,
            weeklyAvailability: weeklyAvailability,
            now: now,
            dependencies: dependencies,
            activeSessionId: activeSessionId,
          );

      await sessionRepository.replaceFutureSessionsInRange(
        start: now,
        end: horizonEnd,
        newSessions: result.rescheduledSessions,
        keepCompleted: true,
        activeSessionId: activeSessionId,
      );

      debugPrint(
        'Rescheduling: missed=${result.summary.missedSessionCount} regenerated=${result.summary.regeneratedSessionCount} recoveredMinutes=${result.summary.totalRecoveredMinutes} unscheduledMinutes=${result.summary.totalUnscheduledMinutes}',
      );
      state = AsyncData(result);
      return result;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  void _ensureIdle() {
    if (state.isLoading) {
      throw StateError('Another recovery action is already in progress.');
    }
  }

  List<PlannedSession> _mergeSessions({
    required List<PlannedSession> originalSessions,
    required List<PlannedSession> updatedSessions,
  }) {
    final updatedById = {
      for (final session in updatedSessions) session.id: session,
    };
    return originalSessions.map((session) {
      return updatedById[session.id] ?? session;
    }).toList();
  }
}
