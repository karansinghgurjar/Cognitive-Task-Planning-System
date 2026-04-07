import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:study_flow/features/review/data/weekly_review_repository.dart';
import 'package:study_flow/features/review/domain/weekly_review_models.dart';
import 'package:study_flow/features/review/models/weekly_review.dart';
import 'package:study_flow/features/review/providers/weekly_review_providers.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(
      WeeklyReview(
        id: 'fallback',
        weekStart: DateTime(2026, 4, 6),
        weekEnd: DateTime(2026, 4, 12),
        createdAt: DateTime(2026, 4, 12, 18),
      ),
    );
  });

  test('WeeklyReviewActionController saves reflection with generated summary', () async {
    final repository = _MockWeeklyReviewRepository();
    final snapshot = WeeklyReviewSnapshot(
      weekStart: DateTime(2026, 4, 6),
      weekEnd: DateTime(2026, 4, 12),
      breakdown: const WeeklyCompletionBreakdown(
        totalPlannedMinutes: 180,
        totalCompletedMinutes: 120,
        completionRate: 120 / 180,
        completedSessionsCount: 2,
        missedSessionsCount: 1,
        cancelledSessionsCount: 0,
      ),
      goalReviews: const [],
      taskReviews: const [],
      recommendations: const [],
      overdueTaskTitles: const [],
      repeatedSlipTaskTitles: const [],
      summaryText: 'You completed 2 of 3 sessions.',
    );

    when(() => repository.getReviewForWeek(snapshot.weekStart)).thenAnswer(
      (_) async => null,
    );
    when(() => repository.saveReview(any())).thenAnswer((_) async {});

    final container = ProviderContainer(
      overrides: [
        weeklyReviewRepositoryProvider.overrideWith((ref) async => repository),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(weeklyReviewActionControllerProvider.notifier)
        .saveReflection(
          snapshot: snapshot,
          winsText: 'Stayed consistent.',
          challengesText: 'Overplanned Thursday.',
          nextWeekFocusText: 'Protect exam prep.',
        );

    final captured = verify(
      () => repository.saveReview(captureAny()),
    ).captured.single as WeeklyReview;
    expect(captured.summaryText, snapshot.summaryText);
    expect(captured.winsText, 'Stayed consistent.');
    expect(captured.challengesText, 'Overplanned Thursday.');
    expect(captured.nextWeekFocusText, 'Protect exam prep.');
  });

  test('selectedWeeklyReviewRecordProvider streams repository data', () async {
    final repository = _MockWeeklyReviewRepository();
    final review = WeeklyReview(
      id: 'weekly-review-20260406',
      weekStart: DateTime(2026, 4, 6),
      weekEnd: DateTime(2026, 4, 12),
      createdAt: DateTime(2026, 4, 12, 18),
      summaryText: 'Strong week.',
    );

    when(
      () => repository.watchReviewForWeek(DateTime(2026, 4, 6)),
    ).thenAnswer((_) => Stream.value(review));

    final container = ProviderContainer(
      overrides: [
        weeklyReviewRepositoryProvider.overrideWith((ref) async => repository),
        selectedWeeklyReviewWeekProvider.overrideWith((ref) => DateTime(2026, 4, 6)),
      ],
    );
    addTearDown(container.dispose);

    final value = await container.read(selectedWeeklyReviewRecordProvider.future);
    expect(value?.summaryText, 'Strong week.');
  });
}

class _MockWeeklyReviewRepository extends Mock
    implements WeeklyReviewRepository {}
