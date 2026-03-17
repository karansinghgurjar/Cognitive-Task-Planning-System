import 'package:isar/isar.dart';

import '../../sync/data/sync_mutation_recorder.dart';
import '../../sync/domain/sync_models.dart';
import '../domain/timetable_overlap_validator.dart';
import '../models/timetable_slot.dart';

class TimetableRepository {
  TimetableRepository(
    this._isar, {
    TimetableOverlapValidator overlapValidator =
        const TimetableOverlapValidator(),
    SyncMutationRecorder syncMutationRecorder = const NoopSyncMutationRecorder(),
  }) : _overlapValidator = overlapValidator,
       _syncMutationRecorder = syncMutationRecorder;

  final Isar _isar;
  final TimetableOverlapValidator _overlapValidator;
  final SyncMutationRecorder _syncMutationRecorder;

  Future<List<TimetableSlot>> getAllSlots() async {
    final slots = await _isar.timetableSlots.where().findAll();
    slots.sort(_compareSlots);
    return slots;
  }

  Stream<List<TimetableSlot>> watchAllSlots() {
    return _isar.timetableSlots.watchLazy(fireImmediately: true).asyncMap((_) {
      return getAllSlots();
    });
  }

  Future<void> addSlot(TimetableSlot slot) async {
    await _ensureNoOverlap(slot);
    await _isar.writeTxn(() async {
      await _isar.timetableSlots.put(slot);
    });
    await _syncMutationRecorder.recordUpsert(
      entityType: SyncEntityType.timetableSlot,
      entityId: slot.id,
      entity: slot,
      operationType: SyncOperationType.create,
    );
  }

  Future<void> updateSlot(TimetableSlot slot) async {
    await _ensureNoOverlap(slot, ignoreSlotId: slot.id);
    await _isar.writeTxn(() async {
      await _isar.timetableSlots.put(slot);
    });
    await _syncMutationRecorder.recordUpsert(
      entityType: SyncEntityType.timetableSlot,
      entityId: slot.id,
      entity: slot,
      operationType: SyncOperationType.update,
    );
  }

  Future<void> deleteSlot(String id) async {
    final slot = await _isar.timetableSlots.filter().idEqualTo(id).findFirst();
    if (slot == null) {
      return;
    }

    await _isar.writeTxn(() async {
      await _isar.timetableSlots.delete(slot.isarId);
    });
    await _syncMutationRecorder.recordDelete(
      entityType: SyncEntityType.timetableSlot,
      entityId: id,
    );
  }

  Future<List<TimetableSlot>> getSlotsForWeekday(int weekday) async {
    final slots = await _isar.timetableSlots
        .filter()
        .weekdayEqualTo(weekday)
        .findAll();
    slots.sort(_compareSlots);
    return slots;
  }

  Future<void> _ensureNoOverlap(
    TimetableSlot candidate, {
    String? ignoreSlotId,
  }) async {
    final sameDaySlots = await getSlotsForWeekday(candidate.weekday);
    _overlapValidator.validateSlot(
      candidate,
      sameDaySlots,
      ignoreSlotId: ignoreSlotId,
    );
  }

  int _compareSlots(TimetableSlot left, TimetableSlot right) {
    final weekdayCompare = left.weekday.compareTo(right.weekday);
    if (weekdayCompare != 0) {
      return weekdayCompare;
    }

    final hourCompare = left.startHour.compareTo(right.startHour);
    if (hourCompare != 0) {
      return hourCompare;
    }

    return left.startMinute.compareTo(right.startMinute);
  }
}
