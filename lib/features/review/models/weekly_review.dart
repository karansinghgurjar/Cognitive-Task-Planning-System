import 'package:isar/isar.dart';

part 'weekly_review.g.dart';

@collection
class WeeklyReview {
  WeeklyReview({
    required this.id,
    required this.weekStart,
    required this.weekEnd,
    required this.createdAt,
    DateTime? updatedAt,
    this.summaryText,
    this.winsText,
    this.challengesText,
    this.nextWeekFocusText,
    this.isLocked = false,
  }) : updatedAt = updatedAt ?? createdAt;

  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String id;

  @Index(unique: true, replace: true)
  late DateTime weekStart;

  late DateTime weekEnd;
  late DateTime createdAt;
  DateTime? updatedAt;
  String? summaryText;
  String? winsText;
  String? challengesText;
  String? nextWeekFocusText;
  late bool isLocked;

  WeeklyReview copyWith({
    String? id,
    DateTime? weekStart,
    DateTime? weekEnd,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearUpdatedAt = false,
    String? summaryText,
    bool clearSummaryText = false,
    String? winsText,
    bool clearWinsText = false,
    String? challengesText,
    bool clearChallengesText = false,
    String? nextWeekFocusText,
    bool clearNextWeekFocusText = false,
    bool? isLocked,
  }) {
    final review = WeeklyReview(
      id: id ?? this.id,
      weekStart: weekStart ?? this.weekStart,
      weekEnd: weekEnd ?? this.weekEnd,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: clearUpdatedAt ? null : updatedAt ?? this.updatedAt,
      summaryText: clearSummaryText ? null : summaryText ?? this.summaryText,
      winsText: clearWinsText ? null : winsText ?? this.winsText,
      challengesText: clearChallengesText
          ? null
          : challengesText ?? this.challengesText,
      nextWeekFocusText: clearNextWeekFocusText
          ? null
          : nextWeekFocusText ?? this.nextWeekFocusText,
      isLocked: isLocked ?? this.isLocked,
    )..isarId = isarId;

    return review;
  }
}
