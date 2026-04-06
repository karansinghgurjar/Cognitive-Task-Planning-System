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
import '../../quick_capture/presentation/quick_capture_inbox_screen.dart';
import '../../quick_capture/presentation/quick_capture_sheet.dart';
import '../../quick_capture/providers/quick_capture_providers.dart';
import '../domain/task_lifecycle_service.dart';
import '../models/task.dart';
import '../providers/task_providers.dart';
import 'add_task_screen.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  TaskListFilter _filter = TaskListFilter.active;

  @override
  Widget build(BuildContext context) {
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
                  data: (tasks) => _buildContent(
                    context,
                    padding,
                    tasks,
                    actionState.isLoading,
                  ),
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

  Widget _buildContent(
    BuildContext context,
    EdgeInsets padding,
    List<Task> tasks,
    bool actionsDisabled,
  ) {
    final activeTasks = tasks.where((task) => !task.isArchived).toList();
    final archivedTasks = tasks.where((task) => task.isArchived).toList();

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
        const SizedBox(height: 20),
        _TaskFilterBar(
          value: _filter,
          onChanged: (value) {
            setState(() {
              _filter = value;
            });
          },
        ),
        const SizedBox(height: 20),
        ...switch (_filter) {
          TaskListFilter.active => _buildSingleSection(
            label: 'Active Tasks',
            tasks: activeTasks,
            emptyState: const AppEmptyState(
              icon: Icons.assignment_turned_in_outlined,
              title: 'No active tasks',
              message:
                  'Your active list is clear. Restore an archived task or create a new one to keep planning.',
            ),
            actionsDisabled: actionsDisabled,
          ),
          TaskListFilter.archived => _buildSingleSection(
            label: 'Archived Tasks',
            tasks: archivedTasks,
            emptyState: const AppEmptyState(
              icon: Icons.archive_outlined,
              title: 'No archived tasks',
              message:
                  'Archived tasks appear only in this view. Restore them to make them active again, or delete them permanently if you no longer need the history.',
            ),
            actionsDisabled: actionsDisabled,
          ),
          TaskListFilter.all => _buildAllSections(
            activeTasks: activeTasks,
            archivedTasks: archivedTasks,
            actionsDisabled: actionsDisabled,
          ),
        },
      ],
    );
  }

  List<Widget> _buildSingleSection({
    required String label,
    required List<Task> tasks,
    required Widget emptyState,
    required bool actionsDisabled,
  }) {
    if (tasks.isEmpty) {
      return [emptyState];
    }

    return [
      _TaskSectionHeader(label: label),
      const SizedBox(height: 12),
      ..._buildTaskCards(tasks, actionsDisabled),
    ];
  }

  List<Widget> _buildAllSections({
    required List<Task> activeTasks,
    required List<Task> archivedTasks,
    required bool actionsDisabled,
  }) {
    final widgets = <Widget>[];

    widgets.addAll(
      _buildSingleSection(
        label: 'Active Tasks',
        tasks: activeTasks,
        emptyState: const AppEmptyState(
          icon: Icons.assignment_turned_in_outlined,
          title: 'No active tasks',
          message:
              'Your active list is clear. Restore an archived task or create a new one to keep planning.',
        ),
        actionsDisabled: actionsDisabled,
      ),
    );

    widgets.add(const SizedBox(height: 24));
    widgets.addAll(
      _buildSingleSection(
        label: 'Archived Tasks',
        tasks: archivedTasks,
        emptyState: const AppEmptyState(
          icon: Icons.archive_outlined,
          title: 'No archived tasks',
          message:
              'Archived tasks appear only in this combined view when they exist. Restore them to return them to normal planning.',
        ),
        actionsDisabled: actionsDisabled,
      ),
    );

    return widgets;
  }

  List<Widget> _buildTaskCards(List<Task> tasks, bool actionsDisabled) {
    return [
      for (var index = 0; index < tasks.length; index++) ...[
        _TaskCard(task: tasks[index], actionsDisabled: actionsDisabled),
        if (index < tasks.length - 1) const SizedBox(height: 12),
      ],
    ];
  }
}

class _TasksHeader extends ConsumerWidget {
  const _TasksHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inboxCount =
        ref.watch(unprocessedCaptureCountProvider).valueOrNull ?? 0;
    return AppSectionHeader(
      title: 'Tasks',
      description:
          'Track work, due dates, completion, and lifecycle actions without losing control of your schedule.',
      actions: [
        FilledButton.tonalIcon(
          onPressed: () => QuickCaptureSheet.show(context),
          icon: const Icon(Icons.bolt_rounded),
          label: const Text('Quick Capture'),
        ),
        FilledButton.tonalIcon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const QuickCaptureInboxScreen(),
              ),
            );
          },
          icon: const Icon(Icons.inbox_rounded),
          label: Text('Inbox ($inboxCount)'),
        ),
        IconButton(
          onPressed: () => AppRouter.openSettings(context),
          icon: const Icon(Icons.settings_outlined),
          tooltip: 'Settings',
        ),
      ],
    );
  }
}

enum TaskListFilter { active, archived, all }

class _TaskFilterBar extends StatelessWidget {
  const _TaskFilterBar({required this.value, required this.onChanged});

  final TaskListFilter value;
  final ValueChanged<TaskListFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          'View',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        SegmentedButton<TaskListFilter>(
          segments: const [
            ButtonSegment<TaskListFilter>(
              value: TaskListFilter.active,
              label: Text('Active'),
              icon: Icon(Icons.checklist_rtl_rounded),
            ),
            ButtonSegment<TaskListFilter>(
              value: TaskListFilter.archived,
              label: Text('Archived'),
              icon: Icon(Icons.archive_outlined),
            ),
            ButtonSegment<TaskListFilter>(
              value: TaskListFilter.all,
              label: Text('All'),
              icon: Icon(Icons.apps_rounded),
            ),
          ],
          selected: {value},
          onSelectionChanged: (selection) {
            if (selection.isNotEmpty) {
              onChanged(selection.first);
            }
          },
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

enum _TaskAction {
  edit,
  toggleCompleted,
  resetProgress,
  clearGeneratedSessions,
  archive,
  restore,
  delete,
}

class _TaskCard extends ConsumerWidget {
  const _TaskCard({required this.task, required this.actionsDisabled});

  final Task task;
  final bool actionsDisabled;

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
              onChanged: task.isArchived || actionsDisabled
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
                      PopupMenuButton<_TaskAction>(
                        tooltip: 'Task actions',
                        enabled: !actionsDisabled,
                        onSelected: (action) =>
                            _handleAction(context, ref, action),
                        itemBuilder: (context) {
                          if (task.isArchived) {
                            return const [
                              PopupMenuItem(
                                value: _TaskAction.edit,
                                child: Text('Edit'),
                              ),
                              PopupMenuItem(
                                value: _TaskAction.restore,
                                child: Text('Restore task'),
                              ),
                              PopupMenuItem(
                                value: _TaskAction.delete,
                                child: Text('Delete permanently'),
                              ),
                            ];
                          }
                          return [
                            const PopupMenuItem(
                              value: _TaskAction.edit,
                              child: Text('Edit'),
                            ),
                            PopupMenuItem(
                              value: _TaskAction.toggleCompleted,
                              child: Text(
                                task.isCompleted
                                    ? 'Mark incomplete'
                                    : 'Mark complete',
                              ),
                            ),
                            const PopupMenuItem(
                              value: _TaskAction.resetProgress,
                              child: Text('Reset progress'),
                            ),
                            const PopupMenuItem(
                              value: _TaskAction.clearGeneratedSessions,
                              child: Text('Clear generated sessions'),
                            ),
                            const PopupMenuItem(
                              value: _TaskAction.archive,
                              child: Text('Archive task'),
                            ),
                            const PopupMenuItem(
                              value: _TaskAction.delete,
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

    if (task.isArchived || actionsDisabled) {
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
      title: 'Delete this task permanently?',
      message:
          'This will remove linked sessions and dependency connections. This action cannot be undone.',
      confirmLabel: 'Delete permanently',
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

  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    _TaskAction action,
  ) async {
    final controller = ref.read(taskActionControllerProvider.notifier);

    try {
      switch (action) {
        case _TaskAction.edit:
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => AddTaskScreen(initialTask: task),
            ),
          );
          break;
        case _TaskAction.toggleCompleted:
          await controller.toggleCompleted(task);
          break;
        case _TaskAction.resetProgress:
          final resetMode = await _showResetDialog(context);
          if (resetMode == null) return;
          await controller.resetTask(task, mode: resetMode);
          break;
        case _TaskAction.clearGeneratedSessions:
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
        case _TaskAction.archive:
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
        case _TaskAction.restore:
          await controller.restoreTask(task);
          break;
        case _TaskAction.delete:
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

  Future<TaskResetMode?> _showResetDialog(BuildContext context) {
    return showDialog<TaskResetMode>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset task progress'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose how to reset "${task.title}". This affects task completion state and linked sessions.',
              ),
              const SizedBox(height: 16),
              _ResetOptionTile(
                title: 'Soft Reset',
                subtitle:
                    'Keep history, mark the task incomplete, and clear future generated sessions.',
                onTap: () => Navigator.of(context).pop(TaskResetMode.soft),
              ),
              const SizedBox(height: 12),
              _ResetOptionTile(
                title: 'Hard Reset',
                subtitle:
                    'Remove all linked sessions and progress for this task, then mark it incomplete.',
                destructive: true,
                onTap: () => Navigator.of(context).pop(TaskResetMode.hard),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}

class _ResetOptionTile extends StatelessWidget {
  const _ResetOptionTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.destructive = false,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderColor = destructive
        ? colorScheme.errorContainer
        : colorScheme.outlineVariant;
    final iconColor = destructive ? colorScheme.error : colorScheme.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              destructive
                  ? Icons.restart_alt_rounded
                  : Icons.history_toggle_off_rounded,
              color: iconColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle),
                ],
              ),
            ),
          ],
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
