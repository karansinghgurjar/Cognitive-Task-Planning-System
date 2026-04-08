import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_handler.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_status_chip.dart';
import '../domain/routine_enums.dart';
import '../providers/routine_providers.dart';
import 'add_edit_routine_screen.dart';

class RoutinesScreen extends ConsumerWidget {
  const RoutinesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routinesAsync = ref.watch(watchAllRoutinesProvider);
    final previewAsync = ref.watch(routinePreviewProvider);
    final actionState = ref.watch(routineActionControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Routine Blocks'),
        actions: [
          IconButton(
            onPressed: actionState.isLoading
                ? null
                : () => _runAction(
                      context,
                      ref,
                      () => ref
                          .read(routineActionControllerProvider.notifier)
                          .generateNext30Days(),
                    ),
            icon: const Icon(Icons.sync_rounded),
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
      body: switch ((routinesAsync, previewAsync)) {
        (
          AsyncData(value: final routines),
          AsyncData(value: final preview),
        ) =>
          routines.isEmpty
              ? const AppEmptyState(
                  icon: Icons.repeat_rounded,
                  title: 'No routines yet',
                  message:
                      'Phase 1 includes backend recurrence support. You can create routines here and sync their occurrences into the planning horizon.',
                )
              : ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    Text(
                      'Previewed occurrences: ${preview.generatedCount}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    for (final routine in routines) ...[
                      Card(
                        child: ListTile(
                          title: Text(routine.title),
                          subtitle: Text(
                            routine.repeatRule.type.label,
                          ),
                          trailing: Wrap(
                            spacing: 8,
                            children: [
                              if (routine.isArchived)
                                const AppStatusChip(label: 'Archived'),
                              if (!routine.isArchived && routine.isActive)
                                const AppStatusChip(label: 'Active'),
                              IconButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) =>
                                          AddEditRoutineScreen(routine: routine),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.edit_outlined),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
        (AsyncError(:final error), _) => Center(
          child: Text(ErrorHandler.mapError(error).message),
        ),
        (_, AsyncError(:final error)) => Center(
          child: Text(ErrorHandler.mapError(error).message),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  Future<void> _runAction(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ErrorHandler.showSnackBar(
        context,
        error,
        fallbackTitle: 'Routine sync failed',
        fallbackMessage: 'Routine occurrences could not be synchronized.',
      );
    }
  }
}
