import 'package:isar/isar.dart';

part 'routine.g.dart';

enum RoutineType { study, health, review, project, custom }

enum RoutineCadenceType { daily, weekly, customWeekdays }

@collection
class Routine {
  Routine({
    required this.id,
    required this.title,
    this.description,
    this.routineType = RoutineType.custom,
    this.isActive = true,
    required this.durationMinutes,
    this.cadenceType = RoutineCadenceType.daily,
    List<int> weekdays = const [],
    this.preferredStartHour,
    this.preferredStartMinute,
    this.priority = 3,
    this.linkedGoalId,
    required this.createdAt,
    DateTime? updatedAt,
  }) : weekdays = List<int>.from(weekdays),
       updatedAt = updatedAt ?? createdAt;

  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String id;

  late String title;
  String? description;

  @Enumerated(EnumType.name)
  late RoutineType routineType;

  late bool isActive;
  late int durationMinutes;

  @Enumerated(EnumType.name)
  late RoutineCadenceType cadenceType;

  late List<int> weekdays;
  int? preferredStartHour;
  int? preferredStartMinute;
  late int priority;
  String? linkedGoalId;
  late DateTime createdAt;
  DateTime? updatedAt;

  Routine copyWith({
    String? id,
    String? title,
    String? description,
    bool clearDescription = false,
    RoutineType? routineType,
    bool? isActive,
    int? durationMinutes,
    RoutineCadenceType? cadenceType,
    List<int>? weekdays,
    int? preferredStartHour,
    bool clearPreferredStartHour = false,
    int? preferredStartMinute,
    bool clearPreferredStartMinute = false,
    int? priority,
    String? linkedGoalId,
    bool clearLinkedGoalId = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final routine = Routine(
      id: id ?? this.id,
      title: title ?? this.title,
      description: clearDescription ? null : description ?? this.description,
      routineType: routineType ?? this.routineType,
      isActive: isActive ?? this.isActive,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      cadenceType: cadenceType ?? this.cadenceType,
      weekdays: weekdays ?? this.weekdays,
      preferredStartHour: clearPreferredStartHour
          ? null
          : preferredStartHour ?? this.preferredStartHour,
      preferredStartMinute: clearPreferredStartMinute
          ? null
          : preferredStartMinute ?? this.preferredStartMinute,
      priority: priority ?? this.priority,
      linkedGoalId: clearLinkedGoalId ? null : linkedGoalId ?? this.linkedGoalId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    )..isarId = isarId;

    return routine;
  }

  bool get hasPreferredStartTime =>
      preferredStartHour != null && preferredStartMinute != null;

  bool occursOnWeekday(int weekday) {
    switch (cadenceType) {
      case RoutineCadenceType.daily:
        return true;
      case RoutineCadenceType.weekly:
      case RoutineCadenceType.customWeekdays:
        return weekdays.contains(weekday);
    }
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
}

extension RoutineCadenceTypeX on RoutineCadenceType {
  String get label {
    switch (this) {
      case RoutineCadenceType.daily:
        return 'Daily';
      case RoutineCadenceType.weekly:
        return 'Weekly';
      case RoutineCadenceType.customWeekdays:
        return 'Custom Weekdays';
    }
  }
}
