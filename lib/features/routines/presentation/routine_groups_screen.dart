import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/errors/error_handler.dart';
import '../../integrations/providers/calendar_export_providers.dart';
import '../models/routine.dart';
import '../models/routine_group.dart';
import '../providers/routine_providers.dart';

class RoutineGroupsScreen extends ConsumerWidget {
  const RoutineGroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(watchRoutineGroupsProvider);
    final routinesAsync = ref.watch(watchActiveRoutinesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Routine Systems')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createGroup(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New System'),
      ),
      body: groupsAsync.when(
        data: (groups) {
          final routines = routinesAsync.valueOrNull ?? const <Routine>[];
          if (groups.isEmpty) {
            return ListView(
              padding: const EdgeInsets.all(24),
              children: const [
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No routine systems yet. Create one to group related recurring blocks.',
                    ),
                  ),
                ),
              ],
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
            itemCount: groups.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final group = groups[index];
              final groupedRoutines = ref
                  .read(routineGroupServiceProvider)
                  .filterRoutinesForGroup(group, routines);
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if ((group.description ?? '').trim().isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(group.description!),
                      ],
                      const SizedBox(height: 12),
                      Text('${groupedRoutines.length} routines linked'),
                      if (groupedRoutines.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          groupedRoutines.map((routine) => routine.title).join(', '),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilledButton.tonalIcon(
                            onPressed: () => _editGroup(context, ref, group),
                            icon: const Icon(Icons.edit_rounded),
                            label: const Text('Edit'),
                          ),
                          FilledButton.tonalIcon(
                            onPressed: groupedRoutines.isEmpty
                                ? null
                                : () => _exportGroup(context, ref, group, groupedRoutines),
                            icon: const Icon(Icons.file_download_rounded),
                            label: const Text('Export'),
                          ),
                          TextButton.icon(
                            onPressed: () => _deleteGroup(context, ref, group.id),
                            icon: const Icon(Icons.delete_outline_rounded),
                            label: const Text('Delete'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        error: (error, _) => Center(child: Text(ErrorHandler.mapError(error).message)),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Future<void> _createGroup(BuildContext context, WidgetRef ref) async {
    await _showGroupEditor(context, ref);
  }

  Future<void> _editGroup(
    BuildContext context,
    WidgetRef ref,
    RoutineGroup group,
  ) async {
    await _showGroupEditor(context, ref, existing: group);
  }

  Future<void> _showGroupEditor(
    BuildContext context,
    WidgetRef ref, {
    RoutineGroup? existing,
  }) async {
    final routines = await ref.read(watchActiveRoutinesProvider.future);
    if (!context.mounted) {
      return;
    }
    final selectedRoutineIds = <String>{...?existing?.routineIds};
    final nameController = TextEditingController(text: existing?.name ?? '');
    final descriptionController = TextEditingController(
      text: existing?.description ?? '',
    );
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(existing == null ? 'New Routine System' : 'Edit Routine System'),
              content: SizedBox(
                width: 480,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Name'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descriptionController,
                        decoration: const InputDecoration(labelText: 'Description'),
                        minLines: 2,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),
                      for (final routine in routines)
                        CheckboxListTile(
                          value: selectedRoutineIds.contains(routine.id),
                          contentPadding: EdgeInsets.zero,
                          title: Text(routine.title),
                          subtitle: Text(routine.isFlexible ? 'Flexible' : 'Fixed'),
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                selectedRoutineIds.add(routine.id);
                              } else {
                                selectedRoutineIds.remove(routine.id);
                              }
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
    if (saved != true) {
      return;
    }
    final repository = await ref.read(routineGroupRepositoryProvider.future);
    final now = DateTime.now();
    final group = (existing ??
            RoutineGroup(
              id: const Uuid().v4(),
              name: nameController.text.trim().isEmpty
                  ? 'Routine System'
                  : nameController.text.trim(),
              createdAt: now,
            ))
        .copyWith(
          name: nameController.text.trim().isEmpty
              ? 'Routine System'
              : nameController.text.trim(),
          description: descriptionController.text.trim().isEmpty
              ? null
              : descriptionController.text.trim(),
          clearDescription: descriptionController.text.trim().isEmpty,
          routineIds: selectedRoutineIds.toList()..sort(),
          updatedAt: now,
        );
    await repository.saveGroup(group);
  }

  Future<void> _deleteGroup(
    BuildContext context,
    WidgetRef ref,
    String groupId,
  ) async {
    final repository = await ref.read(routineGroupRepositoryProvider.future);
    if (!context.mounted) {
      return;
    }
    await repository.deleteGroup(groupId);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Routine system deleted.')),
      );
    }
  }

  Future<void> _exportGroup(
    BuildContext context,
    WidgetRef ref,
    RoutineGroup group,
    List<Routine> routines,
  ) async {
    try {
      final ics = ref.read(routineCalendarExportServiceProvider).generateRecurringRoutineIcs(
            routines,
            calendarName: group.name,
          );
      final result = await ref
          .read(calendarFileExportServiceProvider)
          .saveIcsFile(content: ics, suggestedName: '${group.name}_routines.ics');
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
          fallbackTitle: 'Export failed',
          fallbackMessage: 'The routine system could not be exported.',
        );
      }
    }
  }
}
