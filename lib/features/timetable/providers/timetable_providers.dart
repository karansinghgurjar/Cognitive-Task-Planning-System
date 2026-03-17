import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/isar_providers.dart';
import '../../sync/providers/sync_providers.dart';
import '../data/timetable_repository.dart';
import '../models/timetable_slot.dart';

final timetableRepositoryProvider = FutureProvider<TimetableRepository>((
  ref,
) async {
  final isar = await ref.watch(isarInstanceProvider.future);
  final syncMutationRecorder = await ref.watch(syncMutationRecorderProvider.future);
  return TimetableRepository(isar, syncMutationRecorder: syncMutationRecorder);
});

final watchTimetableSlotsProvider = StreamProvider<List<TimetableSlot>>((
  ref,
) async* {
  final repository = await ref.watch(timetableRepositoryProvider.future);
  yield* repository.watchAllSlots();
});

final timetableActionControllerProvider =
    AsyncNotifierProvider<TimetableActionController, void>(
      TimetableActionController.new,
    );

class TimetableActionController extends AsyncNotifier<void> {
  @override
  void build() {}

  Future<void> addSlot(TimetableSlot slot) async {
    _ensureIdle();
    await _run(() async {
      final repository = await ref.read(timetableRepositoryProvider.future);
      await repository.addSlot(slot);
    });
  }

  Future<void> updateSlot(TimetableSlot slot) async {
    _ensureIdle();
    await _run(() async {
      final repository = await ref.read(timetableRepositoryProvider.future);
      await repository.updateSlot(slot);
    });
  }

  Future<void> deleteSlot(String id) async {
    _ensureIdle();
    await _run(() async {
      final repository = await ref.read(timetableRepositoryProvider.future);
      await repository.deleteSlot(id);
    });
  }

  void _ensureIdle() {
    if (state.isLoading) {
      throw StateError('Another timetable action is already in progress.');
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    _ensureIdle();
    state = const AsyncLoading();
    try {
      await action();
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}
