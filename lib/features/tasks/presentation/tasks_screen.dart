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
import '../domain/task_lifecycle_service.dart';
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
                    final activeTasks = tasks
                        .where((task) => !task.isArchived)
                        .toList();
                    final archivedTasks = tasks
                        .where((task) => task.isArchived)
                        .toList();

                    if (tasks.isEmpty) {
                      return ListView(
                        padding: padding,
                        children: const [
                          _TasksHeader(),
                          SizedBox(height: 24),
                          AppEmptyState(
                            icon: Icons.inbox_rounded,
                            title: 'No tasks yet',
                            message:
                                'Add your first task to define real work before generating schedules or focus sessions.',
                          ),
                        ],
                      );
                    }

                    return ListView(
                      padding: padding,
                      children: [
                        const _TasksHeader(),
                        const SizedBox(height: 24),
                        if (activeTasks.isEmpty)
                          const AppEmptyState(
                            icon: Icons.assignment_turned_in_outlined,
                            title: 'No active tasks',
                            message:
                                'Your active list is clear. Restore an archived task or create a new one to keep planning.',
                          )
                        else ...[
                          const _TaskSectionHeader(label: 'Active Tasks'),
                          const SizedBox(height: 12),
                          ..._buildTaskCards(activeTasks),
                        ],
                        if (archivedTasks.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          const _TaskSectionHeader(label: 'Archived Tasks'),
                          const SizedBox(height: 12),
                          ..._buildTaskCards(archivedTasks),
                        ],
                      ],
                    );
                  },
                  loading: () =>
                      const AppLoadingIndicator(label: 'Loading tasks...'),
                  error: (error, _) => ErrorBoundaryWidget(error: error),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildTaskCards(List<Task> tasks) {
    return [
      for (var index = 0; index < tasks.length; index++) ...[
        _TaskCard(task: tasks[index]),
        if (index < tasks.length - 1) const SizedBox(height: 12),
      ],
    ];
  }
}

class _TasksHeader extends StatelessWidget {
  const _TasksHeader();

  @override
  Widget build(BuildContext context) {
    return AppSectionHeader(
      title: 'Tasks',
      description:
          'Track work, due dates, completion, and lifecycle actions without losing control of your schedule.',
      actions: [
        IconButton(
          onPressed: () => AppRouter.openSettings(context),
          icon: const Icon(Icons.settings_outlined),
          tooltip: 'Settings',
        ),
      ],
    );
  }
}

class _TaskSectionHeader extends StatelessWidget {
  const _TaskSectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(
        context,
      ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

enum _TaskLifecycleAction {
  softReset,
  hardReset,
  resetGeneratedSessions,
  archive,
  restore,
  delete,
}

class _TaskCard extends ConsumerWidget {
  const _TaskCard({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formattedDueDate = task.dueDate == null
        ? null
        : DateFormat.yMMMd().format(task.dueDate!);
    final formattedArchivedDate = task.archivedAt == null
        ? null
        : DateFormat.yMMMd().format(task.archivedAt!);

    final card = Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: task.isCompleted,
              onChanged: task.isArchived
                  ? null
                  : (_) => _toggleCompleted(context, ref),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          task.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      PopupMenuButton<_TaskLifecycleAction>(
                        tooltip: 'Task actions',
                        onSelected: (action) =>
                            _handleLifecycleAction(context, ref, action),
                        itemBuilder: (context) {
                          if (task.isArchived) {
                            return const [
                              PopupMenuItem(
                                value: _TaskLifecycleAction.restore,
                                child: Text('Restore task'),
                              ),
                              PopupMenuItem(
                                value: _TaskLifecycleAction.delete,
                                child: Text('Delete permanently'),
                              ),
                            ];
                          }
                          return const [
                            PopupMenuItem(
                              value: _TaskLifecycleAction.softReset,
                              child: Text('Soft reset progress'),
                            ),
                            PopupMenuItem(
                              value: _TaskLifecycleAction.hardReset,
                              child: Text('Hard reset task'),
                            ),
                            PopupMenuItem(
                              value:
                                  _TaskLifecycleAction.resetGeneratedSessions,
                              child: Text('Clear generated sessions'),
                            ),
                            PopupMenuItem(
                              value: _TaskLifecycleAction.archive,
                              child: Text('Archive task'),
                            ),
                            PopupMenuItem(
                              value: _TaskLifecycleAction.delete,
                              child: Text('Delete permanently'),
                            ),
                          ];
                        },
                      ),
                    ],
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
                        label: task.isArchived
                            ? 'Archived'
                            : task.isCompleted
                            ? 'Completed'
                            : 'Incomplete',
                      ),
                      if (formattedDueDate != null)
                        _TaskMetaChip(label: 'Due $formattedDueDate'),
                      if (formattedArchivedDate != null)
                        _TaskMetaChip(label: 'Archived $formattedArchivedDate'),
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
    );

    if (task.isArchived) {
      return card;
    }

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
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => _deleteTask(context, ref),
      child: card,
    );
  }

  Future<void> _toggleCompleted(BuildContext context, WidgetRef ref) async {
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
              'The task completion state could not be updated safely.',
        );
      }
    }
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return AppConfirmationDialog.show(
      context,
      title: 'Delete task?',
      message:
          'Remove "${task.title}" permanently? This also removes linked sessions and dependency edges.',
      confirmLabel: 'Delete',
      destructive: true,
    );
  }

  Future<void> _deleteTask(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(taskActionControllerProvider.notifier).deleteTask(task.id);
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
  }

  Future<void> _handleLifecycleAction(
    BuildContext context,
    WidgetRef ref,
    _TaskLifecycleAction action,
  ) async {
    final controller = ref.read(taskActionControllerProvider.notifier);

    try {
      switch (action) {
        case _TaskLifecycleAction.softReset:
          final confirmed = await AppConfirmationDialog.show(
            context,
            title: 'Soft reset task?',
            message:
                'Mark "${task.title}" as incomplete and clear its future generated sessions? Completed session history will be kept.',
            confirmLabel: 'Soft reset',
            destructive: true,
          );
          if (confirmed != true) return;
          await controller.resetTask(task, mode: TaskResetMode.soft);
          break;
        case _TaskLifecycleAction.hardReset:
          final confirmed = await AppConfirmationDialog.show(
            context,
            title: 'Hard reset task?',
            message:
                'Reset "${task.title}" completely? All linked planned and completed sessions will be removed.',
            confirmLabel: 'Hard reset',
            destructive: true,
          );
          if (confirmed != true) return;
          await controller.resetTask(task, mode: TaskResetMode.hard);
          break;
        case _TaskLifecycleAction.resetGeneratedSessions:
          final confirmed = await AppConfirmationDialog.show(
            context,
            title: 'Clear generated sessions?',
            message:
                'Remove non-completed planned sessions for "${task.title}"? Completed session history will be kept.',
            confirmLabel: 'Clear sessions',
            destructive: true,
          );
          if (confirmed != true) return;
          await controller.resetGeneratedSessions(task);
          break;
        case _TaskLifecycleAction.archive:
          final confirmed = await AppConfirmationDialog.show(
            context,
            title: 'Archive task?',
            message:
                'Archive "${task.title}" and remove its non-completed scheduled sessions from active planning?',
            confirmLabel: 'Archive',
          );
          if (confirmed != true) return;
          await controller.archiveTask(task);
          break;
        case _TaskLifecycleAction.restore:
          await controller.restoreTask(task);
          break;
        case _TaskLifecycleAction.delete:
          final confirmed = await _confirmDelete(context);
          if (confirmed != true) return;
          await controller.deleteTask(task.id);
          break;
      }
    } catch (error) {
      if (context.mounted) {
        ErrorHandler.showSnackBar(
          context,
          error,
          fallbackTitle: 'Task action failed',
          fallbackMessage: 'The task lifecycle action could not be completed.',
        );
      }
    }
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
