import 'package:isar/isar.dart';

import '../domain/routine_date_utils.dart';
import '../domain/routine_enums.dart';
import '../domain/routine_repeat_rule.dart';

part 'routine.g.dart';

typedef RoutineCadenceType = RoutineRepeatType;

@collection
class Routine {
  Routine({
    required this.id,
    required String title,
    this.description,
    this.isArchived = false,
    required this.createdAt,
    DateTime? updatedAt,
    required DateTime anchorDate,
    required this.repeatRule,
    this.preferredStartMinuteOfDay,
    this.preferredDurationMinutes,
    this.timeWindowStartMinuteOfDay,
    this.timeWindowEndMinuteOfDay,
    this.isFlexible = true,
    this.autoRescheduleMissed = false,
    this.countsTowardConsistency = true,
    this.linkedGoalId,
    this.categoryId,
    List<String> tagIds = const [],
    this.routineType = RoutineType.custom,
    this.isActive = true,
    this.archivedAt,
    this.priority = 3,
    this.energyType,
    this.colorHex,
    this.iconName,
    this.remindersEnabled = false,
    this.reminderLeadMinutes,
  }) : title = title.trim(),
       updatedAt = updatedAt ?? createdAt,
       anchorDate = normalizeDate(anchorDate),
       tagIds = List<String>.from(tagIds) {
    _validate();
  }

  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String id;

  late String title;
  String? description;
  late bool isArchived;
  late DateTime createdAt;
  DateTime? updatedAt;
  late DateTime anchorDate;
  late RoutineRepeatRule repeatRule;
  int? preferredStartMinuteOfDay;
  int? preferredDurationMinutes;
  int? timeWindowStartMinuteOfDay;
  int? timeWindowEndMinuteOfDay;
  late bool isFlexible;
  late bool autoRescheduleMissed;
  late bool countsTowardConsistency;
  String? linkedGoalId;
  String? categoryId;
  late List<String> tagIds;

  @Enumerated(EnumType.name)
  late RoutineType routineType;

  late bool isActive;
  DateTime? archivedAt;
  late int priority;
  String? energyType;
  String? colorHex;
  String? iconName;
  late bool remindersEnabled;
  int? reminderLeadMinutes;

  Routine copyWith({
    String? id,
    String? title,
    String? description,
    bool clearDescription = false,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? anchorDate,
    RoutineRepeatRule? repeatRule,
    int? preferredStartMinuteOfDay,
    bool clearPreferredStartMinuteOfDay = false,
    int? preferredDurationMinutes,
    bool clearPreferredDurationMinutes = false,
    int? timeWindowStartMinuteOfDay,
    bool clearTimeWindowStartMinuteOfDay = false,
    int? timeWindowEndMinuteOfDay,
    bool clearTimeWindowEndMinuteOfDay = false,
    bool? isFlexible,
    bool? autoRescheduleMissed,
    bool? countsTowardConsistency,
    String? linkedGoalId,
    bool clearLinkedGoalId = false,
    String? categoryId,
    bool clearCategoryId = false,
    List<String>? tagIds,
    RoutineType? routineType,
    bool? isActive,
    DateTime? archivedAt,
    bool clearArchivedAt = false,
    int? priority,
    String? energyType,
    bool clearEnergyType = false,
    String? colorHex,
    bool clearColorHex = false,
    String? iconName,
    bool clearIconName = false,
    bool? remindersEnabled,
    int? reminderLeadMinutes,
    bool clearReminderLeadMinutes = false,
  }) {
    final routine = Routine(
      id: id ?? this.id,
      title: title ?? this.title,
      description: clearDescription ? null : description ?? this.description,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      anchorDate: anchorDate ?? this.anchorDate,
      repeatRule: repeatRule ?? this.repeatRule,
      preferredStartMinuteOfDay: clearPreferredStartMinuteOfDay
          ? null
          : preferredStartMinuteOfDay ?? this.preferredStartMinuteOfDay,
      preferredDurationMinutes: clearPreferredDurationMinutes
          ? null
          : preferredDurationMinutes ?? this.preferredDurationMinutes,
      timeWindowStartMinuteOfDay: clearTimeWindowStartMinuteOfDay
          ? null
          : timeWindowStartMinuteOfDay ?? this.timeWindowStartMinuteOfDay,
      timeWindowEndMinuteOfDay: clearTimeWindowEndMinuteOfDay
          ? null
          : timeWindowEndMinuteOfDay ?? this.timeWindowEndMinuteOfDay,
      isFlexible: isFlexible ?? this.isFlexible,
      autoRescheduleMissed:
          autoRescheduleMissed ?? this.autoRescheduleMissed,
      countsTowardConsistency:
          countsTowardConsistency ?? this.countsTowardConsistency,
      linkedGoalId: clearLinkedGoalId ? null : linkedGoalId ?? this.linkedGoalId,
      categoryId: clearCategoryId ? null : categoryId ?? this.categoryId,
      tagIds: tagIds ?? this.tagIds,
      routineType: routineType ?? this.routineType,
      isActive: isActive ?? this.isActive,
      archivedAt: clearArchivedAt ? null : archivedAt ?? this.archivedAt,
      priority: priority ?? this.priority,
      energyType: clearEnergyType ? null : energyType ?? this.energyType,
      colorHex: clearColorHex ? null : colorHex ?? this.colorHex,
      iconName: clearIconName ? null : iconName ?? this.iconName,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      reminderLeadMinutes: clearReminderLeadMinutes
          ? null
          : reminderLeadMinutes ?? this.reminderLeadMinutes,
    )..isarId = isarId;

    return routine;
  }

  bool get generatesOccurrences => isActive && !isArchived;

  bool get hasPreferredStartTime => preferredStartMinuteOfDay != null;

  bool get hasTimeWindow =>
      timeWindowStartMinuteOfDay != null && timeWindowEndMinuteOfDay != null;

  int? get durationMinutes => preferredDurationMinutes;

  @ignore
  List<int> get weekdays => repeatRule.weekdays;

  @ignore
  int? get dayOfMonth => repeatRule.dayOfMonth;

  @ignore
  int get interval => repeatRule.interval;

  @ignore
  RoutineRepeatType get cadenceType => repeatRule.type;

  @ignore
  int? get preferredStartHour =>
      preferredStartMinuteOfDay == null ? null : preferredStartMinuteOfDay! ~/ 60;

  @ignore
  int? get preferredStartMinute =>
      preferredStartMinuteOfDay == null ? null : preferredStartMinuteOfDay! % 60;

  @ignore
  int? get timeWindowStartMinute => timeWindowStartMinuteOfDay;

  @ignore
  int? get timeWindowEndMinute => timeWindowEndMinuteOfDay;

  @ignore
  String? get categoryTag => categoryId;

  @ignore
  List<String> get contextTags => tagIds;

  bool occursOnDate(DateTime date) {
    throw UnsupportedError(
      'Use RoutineGenerationService.computeOccurrenceDates or occursOnDate helper in the pure domain layer.',
    );
  }

  void _validate() {
    if (title.isEmpty) {
      throw ArgumentError.value(title, 'title', 'Routine title is required.');
    }
    if (preferredDurationMinutes != null && preferredDurationMinutes! <= 0) {
      throw ArgumentError.value(
        preferredDurationMinutes,
        'preferredDurationMinutes',
        'Preferred duration must be greater than 0.',
      );
    }
    if (preferredStartMinuteOfDay != null &&
        (preferredStartMinuteOfDay! < 0 || preferredStartMinuteOfDay! > 1439)) {
      throw ArgumentError.value(
        preferredStartMinuteOfDay,
        'preferredStartMinuteOfDay',
        'Preferred start minute must be between 0 and 1439.',
      );
    }
    if (timeWindowStartMinuteOfDay != null &&
        (timeWindowStartMinuteOfDay! < 0 || timeWindowStartMinuteOfDay! > 1439)) {
      throw ArgumentError.value(
        timeWindowStartMinuteOfDay,
        'timeWindowStartMinuteOfDay',
        'Time window start must be between 0 and 1439.',
      );
    }
    if (timeWindowEndMinuteOfDay != null &&
        (timeWindowEndMinuteOfDay! < 0 || timeWindowEndMinuteOfDay! > 1439)) {
      throw ArgumentError.value(
        timeWindowEndMinuteOfDay,
        'timeWindowEndMinuteOfDay',
        'Time window end must be between 0 and 1439.',
      );
    }
    if (timeWindowStartMinuteOfDay != null &&
        timeWindowEndMinuteOfDay != null &&
        timeWindowStartMinuteOfDay! >= timeWindowEndMinuteOfDay!) {
      throw ArgumentError(
        'Time window start must be earlier than time window end.',
      );
    }
    if (reminderLeadMinutes != null && reminderLeadMinutes! < 0) {
      throw ArgumentError.value(
        reminderLeadMinutes,
        'reminderLeadMinutes',
        'Reminder lead time must be 0 or greater.',
      );
    }
  }
}
