import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/errors/error_handler.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_status_chip.dart';
import '../../goals/providers/goal_providers.dart';
import '../models/routine.dart';
import '../models/routine_occurrence.dart';
import '../providers/routine_providers.dart';
import 'add_edit_routine_screen.dart';

class RoutinesScreen extends ConsumerWidget {
  const RoutinesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routinesAsync = ref.watch(watchAllRoutinesProvider);
    final previewsAsync = ref.watch(routinePreviewProvider);
    final goalsAsync = ref.watch(watchGoalsProvider);
    final actionState = ref.watch(routineActionControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Routine Blocks'),
        actions: [
          IconButton(
            tooltip: 'Generate next 7 days',
            onPressed: actionState.isLoading
                ? null
                : () => _runAction(
                      context,
                      ref,
                      () => ref
                          .read(routineActionControllerProvider.notifier)
                          .generateNext7Days(),
                      successMessage: 'Generated routine blocks for 7 days.',
                    ),
            icon: const Icon(Icons.calendar_view_week_rounded),
          ),
          IconButton(
            tooltip: 'Generate next 30 days',
            onPressed: actionState.isLoading
                ? null
                : () => _runAction(
                      context,
                      ref,
                      () => ref
                          .read(routineActionControllerProvider.notifier)
                          .generateNext30Days(),
                      successMessage: 'Generated routine blocks for 30 days.',
                    ),
            icon: const Icon(Icons.calendar_month_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const AddEditRoutineScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Routine'),
      ),
      body: switch ((routinesAsync, previewsAsync, goalsAsync)) {
        (
          AsyncData(value: final routines),
          AsyncData(value: final previews),
          AsyncData(value: final goals),
        ) =>
          () {
            final goalsById = {for (final goal in goals) goal.id: goal};
            return routines.isEmpty
                ? const AppEmptyState(
                    icon: Icons.repeat_rounded,
                    title: 'No routine blocks yet',
                    message:
                        'Routine blocks protect recurring work like workouts, weekly reviews, reading, or project sessions.',
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 96),
                    children: [
                      _RoutineSummaryCard(
                        totalRoutines: routines.length,
                        activeRoutines: routines
                            .where((routine) => routine.generatesOccurrences)
                            .length,
                        archivedRoutines:
                            routines.where((routine) => routine.isArchived).length,
                        generatedCount: previews.generatedCount,
                        skippedCount: previews.skippedCount,
                      ),
                      const SizedBox(height: 16),
                      for (final routine in routines) ...[
                        _RoutineCard(
                          routine: routine,
                          linkedGoalTitle: routine.linkedGoalId == null
                              ? null
                              : goalsById[routine.linkedGoalId!]?.title,
                          nextOccurrence:
                              previews.nextOccurrenceByRoutineId[routine.id],
                          onToggleEnabled: (value) => _runAction(
                            context,
                            ref,
                            () => ref
                                .read(routineActionControllerProvider.notifier)
                                .setActive(routine, value),
                            successMessage: value
                                ? 'Routine enabled.'
                                : 'Routine disabled.',
                          ),
                          onToggleArchived: (value) => _runAction(
                            context,
                            ref,
                            () => ref
                                .read(routineActionControllerProvider.notifier)
                                .setArchived(routine, value),
                            successMessage: value
                                ? 'Routine archived.'
                                : 'Routine restored.',
                          ),
                          onEdit: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    AddEditRoutineScreen(routine: routine),
                              ),
                            );
                          },
                          onDelete: () => _deleteRoutine(context, ref, routine),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ],
                  );
          }(),
        (AsyncError(:final error), _, _) => Center(
          child: Text(ErrorHandler.mapError(error).message),
        ),
        (_, AsyncError(:final error), _) => Center(
          child: Text(ErrorHandler.mapError(error).message),
        ),
        (_, _, AsyncError(:final error)) => Center(
          child: Text(ErrorHandler.mapError(error).message),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  Future<void> _deleteRoutine(
    BuildContext context,
    WidgetRef ref,
    Routine routine,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete routine?'),
          content: Text(
            'This removes ${routine.title} and its saved routine occurrences.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !context.mounted) {
      return;
    }
    await _runAction(
      context,
      ref,
      () => ref.read(routineActionControllerProvider.notifier).deleteRoutine(
            routine.id,
          ),
      successMessage: 'Routine deleted.',
    );
  }

  Future<void> _runAction(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function() action, {
    required String successMessage,
  }) async {
    try {
      await action();
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(successMessage)),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ErrorHandler.showSnackBar(
        context,
        error,
        fallbackTitle: 'Routine update failed',
        fallbackMessage: 'The routine action could not be completed.',
      );
    }
  }
}

class _RoutineSummaryCard extends StatelessWidget {
  const _RoutineSummaryCard({
    required this.totalRoutines,
    required this.activeRoutines,
    required this.archivedRoutines,
    required this.generatedCount,
    required this.skippedCount,
  });

  final int totalRoutines;
  final int activeRoutines;
  final int archivedRoutines;
  final int generatedCount;
  final int skippedCount;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          spacing: 24,
          runSpacing: 16,
          children: [
            _SummaryStat(label: 'Routines', value: '$totalRoutines'),
            _SummaryStat(label: 'Generating', value: '$activeRoutines'),
            _SummaryStat(label: 'Archived', value: '$archivedRoutines'),
            _SummaryStat(label: 'Previewed', value: '$generatedCount'),
            _SummaryStat(label: 'Blocked', value: '$skippedCount'),
          ],
        ),
      ),
    );
  }
}

class _RoutineCard extends StatelessWidget {
  const _RoutineCard({
    required this.routine,
    required this.onToggleEnabled,
    required this.onToggleArchived,
    required this.onEdit,
    required this.onDelete,
    this.nextOccurrence,
    this.linkedGoalTitle,
  });

  final Routine routine;
  final ValueChanged<bool> onToggleEnabled;
  final ValueChanged<bool> onToggleArchived;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final RoutineOccurrence? nextOccurrence;
  final String? linkedGoalTitle;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('EEE, MMM d • h:mm a');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        routine.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      if ((routine.description ?? '').trim().isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(routine.description!),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Switch.adaptive(
                      value: routine.isActive,
                      onChanged: routine.isArchived ? null : onToggleEnabled,
                    ),
                    Text(
                      routine.isArchived ? 'Archived' : 'Enabled',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                AppStatusChip(label: routine.routineType.label),
                if ((routine.categoryTag ?? '').trim().isNotEmpty)
                  AppStatusChip(label: routine.categoryTag!),
                AppStatusChip(label: routine.cadenceType.label),
                AppStatusChip(label: '${routine.durationMinutes} min'),
                AppStatusChip(
                  label: routine.isFlexible ? 'Flexible' : 'Fixed',
                ),
                if (routine.hasPreferredStartTime)
                  AppStatusChip(
                    label:
                        '${routine.preferredStartHour!.toString().padLeft(2, '0')}:${routine.preferredStartMinute!.toString().padLeft(2, '0')}',
                  ),
                if (routine.autoRescheduleMissed)
                  const AppStatusChip(label: 'Auto-Reschedule'),
                if (routine.countsTowardConsistency)
                  const AppStatusChip(label: 'Consistency'),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _cadenceDescription(routine),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (routine.hasTimeWindow) ...[
              const SizedBox(height: 6),
              Text(
                'Time window: ${_formatMinute(routine.timeWindowStartMinute!)} to ${_formatMinute(routine.timeWindowEndMinute!)}',
              ),
            ],
            if ((routine.energyType ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text('Energy/context: ${routine.energyType}'),
            ],
            if (linkedGoalTitle != null) ...[
              const SizedBox(height: 6),
              Text('Linked goal: $linkedGoalTitle'),
            ],
            const SizedBox(height: 6),
            Text(
              nextOccurrence == null
                  ? 'No conflict-free occurrence is available in the preview horizon.'
                  : 'Next occurrence: ${formatter.format(nextOccurrence!.scheduledStart)}',
            ),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: const Text('Archived'),
                  selected: routine.isArchived,
                  onSelected: onToggleArchived,
                ),
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit'),
                ),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _cadenceDescription(Routine routine) {
    switch (routine.cadenceType) {
      case RoutineCadenceType.daily:
        return 'Runs every day.';
      case RoutineCadenceType.weekdays:
        return 'Runs every weekday.';
      case RoutineCadenceType.monthly:
        return 'Runs monthly on day ${routine.dayOfMonth ?? routine.anchorDate?.day ?? 1}.';
      case RoutineCadenceType.weekly:
      case RoutineCadenceType.customWeekdays:
      case RoutineCadenceType.custom:
        final labels = routine.weekdays.map((weekday) {
          switch (weekday) {
            case DateTime.monday:
              return 'Mon';
            case DateTime.tuesday:
              return 'Tue';
            case DateTime.wednesday:
              return 'Wed';
            case DateTime.thursday:
              return 'Thu';
            case DateTime.friday:
              return 'Fri';
            case DateTime.saturday:
              return 'Sat';
            default:
              return 'Sun';
          }
        }).join(', ');
        return labels.isEmpty ? 'Custom recurrence.' : 'Runs on $labels.';
    }
  }

  String _formatMinute(int minuteOfDay) {
    final hour = minuteOfDay ~/ 60;
    final minute = minuteOfDay % 60;
    final date = DateTime(2000, 1, 1, hour, minute);
    return DateFormat.jm().format(date);
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(label),
        ],
      ),
    );
  }
}
