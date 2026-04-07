import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/errors/error_handler.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_status_chip.dart';
import '../../recommendations/domain/recommendation_models.dart';
import '../domain/weekly_review_models.dart';
import '../models/weekly_review.dart';
import '../providers/weekly_review_providers.dart';

class WeeklyReviewScreen extends ConsumerStatefulWidget {
  const WeeklyReviewScreen({this.initialWeekStart, super.key});

  final DateTime? initialWeekStart;

  @override
  ConsumerState<WeeklyReviewScreen> createState() => _WeeklyReviewScreenState();
}

class _WeeklyReviewScreenState extends ConsumerState<WeeklyReviewScreen> {
  final _winsController = TextEditingController();
  final _challengesController = TextEditingController();
  final _nextWeekFocusController = TextEditingController();
  String? _loadedReviewId;
  DateTime? _loadedWeekStart;

  @override
  void initState() {
    super.initState();
    final initialWeekStart = widget.initialWeekStart;
    if (initialWeekStart != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        final normalized = ref
            .read(weeklyReviewServiceProvider)
            .weekStartFor(initialWeekStart);
        ref.read(selectedWeeklyReviewWeekProvider.notifier).state = normalized;
      });
    }
  }

  @override
  void dispose() {
    _winsController.dispose();
    _challengesController.dispose();
    _nextWeekFocusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weekStart = ref.watch(selectedWeeklyReviewWeekProvider);
    final snapshotAsync = ref.watch(selectedWeeklyReviewSnapshotProvider);
    final recordAsync = ref.watch(selectedWeeklyReviewRecordProvider);
    final historyAsync = ref.watch(watchPastWeeklyReviewsProvider);
    final actionState = ref.watch(weeklyReviewActionControllerProvider);

    final record = recordAsync.valueOrNull;
    _syncControllers(record, weekStart);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Review'),
        actions: [
          IconButton(
            onPressed: () => _moveWeek(-1),
            icon: const Icon(Icons.chevron_left_rounded),
            tooltip: 'Previous week',
          ),
          IconButton(
            onPressed: _canMoveToNextWeek(weekStart) ? () => _moveWeek(1) : null,
            icon: const Icon(Icons.chevron_right_rounded),
            tooltip: 'Next week',
          ),
        ],
      ),
      body: snapshotAsync.when(
        data: (snapshot) => ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 96),
          children: [
            _WeekHeader(weekStart: snapshot.weekStart, weekEnd: snapshot.weekEnd),
            const SizedBox(height: 16),
            if (!snapshot.hasMeaningfulData)
              const AppEmptyState(
                icon: Icons.rate_review_outlined,
                title: 'Not enough weekly data yet',
                message:
                    'Complete or miss a few planned sessions first, then return here for a useful weekly review.',
              )
            else ...[
              _WeeklySummaryCard(snapshot: snapshot),
              const SizedBox(height: 16),
              if (snapshot.trendComparison != null)
                _TrendComparisonCard(comparison: snapshot.trendComparison!),
              if (snapshot.trendComparison != null) const SizedBox(height: 16),
              if (snapshot.recommendations.isNotEmpty) ...[
                _SectionCard(
                  title: 'Next Week Recommendations',
                  child: Column(
                    children: snapshot.recommendations.map((recommendation) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _RecommendationTile(recommendation: recommendation),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              _SectionCard(
                title: 'Goal Review',
                child: snapshot.goalReviews.isEmpty
                    ? const Text('No goal-linked work was completed this week.')
                    : Column(
                        children: snapshot.goalReviews.map((review) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _GoalReviewTile(review: review),
                          );
                        }).toList(),
                      ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Task Review',
                child: snapshot.taskReviews.isEmpty
                    ? const Text('No task activity was recorded this week.')
                    : Column(
                        children: snapshot.taskReviews.take(10).map((review) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _TaskReviewTile(review: review),
                          );
                        }).toList(),
                      ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Overdue and Repeated Slips',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      snapshot.overdueTaskTitles.isEmpty
                          ? 'No overdue tasks carried into the end of this week.'
                          : 'Overdue: ${snapshot.overdueTaskTitles.join(', ')}',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.repeatedSlipTaskTitles.isEmpty
                          ? 'No tasks slipped repeatedly this week.'
                          : 'Repeated slips: ${snapshot.repeatedSlipTaskTitles.join(', ')}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Reflection',
                subtitle: record?.summaryText ?? snapshot.summaryText,
                child: Column(
                  children: [
                    TextField(
                      controller: _winsController,
                      decoration: const InputDecoration(
                        labelText: 'Wins',
                        hintText: 'What worked well this week?',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _challengesController,
                      decoration: const InputDecoration(
                        labelText: 'Challenges',
                        hintText: 'What got in the way?',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nextWeekFocusController,
                      decoration: const InputDecoration(
                        labelText: 'Next Week Focus',
                        hintText: 'What should you protect next week?',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: actionState.isLoading
                            ? null
                            : () => _saveReflection(snapshot),
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('Save Reflection'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            historyAsync.when(
              data: (reviews) => _SectionCard(
                title: 'Past Reviews',
                child: reviews.isEmpty
                    ? const Text('Saved weekly reflections will appear here.')
                    : Column(
                        children: reviews.map((review) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _HistoryTile(
                              review: review,
                              isSelected: _sameWeek(review.weekStart, weekStart),
                              onTap: () {
                                ref
                                    .read(selectedWeeklyReviewWeekProvider.notifier)
                                    .state = review.weekStart;
                              },
                            ),
                          );
                        }).toList(),
                      ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text(ErrorHandler.mapError(error).message),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(ErrorHandler.mapError(error).message),
        ),
      ),
    );
  }

  void _syncControllers(WeeklyReview? review, DateTime weekStart) {
    final reviewId = review?.id;
    if (_loadedReviewId == reviewId && _sameWeek(_loadedWeekStart, weekStart)) {
      return;
    }
    _loadedReviewId = reviewId;
    _loadedWeekStart = weekStart;
    _winsController.text = review?.winsText ?? '';
    _challengesController.text = review?.challengesText ?? '';
    _nextWeekFocusController.text = review?.nextWeekFocusText ?? '';
  }

  bool _sameWeek(DateTime? left, DateTime? right) {
    if (left == null || right == null) {
      return left == right;
    }
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }

  bool _canMoveToNextWeek(DateTime currentWeekStart) {
    final currentWeek = ref.read(weeklyReviewServiceProvider).weekStartFor(DateTime.now());
    return currentWeekStart.isBefore(currentWeek);
  }

  void _moveWeek(int deltaWeeks) {
    final current = ref.read(selectedWeeklyReviewWeekProvider);
    ref.read(selectedWeeklyReviewWeekProvider.notifier).state = current.add(
      Duration(days: 7 * deltaWeeks),
    );
  }

  Future<void> _saveReflection(WeeklyReviewSnapshot snapshot) async {
    try {
      await ref.read(weeklyReviewActionControllerProvider.notifier).saveReflection(
            snapshot: snapshot,
            winsText: _winsController.text,
            challengesText: _challengesController.text,
            nextWeekFocusText: _nextWeekFocusController.text,
          );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Weekly reflection saved.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ErrorHandler.showSnackBar(
        context,
        error,
        fallbackTitle: 'Save failed',
        fallbackMessage: 'The weekly reflection could not be saved.',
      );
    }
  }
}

class _WeekHeader extends StatelessWidget {
  const _WeekHeader({required this.weekStart, required this.weekEnd});

  final DateTime weekStart;
  final DateTime weekEnd;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('MMM d');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weekly Review',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 4),
        Text('${formatter.format(weekStart)} - ${formatter.format(weekEnd)}'),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
    this.subtitle,
  });

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
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
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
  const _WeeklySummaryCard({required this.snapshot});

  final WeeklyReviewSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final breakdown = snapshot.breakdown;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Summary',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 16),
            _MetricRow(
              label: 'Planned Minutes',
              value: breakdown.totalPlannedMinutes.toString(),
            ),
            _MetricRow(
              label: 'Completed Minutes',
              value: breakdown.totalCompletedMinutes.toString(),
            ),
            _MetricRow(
              label: 'Completion Rate',
              value: '${(breakdown.completionRate * 100).round()}%',
            ),
            _MetricRow(
              label: 'Completed Sessions',
              value: breakdown.completedSessionsCount.toString(),
            ),
            _MetricRow(
              label: 'Missed Sessions',
              value: breakdown.missedSessionsCount.toString(),
            ),
            _MetricRow(
              label: 'Cancelled Sessions',
              value: breakdown.cancelledSessionsCount.toString(),
            ),
            const SizedBox(height: 12),
            Text(
              snapshot.topGoalTitle == null
                  ? 'No goal received focused time this week.'
                  : 'Most-focused goal: ${snapshot.topGoalTitle} (${snapshot.topGoalMinutes} min)',
            ),
            const SizedBox(height: 4),
            Text(
              snapshot.topTaskTitle == null
                  ? 'No task received focused time this week.'
                  : 'Most-focused task: ${snapshot.topTaskTitle} (${snapshot.topTaskMinutes} min)',
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendComparisonCard extends StatelessWidget {
  const _TrendComparisonCard({required this.comparison});

  final WeeklyTrendComparison comparison;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Compared With Previous Week',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MetricRow(
            label: 'Completed Minutes',
            value: _signedInt(comparison.completedMinutesDelta),
          ),
          _MetricRow(
            label: 'Completion Rate',
            value: _signedPercent(comparison.completionRateDelta),
          ),
          _MetricRow(
            label: 'Missed Sessions',
            value: _signedInt(comparison.missedSessionsDelta),
          ),
          const SizedBox(height: 8),
          Text(comparison.summary),
        ],
      ),
    );
  }
}

class _GoalReviewTile extends StatelessWidget {
  const _GoalReviewTile({required this.review});

  final WeeklyGoalReview review;

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
                  review.goalTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              _RiskChip(level: review.targetRisk),
            ],
          ),
          const SizedBox(height: 8),
          Text('${review.minutesSpent} min focused this week'),
          const SizedBox(height: 4),
          Text(review.statusSummary),
        ],
      ),
    );
  }
}

class _TaskReviewTile extends StatelessWidget {
  const _TaskReviewTile({required this.review});

  final WeeklyTaskReview review;

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
                  review.taskTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              if (review.isOverdue) const AppStatusChip(label: 'Overdue'),
              if (review.isArchived) const AppStatusChip(label: 'Archived'),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${review.completedMinutes}/${review.plannedMinutes} min | Completed sessions ${review.completedSessionsCount} | Missed ${review.missedSessionsCount} | Cancelled ${review.cancelledSessionsCount}',
          ),
          const SizedBox(height: 4),
          Text(review.statusSummary),
        ],
      ),
    );
  }
}

class _RecommendationTile extends StatelessWidget {
  const _RecommendationTile({required this.recommendation});

  final WeeklyRecommendation recommendation;

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
                  recommendation.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              _RiskChip(level: recommendation.riskLevel),
            ],
          ),
          const SizedBox(height: 8),
          Text(recommendation.description),
          const SizedBox(height: 8),
          Text(recommendation.suggestedAction),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.review,
    required this.isSelected,
    required this.onTap,
  });

  final WeeklyReview review;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected
          ? Theme.of(context).colorScheme.primaryContainer
          : null,
      child: ListTile(
        onTap: onTap,
        title: Text(
          '${DateFormat.MMMd().format(review.weekStart)} - ${DateFormat.MMMd().format(review.weekEnd)}',
        ),
        subtitle: Text(
          review.summaryText ??
              review.nextWeekFocusText ??
              'Saved weekly reflection',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
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
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _RiskChip extends StatelessWidget {
  const _RiskChip({required this.level});

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
    return AppStatusChip(
      label: level.label,
      backgroundColor: background,
      foregroundColor: foreground,
    );
  }
}

String _signedInt(int value) {
  if (value == 0) {
    return '0';
  }
  return value > 0 ? '+$value' : value.toString();
}

String _signedPercent(double value) {
  final rounded = (value * 100).round();
  if (rounded == 0) {
    return '0%';
  }
  return rounded > 0 ? '+$rounded%' : '$rounded%';
}
