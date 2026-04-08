import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_handler.dart';
import '../../../core/widgets/app_status_chip.dart';
import '../application/routine_formatters.dart';
import '../domain/routine_enums.dart';
import '../models/routine.dart';
import '../models/routine_occurrence.dart';
import '../providers/routine_intelligence_providers.dart';
import '../providers/routine_providers.dart';

class RoutineListCard extends ConsumerWidget {
  const RoutineListCard({
    required this.routine,
    required this.onOpen,
    required this.onEdit,
    required this.onArchiveToggle,
    required this.onDelete,
    super.key,
  });

  final Routine routine;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onArchiveToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consistencyAsync = ref.watch(routineConsistencySummaryProvider(routine.id));
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      routine.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if ((routine.description ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        routine.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 10),
                    Text(formatRoutineRepeatSummary(routine)),
                    const SizedBox(height: 4),
                    Text(formatRoutineTimingSummary(routine)),
                    if (consistencyAsync.valueOrNull case final summary?) ...[
                      const SizedBox(height: 6),
                      Text(
                        '${summary.completedCount}/${summary.closedOccurrences == 0 ? summary.totalOccurrences : summary.closedOccurrences} completed • '
                        '${(summary.completionRate * 100).round()}% last window',
                      ),
                    ],
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        AppStatusChip(
                          label: routine.isFlexible ? 'Flexible' : 'Fixed',
                        ),
                        if (routine.autoRescheduleMissed)
                          const AppStatusChip(label: 'Auto-recover'),
                        if (routine.countsTowardConsistency)
                          const AppStatusChip(label: 'Consistency'),
                        if (routine.isArchived)
                          const AppStatusChip(label: 'Archived'),
                        if (consistencyAsync.valueOrNull case final summary?
                            when summary.lastCompletedAt != null)
                          AppStatusChip(label: summary.insightLabel),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      onEdit();
                      break;
                    case 'archive':
                      onArchiveToggle();
                      break;
                    case 'delete':
                      onDelete();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(
                    value: 'archive',
                    child: Text(routine.isArchived ? 'Unarchive' : 'Archive'),
                  ),
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RoutineOccurrenceCard extends ConsumerWidget {
  const RoutineOccurrenceCard({
    required this.item,
    this.showInlineActions = false,
    this.onOpenRoutine,
    super.key,
  });

  final RoutineOccurrenceItem item;
  final bool showInlineActions;
  final VoidCallback? onOpenRoutine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final occurrence = item.occurrence;
    final routine = item.routine;
    final canAct = item.effectiveStatus == RoutineOccurrenceStatus.pending;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => showRoutineOccurrenceActionSheet(
          context,
          ref,
          item: item,
          onOpenRoutine: onOpenRoutine,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                          routine?.title ?? 'Routine Block',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(formatOccurrenceScheduleContext(occurrence)),
                        if ((occurrence.schedulingNote ?? '').trim().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(occurrence.schedulingNote!),
                        ],
                        if (occurrence.isManualOverride) ...[
                          const SizedBox(height: 4),
                          const Text('Manual time preserved'),
                        ],
                        if (occurrence.isRecoveryInstance) ...[
                          const SizedBox(height: 4),
                          const Text('Recovery block'),
                        ],
                        if (routine != null) ...[
                          const SizedBox(height: 4),
                          Text(formatRoutineRepeatSummary(routine)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  AppStatusChip(label: formatRoutineStatusLabel(item.effectiveStatus)),
                ],
              ),
              if (showInlineActions && canAct) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (occurrence.needsAttention)
                      const AppStatusChip(label: 'Needs placement'),
                    if (occurrence.isManualOverride)
                      const AppStatusChip(label: 'Manual override'),
                    if (occurrence.isRecoveryInstance)
                      const AppStatusChip(label: 'Recovery'),
                    if ((routine?.remindersEnabled ?? false) &&
                        occurrence.scheduledStart != null)
                      AppStatusChip(
                        label:
                            'Reminder ${routine!.reminderLeadMinutes ?? 10}m before',
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: () => _runOccurrenceAction(
                        context,
                        ref,
                        () => ref
                            .read(routineOccurrenceControllerProvider.notifier)
                            .completeOccurrence(occurrence.id),
                        title: 'Routine update failed',
                        message:
                            'The routine block could not be marked complete.',
                      ),
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Complete'),
                    ),
                    TextButton.icon(
                      onPressed: () => _showSnoozeMenu(context, ref, occurrence),
                      icon: const Icon(Icons.schedule_rounded),
                      label: const Text('Snooze'),
                    ),
                    TextButton.icon(
                      onPressed: () => _runOccurrenceAction(
                        context,
                        ref,
                        () => ref
                            .read(routineOccurrenceControllerProvider.notifier)
                            .skipOccurrence(occurrence.id),
                        title: 'Routine update failed',
                        message: 'The routine block could not be skipped.',
                      ),
                      icon: const Icon(Icons.skip_next_rounded),
                      label: const Text('Skip'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showSnoozeMenu(
    BuildContext context,
    WidgetRef ref,
    RoutineOccurrence occurrence,
  ) async {
    final baseStart =
        occurrence.scheduledStart ?? DateTime.now().add(const Duration(minutes: 15));
    final selected = await showModalBottomSheet<Duration>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Snooze 15 minutes'),
                onTap: () => Navigator.of(context).pop(const Duration(minutes: 15)),
              ),
              ListTile(
                title: const Text('Snooze 30 minutes'),
                onTap: () => Navigator.of(context).pop(const Duration(minutes: 30)),
              ),
              ListTile(
                title: const Text('Snooze 1 hour'),
                onTap: () => Navigator.of(context).pop(const Duration(hours: 1)),
              ),
            ],
          ),
        );
      },
    );
    if (selected == null) {
      return;
    }
    if (!context.mounted) {
      return;
    }

    final newStart = baseStart.add(selected);
    await _runOccurrenceAction(
      context,
      ref,
      () => ref
          .read(routineOccurrenceControllerProvider.notifier)
          .snoozeOccurrence(
            occurrence.id,
            DateTime(
              occurrence.occurrenceDate.year,
              occurrence.occurrenceDate.month,
              occurrence.occurrenceDate.day,
              newStart.hour,
              newStart.minute,
            ),
            notes: 'Snoozed from routine block',
          ),
      title: 'Routine update failed',
      message: 'The routine block could not be rescheduled.',
    );
  }
}

Future<void> showRoutineOccurrenceActionSheet(
  BuildContext context,
  WidgetRef ref, {
  required RoutineOccurrenceItem item,
  VoidCallback? onOpenRoutine,
}) async {
  final occurrence = item.occurrence;
  await showModalBottomSheet<void>(
    context: context,
    builder: (context) {
      final canAct = item.effectiveStatus == RoutineOccurrenceStatus.pending;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.routine?.title ?? 'Routine Block',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(formatOccurrenceScheduleContext(occurrence)),
              const SizedBox(height: 16),
              if (canAct)
                ListTile(
                  leading: const Icon(Icons.check_rounded),
                  title: const Text('Complete'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await _runOccurrenceAction(
                      context,
                      ref,
                      () => ref
                          .read(routineOccurrenceControllerProvider.notifier)
                          .completeOccurrence(occurrence.id),
                      title: 'Routine update failed',
                      message:
                          'The routine block could not be marked complete.',
                    );
                  },
                ),
              if (canAct)
                ListTile(
                  leading: const Icon(Icons.skip_next_rounded),
                  title: const Text('Skip'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await _runOccurrenceAction(
                      context,
                      ref,
                      () => ref
                          .read(routineOccurrenceControllerProvider.notifier)
                          .skipOccurrence(occurrence.id),
                      title: 'Routine update failed',
                      message: 'The routine block could not be skipped.',
                    );
                  },
                ),
              if (canAct)
                ListTile(
                  leading: const Icon(Icons.schedule_rounded),
                  title: const Text('Snooze 30 minutes'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    final baseStart = occurrence.scheduledStart ??
                        DateTime(
                          occurrence.occurrenceDate.year,
                          occurrence.occurrenceDate.month,
                          occurrence.occurrenceDate.day,
                          18,
                        );
                    await _runOccurrenceAction(
                      context,
                      ref,
                      () => ref
                          .read(routineOccurrenceControllerProvider.notifier)
                          .snoozeOccurrence(
                            occurrence.id,
                            baseStart.add(const Duration(minutes: 30)),
                            notes: 'Snoozed 30 minutes',
                          ),
                      title: 'Routine update failed',
                      message: 'The routine block could not be rescheduled.',
                    );
                  },
                ),
              if (onOpenRoutine != null)
                ListTile(
                  leading: const Icon(Icons.open_in_new_rounded),
                  title: const Text('Open Routine'),
                  onTap: () {
                    Navigator.of(context).pop();
                    onOpenRoutine();
                  },
                ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> _runOccurrenceAction(
  BuildContext context,
  WidgetRef ref,
  Future<void> Function() action, {
  required String title,
  required String message,
}) async {
  try {
    await action();
  } catch (error) {
    if (context.mounted) {
      ErrorHandler.showSnackBar(
        context,
        error,
        fallbackTitle: title,
        fallbackMessage: message,
      );
    }
  }
}
