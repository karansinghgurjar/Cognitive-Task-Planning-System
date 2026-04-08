import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../config/app_brand.dart';
import '../../features/goals/models/learning_goal.dart';
import '../../features/recommendations/domain/recommendation_models.dart';
import '../../features/routines/application/routine_reminder_service.dart';
import '../../features/routines/models/routine.dart';
import '../../features/routines/models/routine_occurrence.dart';
import '../../features/schedule/models/planned_session.dart';
import '../../features/settings/models/notification_preferences.dart';
import '../../features/tasks/models/task.dart';
import 'notification_log_repository.dart';
import 'notification_service.dart';

class NotificationSyncService {
  NotificationSyncService({
    required NotificationService notificationService,
    required NotificationLogRepository notificationLogRepository,
  }) : _notificationService = notificationService,
       _routineReminderService = RoutineReminderService(
         notificationService: notificationService,
       ),
       _notificationLogRepository = notificationLogRepository;

  final NotificationService _notificationService;
  final RoutineReminderService _routineReminderService;
  final NotificationLogRepository _notificationLogRepository;

  Future<void> syncSessionReminders({
    required List<PlannedSession> sessions,
    required List<Task> tasks,
    required NotificationPreferences preferences,
    required DateTime now,
  }) async {
    if (!preferences.sessionRemindersEnabled) {
      for (final session in sessions) {
        await _notificationService.cancelSessionReminder(session.id);
      }
      return;
    }

    final taskById = {for (final task in tasks) task.id: task};
    for (final session in sessions) {
      final task = taskById[session.taskId];
      final shouldSchedule =
          !session.isCompleted &&
          !session.isCancelled &&
          !session.isMissed &&
          !session.start.isBefore(now) &&
          !(task?.isCompleted ?? false);
      if (shouldSchedule) {
        await _notificationService.scheduleSessionReminder(
          session,
          taskTitle: task?.title,
          leadTimeMinutes: preferences.reminderLeadTimeMinutes,
        );
      } else {
        await _notificationService.cancelSessionReminder(session.id);
      }
    }
  }

  Future<void> cancelRemovedSessionReminders({
    required List<PlannedSession> previousSessions,
    required List<PlannedSession> currentSessions,
  }) async {
    final currentIds = currentSessions.map((session) => session.id).toSet();
    for (final previous in previousSessions) {
      if (!currentIds.contains(previous.id)) {
        await _notificationService.cancelSessionReminder(previous.id);
      }
    }
  }

  Future<void> cancelRemovedRoutineReminders({
    required List<RoutineOccurrence> previousOccurrences,
    required List<RoutineOccurrence> currentOccurrences,
  }) {
    return _routineReminderService.cancelRemovedRoutineReminders(
      previousOccurrences: previousOccurrences,
      currentOccurrences: currentOccurrences,
    );
  }

  Future<void> syncRoutineReminders({
    required List<Routine> routines,
    required List<RoutineOccurrence> occurrences,
    required NotificationPreferences preferences,
    required DateTime now,
  }) async {
    if (!preferences.sessionRemindersEnabled) {
      for (final occurrence in occurrences) {
        await _notificationService.cancelRoutineReminder(occurrence.id);
      }
      return;
    }
    await _routineReminderService.syncRoutineReminders(
      routines: routines,
      occurrences: occurrences,
      now: now,
    );
  }

  Future<void> notifyNewlyMissedSessions({
    required List<PlannedSession> previousSessions,
    required List<PlannedSession> currentSessions,
    required List<Task> tasks,
    required NotificationPreferences preferences,
    required DateTime now,
  }) async {
    if (!preferences.sessionRemindersEnabled) {
      return;
    }

    final newlyMissedSessions = identifyNewlyMissedSessions(
      previousSessions: previousSessions,
      currentSessions: currentSessions,
    );
    final taskById = {for (final task in tasks) task.id: task};

    for (final session in newlyMissedSessions) {
      final alreadySent = await _notificationLogRepository.wasSentToday(
        type: 'missed-session',
        entityId: session.id,
        now: now,
      );
      if (alreadySent) {
        continue;
      }

      final taskTitle = taskById[session.taskId]?.title ?? 'focus session';
      await _notificationService.showImmediateNotification(
        id: NotificationService.stableMissedSessionNotificationId(session.id),
        title: 'Session missed',
        body: 'You missed your $taskTitle session. Recover schedule?',
        channelId: NotificationService.sessionAlertChannelId,
        payload: NotificationService.encodePayload(
          const NotificationIntent(type: NotificationIntentType.missedSession),
        ),
        actions: const [
          AndroidNotificationAction(
            'open_today',
            'Open Today',
            showsUserInterface: true,
          ),
          AndroidNotificationAction(
            'recover_schedule',
            'Recover',
            showsUserInterface: true,
          ),
        ],
      );
      await _notificationLogRepository.markSent(
        type: 'missed-session',
        entityId: session.id,
        now: now,
      );
    }
  }

  static List<PlannedSession> identifyNewlyMissedSessions({
    required List<PlannedSession> previousSessions,
    required List<PlannedSession> currentSessions,
  }) {
    final previousById = {
      for (final session in previousSessions) session.id: session,
    };
    return currentSessions.where((session) {
      if (!session.isMissed) {
        return false;
      }
      final previous = previousById[session.id];
      return previous == null || !previous.isMissed;
    }).toList();
  }

  Future<void> syncDailySummary({
    required List<PlannedSession> sessions,
    required List<Task> tasks,
    required NotificationPreferences preferences,
    required DateTime now,
  }) async {
    if (!preferences.dailySummaryEnabled) {
      await _notificationService.cancelDailySummaryNotification();
      return;
    }

    final summary = NotificationService.buildDailySummaryContent(
      sessions: sessions,
      taskById: {for (final task in tasks) task.id: task},
      day: now,
    );
    await _notificationService.scheduleDailySummaryNotification(
      TimeOfDay(
        hour: preferences.dailySummaryHour,
        minute: preferences.dailySummaryMinute,
      ),
      title: summary.title,
      body: summary.body,
      payload: NotificationService.encodePayload(
        const NotificationIntent(type: NotificationIntentType.dailySummary),
      ),
      now: now,
    );
  }

  Future<void> syncRiskWarnings({
    required List<GoalFeasibilityReport> goalReports,
    required List<WorkloadWarning> workloadWarnings,
    required List<LearningGoal> goals,
    required NotificationPreferences preferences,
    required DateTime now,
  }) async {
    if (!preferences.deadlineWarningsEnabled) {
      return;
    }

    for (final report in goalReports.where(
      (item) =>
          item.riskLevel == DeadlineRiskLevel.high ||
          item.riskLevel == DeadlineRiskLevel.critical,
    )) {
      final sentToday = await _notificationLogRepository.wasSentToday(
        type: 'goal-risk',
        entityId: report.goalId,
        now: now,
      );
      if (sentToday) {
        continue;
      }

      await _notificationService.showImmediateNotification(
        id: NotificationService.stableGoalRiskNotificationId(report.goalId),
        title: 'Goal deadline risk',
        body:
            '${report.goalTitle} is short by ~${_formatHours(report.shortfallMinutes)} before the target date.',
        payload: NotificationService.encodePayload(
          NotificationIntent(
            type: NotificationIntentType.goalRisk,
            goalId: report.goalId,
          ),
        ),
      );
      await _notificationLogRepository.markSent(
        type: 'goal-risk',
        entityId: report.goalId,
        now: now,
      );
    }

    final overloadWarning = workloadWarnings
        .where((warning) {
          return warning.riskLevel == DeadlineRiskLevel.high ||
              warning.riskLevel == DeadlineRiskLevel.critical;
        })
        .cast<WorkloadWarning?>()
        .firstWhere((warning) => warning != null, orElse: () => null);
    if (overloadWarning != null) {
      final sentToday = await _notificationLogRepository.wasSentToday(
        type: 'overload',
        entityId: 'weekly',
        now: now,
      );
      if (!sentToday) {
        await _notificationService.showImmediateNotification(
          id: NotificationService.stableOverloadNotificationId(),
          title: 'Schedule overload detected',
          body: overloadWarning.description,
          payload: NotificationService.encodePayload(
            const NotificationIntent(type: NotificationIntentType.overload),
          ),
        );
        await _notificationLogRepository.markSent(
          type: 'overload',
          entityId: 'weekly',
          now: now,
        );
      }
    }
  }

  Future<void> showTestNotification() {
    return _notificationService.showImmediateNotification(
      id: NotificationService.immediateIdFor('test', 'manual'),
      title: '${AppBrand.appName} Test Notification',
      body: 'Notifications are configured and ready.',
      channelId: NotificationService.testChannelId,
      payload: NotificationService.encodePayload(
        const NotificationIntent(type: NotificationIntentType.test),
      ),
    );
  }

  String _formatHours(int minutes) {
    return (minutes / 60).toStringAsFixed(1);
  }
}
