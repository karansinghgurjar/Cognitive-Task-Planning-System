import 'package:isar/isar.dart';

part 'routine.g.dart';

enum RoutineType { study, health, review, project, custom }

enum RoutineCadenceType {
  daily,
  weekdays,
  customWeekdays,
  weekly,
  monthly,
  custom,
}

@collection
class Routine {
  Routine({
    required this.id,
    required this.title,
    this.description,
    this.categoryTag,
    this.routineType = RoutineType.custom,
    this.isActive = true,
    this.isArchived = false,
    this.archivedAt,
    required this.durationMinutes,
    this.cadenceType = RoutineCadenceType.daily,
    List<int> weekdays = const [],
    this.dayOfMonth,
    this.interval = 1,
    this.anchorDate,
    this.preferredStartHour,
    this.preferredStartMinute,
    this.timeWindowStartMinute,
    this.timeWindowEndMinute,
    this.priority = 3,
    this.isFlexible = true,
    this.autoRescheduleMissed = false,
    this.countsTowardConsistency = true,
    this.linkedGoalId,
    this.energyType,
    List<String> contextTags = const [],
    this.colorHex,
    this.iconName,
    required this.createdAt,
    DateTime? updatedAt,
  }) : weekdays = List<int>.from(weekdays),
       contextTags = List<String>.from(contextTags),
       updatedAt = updatedAt ?? createdAt;

  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String id;

  late String title;
  String? description;
  String? categoryTag;

  @Enumerated(EnumType.name)
  late RoutineType routineType;

  late bool isActive;
  late bool isArchived;
  DateTime? archivedAt;
  late int durationMinutes;

  @Enumerated(EnumType.name)
  late RoutineCadenceType cadenceType;

  late List<int> weekdays;
  int? dayOfMonth;
  late int interval;
  DateTime? anchorDate;
  int? preferredStartHour;
  int? preferredStartMinute;
  int? timeWindowStartMinute;
  int? timeWindowEndMinute;
  late int priority;
  late bool isFlexible;
  late bool autoRescheduleMissed;
  late bool countsTowardConsistency;
  String? linkedGoalId;
  String? energyType;
  late List<String> contextTags;
  String? colorHex;
  String? iconName;
  late DateTime createdAt;
  DateTime? updatedAt;

  Routine copyWith({
    String? id,
    String? title,
    String? description,
    bool clearDescription = false,
    String? categoryTag,
    bool clearCategoryTag = false,
    RoutineType? routineType,
    bool? isActive,
    bool? isArchived,
    DateTime? archivedAt,
    bool clearArchivedAt = false,
    int? durationMinutes,
    RoutineCadenceType? cadenceType,
    List<int>? weekdays,
    int? dayOfMonth,
    bool clearDayOfMonth = false,
    int? interval,
    DateTime? anchorDate,
    bool clearAnchorDate = false,
    int? preferredStartHour,
    bool clearPreferredStartHour = false,
    int? preferredStartMinute,
    bool clearPreferredStartMinute = false,
    int? timeWindowStartMinute,
    bool clearTimeWindowStartMinute = false,
    int? timeWindowEndMinute,
    bool clearTimeWindowEndMinute = false,
    int? priority,
    bool? isFlexible,
    bool? autoRescheduleMissed,
    bool? countsTowardConsistency,
    String? linkedGoalId,
    bool clearLinkedGoalId = false,
    String? energyType,
    bool clearEnergyType = false,
    List<String>? contextTags,
    String? colorHex,
    bool clearColorHex = false,
    String? iconName,
    bool clearIconName = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final routine = Routine(
      id: id ?? this.id,
      title: title ?? this.title,
      description: clearDescription ? null : description ?? this.description,
      categoryTag: clearCategoryTag ? null : categoryTag ?? this.categoryTag,
      routineType: routineType ?? this.routineType,
      isActive: isActive ?? this.isActive,
      isArchived: isArchived ?? this.isArchived,
      archivedAt: clearArchivedAt ? null : archivedAt ?? this.archivedAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      cadenceType: cadenceType ?? this.cadenceType,
      weekdays: weekdays ?? this.weekdays,
      dayOfMonth: clearDayOfMonth ? null : dayOfMonth ?? this.dayOfMonth,
      interval: interval ?? this.interval,
      anchorDate: clearAnchorDate ? null : anchorDate ?? this.anchorDate,
      preferredStartHour: clearPreferredStartHour
          ? null
          : preferredStartHour ?? this.preferredStartHour,
      preferredStartMinute: clearPreferredStartMinute
          ? null
          : preferredStartMinute ?? this.preferredStartMinute,
      timeWindowStartMinute: clearTimeWindowStartMinute
          ? null
          : timeWindowStartMinute ?? this.timeWindowStartMinute,
      timeWindowEndMinute: clearTimeWindowEndMinute
          ? null
          : timeWindowEndMinute ?? this.timeWindowEndMinute,
      priority: priority ?? this.priority,
      isFlexible: isFlexible ?? this.isFlexible,
      autoRescheduleMissed:
          autoRescheduleMissed ?? this.autoRescheduleMissed,
      countsTowardConsistency:
          countsTowardConsistency ?? this.countsTowardConsistency,
      linkedGoalId: clearLinkedGoalId ? null : linkedGoalId ?? this.linkedGoalId,
      energyType: clearEnergyType ? null : energyType ?? this.energyType,
      contextTags: contextTags ?? this.contextTags,
      colorHex: clearColorHex ? null : colorHex ?? this.colorHex,
      iconName: clearIconName ? null : iconName ?? this.iconName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    )..isarId = isarId;

    return routine;
  }

  bool get hasPreferredStartTime =>
      preferredStartHour != null && preferredStartMinute != null;

  bool get hasTimeWindow =>
      timeWindowStartMinute != null && timeWindowEndMinute != null;

  bool get generatesOccurrences => isActive && !isArchived;

  int? get preferredStartMinuteOfDay {
    if (!hasPreferredStartTime) {
      return null;
    }
    return preferredStartHour! * 60 + preferredStartMinute!;
  }

  bool occursOnDate(DateTime date) {
    if (!generatesOccurrences) {
      return false;
    }

    final normalizedDate = DateTime(date.year, date.month, date.day);
    final anchor = _normalizedAnchorDate;
    if (normalizedDate.isBefore(anchor)) {
      return false;
    }

    switch (cadenceType) {
      case RoutineCadenceType.daily:
        return _daysBetween(anchor, normalizedDate) % interval == 0;
      case RoutineCadenceType.weekdays:
        return _daysBetween(anchor, normalizedDate) % interval == 0 &&
            normalizedDate.weekday >= DateTime.monday &&
            normalizedDate.weekday <= DateTime.friday;
      case RoutineCadenceType.customWeekdays:
        return _daysBetween(anchor, normalizedDate) % interval == 0 &&
            weekdays.contains(normalizedDate.weekday);
      case RoutineCadenceType.weekly:
        final effectiveWeekdays = weekdays.isEmpty ? [anchor.weekday] : weekdays;
        final weekDelta = _weeksBetween(anchor, normalizedDate);
        return weekDelta >= 0 &&
            weekDelta % interval == 0 &&
            effectiveWeekdays.contains(normalizedDate.weekday);
      case RoutineCadenceType.monthly:
        final effectiveDay = dayOfMonth ?? anchor.day;
        if (normalizedDate.day != effectiveDay) {
          return false;
        }
        final monthDelta = _monthsBetween(anchor, normalizedDate);
        return monthDelta >= 0 && monthDelta % interval == 0;
      case RoutineCadenceType.custom:
        if (weekdays.isNotEmpty) {
          return weekdays.contains(normalizedDate.weekday);
        }
        return _daysBetween(anchor, normalizedDate) % interval == 0;
    }
  }

  DateTime get _normalizedAnchorDate {
    final value = anchorDate ?? createdAt;
    return DateTime(value.year, value.month, value.day);
  }

  int _daysBetween(DateTime start, DateTime end) {
    return end.difference(start).inDays;
  }

  int _weeksBetween(DateTime start, DateTime end) {
    return _daysBetween(start, end) ~/ 7;
  }

  int _monthsBetween(DateTime start, DateTime end) {
    return (end.year - start.year) * 12 + end.month - start.month;
  }
}

extension RoutineTypeX on RoutineType {
  String get label {
    switch (this) {
      case RoutineType.study:
        return 'Study';
      case RoutineType.health:
        return 'Health';
      case RoutineType.review:
        return 'Review';
      case RoutineType.project:
        return 'Project';
      case RoutineType.custom:
        return 'Custom';
    }
  }

  String get defaultCategoryTag {
    switch (this) {
      case RoutineType.study:
        return 'Study';
      case RoutineType.health:
        return 'Health';
      case RoutineType.review:
        return 'Review';
      case RoutineType.project:
        return 'Project';
      case RoutineType.custom:
        return 'Routine';
    }
  }
}

extension RoutineCadenceTypeX on RoutineCadenceType {
  String get label {
    switch (this) {
      case RoutineCadenceType.daily:
        return 'Daily';
      case RoutineCadenceType.weekdays:
        return 'Weekdays';
      case RoutineCadenceType.customWeekdays:
        return 'Specific Days';
      case RoutineCadenceType.weekly:
        return 'Weekly';
      case RoutineCadenceType.monthly:
        return 'Monthly';
      case RoutineCadenceType.custom:
        return 'Custom';
    }
  }
}
