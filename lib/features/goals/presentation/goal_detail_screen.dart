import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../core/errors/error_handler.dart';
import '../../ai_planning/presentation/ai_plan_generator_screen.dart';
import '../../recommendations/domain/recommendation_models.dart';
import '../../recommendations/providers/recommendation_providers.dart';
import '../../schedule/models/planned_session.dart';
import '../../schedule/providers/schedule_providers.dart';
import '../../tasks/models/task.dart';
import '../../tasks/providers/task_providers.dart';
import '../models/goal_milestone.dart';
import '../models/learning_goal.dart';
import '../providers/goal_providers.dart';

class GoalDetailScreen extends ConsumerStatefulWidget {
  const GoalDetailScreen({required this.goalId, super.key});

  final String goalId;

  @override
  ConsumerState<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends ConsumerState<GoalDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final goalsAsync = ref.watch(watchGoalsProvider);
    final milestonesAsync = ref.watch(
      watchMilestonesForGoalProvider(widget.goalId),
    );
    final tasksAsync = ref.watch(watchTasksProvider);
    final sessionsAsync = ref.watch(watchAllSessionsProvider);
    final goalFeasibilityAsync = ref.watch(
      goalFeasibilityReportProvider(widget.goalId),
    );
    final actionState = ref.watch(goalActionControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Goal Detail'),
        actions: [
          IconButton(
            onPressed: () => _openAiPlanner(),
            icon: const Icon(Icons.auto_awesome_rounded),
            tooltip: 'Suggest milestones and tasks',
          ),
          IconButton(
            onPressed: actionState.isLoading ? null : _generateTasks,
            icon: const Icon(Icons.auto_fix_high_rounded),
            tooltip: 'Generate tasks',
          ),
          IconButton(
            onPressed: actionState.isLoading
                ? null
                : () => _openMilestoneDialog(),
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add milestone',
          ),
        ],
      ),
      body: switch ((goalsAsync, milestonesAsync, tasksAsync, sessionsAsync)) {
        (
          AsyncData(value: final goals),
          AsyncData(value: final milestones),
          AsyncData(value: final tasks),
          AsyncData(value: final sessions),
        ) =>
          _buildContent(
            context: context,
            goal: _findGoal(goals),
            milestones: milestones,
            tasks: tasks.where((task) => task.goalId == widget.goalId).toList(),
            sessions: sessions,
            goalFeasibilityAsync: goalFeasibilityAsync,
          ),
        (AsyncError(:final error), _, _, _) => _GoalDetailStateMessage(
          icon: Icons.error_outline_rounded,
          title: 'Could not load goal',
          message: ErrorHandler.mapError(error).message,
        ),
        (_, AsyncError(:final error), _, _) => _GoalDetailStateMessage(
          icon: Icons.error_outline_rounded,
          title: 'Could not load milestones',
          message: ErrorHandler.mapError(error).message,
        ),
        (_, _, AsyncError(:final error), _) => _GoalDetailStateMessage(
          icon: Icons.error_outline_rounded,
          title: 'Could not load tasks',
          message: ErrorHandler.mapError(error).message,
        ),
        (_, _, _, AsyncError(:final error)) => _GoalDetailStateMessage(
          icon: Icons.error_outline_rounded,
          title: 'Could not load progress',
          message: ErrorHandler.mapError(error).message,
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  Widget _buildContent({
    required BuildContext context,
    required LearningGoal? goal,
    required List<GoalMilestone> milestones,
    required List<Task> tasks,
    required List<PlannedSession> sessions,
    required AsyncValue<GoalFeasibilityReport?> goalFeasibilityAsync,
  }) {
    if (goal == null) {
      return const _GoalDetailStateMessage(
        icon: Icons.track_changes_rounded,
        title: 'Goal not found',
        message: 'This goal no longer exists.',
      );
    }

    final progress = ref
        .read(goalProgressServiceProvider)
        .computeGoalProgress(
          goal: goal,
          milestones: milestones,
          tasks: tasks,
          sessions: sessions,
        );
    final targetDateLabel = goal.targetDate == null
        ? 'No target date'
        : DateFormat.yMMMd().format(goal.targetDate!);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _DetailChip(label: goal.goalType.label),
                    _DetailChip(label: goal.status.label),
                    _DetailChip(label: 'Priority ${goal.priority}'),
                    _DetailChip(label: targetDateLabel),
                    if (goal.estimatedTotalMinutes != null)
                      _DetailChip(
                        label: '${goal.estimatedTotalMinutes} total min',
                      ),
                  ],
                ),
                if (goal.description != null &&
                    goal.description!.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(goal.description!),
                ],
                const SizedBox(height: 16),
                LinearProgressIndicator(value: progress.percentComplete),
                const SizedBox(height: 8),
                Text(
                  '${(progress.percentComplete * 100).round()}% complete - '
                  '${progress.completedLinkedTasks}/${progress.totalLinkedTasks} tasks and '
                  '${progress.completedMilestones}/${progress.totalMilestones} milestones',
                ),
                const SizedBox(height: 8),
                Text(
                  '${progress.totalCompletedMinutes}/${progress.totalPlannedMinutes} min completed',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _GoalFeasibilityCard(feasibilityAsync: goalFeasibilityAsync),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Text(
                'Milestones',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            FilledButton.tonalIcon(
              onPressed: _openMilestoneDialog,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Milestone'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (milestones.isEmpty)
          const _GoalDetailStateMessage(
            icon: Icons.timeline_rounded,
            title: 'No milestones yet',
            message:
                'Add milestones to break the goal into smaller executable chunks.',
          )
        else
          ...milestones.map(
            (milestone) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _MilestoneCard(
                milestone: milestone,
                onToggleCompleted: () => _toggleMilestoneCompleted(milestone),
                onEdit: () => _openMilestoneDialog(milestone: milestone),
                onDelete: () => _deleteMilestone(milestone),
              ),
            ),
          ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Text(
                'Linked Tasks',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            FilledButton.icon(
              onPressed: _generateTasks,
              icon: const Icon(Icons.auto_awesome_rounded),
              label: const Text('Generate Tasks'),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: _openAiPlanner,
              icon: const Icon(Icons.psychology_alt_rounded),
              label: const Text('Suggest with AI'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (tasks.isEmpty)
          const _GoalDetailStateMessage(
            icon: Icons.checklist_rounded,
            title: 'No linked tasks yet',
            message:
                'Use Generate Tasks to turn this goal and its milestones into executable work.',
          )
        else
          ...tasks.map(
            (task) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _LinkedTaskCard(task: task),
            ),
          ),
      ],
    );
  }

  LearningGoal? _findGoal(List<LearningGoal> goals) {
    for (final goal in goals) {
      if (goal.id == widget.goalId) {
        return goal;
      }
    }
    return null;
  }

  Future<void> _openAiPlanner() async {
    final goals = await ref.read(watchGoalsProvider.future);
    final goal = _findGoal(goals);
    if (goal == null || !mounted) {
      return;
    }

    final prompt = [
      goal.title,
      if (goal.description != null && goal.description!.trim().isNotEmpty)
        goal.description!,
    ].join(' ');

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AiPlanGeneratorScreen(
          existingGoalId: goal.id,
          initialPrompt: prompt,
          initialTargetDate: goal.targetDate,
          initialPriority: goal.priority,
          title: 'Suggest Milestones and Tasks',
        ),
      ),
    );
  }

  Future<void> _generateTasks() async {
    try {
      final goals = await ref.read(watchGoalsProvider.future);
      final goal = _findGoal(goals);
      if (goal == null) {
        return;
      }

      final createdCount = await ref
          .read(goalActionControllerProvider.notifier)
          .generateTasksForGoal(goal);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            createdCount == 0
                ? 'No new tasks were generated. Existing linked tasks already cover this goal.'
                : 'Generated $createdCount linked tasks.',
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
        fallbackTitle: 'Task generation failed',
        fallbackMessage: 'Linked tasks could not be generated for this goal.',
      );
    }
  }

  Future<void> _openMilestoneDialog({GoalMilestone? milestone}) async {
    final draft = await showDialog<_MilestoneDraft>(
      context: context,
      builder: (context) => _MilestoneDialog(initialMilestone: milestone),
    );
    if (draft == null) {
      return;
    }

    final now = DateTime.now();
    final value =
        milestone?.copyWith(
          title: draft.title,
          description: draft.description,
          clearDescription: draft.description == null,
          sequenceOrder: draft.sequenceOrder,
          estimatedMinutes: draft.estimatedMinutes,
        ) ??
        GoalMilestone(
          id: const Uuid().v4(),
          goalId: widget.goalId,
          title: draft.title,
          description: draft.description,
          sequenceOrder: draft.sequenceOrder,
          estimatedMinutes: draft.estimatedMinutes,
          createdAt: now,
          completedAt: null,
        );

    try {
      final controller = ref.read(goalActionControllerProvider.notifier);
      if (milestone == null) {
        await controller.addMilestone(value);
      } else {
        await controller.updateMilestone(value);
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      ErrorHandler.showSnackBar(
        context,
        error,
        fallbackTitle: 'Milestone save failed',
        fallbackMessage: 'The milestone could not be saved.',
      );
    }
  }

  Future<void> _toggleMilestoneCompleted(GoalMilestone milestone) async {
    try {
      await ref
          .read(goalActionControllerProvider.notifier)
          .toggleMilestoneCompleted(milestone);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ErrorHandler.showSnackBar(
        context,
        error,
        fallbackTitle: 'Milestone update failed',
        fallbackMessage: 'The milestone state could not be updated.',
      );
    }
  }

  Future<void> _deleteMilestone(GoalMilestone milestone) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete milestone?'),
          content: Text('Remove "${milestone.title}" from this goal?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await ref
          .read(goalActionControllerProvider.notifier)
          .deleteMilestone(milestone.id);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ErrorHandler.showSnackBar(
        context,
        error,
        fallbackTitle: 'Milestone delete failed',
        fallbackMessage: 'The milestone could not be deleted.',
      );
    }
  }
}

class _MilestoneCard extends StatelessWidget {
  const _MilestoneCard({
    required this.milestone,
    required this.onToggleCompleted,
    required this.onEdit,
    required this.onDelete,
  });

  final GoalMilestone milestone;
  final VoidCallback onToggleCompleted;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: milestone.isCompleted,
              onChanged: (_) => onToggleCompleted(),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    milestone.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      decoration: milestone.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _DetailChip(label: 'Step ${milestone.sequenceOrder}'),
                      _DetailChip(label: '${milestone.estimatedMinutes} min'),
                    ],
                  ),
                  if (milestone.description != null &&
                      milestone.description!.trim().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(milestone.description!),
                  ],
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit();
                } else if (value == 'delete') {
                  onDelete();
                }
              },
              itemBuilder: (context) {
                return const [
                  PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
                  PopupMenuItem<String>(value: 'delete', child: Text('Delete')),
                ];
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LinkedTaskCard extends StatelessWidget {
  const _LinkedTaskCard({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                _DetailChip(label: task.type.label),
                _DetailChip(label: '${task.estimatedDurationMinutes} min'),
                _DetailChip(label: task.isCompleted ? 'Completed' : 'Open'),
                if (task.milestoneId != null)
                  const _DetailChip(label: 'Milestone Task'),
                if (task.dueDate != null)
                  _DetailChip(
                    label: 'Due ${DateFormat.yMMMd().format(task.dueDate!)}',
                  ),
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
    );
  }
}

class _GoalFeasibilityCard extends StatelessWidget {
  const _GoalFeasibilityCard({required this.feasibilityAsync});

  final AsyncValue<GoalFeasibilityReport?> feasibilityAsync;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: feasibilityAsync.when(
          data: (report) {
            if (report == null) {
              return const Text(
                'Feasibility data is not available for this goal yet.',
              );
            }

            final targetDateLabel = report.targetDate == null
                ? 'No target date'
                : DateFormat.yMMMd().format(report.targetDate!);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Feasibility',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    _GoalRiskBadge(level: report.riskLevel),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Target: $targetDateLabel'),
                Text(
                  'Estimated remaining: ${_hours(report.remainingRequiredMinutes)}',
                ),
                Text(
                  'Available until target: ${_hours(report.availableMinutesUntilTarget)}',
                ),
                if (report.shortfallMinutes > 0)
                  Text('Shortfall: ${_hours(report.shortfallMinutes)}'),
                const SizedBox(height: 8),
                Text(report.summary),
                const SizedBox(height: 8),
                Text(report.suggestedActionText),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Text('Could not compute feasibility: $error'),
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelLarge),
    );
  }
}

class _GoalRiskBadge extends StatelessWidget {
  const _GoalRiskBadge({required this.level});

  final DeadlineRiskLevel level;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final (background, foreground) = switch (level) {
      DeadlineRiskLevel.low => (
        colorScheme.secondaryContainer,
        colorScheme.onSecondaryContainer,
      ),
      DeadlineRiskLevel.medium => (
        colorScheme.tertiaryContainer,
        colorScheme.onTertiaryContainer,
      ),
      DeadlineRiskLevel.high => (
        colorScheme.errorContainer,
        colorScheme.onErrorContainer,
      ),
      DeadlineRiskLevel.critical => (colorScheme.error, colorScheme.onError),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        level.label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _GoalDetailStateMessage extends StatelessWidget {
  const _GoalDetailStateMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 52),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MilestoneDraft {
  const _MilestoneDraft({
    required this.title,
    required this.description,
    required this.sequenceOrder,
    required this.estimatedMinutes,
  });

  final String title;
  final String? description;
  final int sequenceOrder;
  final int estimatedMinutes;
}

class _MilestoneDialog extends StatefulWidget {
  const _MilestoneDialog({this.initialMilestone});

  final GoalMilestone? initialMilestone;

  @override
  State<_MilestoneDialog> createState() => _MilestoneDialogState();
}

class _MilestoneDialogState extends State<_MilestoneDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _sequenceController;
  late final TextEditingController _estimatedMinutesController;

  @override
  void initState() {
    super.initState();
    final milestone = widget.initialMilestone;
    _titleController = TextEditingController(text: milestone?.title ?? '');
    _descriptionController = TextEditingController(
      text: milestone?.description ?? '',
    );
    _sequenceController = TextEditingController(
      text: milestone == null ? '' : milestone.sequenceOrder.toString(),
    );
    _estimatedMinutesController = TextEditingController(
      text: milestone == null ? '' : milestone.estimatedMinutes.toString(),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _sequenceController.dispose();
    _estimatedMinutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.initialMilestone == null ? 'Add Milestone' : 'Edit Milestone',
      ),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _sequenceController,
                decoration: const InputDecoration(labelText: 'Sequence order'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final parsed = int.tryParse(value ?? '');
                  if (parsed == null || parsed < 0) {
                    return 'Enter a valid sequence number.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _estimatedMinutesController,
                decoration: const InputDecoration(
                  labelText: 'Estimated minutes',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final parsed = int.tryParse(value ?? '');
                  if (parsed == null || parsed <= 0) {
                    return 'Enter a positive number of minutes.';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }

  void _save() {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    Navigator.of(context).pop(
      _MilestoneDraft(
        title: _titleController.text.trim(),
        description: _normalizeOptionalText(_descriptionController.text),
        sequenceOrder: int.parse(_sequenceController.text),
        estimatedMinutes: int.parse(_estimatedMinutesController.text),
      ),
    );
  }

  String? _normalizeOptionalText(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

String _hours(int minutes) {
  return '${(minutes / 60).toStringAsFixed(1)}h';
}
