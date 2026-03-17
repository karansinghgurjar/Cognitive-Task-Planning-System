import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/timetable/domain/timetable_overlap_validator.dart';
import 'package:study_flow/features/timetable/models/timetable_slot.dart';

void main() {
  const validator = TimetableOverlapValidator();

  group('TimetableOverlapValidator', () {
    test('allows a non-overlapping slot', () {
      final candidate = _slot('b', 1, 11, 0, 12, 0);
      final existing = [_slot('a', 1, 9, 0, 11, 0)];

      expect(
        () => validator.validateSlot(candidate, existing),
        returnsNormally,
      );
    });

    test('rejects an overlapping slot', () {
      final candidate = _slot('b', 1, 10, 30, 12, 0);
      final existing = [_slot('a', 1, 9, 0, 11, 0)];

      expect(
        () => validator.validateSlot(candidate, existing),
        throwsA(isA<TimetableConflictException>()),
      );
    });

    test('allows adjacent slots', () {
      final candidate = _slot('b', 1, 11, 0, 12, 0);
      final existing = [_slot('a', 1, 9, 0, 11, 0)];

      expect(
        () => validator.validateSlot(candidate, existing),
        returnsNormally,
      );
    });

    test('ignores the edited slot id during overlap validation', () {
      final candidate = _slot('a', 1, 9, 0, 11, 0);
      final existing = [
        _slot('a', 1, 9, 0, 11, 0),
        _slot('b', 1, 11, 0, 12, 0),
      ];

      expect(
        () => validator.validateSlot(candidate, existing, ignoreSlotId: 'a'),
        returnsNormally,
      );
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
) {
  return TimetableSlot(
    id: id,
    weekday: weekday,
    startHour: startHour,
    startMinute: startMinute,
    endHour: endHour,
    endMinute: endMinute,
    isBusy: true,
    label: 'Slot $id',
  );
}
