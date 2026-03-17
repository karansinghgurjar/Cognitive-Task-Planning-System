import '../models/timetable_slot.dart';

class AvailabilityWindow {
  const AvailabilityWindow({
    required this.weekday,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
  });

  final int weekday;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;

  int get startMinutesOfDay => (startHour * 60) + startMinute;

  int get endMinutesOfDay => (endHour * 60) + endMinute;
}

class AvailabilityService {
  const AvailabilityService({
    this.dayStartMinutes = 6 * 60,
    this.dayEndMinutes = 23 * 60,
  });

  final int dayStartMinutes;
  final int dayEndMinutes;

  List<AvailabilityWindow> computeAvailabilityForDay(
    int weekday,
    List<TimetableSlot> allSlots,
  ) {
    final busySlots =
        allSlots
            .where((slot) => slot.weekday == weekday && slot.isBusy)
            .toList()
          ..sort(_compareSlots);

    if (busySlots.isEmpty) {
      return [_windowFromMinutes(weekday, dayStartMinutes, dayEndMinutes)];
    }

    final mergedBusyRanges = <_Range>[];
    for (final slot in busySlots) {
      final start = slot.startMinutesOfDay.clamp(
        dayStartMinutes,
        dayEndMinutes,
      );
      final end = slot.endMinutesOfDay.clamp(dayStartMinutes, dayEndMinutes);
      if (start >= end) {
        continue;
      }

      final currentRange = _Range(start, end);
      if (mergedBusyRanges.isEmpty) {
        mergedBusyRanges.add(currentRange);
        continue;
      }

      final last = mergedBusyRanges.last;
      if (currentRange.start <= last.end) {
        mergedBusyRanges[mergedBusyRanges.length - 1] = _Range(
          last.start,
          currentRange.end > last.end ? currentRange.end : last.end,
        );
      } else {
        mergedBusyRanges.add(currentRange);
      }
    }

    if (mergedBusyRanges.isEmpty) {
      return [_windowFromMinutes(weekday, dayStartMinutes, dayEndMinutes)];
    }

    final windows = <AvailabilityWindow>[];
    var cursor = dayStartMinutes;

    for (final busyRange in mergedBusyRanges) {
      if (cursor < busyRange.start) {
        windows.add(_windowFromMinutes(weekday, cursor, busyRange.start));
      }
      if (busyRange.end > cursor) {
        cursor = busyRange.end;
      }
    }

    if (cursor < dayEndMinutes) {
      windows.add(_windowFromMinutes(weekday, cursor, dayEndMinutes));
    }

    return windows;
  }

  Map<int, List<AvailabilityWindow>> computeWeeklyAvailability(
    List<TimetableSlot> allSlots,
  ) {
    return {
      for (var weekday = 1; weekday <= 7; weekday++)
        weekday: computeAvailabilityForDay(weekday, allSlots),
    };
  }

  int _compareSlots(TimetableSlot left, TimetableSlot right) {
    final startCompare = left.startMinutesOfDay.compareTo(
      right.startMinutesOfDay,
    );
    if (startCompare != 0) {
      return startCompare;
    }
    return left.endMinutesOfDay.compareTo(right.endMinutesOfDay);
  }

  AvailabilityWindow _windowFromMinutes(int weekday, int start, int end) {
    return AvailabilityWindow(
      weekday: weekday,
      startHour: start ~/ 60,
      startMinute: start % 60,
      endHour: end ~/ 60,
      endMinute: end % 60,
    );
  }
}

class _Range {
  const _Range(this.start, this.end);

  final int start;
  final int end;
}
