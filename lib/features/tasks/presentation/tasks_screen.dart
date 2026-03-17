import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/app_router.dart';
import '../../../core/errors/error_boundary_widget.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/layout/responsive_layout.dart';
import '../../../core/widgets/app_confirmation_dialog.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../../core/widgets/app_section_header.dart';
import '../../../core/widgets/app_status_chip.dart';
import '../models/task.dart';
import '../providers/task_providers.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(watchTasksProvider);
    final actionState = ref.watch(taskActionControllerProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final breakpoint = ResponsiveLayout.breakpointForWidth(
          constraints.maxWidth,
        );
        final padding = ResponsiveLayout.pagePadding(breakpoint);
        return Column(
          children: [
            if (actionState.isLoading) const LinearProgressIndicator(),
            Expanded(
              child: ResponsiveContent(
                child: tasksAsync.when(
                  data: (tasks) {
                    if (tasks.isEmpty) {
                      return ListView(
                        padding: padding,
                        children: [
                          AppSectionHeader(
                            title: 'Tasks',
                            description:
                                'Track work, due dates, and completion status.',
                            actions: [
                              IconButton(
                                onPressed: () => AppRouter.openSettings(context),
                                icon: const Icon(Icons.settings_outlined),
                                tooltip: 'Settings',
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const AppEmptyState(
                            icon: Icons.inbox_rounded,
                            title: 'No tasks yet',
                            message:
                                'Add your first task to define real work before generating schedules or focus sessions.',
                          ),
                        ],
                      );
                    }

                    return ListView.separated(
                      padding: padding,
                      itemCount: tasks.length + 1,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return AppSectionHeader(
                            title: 'Tasks',
                            description:
                                'Track work, due dates, and completion status.',
                            actions: [
                              IconButton(
                                onPressed: () => AppRouter.openSettings(context),
                                icon: const Icon(Icons.settings_outlined),
                                tooltip: 'Settings',
                              ),
                            ],
                          );
                        }
                        final task = tasks[index - 1];
                        return _TaskCard(task: task);
                      },
                    );
                  },
                  loading: () => const AppLoadingIndicator(
                    label: 'Loading tasks...',
                  ),
                  error: (error, _) => ErrorBoundaryWidget(error: error),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TaskCard extends ConsumerWidget {
  const _TaskCard({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dueDate = task.dueDate;
    final formattedDueDate = dueDate == null
        ? null
        : DateFormat.yMMMd().format(dueDate);

    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Icon(
          Icons.delete_outline_rounded,
          color: Theme.of(context).colorScheme.onErrorContainer,
        ),
      ),
      confirmDismiss: (_) async {
        final shouldDelete = await AppConfirmationDialog.show(
          context,
          title: 'Delete task?',
          message: 'Remove "${task.title}" permanently?',
          confirmLabel: 'Delete',
          destructive: true,
        );
        return shouldDelete;
      },
      onDismissed: (_) async {
        try {
          await ref
              .read(taskActionControllerProvider.notifier)
              .deleteTask(task.id);
        } catch (error) {
          if (context.mounted) {
            ErrorHandler.showSnackBar(
              context,
              error,
              fallbackTitle: 'Delete failed',
              fallbackMessage: 'The task could not be deleted safely.',
            );
          }
        }
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: task.isCompleted,
                onChanged: (_) async {
                  try {
                    await ref
                        .read(taskActionControllerProvider.notifier)
                        .toggleCompleted(task);
                  } catch (error) {
                    if (context.mounted) {
                      ErrorHandler.showSnackBar(
                        context,
                        error,
                        fallbackTitle: 'Task update failed',
                        fallbackMessage:
                            'The task completion state could not be updated.',
                      );
                    }
                  }
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _TaskMetaChip(label: task.type.label),
                        _TaskMetaChip(
                          label: '${task.estimatedDurationMinutes} min',
                        ),
                        _TaskMetaChip(label: 'Priority ${task.priority}'),
                        _TaskMetaChip(
                          label: task.isCompleted ? 'Completed' : 'Incomplete',
                        ),
                        if (formattedDueDate != null)
                          _TaskMetaChip(label: 'Due $formattedDueDate'),
                      ],
                    ),
                    if (task.description != null &&
                        task.description!.trim().isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(task.description!),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskMetaChip extends StatelessWidget {
  const _TaskMetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return AppStatusChip(label: label);
  }
}
