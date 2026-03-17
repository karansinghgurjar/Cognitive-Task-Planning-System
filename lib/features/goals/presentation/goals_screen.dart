import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/app_router.dart';
import '../../../core/errors/error_boundary_widget.dart';
import '../../../core/layout/responsive_layout.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../../core/widgets/app_section_header.dart';
import '../../../core/widgets/app_status_chip.dart';
import '../../ai_planning/presentation/ai_plan_generator_screen.dart';
import '../domain/goal_progress_service.dart';
import '../models/learning_goal.dart';
import '../providers/goal_providers.dart';
import 'goal_detail_screen.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(watchGoalsProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final breakpoint = ResponsiveLayout.breakpointForWidth(
          constraints.maxWidth,
        );
        final padding = ResponsiveLayout.pagePadding(breakpoint);
        return ResponsiveContent(
          child: goalsAsync.when(
            data: (goals) {
              if (goals.isEmpty) {
                return ListView(
                  padding: padding,
                  children: [
                    _header(context),
                    const SizedBox(height: 24),
                    const AppEmptyState(
                      icon: Icons.track_changes_rounded,
                      title: 'No goals yet',
                      message:
                          'Add a goal or generate a plan from a description to build a roadmap before scheduling work.',
                    ),
                  ],
                );
              }

              return ListView.separated(
                padding: padding,
                itemCount: goals.length + 1,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _header(context);
                  }
                  final goal = goals[index - 1];
                  return _GoalCard(goal: goal);
                },
              );
            },
            loading: () => const AppLoadingIndicator(label: 'Loading goals...'),
            error: (error, _) => ErrorBoundaryWidget(error: error),
          ),
        );
      },
    );
  }

  Widget _header(BuildContext context) {
    return AppSectionHeader(
      title: 'Goals',
      description:
          'Plan learning and work outcomes, then turn them into executable tasks.',
      actions: [
        FilledButton.tonalIcon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const AiPlanGeneratorScreen(),
              ),
            );
          },
          icon: const Icon(Icons.auto_awesome_rounded),
          label: const Text('Create Plan'),
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

class _GoalCard extends ConsumerWidget {
  const _GoalCard({required this.goal});

  final LearningGoal goal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(goalProgressByGoalProvider(goal.id));
    final targetDateLabel = goal.targetDate == null
        ? null
        : DateFormat.yMMMd().format(goal.targetDate!);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => GoalDetailScreen(goalId: goal.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _GoalMetaChip(label: goal.goalType.label),
                            _GoalMetaChip(label: 'Priority ${goal.priority}'),
                            _GoalMetaChip(label: goal.status.label),
                            if (targetDateLabel != null)
                              _GoalMetaChip(label: 'Target $targetDateLabel'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              if (goal.description != null &&
                  goal.description!.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(goal.description!),
              ],
              const SizedBox(height: 16),
              progressAsync.when(
                data: (progress) => _GoalProgressSummary(progress: progress),
                loading: () => const LinearProgressIndicator(),
                error: (_, _) => Text(
                  'Progress unavailable',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoalProgressSummary extends StatelessWidget {
  const _GoalProgressSummary({required this.progress});

  final GoalProgress progress;

  @override
  Widget build(BuildContext context) {
    final percentLabel = '${(progress.percentComplete * 100).round()}%';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(value: progress.percentComplete),
        const SizedBox(height: 8),
        Text(
          '$percentLabel complete - ${progress.completedLinkedTasks}/${progress.totalLinkedTasks} tasks, '
          '${progress.completedMilestones}/${progress.totalMilestones} milestones',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _GoalMetaChip extends StatelessWidget {
  const _GoalMetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return AppStatusChip(label: label);
  }
}
