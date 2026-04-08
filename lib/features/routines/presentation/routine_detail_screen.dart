import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/errors/error_handler.dart';
import '../../../core/widgets/app_confirmation_dialog.dart';
import '../../../core/widgets/app_status_chip.dart';
import '../../goals/presentation/goal_detail_screen.dart';
import '../../goals/providers/goal_providers.dart';
import '../../integrations/providers/calendar_export_providers.dart';
import '../application/routine_consistency_service.dart';
import '../application/routine_formatters.dart';
import '../domain/routine_enums.dart';
import '../models/routine.dart';
import '../models/routine_occurrence.dart';
import '../providers/routine_intelligence_providers.dart';
import '../providers/routine_providers.dart';
import 'add_edit_routine_screen.dart';

class RoutineDetailScreen extends ConsumerWidget {
  const RoutineDetailScreen({required this.routineId, super.key});

  final String routineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routinesAsync = ref.watch(watchAllRoutinesProvider);
    final occurrencesAsync = ref.watch(watchAllRoutineOccurrencesProvider);
    final goalsAsync = ref.watch(watchGoalsProvider);
    final summaryAsync = ref.watch(routineConsistencySummaryProvider(routineId));

    return Scaffold(
      appBar: AppBar(title: const Text('Routine Details')),
      body: switch ((routinesAsync, occurrencesAsync, goalsAsync, summaryAsync)) {
        (
          AsyncData(value: final routines),
          AsyncData(value: final occurrences),
          AsyncData(value: final goals),
          AsyncData(value: final summary),
        ) => () {
          final routine = routines.where((item) => item.id == routineId).firstOrNull;
          final linkedGoalName = routine?.linkedGoalId == null
              ? null
              : goals.where((item) => item.id == routine!.linkedGoalId).firstOrNull?.title;
          return _DetailBody(
            routine: routine,
            occurrences: occurrences.where((item) => item.routineId == routineId).toList(),
            linkedGoalName: linkedGoalName,
            summary: summary,
          );
        }(),
        (AsyncError(:final error, :final stackTrace), _, _, _) => _ErrorBody(
          error: error,
          stackTrace: stackTrace,
        ),
        (_, AsyncError(:final error, :final stackTrace), _, _) => _ErrorBody(
          error: error,
          stackTrace: stackTrace,
        ),
        (_, _, AsyncError(:final error, :final stackTrace), _) => _ErrorBody(
          error: error,
          stackTrace: stackTrace,
        ),
        (_, _, _, AsyncError(:final error, :final stackTrace)) => _ErrorBody(
          error: error,
          stackTrace: stackTrace,
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _DetailBody extends ConsumerWidget {
  const _DetailBody({
    required this.routine,
    required this.occurrences,
    required this.linkedGoalName,
    required this.summary,
  });

  final Routine? routine;
  final List<RoutineOccurrence> occurrences;
  final String? linkedGoalName;
  final RoutineConsistencySummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routine = this.routine;
    if (routine == null) {
      return const Center(child: Text('Routine not found.'));
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final nextOccurrences = occurrences
        .where(
          (item) =>
              item.effectiveStatusAt(now) == RoutineOccurrenceStatus.pending &&
              !item.occurrenceDate.isBefore(today),
        )
        .toList()
      ..sort((left, right) => left.occurrenceDate.compareTo(right.occurrenceDate));
    final history = occurrences
        .where((item) => item.effectiveStatusAt(now) != RoutineOccurrenceStatus.pending)
        .toList()
      ..sort((left, right) => right.occurrenceDate.compareTo(left.occurrenceDate));
    final needsAttention = nextOccurrences.where((item) => item.needsAttention).toList();
    final recoveryInstances =
        nextOccurrences.where((item) => item.isRecoveryInstance).toList();
    final recoverySuggestions = occurrences.where((item) {
      return item.effectiveStatusAt(now) == RoutineOccurrenceStatus.missed &&
          item.recoveryDismissedAt == null &&
          !occurrences.any((candidate) => candidate.recoveredFromOccurrenceId == item.id);
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  routine.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if ((routine.description ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(routine.description!),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    AppStatusChip(label: routine.isArchived ? 'Archived' : 'Active'),
                    AppStatusChip(label: routine.isFlexible ? 'Flexible' : 'Fixed'),
                    if (routine.autoRescheduleMissed)
                      const AppStatusChip(label: 'Auto-recover'),
                    if (routine.remindersEnabled)
                      AppStatusChip(
                        label:
                            'Reminder ${routine.reminderLeadMinutes ?? 10}m before',
                      ),
                    AppStatusChip(label: summary.insightLabel),
                  ],
                ),
                const SizedBox(height: 16),
                Text(formatRoutineRepeatSummary(routine)),
                const SizedBox(height: 4),
                Text(formatRoutineTimingSummary(routine)),
                if ((linkedGoalName ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: routine.linkedGoalId == null
                        ? null
                        : () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    GoalDetailScreen(goalId: routine.linkedGoalId!),
                              ),
                            );
                          },
                    icon: const Icon(Icons.track_changes_rounded),
                    label: Text('Linked goal: $linkedGoalName'),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _ActionsCard(
          routine: routine,
          onDelete: () => _deleteRoutine(context, ref, routine),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analytics Snapshot',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${summary.completedCount} completed • ${summary.skippedCount} skipped • ${summary.missedCount} missed',
                ),
                const SizedBox(height: 4),
                Text('${summary.healthLabel} • ${summary.trendLabel}'),
                const SizedBox(height: 4),
                Text(
                  'Completion rate ${(summary.completionRate * 100).round()}% across ${summary.closedOccurrences} closed occurrences',
                ),
                if (summary.lastCompletedAt != null) ...[
                  const SizedBox(height: 4),
                  Text('Last completed ${DateFormat.yMMMd().add_jm().format(summary.lastCompletedAt!)}'),
                ],
              ],
            ),
          ),
        ),
        if (needsAttention.isNotEmpty ||
            recoveryInstances.isNotEmpty ||
            recoverySuggestions.isNotEmpty) ...[
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recovery And Attention',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (needsAttention.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text('${needsAttention.length} upcoming occurrence(s) still need placement.'),
                  ],
                  if (recoveryInstances.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text('${recoveryInstances.length} recovery occurrence(s) are already scheduled.'),
                  ],
                  for (final suggestion in recoverySuggestions.take(3)) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Recovery available for ${DateFormat.yMMMd().format(suggestion.occurrenceDate)}',
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            try {
                              await ref
                                  .read(routineIntelligenceControllerProvider.notifier)
                                  .dismissRecoverySuggestion(suggestion.id);
                            } catch (error) {
                              if (context.mounted) {
                                ErrorHandler.showSnackBar(
                                  context,
                                  error,
                                  fallbackTitle: 'Recovery update failed',
                                  fallbackMessage:
                                      'The recovery suggestion could not be dismissed.',
                                );
                              }
                            }
                          },
                          child: const Text('Ignore'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next Occurrences',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                if (nextOccurrences.isEmpty)
                  const Text('No upcoming routine occurrences in the current horizon.')
                else
                  for (final occurrence in nextOccurrences.take(7)) ...[
                    _OccurrenceRow(occurrence: occurrence),
                    const SizedBox(height: 12),
                  ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent History',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                if (history.isEmpty)
                  const Text('No recent history yet.')
                else
                  for (final occurrence in history.take(8)) ...[
                    _OccurrenceRow(occurrence: occurrence),
                    const SizedBox(height: 12),
                  ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _deleteRoutine(
    BuildContext context,
    WidgetRef ref,
    Routine routine,
  ) async {
    final confirmed = await AppConfirmationDialog.show(
      context,
      title: 'Delete routine?',
      message:
          'Delete this routine and its occurrence history? This cannot be undone.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!confirmed || !context.mounted) {
      return;
    }
    try {
      await ref.read(routineFormControllerProvider(routine).notifier).delete();
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (context.mounted) {
        ErrorHandler.showSnackBar(
          context,
          error,
          fallbackTitle: 'Routine delete failed',
          fallbackMessage: 'The routine block could not be deleted.',
        );
      }
    }
  }
}

class _ActionsCard extends ConsumerWidget {
  const _ActionsCard({
    required this.routine,
    required this.onDelete,
  });

  final Routine routine;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.tonalIcon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => AddEditRoutineScreen(routine: routine),
                  ),
                );
              },
              icon: const Icon(Icons.edit_rounded),
              label: const Text('Edit'),
            ),
            FilledButton.tonalIcon(
              onPressed: () async {
                try {
                  await ref
                      .read(routineIntelligenceControllerProvider.notifier)
                      .replanRoutineOccurrences(routine.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Upcoming routine occurrences replanned.'),
                      ),
                    );
                  }
                } catch (error) {
                  if (context.mounted) {
                    ErrorHandler.showSnackBar(
                      context,
                      error,
                      fallbackTitle: 'Routine replan failed',
                      fallbackMessage:
                          'Upcoming routine occurrences could not be replanned.',
                    );
                  }
                }
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Replan Upcoming'),
            ),
            FilledButton.tonalIcon(
              onPressed: () async {
                try {
                  final template = ref
                      .read(routineTemplateServiceProvider)
                      .buildTemplateFromRoutines(
                        name: '${routine.title} Template',
                        routines: [routine],
                      );
                  final repository = await ref.read(
                    routineTemplateRepositoryProvider.future,
                  );
                  await repository.saveTemplate(template);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Saved as routine template.'),
                      ),
                    );
                  }
                } catch (error) {
                  if (context.mounted) {
                    ErrorHandler.showSnackBar(
                      context,
                      error,
                      fallbackTitle: 'Template save failed',
                      fallbackMessage:
                          'The routine template could not be saved.',
                    );
                  }
                }
              },
              icon: const Icon(Icons.bookmark_add_rounded),
              label: const Text('Save Template'),
            ),
            FilledButton.tonalIcon(
              onPressed: () async {
                try {
                  final ics = ref
                      .read(routineCalendarExportServiceProvider)
                      .generateRecurringRoutineIcs([routine], calendarName: routine.title);
                  final result = await ref
                      .read(calendarFileExportServiceProvider)
                      .saveIcsFile(
                        content: ics,
                        suggestedName: '${routine.title}_routine.ics',
                      );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result.message)),
                    );
                  }
                } catch (error) {
                  if (context.mounted) {
                    ErrorHandler.showSnackBar(
                      context,
                      error,
                      fallbackTitle: 'Routine export failed',
                      fallbackMessage:
                          'The routine calendar file could not be created.',
                    );
                  }
                }
              },
              icon: const Icon(Icons.file_download_rounded),
              label: const Text('Export ICS'),
            ),
            TextButton.icon(
              onPressed: () async {
                try {
                  await ref.read(routineFormControllerProvider(routine).notifier).archive();
                } catch (error) {
                  if (context.mounted) {
                    ErrorHandler.showSnackBar(
                      context,
                      error,
                      fallbackTitle: 'Routine update failed',
                      fallbackMessage: 'The routine block could not be updated.',
                    );
                  }
                }
              },
              icon: Icon(
                routine.isArchived ? Icons.unarchive_outlined : Icons.archive_outlined,
              ),
              label: Text(routine.isArchived ? 'Unarchive' : 'Archive'),
            ),
            TextButton.icon(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }
}

class _OccurrenceRow extends StatelessWidget {
  const _OccurrenceRow({required this.occurrence});

  final RoutineOccurrence occurrence;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(DateFormat.yMMMd().format(occurrence.occurrenceDate)),
              const SizedBox(height: 4),
              Text(formatOccurrenceScheduleContext(occurrence)),
              if ((occurrence.schedulingNote ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(occurrence.schedulingNote!),
              ],
              if (occurrence.isRecoveryInstance) ...[
                const SizedBox(height: 4),
                const Text('Recovery occurrence'),
              ],
              if (occurrence.isManualOverride) ...[
                const SizedBox(height: 4),
                const Text('Manual time preserved'),
              ],
            ],
          ),
        ),
        const SizedBox(width: 12),
        AppStatusChip(label: occurrence.effectiveStatusAt(now).label),
      ],
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({
    required this.error,
    required this.stackTrace,
  });

  final Object error;
  final StackTrace stackTrace;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(ErrorHandler.mapError(error).message),
      ),
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
