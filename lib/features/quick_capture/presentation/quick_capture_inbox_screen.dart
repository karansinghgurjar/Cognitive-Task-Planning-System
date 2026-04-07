import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/errors/error_handler.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error_state.dart';
import '../../../core/widgets/app_status_chip.dart';
import '../../ai_planning/domain/ai_planning_models.dart';
import '../../ai_planning/presentation/ai_plan_generator_screen.dart';
import '../../goals/models/learning_goal.dart';
import '../../goals/presentation/add_goal_screen.dart';
import '../../goals/providers/goal_providers.dart';
import '../../tasks/models/task.dart';
import '../../tasks/presentation/add_task_screen.dart';
import '../../tasks/providers/task_providers.dart';
import '../models/quick_capture_item.dart';
import 'quick_capture_sheet.dart';
import '../providers/quick_capture_providers.dart';

enum QuickCaptureInboxFilter { unprocessed, all }

class QuickCaptureInboxScreen extends ConsumerStatefulWidget {
  const QuickCaptureInboxScreen({this.initialCaptureId, super.key});

  final String? initialCaptureId;

  @override
  ConsumerState<QuickCaptureInboxScreen> createState() =>
      _QuickCaptureInboxScreenState();
}

class _QuickCaptureInboxScreenState
    extends ConsumerState<QuickCaptureInboxScreen> {
  static const _uuid = Uuid();
  QuickCaptureInboxFilter _filter = QuickCaptureInboxFilter.unprocessed;
  String? _busyItemId;
  bool _isBulkActionRunning = false;

  @override
  Widget build(BuildContext context) {
    final capturesAsync = _filter == QuickCaptureInboxFilter.unprocessed
        ? ref.watch(watchUnprocessedCapturesProvider)
        : ref.watch(watchAllCapturesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Capture Inbox'),
        actions: [
          PopupMenuButton<_BulkInboxAction>(
            enabled:
                !_isBulkActionRunning &&
                _filter == QuickCaptureInboxFilter.unprocessed &&
                _noteCaptureCount(capturesAsync.valueOrNull ?? const []) > 0,
            tooltip: 'Bulk actions',
            onSelected: (action) => _handleBulkAction(
              capturesAsync.valueOrNull ?? const [],
              action,
            ),
            itemBuilder: (context) {
              final noteCount = _noteCaptureCount(
                capturesAsync.valueOrNull ?? const [],
              );
              return [
                PopupMenuItem(
                  value: _BulkInboxAction.markAllNotesProcessed,
                  child: Text(
                    noteCount > 0
                        ? 'Mark all notes as processed ($noteCount)'
                        : 'Mark all notes as processed',
                  ),
                ),
              ];
            },
            icon: _isBulkActionRunning
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : const Icon(Icons.done_all_rounded),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: SegmentedButton<QuickCaptureInboxFilter>(
              segments: const [
                ButtonSegment(
                  value: QuickCaptureInboxFilter.unprocessed,
                  label: Text('Inbox'),
                ),
                ButtonSegment(
                  value: QuickCaptureInboxFilter.all,
                  label: Text('All'),
                ),
              ],
              selected: {_filter},
              onSelectionChanged: (selection) {
                setState(() {
                  _filter = selection.first;
                });
              },
            ),
          ),
        ],
      ),
      body: capturesAsync.when(
        data: (captures) {
          if (captures.isEmpty) {
            return AppEmptyState(
              icon: Icons.inbox_rounded,
              title: _filter == QuickCaptureInboxFilter.unprocessed
                  ? 'Inbox is clear'
                  : 'No captured items yet',
              message: _filter == QuickCaptureInboxFilter.unprocessed
                  ? 'Use Quick Capture to dump ideas, tasks, and goals here for later processing.'
                  : 'Your captured items will appear here once you start using Quick Capture.',
              action: FilledButton.icon(
                onPressed: () => QuickCaptureSheet.show(context),
                icon: const Icon(Icons.bolt_rounded),
                label: const Text('Add first capture'),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: captures.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = captures[index];
              final isBusy = _busyItemId == item.id;
              return Card(
                color: widget.initialCaptureId == item.id
                    ? Theme.of(context).colorScheme.primaryContainer
                    : null,
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
                              item.rawText,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          PopupMenuButton<_CaptureMenuAction>(
                            enabled: !isBusy,
                            onSelected: (action) =>
                                _handleMenuAction(item, action),
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: _CaptureMenuAction.edit,
                                child: Text('Edit text'),
                              ),
                              if (!item.isProcessed)
                                const PopupMenuItem(
                                  value: _CaptureMenuAction.instantTask,
                                  child: Text('Create Task Instantly'),
                                ),
                              if (!item.isProcessed)
                                const PopupMenuItem(
                                  value: _CaptureMenuAction.instantGoal,
                                  child: Text('Create Goal Instantly'),
                                ),
                              if (!item.isProcessed)
                                const PopupMenuItem(
                                  value: _CaptureMenuAction.goalAndPlan,
                                  child: Text('Convert to Goal + Plan'),
                                ),
                              if (!item.isProcessed)
                                const PopupMenuItem(
                                  value: _CaptureMenuAction.markNote,
                                  child: Text('Mark as Note / Processed'),
                                ),
                              const PopupMenuItem(
                                value: _CaptureMenuAction.delete,
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          AppStatusChip(label: item.suggestedType.label),
                          AppStatusChip(
                            label: item.isProcessed
                                ? 'Processed'
                                : 'Unprocessed',
                            backgroundColor: item.isProcessed
                                ? Theme.of(
                                    context,
                                  ).colorScheme.tertiaryContainer
                                : Theme.of(
                                    context,
                                  ).colorScheme.secondaryContainer,
                            foregroundColor: item.isProcessed
                                ? Theme.of(
                                    context,
                                  ).colorScheme.onTertiaryContainer
                                : Theme.of(
                                    context,
                                  ).colorScheme.onSecondaryContainer,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Captured ${DateFormat.yMMMd().add_jm().format(item.createdAt)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (item.isProcessed &&
                          item.processedEntityType != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Processed as ${item.processedEntityType!.label}${item.linkedEntityId == null ? '' : ' (${item.linkedEntityId})'}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                      const SizedBox(height: 16),
                      if (!item.isProcessed)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            FilledButton.icon(
                              onPressed: isBusy
                                  ? null
                                  : () => _convertToTask(item),
                              icon: isBusy
                                  ? const SizedBox.square(
                                      dimension: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.checklist_rounded),
                              label: const Text('Convert to Task'),
                            ),
                            OutlinedButton.icon(
                              onPressed: isBusy
                                  ? null
                                  : () => _convertToGoal(item),
                              icon: const Icon(Icons.track_changes_rounded),
                              label: const Text('Convert to Goal'),
                            ),
                            OutlinedButton.icon(
                              onPressed: isBusy
                                  ? null
                                  : () => _convertToGoalAndGeneratePlan(item),
                              icon: const Icon(Icons.auto_awesome_rounded),
                              label: const Text('Goal + Plan'),
                            ),
                            TextButton.icon(
                              onPressed: isBusy
                                  ? null
                                  : () => _markAsNote(item),
                              icon: const Icon(Icons.note_alt_rounded),
                              label: const Text('Mark as Note'),
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
        error: (error, stackTrace) => AppErrorState(
          title: 'Inbox unavailable',
          message: 'Quick Capture items could not be loaded right now.',
          onRetry: () => setState(() {}),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Future<void> _handleMenuAction(
    QuickCaptureItem item,
    _CaptureMenuAction action,
  ) async {
    switch (action) {
      case _CaptureMenuAction.edit:
        await _editRawText(item);
        break;
      case _CaptureMenuAction.instantTask:
        await _createTaskInstantly(item);
        break;
      case _CaptureMenuAction.instantGoal:
        await _createGoalInstantly(item);
        break;
      case _CaptureMenuAction.goalAndPlan:
        await _convertToGoalAndGeneratePlan(item);
        break;
      case _CaptureMenuAction.markNote:
        await _markAsNote(item);
        break;
      case _CaptureMenuAction.delete:
        await _deleteCapture(item);
        break;
    }
  }

  Future<void> _handleBulkAction(
    List<QuickCaptureItem> captures,
    _BulkInboxAction action,
  ) async {
    switch (action) {
      case _BulkInboxAction.markAllNotesProcessed:
        await _markAllNotesAsProcessed(captures);
        break;
    }
  }

  Future<void> _convertToTask(QuickCaptureItem item) async {
    final parser = ref.read(quickCaptureParserServiceProvider);
    final draft =
        parser.toTaskDraft(item.rawText) ??
        TaskDraft(
          id: 'quick-capture-fallback',
          title: item.rawText.trim(),
          type: TaskType.misc,
          estimatedMinutes: 60,
          description: 'Created from Quick Capture.',
        );

    final taskId = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => AddTaskScreen(
          initialTitle: draft.title,
          initialDescription: draft.description,
          initialType: draft.type,
          initialEstimatedDurationMinutes: draft.estimatedMinutes,
          initialPriority: 3,
          initialDueDate: draft.dueDate,
        ),
      ),
    );

    if (taskId == null || !mounted) {
      return;
    }

    await _runItemAction(
      item.id,
      () async {
        await ref
            .read(quickCaptureActionControllerProvider.notifier)
            .markProcessed(
              item.id,
              linkedEntityId: taskId,
              processedEntityType: QuickCaptureProcessedEntityType.task,
            );
      },
      fallbackTitle: 'Task conversion failed',
      fallbackMessage:
          'The inbox item could not be linked to the created task.',
    );
  }

  Future<void> _convertToGoal(QuickCaptureItem item) async {
    final parser = ref.read(quickCaptureParserServiceProvider);
    final draft =
        parser.toGoalDraft(item.rawText) ??
        GoalDraft(
          title: item.rawText.trim(),
          goalType: _fallbackGoalType(item.suggestedType),
          priority: 3,
          description: 'Created from Quick Capture.',
          estimatedTotalMinutes: 480,
        );

    final goalId = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => AddGoalScreen(
          initialTitle: draft.title,
          initialDescription: draft.description,
          initialGoalType: draft.goalType,
          initialPriority: draft.priority,
          initialEstimatedMinutes: draft.estimatedTotalMinutes,
          initialTargetDate: draft.targetDate,
        ),
      ),
    );

    if (goalId == null || !mounted) {
      return;
    }

    await _runItemAction(
      item.id,
      () async {
        await ref
            .read(quickCaptureActionControllerProvider.notifier)
            .markProcessed(
              item.id,
              linkedEntityId: goalId,
              processedEntityType: QuickCaptureProcessedEntityType.goal,
            );
      },
      fallbackTitle: 'Goal conversion failed',
      fallbackMessage:
          'The inbox item could not be linked to the created goal.',
    );
  }

  Future<void> _createTaskInstantly(QuickCaptureItem item) async {
    final parser = ref.read(quickCaptureParserServiceProvider);
    final draft =
        parser.toTaskDraft(item.rawText) ??
        TaskDraft(
          id: 'quick-capture-fallback',
          title: item.rawText.trim(),
          type: TaskType.misc,
          estimatedMinutes: 60,
          description: 'Created from Quick Capture.',
        );

    await _runItemAction(
      item.id,
      () async {
        final now = DateTime.now();
        final task = Task(
          id: _uuid.v4(),
          title: draft.title,
          description: draft.description,
          type: draft.type,
          estimatedDurationMinutes: draft.estimatedMinutes,
          dueDate: draft.dueDate,
          priority: 3,
          createdAt: now,
          updatedAt: now,
        );
        await ref.read(taskActionControllerProvider.notifier).addTask(task);
        await ref
            .read(quickCaptureActionControllerProvider.notifier)
            .markProcessed(
              item.id,
              linkedEntityId: task.id,
              processedEntityType: QuickCaptureProcessedEntityType.task,
            );
      },
      fallbackTitle: 'Instant task creation failed',
      fallbackMessage:
          'The capture could not be converted into a task instantly.',
    );
  }

  Future<void> _createGoalInstantly(QuickCaptureItem item) async {
    final parser = ref.read(quickCaptureParserServiceProvider);
    final draft =
        parser.toGoalDraft(item.rawText) ??
        GoalDraft(
          title: item.rawText.trim(),
          goalType: _fallbackGoalType(item.suggestedType),
          priority: 3,
          description: 'Created from Quick Capture.',
          estimatedTotalMinutes: 480,
        );

    await _runItemAction(
      item.id,
      () async {
        final goal = LearningGoal(
          id: _uuid.v4(),
          title: draft.title,
          description: draft.description,
          goalType: draft.goalType,
          targetDate: draft.targetDate,
          priority: draft.priority,
          status: GoalStatus.active,
          estimatedTotalMinutes: draft.estimatedTotalMinutes,
          createdAt: DateTime.now(),
        );
        await ref.read(goalActionControllerProvider.notifier).addGoal(goal);
        await ref
            .read(quickCaptureActionControllerProvider.notifier)
            .markProcessed(
              item.id,
              linkedEntityId: goal.id,
              processedEntityType: QuickCaptureProcessedEntityType.goal,
            );
      },
      fallbackTitle: 'Instant goal creation failed',
      fallbackMessage:
          'The capture could not be converted into a goal instantly.',
    );
  }

  Future<void> _convertToGoalAndGeneratePlan(QuickCaptureItem item) async {
    final goalId = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => AiPlanGeneratorScreen(
          initialPrompt: item.rawText,
          title: 'Convert to Goal and Generate Plan',
        ),
      ),
    );

    if (goalId == null || !mounted) {
      return;
    }

    await _runItemAction(
      item.id,
      () async {
        await ref
            .read(quickCaptureActionControllerProvider.notifier)
            .markProcessed(
              item.id,
              linkedEntityId: goalId,
              processedEntityType: QuickCaptureProcessedEntityType.goal,
            );
      },
      fallbackTitle: 'Goal planning failed',
      fallbackMessage:
          'The capture could not be linked to the generated goal plan.',
    );
  }

  Future<void> _markAsNote(QuickCaptureItem item) async {
    await _runItemAction(
      item.id,
      () async {
        await ref
            .read(quickCaptureActionControllerProvider.notifier)
            .markProcessed(
              item.id,
              processedEntityType: QuickCaptureProcessedEntityType.note,
            );
      },
      fallbackTitle: 'Inbox update failed',
      fallbackMessage: 'The capture could not be marked as processed.',
    );
  }

  Future<void> _markAllNotesAsProcessed(List<QuickCaptureItem> captures) async {
    final noteIds = captures
        .where(
          (item) =>
              !item.isProcessed &&
              !item.isArchived &&
              item.suggestedType == QuickCaptureSuggestedType.note,
        )
        .map((item) => item.id)
        .toList();

    if (noteIds.isEmpty) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No note captures are waiting in Inbox.')),
      );
      return;
    }

    setState(() {
      _isBulkActionRunning = true;
    });
    try {
      final processedCount = await ref
          .read(quickCaptureActionControllerProvider.notifier)
          .markProcessedBatch(
            noteIds,
            processedEntityType: QuickCaptureProcessedEntityType.note,
          );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            processedCount == 1
                ? '1 note was marked as processed.'
                : '$processedCount notes were marked as processed.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ErrorHandler.showSnackBar(
        context,
        error,
        fallbackTitle: 'Bulk inbox update failed',
        fallbackMessage: 'The note captures could not be marked as processed.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isBulkActionRunning = false;
        });
      }
    }
  }

  Future<void> _editRawText(QuickCaptureItem item) async {
    final controller = TextEditingController(text: item.rawText);
    final updatedText = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Capture'),
          content: TextField(
            controller: controller,
            minLines: 3,
            maxLines: 5,
            autofocus: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Update the captured text',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(controller.text.trim()),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.dispose();
    });

    if (updatedText == null || updatedText.isEmpty || !mounted) {
      return;
    }

    await _runItemAction(
      item.id,
      () async {
        await ref
            .read(quickCaptureActionControllerProvider.notifier)
            .updateCapture(item.copyWith(rawText: updatedText));
      },
      fallbackTitle: 'Capture update failed',
      fallbackMessage: 'The captured text could not be updated.',
    );
  }

  Future<void> _deleteCapture(QuickCaptureItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete capture?'),
          content: const Text(
            'This will remove the captured item from the inbox permanently.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(dialogContext).colorScheme.error,
                foregroundColor: Theme.of(dialogContext).colorScheme.onError,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    await _runItemAction(
      item.id,
      () async {
        await ref
            .read(quickCaptureActionControllerProvider.notifier)
            .deleteCapture(item.id);
      },
      fallbackTitle: 'Delete failed',
      fallbackMessage: 'The capture could not be deleted.',
    );
  }

  Future<void> _runItemAction(
    String itemId,
    Future<void> Function() action, {
    required String fallbackTitle,
    required String fallbackMessage,
  }) async {
    setState(() {
      _busyItemId = itemId;
    });
    try {
      await action();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ErrorHandler.showSnackBar(
        context,
        error,
        fallbackTitle: fallbackTitle,
        fallbackMessage: fallbackMessage,
      );
    } finally {
      if (mounted) {
        setState(() {
          _busyItemId = null;
        });
      }
    }
  }

  GoalType _fallbackGoalType(QuickCaptureSuggestedType suggestedType) {
    switch (suggestedType) {
      case QuickCaptureSuggestedType.goal:
        return GoalType.learning;
      case QuickCaptureSuggestedType.task:
      case QuickCaptureSuggestedType.note:
      case QuickCaptureSuggestedType.unknown:
        return GoalType.learning;
    }
  }

  int _noteCaptureCount(List<QuickCaptureItem> captures) {
    return captures
        .where(
          (item) =>
              !item.isProcessed &&
              !item.isArchived &&
              item.suggestedType == QuickCaptureSuggestedType.note,
        )
        .length;
  }
}

enum _CaptureMenuAction {
  edit,
  instantTask,
  instantGoal,
  goalAndPlan,
  markNote,
  delete,
}

enum _BulkInboxAction { markAllNotesProcessed }
