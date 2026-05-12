import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../review/presentation/weekly_review_screen.dart';
import '../../routines/models/routine.dart';
import '../../routines/presentation/add_edit_routine_screen.dart';
import '../../routines/presentation/routine_detail_screen.dart';
import '../../routines/providers/routine_providers.dart';
import '../../schedule/presentation/today_screen.dart';
import '../domain/planning_insight_action_router.dart';
import '../domain/planning_insight_models.dart';
import '../providers/planning_insight_providers.dart';

class PlanningInsightsPanel extends ConsumerWidget {
  const PlanningInsightsPanel({
    super.key,
    this.title = 'Planning Insights',
    this.maxItems = 3,
    this.routineId,
    this.showEmptyState = false,
  });

  final String title;
  final int maxItems;
  final String? routineId;
  final bool showEmptyState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightsAsync = routineId == null
        ? ref.watch(planningInsightsProvider)
        : ref.watch(planningInsightsForRoutineProvider(routineId!));

    return insightsAsync.when(
      data: (insights) {
        final visible = insights.take(maxItems).toList();
        if (visible.isEmpty && !showEmptyState) {
          return const SizedBox.shrink();
        }
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                if (visible.isEmpty)
                  const Text(
                    'No planning suggestions need attention right now.',
                  )
                else
                  for (var index = 0; index < visible.length; index += 1) ...[
                    _InsightTile(insight: visible[index]),
                    if (index < visible.length - 1) const Divider(height: 24),
                  ],
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _InsightTile extends ConsumerWidget {
  const _InsightTile({required this.insight});

  final PlanningInsight insight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final badgeColor = switch (insight.severity) {
      InsightSeverity.info => colorScheme.secondaryContainer,
      InsightSeverity.suggestion => colorScheme.tertiaryContainer,
      InsightSeverity.warning => colorScheme.errorContainer,
      InsightSeverity.critical => colorScheme.error,
    };
    final badgeForeground = switch (insight.severity) {
      InsightSeverity.info => colorScheme.onSecondaryContainer,
      InsightSeverity.suggestion => colorScheme.onTertiaryContainer,
      InsightSeverity.warning => colorScheme.onErrorContainer,
      InsightSeverity.critical => colorScheme.onError,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                insight.title,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                insight.severity.label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: badgeForeground,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(insight.message),
        const SizedBox(height: 6),
        Text(
          'Why: ${insight.reason}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final action in insight.actions.take(2))
              FilledButton.tonal(
                onPressed: () => _handleAction(context, ref, action),
                child: Text(action.label),
              ),
            TextButton(
              onPressed: () {
                ref
                    .read(insightSuppressionControllerProvider.notifier)
                    .snooze(insight, const Duration(days: 3));
              },
              child: const Text('Remind Later'),
            ),
            TextButton(
              onPressed: () {
                ref
                    .read(insightSuppressionControllerProvider.notifier)
                    .dismiss(insight);
              },
              child: const Text('Dismiss'),
            ),
            if (insight.relatedRoutineId != null ||
                insight.relatedGoalId != null)
              TextButton(
                onPressed: () {
                  ref
                      .read(insightSuppressionControllerProvider.notifier)
                      .disableTypeForEntity(insight);
                },
                child: const Text('Do Not Show Again'),
              ),
          ],
        ),
      ],
    );
  }

  void _handleAction(
    BuildContext context,
    WidgetRef ref,
    InsightAction action,
  ) {
    final router = ref.read(planningInsightActionRouterProvider);
    final route = router.routeFor(action);
    final routines =
        ref.read(watchAllRoutinesProvider).valueOrNull ?? const <Routine>[];
    switch (route.destination) {
      case InsightActionDestination.none:
        return;
      case InsightActionDestination.weeklyReview:
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const WeeklyReviewScreen()),
        );
        return;
      case InsightActionDestination.planner:
        Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const TodayScreen()));
        return;
      case InsightActionDestination.routineDetail:
        final routineId = route.routineId;
        if (routineId == null) {
          _showNoMutationMessage(context, action);
          return;
        }
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => RoutineDetailScreen(routineId: routineId),
          ),
        );
        return;
      case InsightActionDestination.routineEditor:
        final routineId = route.routineId;
        final routine = routines
            .where((item) => item.id == routineId)
            .firstOrNull;
        if (routine == null) {
          _showNoMutationMessage(context, action);
          return;
        }
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => AddEditRoutineScreen(routine: routine),
          ),
        );
        _showNoMutationMessage(context, action);
        return;
    }
  }

  void _showNoMutationMessage(BuildContext context, InsightAction action) {
    final explanation =
        action.explanation ??
        'This suggestion opens the right place to review it. CogniPlan will not change your plan until you confirm and save.';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(explanation)));
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
