import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/errors/error_handler.dart';
import '../../goals/models/learning_goal.dart';
import '../../quick_capture/presentation/quick_capture_inbox_action_button.dart';
import '../../recommendations/domain/recommendation_models.dart';
import '../../recommendations/presentation/recommendations_dashboard.dart';
import '../../settings/presentation/settings_home_screen.dart';
import '../domain/analytics_models.dart';
import '../providers/analytics_providers.dart';

class AnalyticsDashboardScreen extends ConsumerWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(analyticsDashboardDataProvider);
    final rangePreset = ref.watch(analyticsRangePresetProvider);

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
                      'Analytics',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Track consistency, time allocation, plan adherence, and workload sustainability.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const RecommendationsDashboard(),
                    ),
                  );
                },
                icon: const Icon(Icons.insights_outlined),
                tooltip: 'Recommendations',
              ),
              const QuickCaptureInboxActionButton(
                tooltip: 'Open Quick Capture inbox from Analytics',
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<AnalyticsRangePreset>(
                segments: AnalyticsRangePreset.values.map((preset) {
                  return ButtonSegment<AnalyticsRangePreset>(
                    value: preset,
                    label: Text(preset.label),
                  );
                }).toList(),
                selected: {rangePreset},
                onSelectionChanged: (selection) {
                  if (selection.isNotEmpty) {
                    ref.read(analyticsRangePresetProvider.notifier).state =
                        selection.first;
                  }
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: dashboardAsync.when(
            data: (data) => _DashboardBody(data: data),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _StateMessage(
              icon: Icons.error_outline_rounded,
              title: 'Could not compute analytics',
              message: ErrorHandler.mapError(error).message,
            ),
          ),
        ),
      ],
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.data});

  final AnalyticsDashboardData data;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 1100;
        final medium = constraints.maxWidth >= 760;
        final cardWidth = wide
            ? (constraints.maxWidth - 72) / 3
            : medium
            ? (constraints.maxWidth - 48) / 2
            : constraints.maxWidth - 48;

        return ListView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 96),
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: cardWidth,
                  child: _WeeklySummaryCard(stats: data.weeklyStats),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _StreakCard(summary: data.streakSummary),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _BurnoutCard(report: data.burnoutReport),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Focus Trend',
              subtitle: data.selectedRange.label,
              child: Column(
                children: [
                  _FocusTrendChart(points: data.focusTrend),
                  const SizedBox(height: 16),
                  _PlannedVsCompletedChart(stats: data.rangeStats),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: medium
                      ? (constraints.maxWidth - 60) / 2
                      : constraints.maxWidth - 48,
                  child: _SectionCard(
                    title: 'Where Your Time Went',
                    subtitle: 'Task Type',
                    child: _AllocationChart(breakdown: data.taskTypeBreakdown),
                  ),
                ),
                SizedBox(
                  width: medium
                      ? (constraints.maxWidth - 60) / 2
                      : constraints.maxWidth - 48,
                  child: _SectionCard(
                    title: 'When You Focused',
                    subtitle: 'By Weekday',
                    child: _AllocationChart(breakdown: data.weekdayBreakdown),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Goal Progress',
              subtitle: 'Linked work, completed minutes, and target risk',
              child: data.goalAnalytics.isEmpty
                  ? const Text('No goal analytics are available yet.')
                  : Column(
                      children: data.goalAnalytics.take(6).map((goal) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _GoalAnalyticsTile(goal: goal),
                        );
                      }).toList(),
                    ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: medium
                      ? (constraints.maxWidth - 60) / 2
                      : constraints.maxWidth - 48,
                  child: _SectionCard(
                    title: 'Insights',
                    subtitle: 'What the numbers suggest right now',
                    child: data.productivityInsights.isEmpty
                        ? const Text('No notable insights yet.')
                        : Column(
                            children: data.productivityInsights.map((insight) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _InsightTile(insight: insight),
                              );
                            }).toList(),
                          ),
                  ),
                ),
                SizedBox(
                  width: medium
                      ? (constraints.maxWidth - 60) / 2
                      : constraints.maxWidth - 48,
                  child: _SectionCard(
                    title: 'End of Day Review',
                    subtitle: DateFormat.yMMMd().format(data.dayReview.date),
                    child: _DayReviewTile(review: data.dayReview),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: medium
                      ? (constraints.maxWidth - 60) / 2
                      : constraints.maxWidth - 48,
                  child: _SectionCard(
                    title: 'Goal Type Allocation',
                    subtitle: data.selectedRange.label,
                    child: _AllocationList(breakdown: data.goalTypeBreakdown),
                  ),
                ),
                SizedBox(
                  width: medium
                      ? (constraints.maxWidth - 60) / 2
                      : constraints.maxWidth - 48,
                  child: _SectionCard(
                    title: 'Top Goals by Time',
                    subtitle: data.selectedRange.label,
                    child: _AllocationList(breakdown: data.goalBreakdown),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child, this.subtitle});

  final String title;
  final String? subtitle;
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
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium),
            ],
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _WeeklySummaryCard extends StatelessWidget {
  const _WeeklySummaryCard({required this.stats});

  final WeeklyProductivityStats stats;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This Week',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            _MetricRow(label: 'Planned', value: _hours(stats.plannedMinutes)),
            _MetricRow(
              label: 'Completed',
              value: _hours(stats.completedMinutes),
            ),
            _MetricRow(
              label: 'Completion Rate',
              value: '${(stats.completionRate * 100).round()}%',
            ),
            _MetricRow(
              label: 'Completed Sessions',
              value: stats.completedSessions.toString(),
            ),
            _MetricRow(
              label: 'Missed Sessions',
              value: stats.missedSessions.toString(),
            ),
            _MetricRow(
              label: 'Cancelled Sessions',
              value: stats.cancelledSessions.toString(),
            ),
            const SizedBox(height: 12),
            Text(
              'Average per day: ${stats.averageCompletedMinutesPerDay.toStringAsFixed(0)} min',
            ),
            const SizedBox(height: 6),
            Text(
              'Most productive: ${_dateLabel(stats.mostProductiveDay) ?? 'n/a'}',
            ),
          ],
        ),
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.summary});

  final StreakSummary summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Consistency',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            _MetricRow(
              label: 'Current Focus Streak',
              value: '${summary.currentFocusStreak.length} days',
            ),
            _MetricRow(
              label: 'Longest Focus Streak',
              value: '${summary.longestFocusStreak.length} days',
            ),
            _MetricRow(
              label: 'Daily Completion Streak',
              value: '${summary.currentDailyCompletionStreak.length} days',
            ),
            const SizedBox(height: 12),
            Text(
              summary.currentFocusStreak.isActive
                  ? 'You have already protected today\'s streak.'
                  : 'A 25-minute session today will keep the streak alive.',
            ),
          ],
        ),
      ),
    );
  }
}

class _BurnoutCard extends StatelessWidget {
  const _BurnoutCard({required this.report});

  final BurnoutRiskReport report;

  @override
  Widget build(BuildContext context) {
    return Card(
      color:
          report.severity == DeadlineRiskLevel.high ||
              report.severity == DeadlineRiskLevel.critical
          ? Theme.of(context).colorScheme.errorContainer
          : null,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Burnout Risk',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _RiskBadge(level: report.severity),
              ],
            ),
            const SizedBox(height: 16),
            Text(report.reasons.first),
            const SizedBox(height: 12),
            Text(report.suggestedAction),
          ],
        ),
      ),
    );
  }
}

class _FocusTrendChart extends StatelessWidget {
  const _FocusTrendChart({required this.points});

  final List<FocusTrendPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const SizedBox(
        height: 240,
        child: Center(child: Text('No trend data yet.')),
      );
    }

    final maxMinutes = points.fold<int>(0, (max, point) {
      final candidate = point.plannedMinutes > point.completedMinutes
          ? point.plannedMinutes
          : point.completedMinutes;
      return candidate > max ? candidate : max;
    });
    final topY = ((maxMinutes / 30).ceil() * 30).clamp(60, 600).toDouble();

    return SizedBox(
      height: 240,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: topY,
          gridData: const FlGridData(show: true),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: topY / 4,
                getTitlesWidget: (value, meta) =>
                    Text(value.toInt().toString()),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= points.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(DateFormat.Md().format(points[index].date)),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              isCurved: true,
              color: Theme.of(context).colorScheme.primary,
              barWidth: 3,
              spots: [
                for (var index = 0; index < points.length; index++)
                  FlSpot(
                    index.toDouble(),
                    points[index].completedMinutes.toDouble(),
                  ),
              ],
            ),
            LineChartBarData(
              isCurved: true,
              color: Theme.of(context).colorScheme.tertiary,
              barWidth: 3,
              dashArray: const [6, 4],
              spots: [
                for (var index = 0; index < points.length; index++)
                  FlSpot(
                    index.toDouble(),
                    points[index].plannedMinutes.toDouble(),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PlannedVsCompletedChart extends StatelessWidget {
  const _PlannedVsCompletedChart({required this.stats});

  final RangeProductivityStats stats;

  @override
  Widget build(BuildContext context) {
    final maxValue = [
      stats.plannedMinutes,
      stats.completedMinutes,
    ].reduce((left, right) => left > right ? left : right).toDouble();
    final topY = ((maxValue / 30).ceil() * 30).clamp(60, 600).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 220,
          child: BarChart(
            BarChartData(
              maxY: topY,
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: true),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: topY / 4,
                    getTitlesWidget: (value, meta) =>
                        Text(value.toInt().toString()),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      switch (value.toInt()) {
                        case 0:
                          return const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text('Planned'),
                          );
                        case 1:
                          return const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text('Completed'),
                          );
                        default:
                          return const SizedBox.shrink();
                      }
                    },
                  ),
                ),
              ),
              barGroups: [
                BarChartGroupData(
                  x: 0,
                  barRods: [
                    BarChartRodData(
                      toY: stats.plannedMinutes.toDouble(),
                      color: Theme.of(context).colorScheme.tertiary,
                      width: 28,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 1,
                  barRods: [
                    BarChartRodData(
                      toY: stats.completedMinutes.toDouble(),
                      color: Theme.of(context).colorScheme.primary,
                      width: 28,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Completed ${stats.completedMinutes} of ${stats.plannedMinutes} planned minutes in ${stats.range.label.toLowerCase()}.',
        ),
      ],
    );
  }
}

class _AllocationChart extends StatelessWidget {
  const _AllocationChart({required this.breakdown});

  final TimeAllocationBreakdown breakdown;

  @override
  Widget build(BuildContext context) {
    if (breakdown.items.isEmpty) {
      return const SizedBox(
        height: 220,
        child: Center(child: Text('No completed time yet.')),
      );
    }

    final items = breakdown.items.take(5).toList();
    final maxValue = items.fold<int>(
      0,
      (max, item) => item.minutes > max ? item.minutes : max,
    );
    final topY = ((maxValue / 30).ceil() * 30).clamp(60, 600).toDouble();

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          maxY: topY,
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: true),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: topY / 4,
                getTitlesWidget: (value, meta) =>
                    Text(value.toInt().toString()),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= items.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(items[index].label),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var index = 0; index < items.length; index++)
              BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: items[index].minutes.toDouble(),
                    color: Theme.of(context).colorScheme.primary,
                    width: 24,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _AllocationList extends StatelessWidget {
  const _AllocationList({required this.breakdown});

  final TimeAllocationBreakdown breakdown;

  @override
  Widget build(BuildContext context) {
    if (breakdown.items.isEmpty) {
      return const Text('No completed time in this range yet.');
    }

    return Column(
      children: breakdown.items.take(6).map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(item.label)),
                  Text('${item.minutes} min'),
                ],
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(value: item.percentage),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _GoalAnalyticsTile extends StatelessWidget {
  const _GoalAnalyticsTile({required this.goal});

  final GoalAnalytics goal;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
                  goal.goalTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _RiskBadge(level: goal.targetRisk),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${goal.goalType.label} - ${(goal.percentComplete * 100).round()}% complete',
          ),
          const SizedBox(height: 4),
          Text(
            '${goal.completedLinkedTasks}/${goal.totalLinkedTasks} linked tasks complete | ${goal.totalCompletedMinutes}/${goal.totalPlannedMinutes} min',
          ),
          const SizedBox(height: 4),
          Text(
            'Average: ${goal.averageMinutesPerWeekSpent.toStringAsFixed(1)} min/week',
          ),
        ],
      ),
    );
  }
}

class _InsightTile extends StatelessWidget {
  const _InsightTile({required this.insight});

  final ProductivityInsight insight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
                  insight.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _RiskBadge(level: insight.riskLevel),
            ],
          ),
          const SizedBox(height: 6),
          Text(insight.description),
          const SizedBox(height: 8),
          Text(insight.suggestedAction),
        ],
      ),
    );
  }
}

class _DayReviewTile extends StatelessWidget {
  const _DayReviewTile({required this.review});

  final DayReviewSummary review;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MetricRow(
          label: 'Completed Sessions',
          value: review.completedSessions.toString(),
        ),
        _MetricRow(
          label: 'Missed Sessions',
          value: review.missedSessions.toString(),
        ),
        _MetricRow(
          label: 'Focused Minutes',
          value: review.totalFocusedMinutes.toString(),
        ),
        const SizedBox(height: 8),
        Text(
          review.mostImportantCompletedTaskTitle == null
              ? 'No high-priority task completed yet today.'
              : 'Most important completed task: ${review.mostImportantCompletedTaskTitle}',
        ),
        const SizedBox(height: 8),
        Text(review.recommendedNextAction),
      ],
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
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

class _StateMessage extends StatelessWidget {
  const _StateMessage({
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

String? _dateLabel(DateTime? value) {
  if (value == null) {
    return null;
  }
  return DateFormat.E().format(value);
}
