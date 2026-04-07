import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_router.dart';
import '../../../core/navigation/app_navigation.dart';
import '../../../core/widgets/app_confirmation_dialog.dart';
import '../../backup/presentation/backup_restore_screen.dart';
import '../../focus_session/presentation/focus_session_screen.dart';
import '../../goals/presentation/add_goal_screen.dart';
import '../../goals/presentation/goal_detail_screen.dart';
import '../../integrations/presentation/calendar_export_screen.dart';
import '../../quick_capture/presentation/quick_capture_inbox_screen.dart';
import '../../quick_capture/presentation/quick_capture_sheet.dart';
import '../../review/presentation/weekly_review_screen.dart';
import '../../schedule/providers/rescheduling_providers.dart';
import '../../schedule/providers/schedule_providers.dart';
import '../../search/presentation/global_search_screen.dart';
import '../../sync/presentation/sync_status_screen.dart';
import '../../tasks/presentation/add_task_screen.dart';
import '../../tasks/presentation/task_detail_screen.dart';
import '../domain/command_models.dart';
import '../domain/entity_launcher_service.dart';
import '../../focus_session/providers/focus_session_providers.dart';

class CommandExecutionService {
  const CommandExecutionService();

  Future<CommandExecutionResult> executeCommand({
    required BuildContext context,
    required WidgetRef ref,
    required AppCommand command,
  }) async {
    if (!command.isEnabled) {
      return CommandExecutionResult(
        success: false,
        message: command.subtitle ?? 'This command is not available right now.',
      );
    }

    try {
      switch (command.id) {
        case AppCommandId.openToday:
          ref.read(homeTabIndexProvider.notifier).setTab(AppTab.today);
          return const CommandExecutionResult(success: true);
        case AppCommandId.openSearch:
          await GlobalSearchScreen.show(context);
          return const CommandExecutionResult(success: true);
        case AppCommandId.openTasks:
          ref.read(homeTabIndexProvider.notifier).setTab(AppTab.tasks);
          return const CommandExecutionResult(success: true);
        case AppCommandId.openGoals:
          ref.read(homeTabIndexProvider.notifier).setTab(AppTab.goals);
          return const CommandExecutionResult(success: true);
        case AppCommandId.openAnalytics:
          ref.read(homeTabIndexProvider.notifier).setTab(AppTab.insights);
          return const CommandExecutionResult(success: true);
        case AppCommandId.openWeeklyReview:
          await Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const WeeklyReviewScreen()),
          );
          return const CommandExecutionResult(success: true);
        case AppCommandId.openSettings:
          await AppRouter.openSettings(context);
          return const CommandExecutionResult(success: true);
        case AppCommandId.openBackupRestore:
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const BackupRestoreScreen(),
            ),
          );
          return const CommandExecutionResult(success: true);
        case AppCommandId.openSyncStatus:
          await Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const SyncStatusScreen()),
          );
          return const CommandExecutionResult(success: true);
        case AppCommandId.addTask:
          await Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const AddTaskScreen()),
          );
          return const CommandExecutionResult(success: true);
        case AppCommandId.addGoal:
          await Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const AddGoalScreen()),
          );
          return const CommandExecutionResult(success: true);
        case AppCommandId.quickCapture:
          await QuickCaptureSheet.show(context);
          return const CommandExecutionResult(success: true);
        case AppCommandId.openCaptureInbox:
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const QuickCaptureInboxScreen(),
            ),
          );
          return const CommandExecutionResult(success: true);
        case AppCommandId.generateSchedule:
          return _generateSchedule(context, ref);
        case AppCommandId.recoverMissedSessions:
          return _recoverMissed(context, ref);
        case AppCommandId.exportCalendar:
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const CalendarExportScreen(),
            ),
          );
          return const CommandExecutionResult(success: true);
        case AppCommandId.resumeFocus:
          final active = ref.read(focusSessionControllerProvider);
          if (active == null) {
            return const CommandExecutionResult(
              success: false,
              message: 'No active focus session to resume.',
            );
          }
          await Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const FocusSessionScreen()),
          );
          return const CommandExecutionResult(success: true);
      }
      return const CommandExecutionResult(
        success: false,
        message: 'That command is not supported yet.',
      );
    } catch (_) {
      return CommandExecutionResult(
        success: false,
        message: _failureMessageFor(command.id),
      );
    }
  }

  Future<CommandExecutionResult> executeEntity({
    required BuildContext context,
    required LauncherEntityResult entity,
  }) async {
    try {
      switch (entity.entityType) {
        case LauncherEntityType.task:
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => TaskDetailScreen(taskId: entity.entityId),
            ),
          );
          break;
        case LauncherEntityType.goal:
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => GoalDetailScreen(goalId: entity.entityId),
            ),
          );
          break;
      }
      return const CommandExecutionResult(success: true);
    } catch (_) {
      return const CommandExecutionResult(
        success: false,
        message: 'That item could not be opened right now.',
      );
    }
  }

  Future<CommandExecutionResult> _generateSchedule(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await AppConfirmationDialog.show(
      context,
      title: 'Generate schedule?',
      message:
          'This rebuilds future incomplete sessions for the next 7 days using your current tasks and timetable.',
      confirmLabel: 'Generate',
    );
    if (confirmed != true) {
      return const CommandExecutionResult(success: false);
    }
    await ref.read(scheduleActionControllerProvider.notifier).generateNext7DaysSchedule();
    return const CommandExecutionResult(
      success: true,
      message: 'Schedule generated.',
    );
  }

  Future<CommandExecutionResult> _recoverMissed(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final now = DateTime.now();
    final sessions = ref.read(watchAllSessionsProvider).valueOrNull ?? const [];
    final missedCount = sessions.where((session) {
      if (session.isMissed) {
        return true;
      }
      return session.isPending && session.end.isBefore(now);
    }).length;
    if (missedCount <= 0) {
      return const CommandExecutionResult(
        success: false,
        message: 'No missed sessions to recover right now.',
      );
    }
    final confirmed = await AppConfirmationDialog.show(
      context,
      title: 'Recover and reschedule?',
      message:
          'This keeps completed work but rebuilds future recoverable sessions in the next 7 days.',
      confirmLabel: 'Recover',
    );
    if (confirmed != true) {
      return const CommandExecutionResult(success: false);
    }
    await ref
        .read(reschedulingControllerProvider.notifier)
        .recoverAndRescheduleNext7Days();
    return const CommandExecutionResult(
      success: true,
      message: 'Missed sessions recovered.',
    );
  }

  String _failureMessageFor(String commandId) {
    switch (commandId) {
      case AppCommandId.exportCalendar:
        return 'Could not open calendar export right now.';
      case AppCommandId.generateSchedule:
        return 'Could not generate the schedule right now.';
      case AppCommandId.recoverMissedSessions:
        return 'Could not recover missed sessions right now.';
      default:
        return 'That command could not be completed right now.';
    }
  }
}
