import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/timetable/domain/availability_service.dart';
import 'package:study_flow/features/timetable/models/timetable_slot.dart';

void main() {
  const service = AvailabilityService();

  group('AvailabilityService', () {
    test('returns full day when there are no slots', () {
      final windows = service.computeAvailabilityForDay(1, const []);

      expect(windows, hasLength(1));
      expect(windows.first.startHour, 6);
      expect(windows.first.startMinute, 0);
      expect(windows.first.endHour, 23);
      expect(windows.first.endMinute, 0);
    });

    test('subtracts one busy slot from the day', () {
      final windows = service.computeAvailabilityForDay(1, [
        _slot('a', 1, 9, 0, 11, 0, true),
      ]);

      expect(_asRanges(windows), ['06:00-09:00', '11:00-23:00']);
    });

    test('subtracts multiple busy slots from the day', () {
      final windows = service.computeAvailabilityForDay(1, [
        _slot('a', 1, 9, 0, 11, 0, true),
        _slot('b', 1, 14, 0, 16, 0, true),
      ]);

      expect(_asRanges(windows), ['06:00-09:00', '11:00-14:00', '16:00-23:00']);
    });

    test('treats adjacent busy slots as one continuous blocked period', () {
      final windows = service.computeAvailabilityForDay(1, [
        _slot('a', 1, 9, 0, 11, 0, true),
        _slot('b', 1, 11, 0, 12, 0, true),
      ]);

      expect(_asRanges(windows), ['06:00-09:00', '12:00-23:00']);
    });

    test('ignores free slots when computing availability', () {
      final windows = service.computeAvailabilityForDay(1, [
        _slot('a', 1, 8, 0, 10, 0, false),
      ]);

      expect(_asRanges(windows), ['06:00-23:00']);
    });
  });
}

TimetableSlot _slot(
  String id,
  int weekday,
  int startHour,
  int startMinute,
  int endHour,
  int endMinute,
  bool isBusy,
) {
  return TimetableSlot(
    id: id,
    weekday: weekday,
    startHour: startHour,
    startMinute: startMinute,
    endHour: endHour,
    endMinute: endMinute,
    isBusy: isBusy,
    label: 'Slot $id',
  );
}

List<String> _asRanges(List<AvailabilityWindow> windows) {
  String two(int value) => value.toString().padLeft(2, '0');

  return windows
      .map(
        (window) =>
            '${two(window.startHour)}:${two(window.startMinute)}-'
            '${two(window.endHour)}:${two(window.endMinute)}',
      )
      .toList();
}
