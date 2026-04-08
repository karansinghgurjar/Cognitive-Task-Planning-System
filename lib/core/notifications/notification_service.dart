import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../config/app_brand.dart';
import '../../features/schedule/models/planned_session.dart';
import '../../features/tasks/models/task.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {}

enum NotificationIntentType {
  sessionReminder,
  routineReminder,
  missedSession,
  dailySummary,
  goalRisk,
  overload,
  test,
}

enum NotificationIntentAction { open, recover }

class NotificationIntent {
  const NotificationIntent({
    required this.type,
    this.action = NotificationIntentAction.open,
    this.sessionId,
    this.routineId,
    this.occurrenceId,
    this.goalId,
  });

  final NotificationIntentType type;
  final NotificationIntentAction action;
  final String? sessionId;
  final String? routineId;
  final String? occurrenceId;
  final String? goalId;
}

class ScheduledNotificationRequest {
  const ScheduledNotificationRequest({
    required this.id,
    required this.when,
    required this.title,
    required this.body,
    required this.payload,
    this.actions = const [],
  });

  final int id;
  final DateTime when;
  final String title;
  final String body;
  final String payload;
  final List<AndroidNotificationAction> actions;
}

class DailySummaryNotificationContent {
  const DailySummaryNotificationContent({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;
}

class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const sessionReminderChannelId = 'session_reminders';
  static const routineReminderChannelId = 'routine_reminders';
  static const sessionAlertChannelId = 'session_alerts';
  static const plannerSummaryChannelId = 'planner_summary';
  static const testChannelId = 'test_notifications';

  final FlutterLocalNotificationsPlugin _plugin;
  final StreamController<NotificationIntent> _intentController =
      StreamController<NotificationIntent>.broadcast();

  bool _initialized = false;

  Stream<NotificationIntent> get intents => _intentController.stream;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const windowsSettings = WindowsInitializationSettings(
      appName: AppBrand.appName,
      appUserModelId: AppBrand.windowsAppUserModelId,
      guid: '9c6cbf00-0ca8-4f47-a6d3-ecdf0b51fd3f',
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      windows: windowsSettings,
    );

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _handleResponse,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    await _requestPermissions();
    await _ensureAndroidChannels();

    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    final payload = launchDetails?.notificationResponse?.payload;
    final intent = parsePayload(
      payload,
      actionId: launchDetails?.notificationResponse?.actionId,
    );
    if (intent != null) {
      _intentController.add(intent);
    }

    _initialized = true;
  }

  Future<void> requestPermissions() => _requestPermissions();

  Future<void> scheduleSessionReminder(
    PlannedSession session, {
    String? taskTitle,
    int leadTimeMinutes = 10,
  }) async {
    await initialize();
    await cancelSessionReminder(session.id);

    final requests = buildSessionReminderRequests(
      session,
      taskTitle: taskTitle,
      leadTimeMinutes: leadTimeMinutes,
      now: DateTime.now(),
    );

    for (final request in requests) {
      await _scheduleZonedNotification(
        request: request,
        channelId: request.id == _sessionStartId(session.id)
            ? sessionAlertChannelId
            : sessionReminderChannelId,
      );
    }
  }

  Future<void> cancelSessionReminder(String sessionId) async {
    await initialize();
    await _plugin.cancel(id: _sessionSoonId(sessionId));
    await _plugin.cancel(id: _sessionStartId(sessionId));
    await _plugin.cancel(id: _missedSessionId(sessionId));
  }

  Future<void> cancelDailySummaryNotification() async {
    await initialize();
    await _plugin.cancel(id: _dailySummaryId());
  }

  Future<void> cancelNotification(int id) async {
    await initialize();
    await _plugin.cancel(id: id);
  }

  Future<void> scheduleRoutineReminder({
    required String occurrenceId,
    required String routineId,
    required DateTime when,
    required String title,
    required String body,
  }) async {
    await initialize();
    await cancelRoutineReminder(occurrenceId);
    if (!when.isAfter(DateTime.now())) {
      return;
    }
    await _scheduleZonedNotification(
      request: ScheduledNotificationRequest(
        id: _routineReminderId(occurrenceId),
        when: when,
        title: title,
        body: body,
        payload: encodePayload(
          NotificationIntent(
            type: NotificationIntentType.routineReminder,
            routineId: routineId,
            occurrenceId: occurrenceId,
          ),
        ),
      ),
      channelId: routineReminderChannelId,
    );
  }

  Future<void> cancelRoutineReminder(String occurrenceId) async {
    await initialize();
    await _plugin.cancel(id: _routineReminderId(occurrenceId));
  }

  Future<void> scheduleDailySummaryNotification(
    TimeOfDay time, {
    required String title,
    required String body,
    String? payload,
    DateTime? now,
  }) async {
    await initialize();
    final current = now ?? DateTime.now();
    final next = _nextOccurrence(time, current);
    final request = ScheduledNotificationRequest(
      id: _dailySummaryId(),
      when: next,
      title: title,
      body: body,
      payload:
          payload ??
          encodePayload(
            const NotificationIntent(type: NotificationIntentType.dailySummary),
          ),
    );
    await _plugin.cancel(id: _dailySummaryId());
    await _scheduleZonedNotification(
      request: request,
      channelId: plannerSummaryChannelId,
    );
  }

  Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String channelId = plannerSummaryChannelId,
    List<AndroidNotificationAction> actions = const [],
  }) async {
    await initialize();
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: _notificationDetails(
        channelId: channelId,
        actions: actions,
      ),
      payload: payload,
    );
  }

  Future<void> cancelAllNotifications() async {
    await initialize();
    await _plugin.cancelAll();
  }

  Future<void> dispose() async {
    await _intentController.close();
  }

  static List<ScheduledNotificationRequest> buildSessionReminderRequests(
    PlannedSession session, {
    String? taskTitle,
    required int leadTimeMinutes,
    required DateTime now,
  }) {
    final label = taskTitle ?? 'Focus task';
    final requests = <ScheduledNotificationRequest>[];
    final soonTime = session.start.subtract(Duration(minutes: leadTimeMinutes));

    if (soonTime.isAfter(now)) {
      requests.add(
        ScheduledNotificationRequest(
          id: _sessionSoonId(session.id),
          when: soonTime,
          title: 'Focus session starting soon',
          body: '$label starts in $leadTimeMinutes minutes',
          payload: encodePayload(
            NotificationIntent(
              type: NotificationIntentType.sessionReminder,
              sessionId: session.id,
            ),
          ),
        ),
      );
    }

    if (session.start.isAfter(now)) {
      requests.add(
        ScheduledNotificationRequest(
          id: _sessionStartId(session.id),
          when: session.start,
          title: 'Start focus session now',
          body: '$label is scheduled to start now',
          payload: encodePayload(
            NotificationIntent(
              type: NotificationIntentType.sessionReminder,
              sessionId: session.id,
            ),
          ),
        ),
      );
    }

    return requests;
  }

  static DailySummaryNotificationContent buildDailySummaryContent({
    required List<PlannedSession> sessions,
    required Map<String, Task> taskById,
    required DateTime day,
  }) {
    final dayStart = DateTime(day.year, day.month, day.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    final todaysSessions = sessions.where((session) {
      return session.start.isBefore(dayEnd) && session.end.isAfter(dayStart);
    }).toList();

    final totalMinutes = todaysSessions.fold<int>(
      0,
      (sum, session) => sum + session.plannedDurationMinutes,
    );
    Task? highestPriorityTask;
    for (final session in todaysSessions) {
      final task = taskById[session.taskId];
      if (task == null) {
        continue;
      }
      if (highestPriorityTask == null ||
          task.priority < highestPriorityTask.priority) {
        highestPriorityTask = task;
      }
    }

    final highestPriorityLabel = highestPriorityTask == null
        ? 'No top task yet'
        : highestPriorityTask.title;

    return DailySummaryNotificationContent(
      title: "Today's Study Plan",
      body:
          '${todaysSessions.length} sessions planned today (${_formatDuration(totalMinutes)} total). Top priority: $highestPriorityLabel.',
    );
  }

  static String encodePayload(NotificationIntent intent) {
    return jsonEncode({
      'type': intent.type.name,
      'action': intent.action.name,
      if (intent.sessionId != null) 'sessionId': intent.sessionId,
      if (intent.routineId != null) 'routineId': intent.routineId,
      if (intent.occurrenceId != null) 'occurrenceId': intent.occurrenceId,
      if (intent.goalId != null) 'goalId': intent.goalId,
    });
  }

  static NotificationIntent? parsePayload(String? payload, {String? actionId}) {
    if (payload == null || payload.trim().isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(payload) as Map<String, dynamic>;
      final type = NotificationIntentType.values.firstWhere(
        (value) => value.name == decoded['type'],
      );
      final action = actionId == 'recover_schedule'
          ? NotificationIntentAction.recover
          : NotificationIntentAction.values.firstWhere(
              (value) =>
                  value.name ==
                  (decoded['action'] ?? NotificationIntentAction.open.name),
              orElse: () => NotificationIntentAction.open,
            );

      return NotificationIntent(
        type: type,
        action: action,
        sessionId: decoded['sessionId'] as String?,
        routineId: decoded['routineId'] as String?,
        occurrenceId: decoded['occurrenceId'] as String?,
        goalId: decoded['goalId'] as String?,
      );
    } catch (_) {
      return null;
    }
  }

  static int immediateIdFor(String type, String entityId) {
    return _stableId('immediate|$type|$entityId');
  }

  void _handleResponse(NotificationResponse response) {
    final intent = parsePayload(response.payload, actionId: response.actionId);
    if (intent != null) {
      _intentController.add(intent);
    }
  }

  Future<void> _requestPermissions() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    try {
      await android?.requestNotificationsPermission();
    } catch (_) {}
    try {
      await android?.requestExactAlarmsPermission();
    } catch (_) {}
  }

  Future<void> _ensureAndroidChannels() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) {
      return;
    }

    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        sessionReminderChannelId,
        'Session Reminders',
        description: 'Reminders for upcoming focus sessions',
        importance: Importance.high,
      ),
    );
    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        routineReminderChannelId,
        'Routine Reminders',
        description: 'Reminders for scheduled routine blocks',
        importance: Importance.high,
      ),
    );
    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        sessionAlertChannelId,
        'Session Alerts',
        description: 'Immediate focus and recovery prompts',
        importance: Importance.max,
      ),
    );
    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        plannerSummaryChannelId,
        'Planner Summary',
        description: 'Daily plan and workload notifications',
        importance: Importance.defaultImportance,
      ),
    );
    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        testChannelId,
        'Test Notifications',
        description: 'Manual notification tests',
        importance: Importance.defaultImportance,
      ),
    );
  }

  Future<void> _scheduleZonedNotification({
    required ScheduledNotificationRequest request,
    required String channelId,
  }) async {
    final scheduledDate = tz.TZDateTime.fromMillisecondsSinceEpoch(
      tz.UTC,
      request.when.millisecondsSinceEpoch,
    );
    final details = _notificationDetails(
      channelId: channelId,
      actions: request.actions,
    );
    final scheduleMode = preferredScheduleModeFor(
      request.when,
      now: DateTime.now(),
    );
    try {
      await _plugin.zonedSchedule(
        id: request.id,
        title: request.title,
        body: request.body,
        scheduledDate: scheduledDate,
        notificationDetails: details,
        payload: request.payload,
        androidScheduleMode: scheduleMode,
      );
    } catch (_) {
      await _plugin.zonedSchedule(
        id: request.id,
        title: request.title,
        body: request.body,
        scheduledDate: scheduledDate,
        notificationDetails: details,
        payload: request.payload,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  static AndroidScheduleMode preferredScheduleModeFor(
    DateTime scheduledFor, {
    required DateTime now,
  }) {
    final difference = scheduledFor.difference(now);
    if (difference.inMinutes <= 90) {
      return AndroidScheduleMode.exactAllowWhileIdle;
    }
    return AndroidScheduleMode.inexactAllowWhileIdle;
  }

  NotificationDetails _notificationDetails({
    required String channelId,
    List<AndroidNotificationAction> actions = const [],
  }) {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelId,
      importance: Importance.max,
      priority: Priority.high,
      actions: actions,
    );
    const windowsDetails = WindowsNotificationDetails();

    return NotificationDetails(
      android: androidDetails,
      windows: windowsDetails,
    );
  }

  static int _sessionSoonId(String sessionId) =>
      _stableId('sessionSoon|$sessionId');
  static int _sessionStartId(String sessionId) =>
      _stableId('sessionStart|$sessionId');
  static int _missedSessionId(String sessionId) =>
      _stableId('missedSession|$sessionId');
  static int _dailySummaryId() => _stableId('dailySummary');
  static int _routineReminderId(String occurrenceId) =>
      _stableId('routineReminder|$occurrenceId');

  static int stableMissedSessionNotificationId(String sessionId) =>
      _missedSessionId(sessionId);

  static int stableGoalRiskNotificationId(String goalId) =>
      _stableId('goalRisk|$goalId');

  static int stableOverloadNotificationId() => _stableId('workloadOverload');

  static int _stableId(String value) {
    return value.hashCode & 0x7fffffff;
  }

  static String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (hours == 0) {
      return '${remainingMinutes}m';
    }
    if (remainingMinutes == 0) {
      return '${hours}h';
    }
    return '${hours}h ${remainingMinutes}m';
  }

  static DateTime _nextOccurrence(TimeOfDay time, DateTime now) {
    var candidate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (!candidate.isAfter(now)) {
      candidate = candidate.add(const Duration(days: 1));
    }
    return candidate;
  }
}
