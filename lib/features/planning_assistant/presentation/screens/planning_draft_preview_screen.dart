import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/error_handler.dart';
import '../../domain/models/planning_draft.dart';
import '../../providers/planning_assistant_providers.dart';
import '../widgets/load_estimate_card.dart';
import '../widgets/planning_warning_card.dart';

class PlanningDraftPreviewScreen extends ConsumerWidget {
  const PlanningDraftPreviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(planningAssistantControllerProvider);
    final draft = state.draft;
    if (draft == null) {
      return const Scaffold(
        body: Center(child: Text('No planning draft is available yet.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Plan Preview')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 96),
        children: [
          LoadEstimateCard(estimate: draft.loadEstimate),
          if (draft.warnings.isNotEmpty) ...[
            const SizedBox(height: 16),
            for (final warning in draft.warnings) ...[
              PlanningWarningCard(warning: warning),
              const SizedBox(height: 12),
            ],
          ],
          _SectionCard(
            title: 'Goals',
            child: draft.goals.isEmpty
                ? const Text('No goals will be created.')
                : Column(
                    children: [
                      for (
                        var index = 0;
                        index < draft.goals.length;
                        index += 1
                      )
                        _GoalDraftTile(goal: draft.goals[index], index: index),
                    ],
                  ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Routines',
            child: draft.routines.isEmpty
                ? const Text('No routines will be created.')
                : Column(
                    children: [
                      for (
                        var index = 0;
                        index < draft.routines.length;
                        index += 1
                      )
                        _RoutineDraftTile(
                          draft: draft.routines[index],
                          index: index,
                        ),
                    ],
                  ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Tasks',
            child: draft.tasks.isEmpty
                ? const Text('No setup tasks will be created.')
                : Column(
                    children: [
                      for (
                        var index = 0;
                        index < draft.tasks.length;
                        index += 1
                      )
                        _TaskDraftTile(task: draft.tasks[index], index: index),
                    ],
                  ),
          ),
          if (draft.assumptions.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Assumptions',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: draft.assumptions
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text('- $item'),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: state.isBusy
                ? null
                : () async {
                    try {
                      final result = await ref
                          .read(planningAssistantControllerProvider.notifier)
                          .applyDraft();
                      if (result == null || !context.mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Created ${result.createdGoalCount} goals, ${result.createdRoutineCount} routines, and ${result.createdTaskCount} tasks.',
                          ),
                        ),
                      );
                      Navigator.of(context).pop();
                    } catch (error) {
                      if (!context.mounted) {
                        return;
                      }
                      ErrorHandler.showSnackBar(
                        context,
                        error,
                        fallbackTitle: 'Plan apply failed',
                        fallbackMessage:
                            'The planning draft could not be applied safely.',
                      );
                    }
                  },
            icon: state.isBusy
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_circle_outline_rounded),
            label: Text(state.isBusy ? 'Applying...' : 'Apply Plan'),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _GoalDraftTile extends ConsumerWidget {
  const _GoalDraftTile({required this.goal, required this.index});

  final GoalDraft goal;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(goal.title),
      subtitle: Text(goal.explanation ?? 'Generated goal'),
      trailing: IconButton(
        tooltip: 'Remove goal',
        onPressed: () {
          ref
              .read(planningAssistantControllerProvider.notifier)
              .removeGoal(index);
        },
        icon: const Icon(Icons.close_rounded),
      ),
    );
  }
}

class _RoutineDraftTile extends ConsumerWidget {
  const _RoutineDraftTile({required this.draft, required this.index});

  final RoutineDraft draft;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  draft.title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                tooltip: 'Remove routine',
                onPressed: () {
                  ref
                      .read(planningAssistantControllerProvider.notifier)
                      .removeRoutine(index);
                },
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          Text(draft.explanation),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: SwitchListTile(
                  value: draft.isFlexible,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Flexible'),
                  onChanged: (value) {
                    ref
                        .read(planningAssistantControllerProvider.notifier)
                        .updateRoutine(
                          index,
                          draft.copyWith(isFlexible: value),
                        );
                  },
                ),
              ),
              IconButton(
                tooltip: '15 minutes shorter',
                onPressed: () {
                  ref
                      .read(planningAssistantControllerProvider.notifier)
                      .updateRoutine(
                        index,
                        draft.copyWith(
                          durationMinutes: (draft.durationMinutes - 15).clamp(
                            15,
                            240,
                          ),
                        ),
                      );
                },
                icon: const Icon(Icons.remove_circle_outline_rounded),
              ),
              Text('${draft.durationMinutes}m'),
              IconButton(
                tooltip: '15 minutes longer',
                onPressed: () {
                  ref
                      .read(planningAssistantControllerProvider.notifier)
                      .updateRoutine(
                        index,
                        draft.copyWith(
                          durationMinutes: (draft.durationMinutes + 15).clamp(
                            15,
                            240,
                          ),
                        ),
                      );
                },
                icon: const Icon(Icons.add_circle_outline_rounded),
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            children: [
              TextButton(
                onPressed: () {
                  final current = draft.preferredStartMinuteOfDay ?? 19 * 60;
                  ref
                      .read(planningAssistantControllerProvider.notifier)
                      .updateRoutine(
                        index,
                        draft.copyWith(
                          preferredStartMinuteOfDay: (current - 30).clamp(
                            0,
                            1439,
                          ),
                        ),
                      );
                },
                child: const Text('Earlier'),
              ),
              TextButton(
                onPressed: () {
                  final current = draft.preferredStartMinuteOfDay ?? 19 * 60;
                  ref
                      .read(planningAssistantControllerProvider.notifier)
                      .updateRoutine(
                        index,
                        draft.copyWith(
                          preferredStartMinuteOfDay: (current + 30).clamp(
                            0,
                            1439,
                          ),
                        ),
                      );
                },
                child: const Text('Later'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TaskDraftTile extends ConsumerWidget {
  const _TaskDraftTile({required this.task, required this.index});

  final TaskDraft task;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(task.title),
      subtitle: Text(task.explanation),
      trailing: IconButton(
        tooltip: 'Remove task',
        onPressed: () {
          ref
              .read(planningAssistantControllerProvider.notifier)
              .removeTask(index);
        },
        icon: const Icon(Icons.close_rounded),
      ),
    );
  }
}
