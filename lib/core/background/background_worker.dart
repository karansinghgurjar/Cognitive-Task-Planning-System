import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

import '../../features/goals/data/goal_repository.dart';
import '../../features/recommendations/domain/recommendation_engine_service.dart';
import '../../features/schedule/models/planned_session.dart';
import '../../features/schedule/data/planned_session_repository.dart';
import '../../features/schedule/domain/missed_session_service.dart';
import '../../features/settings/data/settings_repository.dart';
import '../../features/tasks/data/task_repository.dart';
import '../../features/timetable/data/timetable_repository.dart';
import '../../features/timetable/domain/availability_service.dart';
import '../database/isar_service.dart';
import '../notifications/notification_log_repository.dart';
import '../notifications/notification_service.dart';
import '../notifications/notification_sync_service.dart';

class BackgroundWorker {
  static const _taskName = 'study_flow_proactive_checks';

  Future<void> initialize() async {
    if (!Platform.isAndroid) {
      return;
    }

    await Workmanager().initialize(callbackDispatcher);
    await Workmanager().registerPeriodicTask(
      _taskName,
      _taskName,
      frequency: const Duration(minutes: 15),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      constraints: Constraints(networkType: NetworkType.notRequired),
    );
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();

      final isar = await IsarService().openIsar();
      final settingsRepository = SettingsRepository(isar);
      final plannedSessionRepository = PlannedSessionRepository(isar);
      final taskRepository = TaskRepository(isar);
      final goalRepository = GoalRepository(isar);
      final timetableRepository = TimetableRepository(isar);
      final notificationService = NotificationService();
      final notificationSyncService = NotificationSyncService(
        notificationService: notificationService,
        notificationLogRepository: NotificationLogRepository(isar),
      );

      await notificationService.initialize();

      final preferences = await settingsRepository.getPreferences();
      final sessions = await plannedSessionRepository.getAllSessions();
      final tasks = await taskRepository.getAllTasks(includeArchived: false);
      final goals = await goalRepository.getAllGoals();
      final milestones = await goalRepository.getAllMilestones();
      final timetableSlots = await timetableRepository.getAllSlots();
      final weeklyAvailability = const AvailabilityService()
          .computeWeeklyAvailability(timetableSlots);
      final now = DateTime.now();

      final missedSessions = const MissedSessionService().detectMissedSessions(
        sessions,
        now,
      );
      if (missedSessions.isNotEmpty) {
        await plannedSessionRepository.updateSessions(missedSessions);
      }

      final currentSessions = _mergeSessions(sessions, missedSessions);
      final recommendationEngine = const RecommendationEngineService();
      final goalReports = recommendationEngine.computeGoalFeasibility(
        goals: goals,
        milestones: milestones,
        tasks: tasks,
        plannedSessions: currentSessions,
        weeklyAvailability: weeklyAvailability,
        now: now,
      );
      final warnings = recommendationEngine.computeWorkloadWarnings(
        tasks: tasks,
        goals: goals,
        milestones: milestones,
        plannedSessions: currentSessions,
        weeklyAvailability: weeklyAvailability,
        now: now,
      );

      await notificationSyncService.syncSessionReminders(
        sessions: currentSessions,
        tasks: tasks,
        preferences: preferences,
        now: now,
      );
      await notificationSyncService.notifyNewlyMissedSessions(
        previousSessions: sessions,
        currentSessions: currentSessions,
        tasks: tasks,
        preferences: preferences,
        now: now,
      );
      await notificationSyncService.syncDailySummary(
        sessions: currentSessions,
        tasks: tasks,
        preferences: preferences,
        now: now,
      );
      await notificationSyncService.syncRiskWarnings(
        goalReports: goalReports,
        workloadWarnings: warnings,
        goals: goals,
        preferences: preferences,
        now: now,
      );

      return true;
    } catch (error, stackTrace) {
      debugPrint('Background worker failed: $error');
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'study_flow',
          context: ErrorDescription('during background worker task execution'),
        ),
      );
      return false;
    }
  });
}

List<PlannedSession> _mergeSessions(
  List<PlannedSession> original,
  List<PlannedSession> updated,
) {
  if (updated.isEmpty) {
    return original;
  }

  final updatedById = {for (final session in updated) session.id: session};
  return original.map((session) => updatedById[session.id] ?? session).toList();
}
