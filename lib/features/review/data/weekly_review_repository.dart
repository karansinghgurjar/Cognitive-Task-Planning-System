import 'package:isar/isar.dart';

import '../models/weekly_review.dart';

class WeeklyReviewRepository {
  WeeklyReviewRepository(this._isar);

  final Isar _isar;

  Future<void> saveReview(WeeklyReview review) async {
    final reviewToStore = review.copyWith(
      updatedAt: review.updatedAt ?? review.createdAt,
    );
    await _isar.writeTxn(() async {
      await _isar.weeklyReviews.put(reviewToStore);
    });
  }

  Future<WeeklyReview?> getReviewForWeek(DateTime weekStart) {
    return _isar.weeklyReviews
        .filter()
        .weekStartEqualTo(_normalizeWeekStart(weekStart))
        .findFirst();
  }

  Stream<WeeklyReview?> watchReviewForWeek(DateTime weekStart) {
    final normalizedWeekStart = _normalizeWeekStart(weekStart);
    return _isar.weeklyReviews.watchLazy(fireImmediately: true).asyncMap((_) {
      return _isar.weeklyReviews
          .filter()
          .weekStartEqualTo(normalizedWeekStart)
          .findFirst();
    });
  }

  Stream<List<WeeklyReview>> watchPastReviews() {
    return _isar.weeklyReviews.watchLazy(fireImmediately: true).asyncMap((_) async {
      final reviews = await _isar.weeklyReviews.where().findAll();
      reviews.sort((left, right) => right.weekStart.compareTo(left.weekStart));
      return reviews;
    });
  }

  Future<List<WeeklyReview>> getAllReviews() async {
    final reviews = await _isar.weeklyReviews.where().findAll();
    reviews.sort((left, right) => right.weekStart.compareTo(left.weekStart));
    return reviews;
  }

  DateTime _normalizeWeekStart(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}
