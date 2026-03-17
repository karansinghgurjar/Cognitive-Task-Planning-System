import 'package:isar/isar.dart';

part 'timetable_slot.g.dart';

@collection
class TimetableSlot {
  TimetableSlot({
    required this.id,
    required this.weekday,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
    required this.isBusy,
    required this.label,
  });

  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String id;

  late int weekday;
  late int startHour;
  late int startMinute;
  late int endHour;
  late int endMinute;
  late bool isBusy;
  late String label;

  TimetableSlot copyWith({
    String? id,
    int? weekday,
    int? startHour,
    int? startMinute,
    int? endHour,
    int? endMinute,
    bool? isBusy,
    String? label,
  }) {
    final slot = TimetableSlot(
      id: id ?? this.id,
      weekday: weekday ?? this.weekday,
      startHour: startHour ?? this.startHour,
      startMinute: startMinute ?? this.startMinute,
      endHour: endHour ?? this.endHour,
      endMinute: endMinute ?? this.endMinute,
      isBusy: isBusy ?? this.isBusy,
      label: label ?? this.label,
    )..isarId = isarId;

    return slot;
  }

  int get startMinutesOfDay => (startHour * 60) + startMinute;

  int get endMinutesOfDay => (endHour * 60) + endMinute;
}

extension TimetableWeekdayX on int {
  String get weekdayLabel {
    switch (this) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return 'Unknown';
    }
  }
}
