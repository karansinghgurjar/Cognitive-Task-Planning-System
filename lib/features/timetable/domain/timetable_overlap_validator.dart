import '../models/timetable_slot.dart';

class TimetableConflictException implements Exception {
  TimetableConflictException(this.message);

  final String message;

  @override
  String toString() => message;
}

class TimetableOverlapValidator {
  const TimetableOverlapValidator();

  void validateSlot(
    TimetableSlot candidate,
    List<TimetableSlot> existingSlots, {
    String? ignoreSlotId,
  }) {
    final conflict = findConflict(
      candidate,
      existingSlots,
      ignoreSlotId: ignoreSlotId,
    );

    if (conflict == null) {
      return;
    }

    throw TimetableConflictException(
      'This slot overlaps with "${conflict.label}" on '
      '${conflict.weekday.weekdayLabel}.',
    );
  }

  TimetableSlot? findConflict(
    TimetableSlot candidate,
    List<TimetableSlot> existingSlots, {
    String? ignoreSlotId,
  }) {
    for (final slot in existingSlots) {
      if (slot.weekday != candidate.weekday) {
        continue;
      }
      if (ignoreSlotId != null && slot.id == ignoreSlotId) {
        continue;
      }
      if (_overlaps(candidate, slot)) {
        return slot;
      }
    }
    return null;
  }

  bool _overlaps(TimetableSlot left, TimetableSlot right) {
    return left.startMinutesOfDay < right.endMinutesOfDay &&
        left.endMinutesOfDay > right.startMinutesOfDay;
  }
}
