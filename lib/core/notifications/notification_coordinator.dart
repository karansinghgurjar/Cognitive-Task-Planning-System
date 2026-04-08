import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/focus_session/presentation/focus_session_screen.dart';
import '../../features/focus_session/providers/focus_session_providers.dart';
import '../../features/goals/models/learning_goal.dart';
import '../../features/goals/presentation/goal_detail_screen.dart';
import '../../features/goals/providers/goal_providers.dart';
import '../../features/recommendations/domain/recommendation_models.dart';
import '../../features/recommendations/providers/recommendation_providers.dart';
import '../../features/routines/models/routine.dart';
import '../../features/routines/models/routine_occurrence.dart';
import '../../features/routines/presentation/routine_detail_screen.dart';
import '../../features/routines/providers/routine_providers.dart';
import '../../features/schedule/models/planned_session.dart';
import '../../features/schedule/presentation/today_screen.dart';
import '../../features/schedule/providers/rescheduling_providers.dart';
import '../../features/schedule/providers/schedule_providers.dart';
import '../../features/settings/models/notification_preferences.dart';
import '../../features/settings/providers/settings_providers.dart';
import '../../features/tasks/models/task.dart';
import '../../features/tasks/providers/task_providers.dart';
import '../navigation/app_navigation.dart';
import 'notification_providers.dart';
import 'notification_service.dart';

class NotificationCoordinator extends ConsumerStatefulWidget {
  const NotificationCoordinator({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<NotificationCoordinator> createState() =>
      _NotificationCoordinatorState();
}

class _NotificationCoordinatorState
    extends ConsumerState<NotificationCoordinator> {
  ProviderSubscription<AsyncValue<List<PlannedSession>>>? _sessionsSub;
  ProviderSubscription<AsyncValue<List<Task>>>? _tasksSub;
  ProviderSubscription<AsyncValue<NotificationPreferences>>? _prefsSub;
  ProviderSubscription<AsyncValue<List<LearningGoal>>>? _goalsSub;
  ProviderSubscription<AsyncValue<List<Routine>>>? _routinesSub;
  ProviderSubscription<AsyncValue<List<RoutineOccurrence>>>? _routineOccurrencesSub;
  ProviderSubscription<AsyncValue<List<GoalFeasibilityReport>>>?
  _goalReportsSub;
  ProviderSubscription<AsyncValue<List<WorkloadWarning>>>? _warningsSub;
  StreamSubscription<NotificationIntent>? _intentSub;

  List<PlannedSession> _sessions = const [];
  List<PlannedSession> _previousSessions = const [];
  List<Task> _tasks = const [];
  List<LearningGoal> _goals = const [];
  List<Routine> _routines = const [];
  List<RoutineOccurrence> _routineOccurrences = const [];
  List<RoutineOccurrence> _previousRoutineOccurrences = const [];
  NotificationPreferences? _preferences;
  List<GoalFeasibilityReport> _goalReports = const [];
  List<WorkloadWarning> _workloadWarnings = const [];
  bool _notificationsAvailable = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  @override
  void dispose() {
    _sessionsSub?.close();
    _tasksSub?.close();
    _prefsSub?.close();
    _goalsSub?.close();
    _routinesSub?.close();
    _routineOccurrencesSub?.close();
    _goalReportsSub?.close();
    _warningsSub?.close();
    unawaited(_intentSub?.cancel());
    super.dispose();
  }

  Future<void> _initialize() async {
    final notificationService = ref.read(notificationServiceProvider);
    try {
      await notificationService.initialize();
      _intentSub = notificationService.intents.listen(_handleIntent);
    } catch (error, stackTrace) {
      _notificationsAvailable = false;
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'study_flow',
          context: ErrorDescription('during notification coordinator init'),
        ),
      );
      return;
    }

    _sessionsSub = ref.listenManual(watchAllSessionsProvider, (_, next) {
      next.whenData((sessions) {
        _previousSessions = _sessions;
        _sessions = sessions;
        unawaited(_syncSessionNotifications());
      });
    }, fireImmediately: true);

    _tasksSub = ref.listenManual(watchActiveTasksProvider, (_, next) {
      next.whenData((tasks) {
        _tasks = tasks;
        unawaited(_syncSessionNotifications());
      });
    }, fireImmediately: true);

    _prefsSub = ref.listenManual(notificationPreferencesProvider, (_, next) {
      next.whenData((preferences) {
        _preferences = preferences;
        unawaited(_syncSessionNotifications());
        unawaited(_syncRoutineNotifications());
        unawaited(_syncRiskNotifications());
      });
    }, fireImmediately: true);

    _goalsSub = ref.listenManual(watchGoalsProvider, (_, next) {
      next.whenData((goals) {
        _goals = goals;
        unawaited(_syncRiskNotifications());
      });
    }, fireImmediately: true);

    _routinesSub = ref.listenManual(watchAllRoutinesProvider, (_, next) {
      next.whenData((routines) {
        _routines = routines;
        unawaited(_syncRoutineNotifications());
      });
    }, fireImmediately: true);

    _routineOccurrencesSub = ref.listenManual(
      watchAllRoutineOccurrencesProvider,
      (_, next) {
        next.whenData((occurrences) {
          _previousRoutineOccurrences = _routineOccurrences;
          _routineOccurrences = occurrences;
          unawaited(_syncRoutineNotifications());
        });
      },
      fireImmediately: true,
    );

    _goalReportsSub = ref.listenManual(goalFeasibilityReportsProvider, (
      _,
      next,
    ) {
      next.whenData((reports) {
        _goalReports = reports;
        unawaited(_syncRiskNotifications());
      });
    }, fireImmediately: true);

    _warningsSub = ref.listenManual(workloadWarningsProvider, (_, next) {
      next.whenData((warnings) {
        _workloadWarnings = warnings;
        unawaited(_syncRiskNotifications());
      });
    }, fireImmediately: true);
  }

  Future<void> _syncSessionNotifications() async {
    if (!_notificationsAvailable) {
      return;
    }
    final preferences = _preferences;
    if (preferences == null) {
      return;
    }

    try {
      final syncService = await ref.read(
        notificationSyncServiceProvider.future,
      );
      final now = DateTime.now();
      await syncService.cancelRemovedSessionReminders(
        previousSessions: _previousSessions,
        currentSessions: _sessions,
      );
      await syncService.syncSessionReminders(
        sessions: _sessions,
        tasks: _tasks,
        preferences: preferences,
        now: now,
      );
      await syncService.notifyNewlyMissedSessions(
        previousSessions: _previousSessions,
        currentSessions: _sessions,
        tasks: _tasks,
        preferences: preferences,
        now: now,
      );
      await syncService.syncDailySummary(
        sessions: _sessions,
        tasks: _tasks,
        preferences: preferences,
        now: now,
      );
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'study_flow',
          context: ErrorDescription('during notification sync'),
        ),
      );
    }
  }

  Future<void> _syncRiskNotifications() async {
    if (!_notificationsAvailable) {
      return;
    }
    final preferences = _preferences;
    if (preferences == null) {
      return;
    }

    try {
      final syncService = await ref.read(
        notificationSyncServiceProvider.future,
      );
      await syncService.syncRiskWarnings(
        goalReports: _goalReports,
        workloadWarnings: _workloadWarnings,
        goals: _goals,
        preferences: preferences,
        now: DateTime.now(),
      );
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'study_flow',
          context: ErrorDescription('during risk notification sync'),
        ),
      );
    }
  }

  Future<void> _syncRoutineNotifications() async {
    if (!_notificationsAvailable) {
      return;
    }
    final preferences = _preferences;
    if (preferences == null) {
      return;
    }

    try {
      final syncService = await ref.read(notificationSyncServiceProvider.future);
      final now = DateTime.now();
      await syncService.cancelRemovedRoutineReminders(
        previousOccurrences: _previousRoutineOccurrences,
        currentOccurrences: _routineOccurrences,
      );
      await syncService.syncRoutineReminders(
        routines: _routines,
        occurrences: _routineOccurrences,
        preferences: preferences,
        now: now,
      );
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'study_flow',
          context: ErrorDescription('during routine notification sync'),
        ),
      );
    }
  }

  Future<void> _handleIntent(NotificationIntent intent) async {
    try {
      switch (intent.type) {
        case NotificationIntentType.sessionReminder:
          ref.read(homeTabIndexProvider.notifier).setTab(AppTab.today);
          final sessionId = intent.sessionId;
          if (sessionId == null) {
            return;
          }
          final sessionRepository = await ref.read(
            plannedSessionRepositoryProvider.future,
          );
          final taskRepository = await ref.read(taskRepositoryProvider.future);
          final session = await sessionRepository.getSessionById(sessionId);
          if (session == null ||
              session.isCompleted ||
              session.isCancelled ||
              session.isMissed) {
            return;
          }
          final task = await taskRepository.getTaskById(session.taskId);
          final activeSession = ref.read(focusSessionControllerProvider);
          if (activeSession == null) {
            await ref
                .read(focusSessionControllerProvider.notifier)
                .startSession(session, task?.title ?? 'Focus session');
          }
          appNavigatorKey.currentState?.push(
            MaterialPageRoute<void>(builder: (_) => const FocusSessionScreen()),
          );
          return;
        case NotificationIntentType.routineReminder:
          ref.read(homeTabIndexProvider.notifier).setTab(AppTab.today);
          if (intent.routineId != null) {
            appNavigatorKey.currentState?.push(
              MaterialPageRoute<void>(
                builder: (_) => RoutineDetailScreen(routineId: intent.routineId!),
              ),
            );
          }
          return;
        case NotificationIntentType.missedSession:
          ref.read(homeTabIndexProvider.notifier).setTab(AppTab.today);
          appNavigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute<void>(builder: (_) => const TodayScreen()),
            (route) => route.isFirst,
          );
          if (intent.action == NotificationIntentAction.recover) {
            await ref
                .read(reschedulingControllerProvider.notifier)
                .recoverAndRescheduleNext7Days();
          }
          return;
        case NotificationIntentType.dailySummary:
          ref.read(homeTabIndexProvider.notifier).setTab(AppTab.today);
          return;
        case NotificationIntentType.goalRisk:
          ref.read(homeTabIndexProvider.notifier).setTab(AppTab.goals);
          if (intent.goalId != null) {
            appNavigatorKey.currentState?.push(
              MaterialPageRoute<void>(
                builder: (_) => GoalDetailScreen(goalId: intent.goalId!),
              ),
            );
          }
          return;
        case NotificationIntentType.overload:
          ref.read(homeTabIndexProvider.notifier).setTab(AppTab.insights);
          return;
        case NotificationIntentType.test:
          ref.read(homeTabIndexProvider.notifier).setTab(AppTab.insights);
          return;
      }
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'study_flow',
          context: ErrorDescription('during notification intent handling'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
