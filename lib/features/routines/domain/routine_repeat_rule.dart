import 'package:isar/isar.dart';

import 'routine_enums.dart';

part 'routine_repeat_rule.g.dart';

@embedded
class RoutineRepeatRule {
  RoutineRepeatRule({
    this.type = RoutineRepeatType.daily,
    this.interval = 1,
    List<int> weekdays = const [],
    this.dayOfMonth,
  }) : weekdays = List<int>.from(weekdays) {
    _validate();
  }

  @Enumerated(EnumType.name)
  late RoutineRepeatType type;

  late int interval;
  late List<int> weekdays;
  int? dayOfMonth;

  RoutineRepeatRule copyWith({
    RoutineRepeatType? type,
    int? interval,
    List<int>? weekdays,
    int? dayOfMonth,
    bool clearDayOfMonth = false,
  }) {
    return RoutineRepeatRule(
      type: type ?? this.type,
      interval: interval ?? this.interval,
      weekdays: weekdays ?? this.weekdays,
      dayOfMonth: clearDayOfMonth ? null : dayOfMonth ?? this.dayOfMonth,
    );
  }

  void _validate() {
    if (interval < 1) {
      throw ArgumentError.value(interval, 'interval', 'Must be at least 1.');
    }

    final uniqueWeekdays = {...weekdays}.toList()..sort();
    if (uniqueWeekdays.length != weekdays.length) {
      throw ArgumentError.value(
        weekdays,
        'weekdays',
        'Weekdays must not contain duplicates.',
      );
    }
    if (uniqueWeekdays.any((weekday) => weekday < 1 || weekday > 7)) {
      throw ArgumentError.value(
        weekdays,
        'weekdays',
        'Weekdays must use values from 1 (Mon) to 7 (Sun).',
      );
    }

    if (type == RoutineRepeatType.selectedWeekdays && uniqueWeekdays.isEmpty) {
      throw ArgumentError.value(
        weekdays,
        'weekdays',
        'Selected weekdays requires at least one weekday.',
      );
    }

    if (type == RoutineRepeatType.weekdays && weekdays.isNotEmpty) {
      throw ArgumentError.value(
        weekdays,
        'weekdays',
        'Weekdays repeat rule does not accept a custom weekday list.',
      );
    }

    if (type == RoutineRepeatType.weekdays && interval != 1) {
      throw ArgumentError.value(
        interval,
        'interval',
        'Weekdays repeat rule only supports interval 1 in Phase 1.',
      );
    }

    if (dayOfMonth != null && (dayOfMonth! < 1 || dayOfMonth! > 31)) {
      throw ArgumentError.value(
        dayOfMonth,
        'dayOfMonth',
        'Day of month must be between 1 and 31.',
      );
    }
  }
}
