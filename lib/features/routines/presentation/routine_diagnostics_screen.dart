import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/routine_providers.dart';

class RoutineDiagnosticsScreen extends ConsumerWidget {
  const RoutineDiagnosticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diagnostics = ref.watch(routinePlannerDiagnosticsProvider);
    final planningWindow = ref.read(routineHistoryPolicyServiceProvider).activePlanningWindow();
    final routinesAsync = ref.watch(watchAllRoutinesProvider);
    final occurrencesAsync = ref.watch(planningHorizonRoutineOccurrencesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Routine Diagnostics')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Planning Window',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${planningWindow.startDate} to ${planningWindow.endDate}',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Counts',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text('Routines: ${routinesAsync.valueOrNull?.length ?? 0}'),
                  Text(
                    'Planning-horizon occurrences: ${occurrencesAsync.valueOrNull?.length ?? 0}',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Last Planner Run',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  if (diagnostics == null)
                    const Text('No planner diagnostics captured yet.')
                  else ...[
                    Text('Duration: ${diagnostics.duration.inMilliseconds} ms'),
                    Text('Scanned: ${diagnostics.scannedOccurrences}'),
                    Text('Missed marked: ${diagnostics.missedMarked}'),
                    Text('Recovery suggestions: ${diagnostics.recoverySuggestions}'),
                    Text('Auto-scheduled: ${diagnostics.autoScheduled}'),
                    Text('Unscheduled: ${diagnostics.unscheduled}'),
                    Text('Reminders scheduled: ${diagnostics.remindersScheduled}'),
                    Text('Reminders cancelled: ${diagnostics.remindersCancelled}'),
                    if (diagnostics.notes.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      for (final note in diagnostics.notes) Text(note),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
