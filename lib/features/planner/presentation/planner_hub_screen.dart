import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_router.dart';
import '../../../core/widgets/app_section_header.dart';
import '../../goals/providers/goal_providers.dart';
import '../../knowledge/providers/knowledge_providers.dart';
import '../../routines/providers/routine_providers.dart';
import '../../tasks/providers/task_providers.dart';

class PlannerHubScreen extends ConsumerWidget {
  const PlannerHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskCount = ref.watch(watchActiveTasksProvider).valueOrNull?.length ?? 0;
    final goalCount = ref.watch(watchGoalsProvider).valueOrNull?.length ?? 0;
    final routineCount = ref.watch(watchActiveRoutinesProvider).valueOrNull?.length ?? 0;
    final knowledgeCount =
        ref.watch(watchKnowledgeItemsProvider).valueOrNull?.length ?? 0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
      children: [
        AppSectionHeader(
          title: 'Planner',
          description:
              'Keep the core planning surfaces close together: tasks, routines, time structure, knowledge, and review.',
          actions: [
            FilledButton.icon(
              onPressed: () => AppRouter.openPlanningAssistant(context),
              icon: const Icon(Icons.auto_awesome_rounded),
              label: const Text('Planning Assistant'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _PlannerTile(
              title: 'Tasks',
              subtitle: '$taskCount active items and quick manual planning.',
              icon: Icons.checklist_rounded,
              actionLabel: 'Open Tasks',
              onPressed: () => AppRouter.openTasks(context),
            ),
            _PlannerTile(
              title: 'Routines',
              subtitle: '$routineCount active routines and recovery flows.',
              icon: Icons.repeat_rounded,
              actionLabel: 'Open Routines',
              onPressed: () => AppRouter.openRoutines(context),
            ),
            _PlannerTile(
              title: 'Knowledge',
              subtitle: '$knowledgeCount notes, resources, and revision items.',
              icon: Icons.menu_book_rounded,
              actionLabel: 'Open Knowledge',
              onPressed: () => AppRouter.openKnowledgeDashboard(context),
            ),
            _PlannerTile(
              title: 'Review',
              subtitle: 'Weekly reflection, trends, and calm next-step planning.',
              icon: Icons.fact_check_rounded,
              actionLabel: 'Open Review',
              onPressed: () => AppRouter.openWeeklyReview(context),
            ),
            _PlannerTile(
              title: 'Timetable',
              subtitle: 'Protect the busy hours that shape your real week.',
              icon: Icons.calendar_view_week_rounded,
              actionLabel: 'Open Timetable',
              onPressed: () => AppRouter.openTimetable(context),
            ),
            _PlannerTile(
              title: 'Analytics',
              subtitle: 'Use evidence before you change your planning system.',
              icon: Icons.insights_rounded,
              actionLabel: 'Open Analytics',
              onPressed: () => AppRouter.openAnalytics(context),
            ),
            _PlannerTile(
              title: 'Goals',
              subtitle: '$goalCount active goals linked back to execution.',
              icon: Icons.track_changes_rounded,
              actionLabel: 'Open Goals',
              onPressed: () => AppRouter.openGoals(context),
            ),
            _PlannerTile(
              title: 'Settings',
              subtitle: 'Sync, backups, sample data, and maintenance tools.',
              icon: Icons.settings_outlined,
              actionLabel: 'Open Settings',
              onPressed: () => AppRouter.openSettings(context),
            ),
          ],
        ),
      ],
    );
  }
}

class _PlannerTile extends StatelessWidget {
  const _PlannerTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.actionLabel,
    required this.onPressed,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 24),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(subtitle),
              const SizedBox(height: 16),
              FilledButton.tonal(onPressed: onPressed, child: Text(actionLabel)),
            ],
          ),
        ),
      ),
    );
  }
}
