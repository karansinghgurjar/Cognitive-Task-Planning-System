import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/errors/error_handler.dart';
import '../../../core/widgets/app_status_chip.dart';
import '../../notes/models/entity_note.dart';
import '../../notes/presentation/entity_support_sections.dart';
import '../models/task.dart';
import '../providers/task_providers.dart';
import 'add_task_screen.dart';

class TaskDetailScreen extends ConsumerWidget {
  const TaskDetailScreen({required this.taskId, super.key});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(watchTasksProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Detail'),
      ),
      body: tasksAsync.when(
        data: (tasks) {
          Task? task;
          for (final candidate in tasks) {
            if (candidate.id == taskId) {
              task = candidate;
              break;
            }
          }
          if (task == null) {
            return const Center(child: Text('This task no longer exists.'));
          }
          return _TaskDetailBody(task: task);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text(ErrorHandler.mapError(error).message)),
      ),
    );
  }
}

class _TaskDetailBody extends ConsumerWidget {
  const _TaskDetailBody({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dueLabel = task.dueDate == null
        ? 'No due date'
        : DateFormat.yMMMd().format(task.dueDate!);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => AddTaskScreen(initialTask: task),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Edit task',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    AppStatusChip(label: task.type.label),
                    AppStatusChip(label: '${task.estimatedDurationMinutes} min'),
                    AppStatusChip(label: 'Priority ${task.priority}'),
                    AppStatusChip(
                      label: task.isArchived
                          ? 'Archived'
                          : task.isCompleted
                          ? 'Completed'
                          : 'Active',
                    ),
                    AppStatusChip(label: dueLabel),
                  ],
                ),
                if (task.description != null &&
                    task.description!.trim().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(task.description!),
                ],
                if ((task.resourceUrl?.trim().isNotEmpty ?? false) ||
                    (task.resourceTag?.trim().isNotEmpty ?? false)) ...[
                  const SizedBox(height: 16),
                  if (task.resourceTag?.trim().isNotEmpty ?? false)
                    Text('Resource Tag: ${task.resourceTag!}'),
                  if (task.resourceUrl?.trim().isNotEmpty ?? false)
                    Text('Legacy URL: ${task.resourceUrl!}'),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        EntityNotesSection(
          entityType: EntityAttachmentType.task,
          entityId: task.id,
          title: 'Notes',
        ),
        const SizedBox(height: 20),
        EntityResourcesSection(
          entityType: EntityAttachmentType.task,
          entityId: task.id,
          title: 'Resources',
        ),
      ],
    );
  }
}
