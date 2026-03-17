import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/errors/error_handler.dart';
import '../../ai_planning/presentation/ai_plan_generator_screen.dart';
import '../../ai_planning/providers/ai_planning_providers.dart';
import '../../settings/presentation/settings_home_screen.dart';
import '../domain/recommendation_models.dart';
import '../providers/recommendation_providers.dart';

class RecommendationsDashboard extends ConsumerWidget {
  const RecommendationsDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(recommendationSummaryProvider);
    final planningOpportunityAsync = ref.watch(aiPlanningOpportunityProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recommendations',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'See what to work on next, where deadlines are at risk, and whether your plan is feasible.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const SettingsHomeScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.settings_outlined),
                tooltip: 'Settings',
              ),
            ],
          ),
        ),
        Expanded(
          child: summaryAsync.when(
            data: (summary) => _DashboardBody(
              summary: summary,
              planningOpportunityAsync: planningOpportunityAsync,
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _DashboardStateMessage(
              icon: Icons.error_outline_rounded,
              title: 'Could not build recommendations',
              message: ErrorHandler.mapError(error).message,
            ),
          ),
        ),
      ],
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({
    required this.summary,
    required this.planningOpportunityAsync,
  });

  final RecommendationSummary summary;
  final AsyncValue<String?> planningOpportunityAsync;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 96),
      children: [
        planningOpportunityAsync.when(
          data: (message) => message == null
              ? const SizedBox.shrink()
              : Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Planning Opportunity',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 12),
                        Text(message),
                        const SizedBox(height: 12),
                        FilledButton.tonalIcon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const AiPlanGeneratorScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.auto_awesome_rounded),
                          label: const Text('Generate Structured Plan'),
                        ),
                      ],
                    ),
                  ),
                ),
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
        ),
        if (planningOpportunityAsync.valueOrNull != null)
          const SizedBox(height: 16),
        _BestNextTaskCard(
          recommendation: summary.bestNextTask,
          nextBlock: summary.nextStudyBlock,
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Suggested Actions',
          child: summary.suggestedActions.isEmpty
              ? const Text('No immediate action is suggested right now.')
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final action in summary.suggestedActions)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text('• $action'),
                      ),
                  ],
                ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Deadline Risk',
          child: summary.goalFeasibilityReports.isEmpty
              ? const Text('No goal deadlines to evaluate yet.')
              : Column(
                  children: summary.goalFeasibilityReports.take(3).map((
                    report,
                  ) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _GoalRiskTile(report: report),
                    );
                  }).toList(),
                ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Workload Warnings',
          child: summary.workloadWarnings.isEmpty
              ? const Text('No major workload warnings detected.')
              : Column(
                  children: summary.workloadWarnings.map((warning) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _WarningTile(warning: warning),
                    );
                  }).toList(),
                ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Goal Feasibility',
          child: summary.goalFeasibilityReports.isEmpty
              ? const Text(
                  'Create goals with target dates to evaluate feasibility.',
                )
              : Column(
                  children: summary.goalFeasibilityReports.map((report) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _GoalFeasibilityTile(report: report),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }
}

class _BestNextTaskCard extends StatelessWidget {
  const _BestNextTaskCard({
    required this.recommendation,
    required this.nextBlock,
  });

  final TaskRecommendation? recommendation;
  final RecommendedStudyBlock? nextBlock;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Best Next Task',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            if (recommendation == null)
              const Text(
                'No recommendation is available yet. Add tasks or free time in your timetable.',
              )
            else ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      recommendation!.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  _RiskBadge(level: recommendation!.riskLevel),
                ],
              ),
              const SizedBox(height: 8),
              Text(recommendation!.description),
              const SizedBox(height: 8),
              Text(
                'Suggested focus: ${recommendation!.suggestedDurationMinutes} min',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 6),
              Text(
                recommendation!.reasoning,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (nextBlock != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Best next slot: ${nextBlock!.description}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ],
          ],
        ),
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _GoalRiskTile extends StatelessWidget {
  const _GoalRiskTile({required this.report});

  final GoalFeasibilityReport report;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                report.goalTitle,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            _RiskBadge(level: report.riskLevel),
          ],
        ),
        const SizedBox(height: 6),
        Text(report.summary),
      ],
    );
  }
}

class _GoalFeasibilityTile extends StatelessWidget {
  const _GoalFeasibilityTile({required this.report});

  final GoalFeasibilityReport report;

  @override
  Widget build(BuildContext context) {
    final targetDateLabel = report.targetDate == null
        ? 'No target date'
        : DateFormat.yMMMd().format(report.targetDate!);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  report.goalTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _RiskBadge(level: report.riskLevel),
            ],
          ),
          const SizedBox(height: 6),
          Text('Target: $targetDateLabel'),
          Text(
            'Remaining: ${_hours(report.remainingRequiredMinutes)} | Available: ${_hours(report.availableMinutesUntilTarget)}',
          ),
          if (report.shortfallMinutes > 0)
            Text('Shortfall: ${_hours(report.shortfallMinutes)}'),
          const SizedBox(height: 6),
          Text(report.suggestedActionText),
        ],
      ),
    );
  }
}

class _WarningTile extends StatelessWidget {
  const _WarningTile({required this.warning});

  final WorkloadWarning warning;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  warning.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _RiskBadge(level: warning.riskLevel),
            ],
          ),
          const SizedBox(height: 6),
          Text(warning.description),
          const SizedBox(height: 6),
          Text(warning.suggestedActionText),
        ],
      ),
    );
  }
}

class _RiskBadge extends StatelessWidget {
  const _RiskBadge({required this.level});

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

class _DashboardStateMessage extends StatelessWidget {
  const _DashboardStateMessage({
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

String _hours(int minutes) {
  return '${(minutes / 60).toStringAsFixed(1)}h';
}
