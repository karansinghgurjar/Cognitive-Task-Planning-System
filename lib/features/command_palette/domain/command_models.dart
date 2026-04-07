import 'package:flutter/material.dart';

import '../../focus_session/domain/focus_session_state.dart';
import '../../goals/models/learning_goal.dart';
import '../../tasks/models/task.dart';

enum CommandCategory {
  navigation,
  taskActions,
  scheduleActions,
  review,
  settings,
  focus,
}

extension CommandCategoryX on CommandCategory {
  String get label {
    switch (this) {
      case CommandCategory.navigation:
        return 'Navigation';
      case CommandCategory.taskActions:
        return 'Actions';
      case CommandCategory.scheduleActions:
        return 'Schedule';
      case CommandCategory.review:
        return 'Review';
      case CommandCategory.settings:
        return 'Settings';
      case CommandCategory.focus:
        return 'Focus';
    }
  }
}

abstract final class AppCommandId {
  static const openToday = 'open_today';
  static const openTasks = 'open_tasks';
  static const openGoals = 'open_goals';
  static const openAnalytics = 'open_analytics';
  static const openWeeklyReview = 'open_weekly_review';
  static const openSettings = 'open_settings';
  static const openBackupRestore = 'open_backup_restore';
  static const openSyncStatus = 'open_sync_status';
  static const addTask = 'add_task';
  static const addGoal = 'add_goal';
  static const quickCapture = 'quick_capture';
  static const openCaptureInbox = 'open_capture_inbox';
  static const generateSchedule = 'generate_schedule';
  static const recoverMissedSessions = 'recover_missed_sessions';
  static const exportCalendar = 'export_calendar';
  static const resumeFocus = 'resume_focus';
}

class AppCommand {
  const AppCommand({
    required this.id,
    required this.title,
    required this.category,
    required this.icon,
    required this.keywords,
    this.subtitle,
    this.isEnabled = true,
    this.priority = 0,
  });

  final String id;
  final String title;
  final String? subtitle;
  final List<String> keywords;
  final CommandCategory category;
  final IconData icon;
  final bool isEnabled;
  final int priority;
}

class CommandMatchResult {
  const CommandMatchResult({
    required this.command,
    required this.score,
  });

  final AppCommand command;
  final int score;
}

class CommandExecutionResult {
  const CommandExecutionResult({
    required this.success,
    this.message,
  });

  final bool success;
  final String? message;
}

class CommandContext {
  const CommandContext({
    required this.tasks,
    required this.goals,
    required this.activeFocusSession,
    required this.missedSessionCount,
    required this.isGeneratingSchedule,
    required this.isRecoveringSchedule,
  });

  final List<Task> tasks;
  final List<LearningGoal> goals;
  final FocusSessionState? activeFocusSession;
  final int missedSessionCount;
  final bool isGeneratingSchedule;
  final bool isRecoveringSchedule;

  bool get hasActiveFocusSession => activeFocusSession != null;
}
