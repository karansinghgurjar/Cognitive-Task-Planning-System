import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_handler.dart';
import '../../goals/models/learning_goal.dart';
import '../../goals/providers/goal_providers.dart';
import '../application/routine_template_service.dart';
import '../models/routine_template.dart';
import '../providers/routine_providers.dart';

class RoutineTemplatesScreen extends ConsumerWidget {
  const RoutineTemplatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final builtInPacks = ref.watch(routineStarterPacksProvider);
    final templatesAsync = ref.watch(watchRoutineTemplatesProvider);
    final routinesAsync = ref.watch(watchActiveRoutinesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Routine Templates')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _saveCurrentRoutinesAsTemplate(context, ref),
        icon: const Icon(Icons.bookmark_add_rounded),
        label: const Text('Save Current'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
        children: [
          Text(
            'Starter Packs',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          for (final pack in builtInPacks) ...[
            _TemplateCard(
              template: pack.template,
              subtitle:
                  '${pack.description}\n${(pack.estimatedWeeklyMinutes / 60).toStringAsFixed(1)} hours / week',
              onApply: () => _applyTemplate(context, ref, pack.template),
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 12),
          Text(
            'Saved Templates',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          templatesAsync.when(
            data: (templates) {
              if (templates.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No user templates yet. Save your current routine system or apply a starter pack first.',
                    ),
                  ),
                );
              }
              return Column(
                children: [
                  for (final template in templates) ...[
                    _TemplateCard(
                      template: template,
                      subtitle: template.description ?? template.category,
                      onApply: () => _applyTemplate(context, ref, template),
                      onDelete: () => _deleteTemplate(context, ref, template.id),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              );
            },
            error: (error, _) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(ErrorHandler.mapError(error).message),
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
          const SizedBox(height: 16),
          routinesAsync.when(
            data: (routines) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  routines.isEmpty
                      ? 'Active routines are empty. Create a system or apply a starter pack.'
                      : '${routines.length} active routine${routines.length == 1 ? '' : 's'} available to save as a reusable template.',
                ),
              ),
            ),
            error: (_, _) => const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Future<void> _saveCurrentRoutinesAsTemplate(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final routines = await ref.read(watchActiveRoutinesProvider.future);
    if (!context.mounted) {
      return;
    }
    if (routines.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Create routines before saving a template.')),
        );
      }
      return;
    }
    final controller = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Save Current Routines'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Template name'),
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
    if (saved != true) {
      return;
    }
    final template = ref.read(routineTemplateServiceProvider).buildTemplateFromRoutines(
          name: controller.text.trim().isEmpty
              ? 'Routine System'
              : controller.text.trim(),
          routines: routines,
        );
    final repository = await ref.read(routineTemplateRepositoryProvider.future);
    await repository.saveTemplate(template);
  }

  Future<void> _deleteTemplate(
    BuildContext context,
    WidgetRef ref,
    String templateId,
  ) async {
    final repository = await ref.read(routineTemplateRepositoryProvider.future);
    if (!context.mounted) {
      return;
    }
    await repository.deleteTemplate(templateId);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Template deleted.')),
      );
    }
  }

  Future<void> _applyTemplate(
    BuildContext context,
    WidgetRef ref,
    RoutineTemplate template,
  ) async {
    final goals = ref.read(watchGoalsProvider).valueOrNull ?? const <LearningGoal>[];
    var selectedDate = DateTime.now();
    var shiftMinutes = 0;
    String? selectedGoalId;
    final projectController = TextEditingController();
    final applied = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Apply ${template.name}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(template.description ?? template.category),
                    const SizedBox(height: 12),
                    Text('Includes ${template.items.length} routine blocks'),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() => selectedDate = picked);
                        }
                      },
                      icon: const Icon(Icons.event_rounded),
                      label: Text(
                        'Start ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      initialValue: shiftMinutes,
                      decoration: const InputDecoration(
                        labelText: 'Time shift',
                      ),
                      items: const [
                        DropdownMenuItem(value: -60, child: Text('-60 min')),
                        DropdownMenuItem(value: -30, child: Text('-30 min')),
                        DropdownMenuItem(value: 0, child: Text('No shift')),
                        DropdownMenuItem(value: 30, child: Text('+30 min')),
                        DropdownMenuItem(value: 60, child: Text('+60 min')),
                      ],
                      onChanged: (value) => setState(() => shiftMinutes = value ?? 0),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String?>(
                      initialValue: selectedGoalId,
                      decoration: const InputDecoration(labelText: 'Link goal'),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('No goal'),
                        ),
                        ...goals.map(
                          (goal) => DropdownMenuItem<String?>(
                            value: goal.id,
                            child: Text(goal.title),
                          ),
                        ),
                      ],
                      onChanged: (value) => setState(() => selectedGoalId = value),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: projectController,
                      decoration: const InputDecoration(
                        labelText: 'Project label',
                        hintText: 'Optional lightweight project link',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
    if (applied != true) {
      return;
    }
    try {
      final routines = ref.read(routineTemplateServiceProvider).applyTemplate(
            template,
            options: RoutineTemplateApplyOptions(
              anchorDate: selectedDate,
              timeShiftMinutes: shiftMinutes,
              goalId: selectedGoalId,
              projectId: projectController.text.trim().isEmpty
                  ? null
                  : projectController.text.trim(),
            ),
          );
      final repository = await ref.read(routineRepositoryProvider.future);
      for (final routine in routines) {
        await repository.saveRoutine(routine);
      }
      final syncService = await ref.read(routineSyncServiceProvider.future);
      await syncService.syncAllRoutines(
        startDate: selectedDate,
        endDate: selectedDate.add(const Duration(days: 30)),
      );
      if (!context.mounted) {
        return;
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Created ${routines.length} routines from ${template.name}.'),
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ErrorHandler.showSnackBar(
          context,
          error,
          fallbackTitle: 'Template apply failed',
          fallbackMessage: 'The routine template could not be applied safely.',
        );
      }
    }
  }
}

class _TemplateCard extends ConsumerWidget {
  const _TemplateCard({
    required this.template,
    required this.subtitle,
    required this.onApply,
    this.onDelete,
  });

  final RoutineTemplate template;
  final String subtitle;
  final VoidCallback onApply;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preview = ref.read(routineTemplateServiceProvider).buildPreview(template);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              template.name,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(subtitle),
            const SizedBox(height: 12),
            Text(
              '${template.items.length} items • ${preview.fixedItemCount} fixed • ${preview.flexibleItemCount} flexible • ${(preview.totalWeeklyMinutes / 60).toStringAsFixed(1)}h/week',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  onPressed: onApply,
                  icon: const Icon(Icons.playlist_add_check_rounded),
                  label: const Text('Apply'),
                ),
                if (onDelete != null)
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
}
