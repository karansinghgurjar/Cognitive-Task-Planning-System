import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../goals/models/learning_goal.dart';
import '../../recommendations/domain/recommendation_models.dart';
import '../../tasks/models/task.dart';
import '../domain/ai_planning_models.dart';
import '../providers/ai_planning_providers.dart';

class AiPlanPreviewScreen extends ConsumerStatefulWidget {
  const AiPlanPreviewScreen({
    required this.initialPreview,
    super.key,
    this.existingGoalId,
  });

  final AiPlanPreview initialPreview;
  final String? existingGoalId;

  @override
  ConsumerState<AiPlanPreviewScreen> createState() =>
      _AiPlanPreviewScreenState();
}

class _AiPlanPreviewScreenState extends ConsumerState<AiPlanPreviewScreen> {
  late GoalDraft _goal;
  late List<MilestoneDraft> _milestones;
  late List<TaskDraft> _tasks;
  late List<DependencyDraft> _dependencies;
  late List<AiPlanningWarning> _warnings;
  late List<PlanningSuggestion> _suggestions;
  bool _isImporting = false;

  @override
  void initState() {
    super.initState();
    final result = widget.initialPreview.result;
    _goal = result.goal;
    _milestones = List<MilestoneDraft>.from(result.milestones);
    _tasks = List<TaskDraft>.from(result.tasks);
    _dependencies = List<DependencyDraft>.from(result.dependencies);
    _warnings = List<AiPlanningWarning>.from(result.warnings);
    _suggestions = List<PlanningSuggestion>.from(result.suggestions);
  }

  @override
  Widget build(BuildContext context) {
    final totalMinutes = _tasks.fold<int>(
      0,
      (sum, task) => sum + task.estimatedMinutes,
    );
    final recommendedWeeklyMinutes =
        widget.initialPreview.recommendedWeeklyMinutes;
    final availableWeeklyMinutes = widget.initialPreview.availableWeeklyMinutes;
    final riskLevel = _riskLevel(
      totalMinutes,
      recommendedWeeklyMinutes,
      availableWeeklyMinutes,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Plan Preview')),
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
                    'Inferred Goal',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: _goal.title,
                    decoration: const InputDecoration(labelText: 'Goal title'),
                    onChanged: (value) {
                      _goal = _goal.copyWith(title: value.trim());
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _goal.reasoning ??
                        widget.initialPreview.result.explanationSummary,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _PreviewChip(label: _goal.goalType.label),
                      _PreviewChip(label: 'Priority ${_goal.priority}'),
                      _PreviewChip(
                        label:
                            '${(totalMinutes / 60).toStringAsFixed(1)} total h',
                      ),
                      _PreviewChip(
                        label:
                            '${(recommendedWeeklyMinutes / 60).toStringAsFixed(1)} h/week target',
                      ),
                      _PreviewChip(
                        label:
                            'Available ${(availableWeeklyMinutes / 60).toStringAsFixed(1)} h/week',
                      ),
                      _RiskChip(level: riskLevel),
                    ],
                  ),
                  if (_goal.targetDate != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Target date: ${DateFormat.yMMMd().format(_goal.targetDate!)}',
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Warnings',
            child: _warnings.isEmpty
                ? const Text('No immediate warnings for this draft.')
                : Column(
                    children: _warnings
                        .map(
                          (warning) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(warning.message),
                              subtitle: warning.reasoning == null
                                  ? null
                                  : Text(warning.reasoning!),
                              leading: Icon(_warningIcon(warning.severity)),
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Milestones',
            action: TextButton.icon(
              onPressed: _addMilestone,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add'),
            ),
            child: _milestones.isEmpty
                ? const Text('No milestones remain in this plan.')
                : Column(
                    children: _milestones
                        .map(
                          (milestone) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Card.outlined(
                              child: ListTile(
                                title: Text(milestone.title),
                                subtitle: Text(
                                  '${milestone.estimatedMinutes} min\n${milestone.reasoning ?? 'Milestone generated from the prompt.'}',
                                ),
                                isThreeLine: true,
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _editMilestone(milestone);
                                    } else if (value == 'delete') {
                                      _removeMilestone(milestone.id);
                                    }
                                  },
                                  itemBuilder: (context) => const [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Text('Edit'),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Remove'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Tasks',
            action: TextButton.icon(
              onPressed: _addTask,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add'),
            ),
            child: _tasks.isEmpty
                ? const Text('No tasks remain in this plan.')
                : Column(
                    children: _tasks
                        .map(
                          (task) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Card.outlined(
                              child: ListTile(
                                title: Text(task.title),
                                subtitle: Text(
                                  '${task.type.label} - ${task.estimatedMinutes} min${task.milestoneDraftId == null ? '' : ' - milestone task'}\n${task.reasoning ?? 'Generated from the roadmap template.'}',
                                ),
                                isThreeLine: true,
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _editTask(task);
                                    } else if (value == 'delete') {
                                      _removeTask(task.id);
                                    }
                                  },
                                  itemBuilder: (context) => const [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Text('Edit'),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Remove'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Dependencies',
            child: _dependencies.isEmpty
                ? const Text('No explicit dependencies were suggested.')
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _dependencies
                        .map(
                          (dependency) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(_dependencyLabel(dependency)),
                          ),
                        )
                        .toList(),
                  ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Suggested workflow',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _suggestions
                  .map(
                    (suggestion) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            suggestion.title,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(suggestion.description),
                          const SizedBox(height: 2),
                          Text(
                            suggestion.suggestedActionText,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _isImporting ? null : _importPlan,
            icon: _isImporting
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download_done_rounded),
            label: Text(
              _isImporting
                  ? 'Importing...'
                  : widget.existingGoalId == null
                  ? 'Create Goal and Tasks'
                  : 'Import Suggestions',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addMilestone() async {
    final milestone = await showDialog<MilestoneDraft>(
      context: context,
      builder: (context) => _MilestoneEditorDialog(
        initial: MilestoneDraft(
          id: 'milestone-${DateTime.now().microsecondsSinceEpoch}',
          title: '',
          sequenceOrder: _milestones.length + 1,
          estimatedMinutes: 120,
        ),
      ),
    );
    if (milestone == null) {
      return;
    }
    setState(() {
      _milestones = [..._milestones, milestone];
    });
  }

  Future<void> _editMilestone(MilestoneDraft milestone) async {
    final updated = await showDialog<MilestoneDraft>(
      context: context,
      builder: (context) => _MilestoneEditorDialog(initial: milestone),
    );
    if (updated == null) {
      return;
    }
    setState(() {
      _milestones = _milestones
          .map((item) => item.id == updated.id ? updated : item)
          .toList();
    });
  }

  void _removeMilestone(String milestoneId) {
    setState(() {
      final removedTaskIds = _tasks
          .where((task) => task.milestoneDraftId == milestoneId)
          .map((task) => task.id)
          .toSet();
      _milestones = _milestones
          .where((item) => item.id != milestoneId)
          .toList();
      _tasks = _tasks
          .where((task) => task.milestoneDraftId != milestoneId)
          .toList();
      _dependencies = _dependencies
          .where(
            (dependency) =>
                !removedTaskIds.contains(dependency.taskDraftId) &&
                !removedTaskIds.contains(dependency.dependsOnTaskDraftId),
          )
          .toList();
    });
  }

  Future<void> _addTask() async {
    final task = await showDialog<TaskDraft>(
      context: context,
      builder: (context) => _TaskEditorDialog(
        initial: TaskDraft(
          id: 'task-${DateTime.now().microsecondsSinceEpoch}',
          title: '',
          type: TaskType.study,
          estimatedMinutes: 60,
          milestoneDraftId: _milestones.isEmpty ? null : _milestones.first.id,
        ),
        milestones: _milestones,
      ),
    );
    if (task == null) {
      return;
    }
    setState(() {
      _tasks = [..._tasks, task];
    });
  }

  Future<void> _editTask(TaskDraft task) async {
    final updated = await showDialog<TaskDraft>(
      context: context,
      builder: (context) =>
          _TaskEditorDialog(initial: task, milestones: _milestones),
    );
    if (updated == null) {
      return;
    }
    setState(() {
      _tasks = _tasks
          .map((item) => item.id == updated.id ? updated : item)
          .toList();
    });
  }

  void _removeTask(String taskId) {
    setState(() {
      _tasks = _tasks.where((task) => task.id != taskId).toList();
      _dependencies = _dependencies
          .where(
            (dependency) =>
                dependency.taskDraftId != taskId &&
                dependency.dependsOnTaskDraftId != taskId,
          )
          .toList();
    });
  }

  Future<void> _importPlan() async {
    setState(() {
      _isImporting = true;
    });

    final result = widget.initialPreview.result.copyWith(
      goal: _goal.copyWith(
        estimatedTotalMinutes: _tasks.fold<int>(
          0,
          (sum, task) => sum + task.estimatedMinutes,
        ),
      ),
      milestones: _milestones,
      tasks: _tasks,
      dependencies: _dependencies,
      warnings: _warnings,
      suggestions: _suggestions,
    );

    try {
      await ref
          .read(aiPlanningControllerProvider.notifier)
          .importPlan(result, existingGoalId: widget.existingGoalId);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.existingGoalId == null
                ? 'AI plan imported into goals and tasks.'
                : 'AI suggestions imported into the existing goal.',
          ),
        ),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not import plan: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
    }
  }

  String _dependencyLabel(DependencyDraft dependency) {
    final task = _taskById(dependency.taskDraftId);
    final blockedBy = _taskById(dependency.dependsOnTaskDraftId);
    final taskTitle = task?.title ?? dependency.taskDraftId;
    final blockedByTitle = blockedBy?.title ?? dependency.dependsOnTaskDraftId;
    return '$taskTitle depends on $blockedByTitle. ${dependency.reason}';
  }

  TaskDraft? _taskById(String id) {
    for (final task in _tasks) {
      if (task.id == id) {
        return task;
      }
    }
    return null;
  }

  DeadlineRiskLevel _riskLevel(
    int totalMinutes,
    int recommendedWeeklyMinutes,
    int availableWeeklyMinutes,
  ) {
    if (_goal.targetDate == null || availableWeeklyMinutes <= 0) {
      return DeadlineRiskLevel.low;
    }
    if (recommendedWeeklyMinutes > availableWeeklyMinutes * 1.5) {
      return DeadlineRiskLevel.critical;
    }
    if (recommendedWeeklyMinutes > availableWeeklyMinutes) {
      return DeadlineRiskLevel.high;
    }
    if (totalMinutes > availableWeeklyMinutes * 2) {
      return DeadlineRiskLevel.medium;
    }
    return DeadlineRiskLevel.low;
  }

  IconData _warningIcon(AiWarningSeverity severity) {
    switch (severity) {
      case AiWarningSeverity.info:
        return Icons.info_outline_rounded;
      case AiWarningSeverity.caution:
        return Icons.warning_amber_rounded;
      case AiWarningSeverity.high:
        return Icons.priority_high_rounded;
    }
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child, this.action});

  final String title;
  final Widget child;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                ...?(action == null ? null : [action!]),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _PreviewChip extends StatelessWidget {
  const _PreviewChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label),
    );
  }
}

class _RiskChip extends StatelessWidget {
  const _RiskChip({required this.level});

  final DeadlineRiskLevel level;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final background = switch (level) {
      DeadlineRiskLevel.low => colorScheme.secondaryContainer,
      DeadlineRiskLevel.medium => colorScheme.tertiaryContainer,
      DeadlineRiskLevel.high => colorScheme.errorContainer,
      DeadlineRiskLevel.critical => colorScheme.error,
    };
    final foreground = switch (level) {
      DeadlineRiskLevel.low => colorScheme.onSecondaryContainer,
      DeadlineRiskLevel.medium => colorScheme.onTertiaryContainer,
      DeadlineRiskLevel.high => colorScheme.onErrorContainer,
      DeadlineRiskLevel.critical => colorScheme.onError,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        level.label,
        style: TextStyle(color: foreground, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _MilestoneEditorDialog extends StatefulWidget {
  const _MilestoneEditorDialog({required this.initial});

  final MilestoneDraft initial;

  @override
  State<_MilestoneEditorDialog> createState() => _MilestoneEditorDialogState();
}

class _MilestoneEditorDialogState extends State<_MilestoneEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _sequenceController;
  late final TextEditingController _minutesController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initial.title);
    _descriptionController = TextEditingController(
      text: widget.initial.description ?? '',
    );
    _sequenceController = TextEditingController(
      text: widget.initial.sequenceOrder.toString(),
    );
    _minutesController = TextEditingController(
      text: widget.initial.estimatedMinutes.toString(),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _sequenceController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit milestone'),
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
                validator: _required,
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
                decoration: const InputDecoration(labelText: 'Order'),
                keyboardType: TextInputType.number,
                validator: _positiveInt,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _minutesController,
                decoration: const InputDecoration(
                  labelText: 'Estimated minutes',
                ),
                keyboardType: TextInputType.number,
                validator: _positiveInt,
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
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final description = _normalizeOptional(_descriptionController.text);
    Navigator.of(context).pop(
      widget.initial.copyWith(
        title: _titleController.text.trim(),
        description: description,
        clearDescription: description == null,
        sequenceOrder: int.parse(_sequenceController.text),
        estimatedMinutes: int.parse(_minutesController.text),
      ),
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required.';
    }
    return null;
  }

  String? _positiveInt(String? value) {
    final parsed = int.tryParse(value ?? '');
    if (parsed == null || parsed <= 0) {
      return 'Enter a positive number.';
    }
    return null;
  }

  String? _normalizeOptional(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

class _TaskEditorDialog extends StatefulWidget {
  const _TaskEditorDialog({required this.initial, required this.milestones});

  final TaskDraft initial;
  final List<MilestoneDraft> milestones;

  @override
  State<_TaskEditorDialog> createState() => _TaskEditorDialogState();
}

class _TaskEditorDialogState extends State<_TaskEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _minutesController;
  late TaskType _taskType;
  String? _selectedMilestoneId;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initial.title);
    _descriptionController = TextEditingController(
      text: widget.initial.description ?? '',
    );
    _minutesController = TextEditingController(
      text: widget.initial.estimatedMinutes.toString(),
    );
    _taskType = widget.initial.type;
    _selectedMilestoneId = widget.initial.milestoneDraftId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit task'),
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
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Required.' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<TaskType>(
                initialValue: _taskType,
                decoration: const InputDecoration(labelText: 'Task type'),
                items: TaskType.values
                    .map(
                      (type) => DropdownMenuItem<TaskType>(
                        value: type,
                        child: Text(type.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _taskType = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _minutesController,
                decoration: const InputDecoration(
                  labelText: 'Estimated minutes',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final parsed = int.tryParse(value ?? '');
                  if (parsed == null || parsed <= 0) {
                    return 'Enter a positive number.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                initialValue: _selectedMilestoneId,
                decoration: const InputDecoration(labelText: 'Milestone'),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('No milestone'),
                  ),
                  ...widget.milestones.map(
                    (milestone) => DropdownMenuItem<String?>(
                      value: milestone.id,
                      child: Text(milestone.title),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedMilestoneId = value;
                  });
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
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final description = _descriptionController.text.trim();
    Navigator.of(context).pop(
      widget.initial.copyWith(
        title: _titleController.text.trim(),
        description: description.isEmpty ? null : description,
        clearDescription: description.isEmpty,
        type: _taskType,
        estimatedMinutes: int.parse(_minutesController.text),
        milestoneDraftId: _selectedMilestoneId,
        clearMilestoneDraftId: _selectedMilestoneId == null,
      ),
    );
  }
}
