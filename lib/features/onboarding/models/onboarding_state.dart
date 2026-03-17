import 'package:isar/isar.dart';

part 'onboarding_state.g.dart';

@collection
class OnboardingStateRecord {
  OnboardingStateRecord({
    this.id = 1,
    this.isCompleted = false,
    this.hasBeenSeen = false,
    this.lastViewedAt,
    this.completedAt,
    this.skippedAt,
  });

  Id id;
  late bool isCompleted;
  late bool hasBeenSeen;
  DateTime? lastViewedAt;
  DateTime? completedAt;
  DateTime? skippedAt;

  OnboardingStateRecord copyWith({
    int? id,
    bool? isCompleted,
    bool? hasBeenSeen,
    DateTime? lastViewedAt,
    bool clearLastViewedAt = false,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    DateTime? skippedAt,
    bool clearSkippedAt = false,
  }) {
    return OnboardingStateRecord(
      id: id ?? this.id,
      isCompleted: isCompleted ?? this.isCompleted,
      hasBeenSeen: hasBeenSeen ?? this.hasBeenSeen,
      lastViewedAt: clearLastViewedAt
          ? null
          : lastViewedAt ?? this.lastViewedAt,
      completedAt: clearCompletedAt ? null : completedAt ?? this.completedAt,
      skippedAt: clearSkippedAt ? null : skippedAt ?? this.skippedAt,
    );
  }
}
