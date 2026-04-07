import 'package:flutter/material.dart';

import 'command_models.dart';

class CommandRegistryService {
  const CommandRegistryService();

  List<AppCommand> getCommands(CommandContext context) {
    return [
      const AppCommand(
        id: AppCommandId.openToday,
        title: 'Open Today',
        subtitle: 'Go to the today dashboard',
        keywords: ['today', 'dashboard', 'home'],
        category: CommandCategory.navigation,
        icon: Icons.today_rounded,
        priority: 100,
      ),
      const AppCommand(
        id: AppCommandId.openTasks,
        title: 'Open Tasks',
        subtitle: 'Go to the task list',
        keywords: ['tasks', 'todo', 'work'],
        category: CommandCategory.navigation,
        icon: Icons.checklist_rounded,
        priority: 95,
      ),
      const AppCommand(
        id: AppCommandId.openGoals,
        title: 'Open Goals',
        subtitle: 'Go to goals and milestones',
        keywords: ['goals', 'milestones', 'roadmap'],
        category: CommandCategory.navigation,
        icon: Icons.track_changes_rounded,
        priority: 90,
      ),
      const AppCommand(
        id: AppCommandId.openAnalytics,
        title: 'Open Analytics',
        subtitle: 'See progress and workload insights',
        keywords: ['analytics', 'insights', 'charts', 'stats'],
        category: CommandCategory.navigation,
        icon: Icons.insights_rounded,
        priority: 85,
      ),
      const AppCommand(
        id: AppCommandId.openWeeklyReview,
        title: 'Open Weekly Review',
        subtitle: 'Review this week and plan the next',
        keywords: ['weekly', 'review', 'reflection'],
        category: CommandCategory.review,
        icon: Icons.rate_review_outlined,
        priority: 88,
      ),
      const AppCommand(
        id: AppCommandId.openBackupRestore,
        title: 'Open Backup & Restore',
        subtitle: 'Open data backup and export tools',
        keywords: ['backup', 'restore', 'export', 'data safety'],
        category: CommandCategory.settings,
        icon: Icons.backup_rounded,
        priority: 60,
      ),
      const AppCommand(
        id: AppCommandId.openSyncStatus,
        title: 'Open Sync Status',
        subtitle: 'Check sync queue, conflicts, and runs',
        keywords: ['sync', 'status', 'account', 'conflicts'],
        category: CommandCategory.settings,
        icon: Icons.sync_rounded,
        priority: 58,
      ),
      const AppCommand(
        id: AppCommandId.openSettings,
        title: 'Open Settings',
        subtitle: 'Open app settings',
        keywords: ['settings', 'preferences', 'config'],
        category: CommandCategory.settings,
        icon: Icons.settings_outlined,
        priority: 55,
      ),
      const AppCommand(
        id: AppCommandId.addTask,
        title: 'Add Task',
        subtitle: 'Create a new task',
        keywords: ['add task', 'new task', 'create task'],
        category: CommandCategory.taskActions,
        icon: Icons.add_task_rounded,
        priority: 98,
      ),
      const AppCommand(
        id: AppCommandId.addGoal,
        title: 'Add Goal',
        subtitle: 'Create a new goal',
        keywords: ['add goal', 'new goal', 'create goal'],
        category: CommandCategory.taskActions,
        icon: Icons.add_chart_rounded,
        priority: 78,
      ),
      const AppCommand(
        id: AppCommandId.quickCapture,
        title: 'Quick Capture',
        subtitle: 'Capture a task, goal, or note quickly',
        keywords: ['quick capture', 'brain dump', 'capture'],
        category: CommandCategory.taskActions,
        icon: Icons.bolt_rounded,
        priority: 99,
      ),
      const AppCommand(
        id: AppCommandId.openCaptureInbox,
        title: 'Open Capture Inbox',
        subtitle: 'Review quick capture items',
        keywords: ['inbox', 'quick capture inbox', 'capture inbox'],
        category: CommandCategory.taskActions,
        icon: Icons.inbox_rounded,
        priority: 80,
      ),
      AppCommand(
        id: AppCommandId.generateSchedule,
        title: 'Generate Schedule',
        subtitle: context.isGeneratingSchedule
            ? 'Schedule generation is already running'
            : 'Generate the next 7 days of planned sessions',
        keywords: ['generate schedule', 'schedule', 'plan week'],
        category: CommandCategory.scheduleActions,
        icon: Icons.auto_awesome_rounded,
        priority: 92,
        isEnabled: !context.isGeneratingSchedule,
      ),
      AppCommand(
        id: AppCommandId.recoverMissedSessions,
        title: 'Recover Missed Sessions',
        subtitle: context.missedSessionCount > 0
            ? 'Recover ${context.missedSessionCount} missed sessions'
            : 'No missed sessions detected right now',
        keywords: ['recover', 'missed sessions', 'reschedule'],
        category: CommandCategory.scheduleActions,
        icon: Icons.refresh_rounded,
        priority: 84,
        isEnabled:
            context.missedSessionCount > 0 && !context.isRecoveringSchedule,
      ),
      const AppCommand(
        id: AppCommandId.exportCalendar,
        title: 'Export Calendar',
        subtitle: 'Export planned sessions as .ics',
        keywords: ['calendar', 'ics', 'export schedule'],
        category: CommandCategory.scheduleActions,
        icon: Icons.event_available_rounded,
        priority: 70,
      ),
      AppCommand(
        id: AppCommandId.resumeFocus,
        title: 'Resume Focus Session',
        subtitle: context.activeFocusSession == null
            ? 'No active focus session'
            : 'Resume ${context.activeFocusSession!.taskTitle}',
        keywords: ['focus', 'resume focus', 'timer'],
        category: CommandCategory.focus,
        icon: Icons.play_circle_outline_rounded,
        priority: 87,
        isEnabled: context.hasActiveFocusSession,
      ),
    ];
  }
}
