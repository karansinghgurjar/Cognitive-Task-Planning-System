// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/app_router.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/widgets/app_confirmation_dialog.dart';
import '../../../core/widgets/app_section_header.dart';
import '../../../core/widgets/app_status_chip.dart';
import '../../analytics/domain/analytics_models.dart';
import '../../analytics/providers/analytics_providers.dart';
import '../../focus_session/domain/focus_session_state.dart';
import '../../focus_session/presentation/focus_session_screen.dart';
import '../../focus_session/providers/focus_session_providers.dart';
import '../../goals/presentation/goal_detail_screen.dart';
import '../../integrations/presentation/calendar_export_screen.dart';
import '../../recommendations/domain/recommendation_models.dart';
import '../../recommendations/providers/recommendation_providers.dart';
import '../../tasks/models/task.dart';
import '../../tasks/presentation/task_detail_screen.dart';
import '../../quick_capture/presentation/quick_capture_inbox_screen.dart';
import '../../quick_capture/presentation/quick_capture_sheet.dart';
import '../../quick_capture/providers/quick_capture_providers.dart';
import '../../review/presentation/weekly_review_screen.dart';
import '../../routines/domain/routine_enums.dart';
import '../../routines/models/routine.dart';
import '../../routines/models/routine_occurrence.dart';
import '../../routines/presentation/add_edit_routine_screen.dart';
import '../../routines/presentation/routines_screen.dart';
import '../../routines/presentation/routine_widgets.dart';
import '../../routines/providers/routine_providers.dart';
import '../../tasks/providers/task_providers.dart';
import '../domain/rescheduling_models.dart';
import '../models/planned_session.dart';
import '../providers/rescheduling_providers.dart';
import '../providers/schedule_providers.dart';

class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _refreshMissedDetection();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshMissedDetection();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionsAsync = ref.watch(watchAllSessionsProvider);
    final tasksAsync = ref.watch(watchActiveTasksProvider);
    final generateState = ref.watch(scheduleActionControllerProvider);
    final recoverState = ref.watch(reschedulingControllerProvider);
    final activeFocusSession = ref.watch(focusSessionControllerProvider);
    final detectedMissedAsync = ref.watch(detectedMissedSessionsProvider);
    final recommendationSummaryAsync = ref.watch(recommendationSummaryProvider);
    final dailyStatsAsync = ref.watch(dailyStatsProvider);
    final streakSummaryAsync = ref.watch(streakSummaryProvider);
    final todayRoutineOccurrencesAsync = ref.watch(todayRoutineOccurrencesProvider);

    return Column(
      children: [
        if (generateState.isLoading || recoverState.isLoading)
          const LinearProgressIndicator(),
        Expanded(
          child: _buildBody(
            context: context,
            sessionsAsync: sessionsAsync,
            tasksAsync: tasksAsync,
            activeFocusSession: activeFocusSession,
            detectedMissedAsync: detectedMissedAsync,
            recoveryResult: recoverState.valueOrNull,
            isGenerating: generateState.isLoading,
            isRecovering: recoverState.isLoading,
            recommendationSummaryAsync: recommendationSummaryAsync,
            dailyStatsAsync: dailyStatsAsync,
            streakSummaryAsync: streakSummaryAsync,
            todayRoutineOccurrencesAsync: todayRoutineOccurrencesAsync,
          ),
        ),
      ],
    );
  }

  Widget _buildBody({
    required BuildContext context,
    required AsyncValue<List<PlannedSession>> sessionsAsync,
    required AsyncValue<List<Task>> tasksAsync,
    required FocusSessionState? activeFocusSession,
    required AsyncValue<List<PlannedSession>> detectedMissedAsync,
    required ReschedulingResult? recoveryResult,
    required bool isGenerating,
    required bool isRecovering,
    required AsyncValue<RecommendationSummary> recommendationSummaryAsync,
    required AsyncValue<DailyProductivityStats> dailyStatsAsync,
    required AsyncValue<StreakSummary> streakSummaryAsync,
    required AsyncValue<List<RoutineOccurrenceItem>> todayRoutineOccurrencesAsync,
  }) {
    final header = _TodayHeader(
      isGenerating: isGenerating,
      isRecovering: isRecovering,
      onGenerate: () => _generateSchedule(context),
      onRecover: () => _recoverAndReschedule(context),
    );

    if (sessionsAsync.hasError) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 96),
        children: [
          header,
          const SizedBox(height: 24),
          _TodayStateMessage(
            icon: Icons.error_outline_rounded,
            title: 'Could not load sessions',
            message: ErrorHandler.mapError(sessionsAsync.error!).message,
          ),
        ],
      );
    }

    if (tasksAsync.hasError) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 96),
        children: [
          header,
          const SizedBox(height: 24),
          _TodayStateMessage(
            icon: Icons.error_outline_rounded,
            title: 'Could not load tasks',
            message: ErrorHandler.mapError(tasksAsync.error!).message,
          ),
        ],
      );
    }

    if (sessionsAsync.isLoading || tasksAsync.isLoading) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 96),
        children: [
          header,
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      );
    }

    final now = DateTime.now();
    final sessions = sessionsAsync.value ?? const <PlannedSession>[];
    final tasks = tasksAsync.value ?? const <Task>[];
    final taskById = {for (final task in tasks) task.id: task};
    final todayRoutineItems = todayRoutineOccurrencesAsync.valueOrNull ?? const <RoutineOccurrenceItem>[];

    final missedSessions =
        sessions.where((session) => session.isMissed).toList()
          ..sort((left, right) => right.end.compareTo(left.end));
    final upcomingSessions =
        sessions
            .where(
              (session) =>
                  !session.isMissed &&
                  !session.isCancelled &&
                  (session.end.isAfter(now) ||
                      session.end.isAtSameMomentAs(now) ||
                      session.isInProgress),
            )
            .toList()
          ..sort((left, right) => left.start.compareTo(right.start));

    final groupedUpcomingSessions = _groupSessionsByDate(upcomingSessions);
    final pendingTodayRoutineItems =
        todayRoutineItems.where((item) => item.isPending).toList();
    final completedTodayRoutineItems =
        todayRoutineItems.where((item) => !item.isPending).toList();

    if (sessions.isEmpty && todayRoutineItems.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 96),
        children: [
          header,
          const SizedBox(height: 24),
          if (activeFocusSession != null) ...[
            _ActiveFocusBanner(session: activeFocusSession),
            const SizedBox(height: 16),
          ],
          const _QuickCaptureTodayCard(),
          const SizedBox(height: 16),
          _TodayRecommendationCard(
            summaryAsync: recommendationSummaryAsync,
            tasks: tasks,
            sessions: sessions,
            onStartFocus: null,
            onShowSuggestion: (summary) =>
                _showRecommendationDialog(context, summary),
          ),
          const SizedBox(height: 16),
          _TodayAnalyticsCard(
            dailyStatsAsync: dailyStatsAsync,
            streakSummaryAsync: streakSummaryAsync,
          ),
          const SizedBox(height: 16),
          const _TodaySummaryCard(
            totalSessions: 0,
            totalMinutes: 0,
            distinctTasks: 0,
          ),
          const SizedBox(height: 16),
          const _TodayStateMessage(
            icon: Icons.event_note_rounded,
            title: 'No planned sessions yet',
            message:
                'Generate a schedule to turn your tasks and timetable into a work plan.',
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 96),
      children: [
        header,
        const SizedBox(height: 24),
        if (activeFocusSession != null) ...[
          _ActiveFocusBanner(session: activeFocusSession),
          const SizedBox(height: 16),
        ],
        const _QuickCaptureTodayCard(),
        const SizedBox(height: 16),
        _TodayRecommendationCard(
          summaryAsync: recommendationSummaryAsync,
          tasks: tasks,
          sessions: sessions,
          onStartFocus: (session, taskTitle) =>
              _startRecommendedFocus(context, session, taskTitle),
          onShowSuggestion: (summary) =>
              _showRecommendationDialog(context, summary),
        ),
        const SizedBox(height: 16),
        _TodayAnalyticsCard(
          dailyStatsAsync: dailyStatsAsync,
          streakSummaryAsync: streakSummaryAsync,
        ),
        const SizedBox(height: 16),
        if (detectedMissedAsync.valueOrNull case final detectedMissed?
            when detectedMissed.isNotEmpty) ...[
          _MissedRecoveryBanner(
            missedCount: detectedMissed.length,
            onRecover: () => _recoverAndReschedule(context),
          ),
          const SizedBox(height: 16),
        ],
        _TodaySummaryCard(
          totalSessions: upcomingSessions.length,
          totalMinutes: upcomingSessions.fold<int>(
            0,
            (sum, session) => sum + session.plannedDurationMinutes,
          ),
          distinctTasks: upcomingSessions
              .map((session) => session.taskId)
              .toSet()
              .length,
        ),
        if (recoveryResult != null) ...[
          const SizedBox(height: 16),
          _RecoverySummaryCard(result: recoveryResult),
        ],
        if (todayRoutineItems.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Today\'s Routine Blocks',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          for (var index = 0; index < pendingTodayRoutineItems.length; index++) ...[
            RoutineOccurrenceCard(
              item: pendingTodayRoutineItems[index],
              showInlineActions: true,
              onOpenRoutine: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => AddEditRoutineScreen(
                      routine: pendingTodayRoutineItems[index].routine,
                    ),
                  ),
                );
              },
            ),
            if (index < pendingTodayRoutineItems.length - 1)
              const SizedBox(height: 12),
          ],
          if (completedTodayRoutineItems.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Completed / Skipped',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            for (var index = 0; index < completedTodayRoutineItems.length; index++) ...[
              RoutineOccurrenceCard(
                item: completedTodayRoutineItems[index],
                onOpenRoutine: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => AddEditRoutineScreen(
                        routine: completedTodayRoutineItems[index].routine,
                      ),
                    ),
                  );
                },
              ),
              if (index < completedTodayRoutineItems.length - 1)
                const SizedBox(height: 12),
            ],
          ],
        ],
        const SizedBox(height: 16),
        if (missedSessions.isNotEmpty) ...[
          Text(
            'Missed Sessions',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          for (var index = 0; index < missedSessions.length; index++) ...[
            _SessionTile(
              session: missedSessions[index],
              taskTitle:
                  taskById[missedSessions[index].taskId]?.title ?? 'Task',
              activeFocusSession: activeFocusSession,
            ),
            if (index < missedSessions.length - 1) const SizedBox(height: 12),
          ],
          const SizedBox(height: 20),
        ],
        if (upcomingSessions.isEmpty)
          const _TodayStateMessage(
            icon: Icons.schedule_rounded,
            title: 'No upcoming sessions',
            message:
                'Generate or recover your schedule to see upcoming work here.',
          )
        else ...[
          Text(
            'Upcoming Sessions',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          for (final entry in groupedUpcomingSessions.entries) ...[
            _DateGroupHeader(date: entry.key),
            const SizedBox(height: 12),
            for (var index = 0; index < entry.value.length; index++) ...[
              _SessionTile(
                session: entry.value[index],
                taskTitle: taskById[entry.value[index].taskId]?.title ?? 'Task',
                activeFocusSession: activeFocusSession,
              ),
              if (index < entry.value.length - 1) const SizedBox(height: 12),
            ],
            const SizedBox(height: 20),
          ],
        ],
      ],
    );
  }

  Map<DateTime, List<PlannedSession>> _groupSessionsByDate(
    List<PlannedSession> sessions,
  ) {
    final grouped = <DateTime, List<PlannedSession>>{};

    for (final session in sessions) {
      final date = DateTime(
        session.start.year,
        session.start.month,
        session.start.day,
      );
      grouped.putIfAbsent(date, () => []).add(session);
    }

    return grouped;
  }

  Map<DateTime, List<RoutineOccurrence>> _groupRoutineOccurrencesByDate(
    List<RoutineOccurrence> occurrences,
  ) {
    final grouped = <DateTime, List<RoutineOccurrence>>{};
    for (final occurrence in occurrences) {
      final date = occurrence.occurrenceDate;
      grouped.putIfAbsent(date, () => []).add(occurrence);
    }
    return grouped;
  }

  Future<void> _generateSchedule(BuildContext context) async {
    final confirmed = await AppConfirmationDialog.show(
      context,
      title: 'Generate schedule?',
      message:
          'This rebuilds future incomplete sessions for the next 7 days using your current tasks and timetable.',
      confirmLabel: 'Generate',
    );
    if (!confirmed) {
      return;
    }
    try {
      final result = await ref
          .read(scheduleActionControllerProvider.notifier)
          .generateNext7DaysSchedule();

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Generated ${result.generatedSessions.length} sessions for ${result.scheduledTaskCount} tasks.',
          ),
        ),
      );
      _refreshMissedDetection();
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ErrorHandler.showSnackBar(
        context,
        error,
        fallbackTitle: 'Schedule generation failed',
        fallbackMessage:
            'The schedule could not be generated with the current data.',
      );
    }
  }

  Future<void> _recoverAndReschedule(BuildContext context) async {
    final confirmed = await AppConfirmationDialog.show(
      context,
      title: 'Recover and reschedule?',
      message:
          'This keeps completed work but rebuilds future recoverable sessions in the next 7 days.',
      confirmLabel: 'Recover',
    );
    if (!confirmed) {
      return;
    }
    try {
      final result = await ref
          .read(reschedulingControllerProvider.notifier)
          .recoverAndRescheduleNext7Days();

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Recovered ${result.summary.totalRecoveredMinutes} minutes across ${result.summary.regeneratedSessionCount} sessions.',
          ),
        ),
      );
      _refreshMissedDetection();
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ErrorHandler.showSnackBar(
        context,
        error,
        fallbackTitle: 'Recovery failed',
        fallbackMessage: 'The schedule recovery could not complete safely.',
      );
    }
  }

  void _refreshMissedDetection() {
    ref.invalidate(detectedMissedSessionsProvider);
  }

  Future<void> _startRecommendedFocus(
    BuildContext context,
    PlannedSession session,
    String taskTitle,
  ) async {
    final controller = ref.read(focusSessionControllerProvider.notifier);
    final activeSession = ref.read(focusSessionControllerProvider);

    if (activeSession != null && activeSession.plannedSessionId != session.id) {
      ErrorHandler.showSnackBar(
        context,
        StateError('Another focus session is already active.'),
        fallbackTitle: 'Focus unavailable',
        fallbackMessage:
            'Another focus session is already active. Resume or cancel it first.',
      );
      return;
    }

    try {
      if (activeSession == null) {
        await controller.startSession(session, taskTitle);
      }
      if (!context.mounted) {
        return;
      }
      await Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const FocusSessionScreen()),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ErrorHandler.showSnackBar(
        context,
        error,
        fallbackTitle: 'Focus start failed',
        fallbackMessage: 'The recommended focus session could not be started.',
      );
    }
  }

  Future<void> _showRecommendationDialog(
    BuildContext context,
    RecommendationSummary summary,
  ) async {
    final recommendation = summary.bestNextTask;
    final nextBlock = summary.nextStudyBlock;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Recommended Next Move'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (recommendation != null) ...[
                Text(
                  recommendation.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(recommendation.description),
                const SizedBox(height: 8),
                Text(
                  'Suggested focus: ${recommendation.suggestedDurationMinutes} min',
                ),
              ] else
                const Text('No immediate task recommendation is available.'),
              if (nextBlock != null) ...[
                const SizedBox(height: 12),
                Text('Best next slot: ${nextBlock.description}'),
              ],
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class _TodayHeader extends ConsumerWidget {
  const _TodayHeader({
    required this.isGenerating,
    required this.isRecovering,
    required this.onGenerate,
    required this.onRecover,
  });

  final bool isGenerating;
  final bool isRecovering;
  final VoidCallback onGenerate;
  final VoidCallback onRecover;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inboxCount =
        ref.watch(unprocessedCaptureCountProvider).valueOrNull ?? 0;
    return AppSectionHeader(
      title: 'Today',
      description:
          'Generate, recover, and execute your next seven days of planned work.',
      actions: [
        FilledButton.tonalIcon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const RoutinesScreen()),
            );
          },
          icon: const Icon(Icons.repeat_rounded),
          label: const Text('Routines'),
        ),
        FilledButton.tonalIcon(
          onPressed: () => QuickCaptureSheet.show(context),
          icon: const Icon(Icons.bolt_rounded),
          label: const Text('Quick Capture'),
        ),
        FilledButton.tonalIcon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const QuickCaptureInboxScreen(),
              ),
            );
          },
          icon: const Icon(Icons.inbox_rounded),
          label: Text('Inbox ($inboxCount)'),
        ),
        Semantics(
          button: true,
          label: 'Generate Schedule',
          child: FilledButton.icon(
            onPressed: isGenerating ? null : onGenerate,
            icon: const Icon(Icons.auto_awesome_rounded),
            label: const Text('Generate Schedule'),
          ),
        ),
        Semantics(
          button: true,
          label: 'Recover and reschedule',
          child: FilledButton.tonalIcon(
            onPressed: isRecovering ? null : onRecover,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Recover & Reschedule'),
          ),
        ),
        IconButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const CalendarExportScreen(),
              ),
            );
          },
          icon: const Icon(Icons.event_available_rounded),
          tooltip: 'Export to Calendar',
        ),
        IconButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const WeeklyReviewScreen(),
              ),
            );
          },
          icon: const Icon(Icons.rate_review_outlined),
          tooltip: 'Weekly Review',
        ),
        IconButton(
          onPressed: () => AppRouter.openSettings(context),
          icon: const Icon(Icons.settings_outlined),
          tooltip: 'Settings',
        ),
      ],
    );
  }
}

class _TodayRecommendationCard extends StatelessWidget {
  const _TodayRecommendationCard({
    required this.summaryAsync,
    required this.tasks,
    required this.sessions,
    required this.onStartFocus,
    required this.onShowSuggestion,
  });

  final AsyncValue<RecommendationSummary> summaryAsync;
  final List<Task> tasks;
  final List<PlannedSession> sessions;
  final Future<void> Function(PlannedSession session, String taskTitle)?
  onStartFocus;
  final Future<void> Function(RecommendationSummary summary)? onShowSuggestion;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: summaryAsync.when(
          data: (summary) {
            final recommendation = summary.bestNextTask;
            if (recommendation == null) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recommended Next Move',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'No recommendation is available yet. Add tasks, goals, or timetable capacity to get guidance.',
                  ),
                ],
              );
            }

            Task? relatedTask;
            for (final task in tasks) {
              if (task.id == recommendation.taskId) {
                relatedTask = task;
                break;
              }
            }
            final matchingSession = _findMatchingSession(recommendation);
            final buttonLabel = matchingSession != null
                ? 'Start Recommended Focus'
                : 'Review Recommendation';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Recommended Next Move',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    _InlineRiskBadge(level: recommendation.riskLevel),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  recommendation.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(recommendation.description),
                const SizedBox(height: 8),
                Text(
                  'Suggested focus: ${recommendation.suggestedDurationMinutes} min',
                ),
                if (summary.nextStudyBlock != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Best next slot: ${summary.nextStudyBlock!.description}',
                  ),
                ],
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.tonalIcon(
                    onPressed: () async {
                      if (matchingSession != null && onStartFocus != null) {
                        await onStartFocus!(
                          matchingSession,
                          relatedTask?.title ?? recommendation.title,
                        );
                        return;
                      }
                      if (onShowSuggestion != null) {
                        await onShowSuggestion!(summary);
                      }
                    },
                    icon: Icon(
                      matchingSession != null
                          ? Icons.play_arrow_rounded
                          : Icons.insights_rounded,
                    ),
                    label: Text(buttonLabel),
                  ),
                ),
              ],
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recommended Next Move',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(ErrorHandler.mapError(error).message),
            ],
          ),
        ),
      ),
    );
  }

  PlannedSession? _findMatchingSession(TaskRecommendation recommendation) {
    if (recommendation.relatedPlannedSessionId != null) {
      for (final session in sessions) {
        if (session.id == recommendation.relatedPlannedSessionId) {
          return session;
        }
      }
    }

    final candidates = sessions.where((session) {
      return session.taskId == recommendation.taskId &&
          (session.isPending || session.isInProgress) &&
          !session.isCancelled &&
          !session.isMissed;
    }).toList()..sort((left, right) => left.start.compareTo(right.start));
    return candidates.isEmpty ? null : candidates.first;
  }
}

class _InlineRiskBadge extends StatelessWidget {
  const _InlineRiskBadge({required this.level});

  final DeadlineRiskLevel level;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final (background, foreground) = switch (level) {
      DeadlineRiskLevel.low => (
        colorScheme.secondaryContainer,
        colorScheme.onSecondaryContainer,
      ),
      DeadlineRiskLevel.medium => (
        colorScheme.tertiaryContainer,
        colorScheme.onTertiaryContainer,
      ),
      DeadlineRiskLevel.high => (
        colorScheme.errorContainer,
        colorScheme.onErrorContainer,
      ),
      DeadlineRiskLevel.critical => (colorScheme.error, colorScheme.onError),
    };

    return AppStatusChip(
      label: level.label,
      backgroundColor: background,
      foregroundColor: foreground,
    );
  }
}

class _TodaySummaryCard extends StatelessWidget {
  const _TodaySummaryCard({
    required this.totalSessions,
    required this.totalMinutes,
    required this.distinctTasks,
  });

  final int totalSessions;
  final int totalMinutes;
  final int distinctTasks;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: _SummaryStat(
                label: 'Sessions',
                value: totalSessions.toString(),
              ),
            ),
            Expanded(
              child: _SummaryStat(
                label: 'Planned Minutes',
                value: totalMinutes.toString(),
              ),
            ),
            Expanded(
              child: _SummaryStat(
                label: 'Tasks Scheduled',
                value: distinctTasks.toString(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayAnalyticsCard extends StatelessWidget {
  const _TodayAnalyticsCard({
    required this.dailyStatsAsync,
    required this.streakSummaryAsync,
  });

  final AsyncValue<DailyProductivityStats> dailyStatsAsync;
  final AsyncValue<StreakSummary> streakSummaryAsync;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: switch ((dailyStatsAsync, streakSummaryAsync)) {
          (
            AsyncData(value: final dailyStats),
            AsyncData(value: final streaks),
          ) =>
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today\'s Insights',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  'You\'ve completed ${dailyStats.completedMinutes} of ${dailyStats.plannedMinutes} planned minutes today.',
                ),
                const SizedBox(height: 4),
                Text(
                  'Completion rate: ${(dailyStats.completionRate * 100).round()}% | Current focus streak: ${streaks.currentFocusStreak.length} days.',
                ),
              ],
            ),
          (AsyncError(error: final error), _) => Text(
            'Could not load today\'s insights: $error',
          ),
          (_, AsyncError(error: final error)) => Text(
            'Could not load today\'s streaks: $error',
          ),
          _ => const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: CircularProgressIndicator()),
          ),
        },
      ),
    );
  }
}

class _RecoverySummaryCard extends StatelessWidget {
  const _RecoverySummaryCard({required this.result});

  final ReschedulingResult result;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recovery Summary',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text('Missed sessions found: ${result.summary.missedSessionCount}'),
            Text(
              'Sessions regenerated: ${result.summary.regeneratedSessionCount}',
            ),
            Text('Recovered minutes: ${result.summary.totalRecoveredMinutes}'),
            Text(
              'Unscheduled minutes: ${result.summary.totalUnscheduledMinutes}',
            ),
          ],
        ),
      ),
    );
  }
}

class _MissedRecoveryBanner extends StatelessWidget {
  const _MissedRecoveryBanner({
    required this.missedCount,
    required this.onRecover,
  });

  final int missedCount;
  final VoidCallback onRecover;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'You have $missedCount missed sessions. Recover schedule?',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.tonal(
              onPressed: onRecover,
              child: const Text('Recover Now'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _DateGroupHeader extends StatelessWidget {
  const _DateGroupHeader({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Text(
      DateFormat('EEEE, MMM d').format(date),
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _SessionTile extends ConsumerWidget {
  const _SessionTile({
    required this.session,
    required this.taskTitle,
    required this.activeFocusSession,
  });

  final PlannedSession session;
  final String taskTitle;
  final FocusSessionState? activeFocusSession;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeFormat = DateFormat.jm();
    final durationMinutes = session.plannedDurationMinutes;
    final canManuallyComplete = session.isPending || session.isInProgress;
    final canStartFocus = session.isPending || session.isInProgress;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: session.isCompleted,
                  onChanged: canManuallyComplete
                      ? (_) async {
                          try {
                            await ref
                                .read(scheduleActionControllerProvider.notifier)
                                .markSessionCompleted(session);
                          } catch (error) {
                            if (context.mounted) {
                              ErrorHandler.showSnackBar(
                                context,
                                error,
                                fallbackTitle: 'Session update failed',
                                fallbackMessage:
                                    'The session could not be marked complete.',
                              );
                            }
                          }
                        }
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        taskTitle,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              decoration: session.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${timeFormat.format(session.start)} -> ${timeFormat.format(session.end)}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$durationMinutes min',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _SessionStatusBadge(status: session.status),
              ],
            ),
            if (canStartFocus) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: Semantics(
                  button: true,
                  label: activeFocusSession?.plannedSessionId == session.id
                      ? 'Resume Focus'
                      : 'Start Focus',
                  child: FilledButton.tonalIcon(
                    onPressed: () => _startFocus(context, ref),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(
                      activeFocusSession?.plannedSessionId == session.id
                          ? 'Resume Focus'
                          : 'Start Focus',
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _startFocus(BuildContext context, WidgetRef ref) async {
    final controller = ref.read(focusSessionControllerProvider.notifier);
    final activeSession = ref.read(focusSessionControllerProvider);

    if (activeSession != null && activeSession.plannedSessionId != session.id) {
      ErrorHandler.showSnackBar(
        context,
        StateError('Another focus session is already active.'),
        fallbackTitle: 'Focus unavailable',
        fallbackMessage:
            'Another focus session is already active. Resume or cancel it first.',
      );
      return;
    }

    try {
      if (activeSession == null) {
        await controller.startSession(session, taskTitle);
      }
      if (!context.mounted) {
        return;
      }
      await Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const FocusSessionScreen()),
      );
    } catch (error) {
      if (context.mounted) {
        ErrorHandler.showSnackBar(
          context,
          error,
          fallbackTitle: 'Focus start failed',
          fallbackMessage: 'The focus session could not be started.',
        );
      }
    }
  }
}

class _RoutineOccurrenceTile extends ConsumerWidget {
  const _RoutineOccurrenceTile({
    required this.occurrence,
    required this.routine,
  });

  final RoutineOccurrence occurrence;
  final Routine? routine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeFormat = DateFormat.jm();
    final effectiveStatus = occurrence.effectiveStatusAt(DateTime.now());
    final canComplete = effectiveStatus == RoutineOccurrenceStatus.pending;
    final routineTitle = routine?.title ?? 'Routine';
    final linkedTaskId = occurrence.linkedTaskId;
    final scheduledStart = occurrence.scheduledStart;
    final scheduledEnd = occurrence.scheduledEnd;
    final timingLabel = scheduledStart != null && scheduledEnd != null
        ? '${timeFormat.format(scheduledStart)} -> ${timeFormat.format(scheduledEnd)}'
        : 'Any time on ${DateFormat('EEE, MMM d').format(occurrence.occurrenceDate)}';
    final durationLabel = occurrence.durationMinutes == null
        ? 'Flexible duration'
        : '${occurrence.durationMinutes} min';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: effectiveStatus == RoutineOccurrenceStatus.completed,
                  onChanged: canComplete
                      ? (_) async {
                          try {
                            await ref
                                .read(routineOccurrenceControllerProvider.notifier)
                                .completeOccurrence(occurrence.id);
                          } catch (error) {
                            if (context.mounted) {
                              ErrorHandler.showSnackBar(
                                context,
                                error,
                                fallbackTitle: 'Routine update failed',
                                fallbackMessage:
                                    'The routine block could not be marked complete.',
                              );
                            }
                          }
                        }
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        routineTitle,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              decoration:
                                  effectiveStatus ==
                                      RoutineOccurrenceStatus.completed
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        timingLabel,
                      ),
                      const SizedBox(height: 6),
                      Text(durationLabel),
                      if ((routine?.categoryId ?? '').trim().isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text('Tag: ${routine!.categoryId}'),
                      ],
                      if ((routine?.energyType ?? '').trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text('Energy/context: ${routine!.energyType}'),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _RoutineStatusBadge(status: effectiveStatus),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: [
                if (canComplete)
                  FilledButton.tonalIcon(
                    onPressed: () async {
                      try {
                        await ref
                            .read(routineOccurrenceControllerProvider.notifier)
                            .completeOccurrence(occurrence.id);
                      } catch (error) {
                        if (context.mounted) {
                          ErrorHandler.showSnackBar(
                            context,
                            error,
                            fallbackTitle: 'Routine update failed',
                            fallbackMessage:
                                'The routine block could not be marked complete.',
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Complete'),
                  ),
                if (canComplete)
                  TextButton.icon(
                    onPressed: () => _snoozeOccurrence(context, ref),
                    icon: const Icon(Icons.schedule_rounded),
                    label: const Text('Snooze'),
                  ),
                if (canComplete)
                  TextButton.icon(
                    onPressed: () async {
                      try {
                        await ref
                            .read(routineOccurrenceControllerProvider.notifier)
                            .skipOccurrence(occurrence.id);
                      } catch (error) {
                        if (context.mounted) {
                          ErrorHandler.showSnackBar(
                            context,
                            error,
                            fallbackTitle: 'Routine update failed',
                            fallbackMessage:
                                'The routine block could not be skipped.',
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.skip_next_rounded),
                    label: const Text('Skip'),
                  ),
                if (routine != null && canComplete)
                  TextButton.icon(
                    onPressed: () => _convertToTask(context, ref),
                    icon: const Icon(Icons.task_alt_rounded),
                    label: const Text('Convert To Task'),
                  ),
                if (routine?.linkedGoalId != null)
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              GoalDetailScreen(goalId: routine!.linkedGoalId!),
                        ),
                      );
                    },
                    icon: const Icon(Icons.track_changes_rounded),
                    label: const Text('Open Goal'),
                  ),
                if (linkedTaskId != null)
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => TaskDetailScreen(taskId: linkedTaskId),
                        ),
                      );
                    },
                    icon: const Icon(Icons.open_in_new_rounded),
                    label: const Text('Open Task'),
                  ),
              ],
            ),
            if ((occurrence.notes ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  occurrence.notes!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _snoozeOccurrence(BuildContext context, WidgetRef ref) async {
    final initialDate = occurrence.scheduledStart ?? occurrence.occurrenceDate;
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date == null || !context.mounted) {
      return;
    }
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        occurrence.scheduledStart ??
            DateTime(
              occurrence.occurrenceDate.year,
              occurrence.occurrenceDate.month,
              occurrence.occurrenceDate.day,
              18,
            ),
      ),
    );
    if (pickedTime == null || !context.mounted) {
      return;
    }
    final newStart = DateTime(
      date.year,
      date.month,
      date.day,
      pickedTime.hour,
      pickedTime.minute,
    );
    try {
      await ref
          .read(routineOccurrenceControllerProvider.notifier)
          .snoozeOccurrence(
            occurrence.id,
            newStart,
            notes: 'Snoozed from Today',
          );
    } catch (error) {
      if (context.mounted) {
        ErrorHandler.showSnackBar(
          context,
          error,
          fallbackTitle: 'Routine update failed',
          fallbackMessage: 'The routine block could not be rescheduled.',
        );
      }
    }
  }

  Future<void> _convertToTask(BuildContext context, WidgetRef ref) async {
    final sourceRoutine = routine;
    if (sourceRoutine == null) {
      return;
    }
    try {
      final task = await ref
          .read(routineCrudControllerProvider.notifier)
          .convertOccurrenceToTask(
            routine: sourceRoutine,
            occurrence: occurrence,
          );
      if (!context.mounted) {
        return;
      }
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => TaskDetailScreen(taskId: task.id),
        ),
      );
    } catch (error) {
      if (context.mounted) {
        ErrorHandler.showSnackBar(
          context,
          error,
          fallbackTitle: 'Routine conversion failed',
          fallbackMessage:
              'The routine block could not be converted into a normal task.',
        );
      }
    }
  }
}

class _RoutineStatusBadge extends StatelessWidget {
  const _RoutineStatusBadge({required this.status});

  final RoutineOccurrenceStatus status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final (background, foreground) = switch (status) {
      RoutineOccurrenceStatus.pending => (
        colorScheme.tertiaryContainer,
        colorScheme.onTertiaryContainer,
      ),
      RoutineOccurrenceStatus.completed => (
        colorScheme.secondaryContainer,
        colorScheme.onSecondaryContainer,
      ),
      RoutineOccurrenceStatus.skipped => (
        colorScheme.surfaceContainerHighest,
        colorScheme.onSurface,
      ),
      RoutineOccurrenceStatus.missed => (
        colorScheme.errorContainer,
        colorScheme.onErrorContainer,
      ),
    };
    return AppStatusChip(
      label: status.label,
      backgroundColor: background,
      foregroundColor: foreground,
    );
  }
}

class _SessionStatusBadge extends StatelessWidget {
  const _SessionStatusBadge({required this.status});

  final PlannedSessionStatus status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final (background, foreground, label) = switch (status) {
      PlannedSessionStatus.pending => (
        colorScheme.tertiaryContainer,
        colorScheme.onTertiaryContainer,
        'Pending',
      ),
      PlannedSessionStatus.inProgress => (
        colorScheme.primaryContainer,
        colorScheme.onPrimaryContainer,
        'In Progress',
      ),
      PlannedSessionStatus.completed => (
        colorScheme.secondaryContainer,
        colorScheme.onSecondaryContainer,
        'Completed',
      ),
      PlannedSessionStatus.missed => (
        colorScheme.errorContainer,
        colorScheme.onErrorContainer,
        'Missed',
      ),
      PlannedSessionStatus.cancelled => (
        colorScheme.surfaceContainerHighest,
        colorScheme.onSurface,
        'Cancelled',
      ),
    };

    return AppStatusChip(
      label: label,
      backgroundColor: background,
      foregroundColor: foreground,
    );
  }
}

class _TodayStateMessage extends StatelessWidget {
  const _TodayStateMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 52),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveFocusBanner extends StatelessWidget {
  const _ActiveFocusBanner({required this.session});

  final FocusSessionState session;

  @override
  Widget build(BuildContext context) {
    final minutes = session.remainingSeconds ~/ 60;
    final seconds = session.remainingSeconds % 60;

    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const FocusSessionScreen()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Active Focus Session',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      session.taskTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'
                      ' - ${session.isPaused ? 'Paused' : 'Running'}',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.tonal(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const FocusSessionScreen(),
                    ),
                  );
                },
                child: const Text('Resume Focus'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickCaptureTodayCard extends ConsumerWidget {
  const _QuickCaptureTodayCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inboxCount =
        ref.watch(unprocessedCaptureCountProvider).valueOrNull ?? 0;
    final compact = MediaQuery.sizeOf(context).width < 720;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Capture',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              inboxCount == 0
                  ? 'Capture ideas, tasks, and goals before they disappear.'
                  : '$inboxCount item${inboxCount == 1 ? '' : 's'} waiting in your inbox.',
            ),
            const SizedBox(height: 16),
            if (compact)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: () => QuickCaptureSheet.show(context),
                    icon: const Icon(Icons.bolt_rounded),
                    label: const Text('Quick Capture'),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.tonalIcon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const QuickCaptureInboxScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.inbox_rounded),
                    label: Text('Inbox ($inboxCount)'),
                  ),
                ],
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: () => QuickCaptureSheet.show(context),
                    icon: const Icon(Icons.bolt_rounded),
                    label: const Text('Quick Capture'),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const QuickCaptureInboxScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.inbox_rounded),
                    label: Text('Inbox ($inboxCount)'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
