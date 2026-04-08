import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/routine_enums.dart';
import '../domain/routine_scheduling_service.dart';
import '../models/routine_occurrence.dart';

typedef RoutineOccurrenceByIdLoader = Future<RoutineOccurrence?> Function(
  String occurrenceId,
);
typedef RoutineOccurrenceUpdater = Future<void> Function(
  RoutineOccurrence occurrence,
);

class RoutineOccurrenceController extends StateNotifier<AsyncValue<void>> {
  RoutineOccurrenceController({
    required RoutineOccurrenceByIdLoader loadOccurrenceById,
    required RoutineOccurrenceUpdater updateOccurrence,
    required RoutineSchedulingService schedulingService,
    required DateTime Function() nowProvider,
  }) : _loadOccurrenceById = loadOccurrenceById,
       _updateOccurrence = updateOccurrence,
       _schedulingService = schedulingService,
       _nowProvider = nowProvider,
       super(const AsyncData(null));

  final RoutineOccurrenceByIdLoader _loadOccurrenceById;
  final RoutineOccurrenceUpdater _updateOccurrence;
  final RoutineSchedulingService _schedulingService;
  final DateTime Function() _nowProvider;

  Future<void> completeOccurrence(String occurrenceId) async {
    await _run(() async {
      final occurrence = await _loadOccurrenceById(occurrenceId);
      if (occurrence == null ||
          occurrence.status == RoutineOccurrenceStatus.completed) {
        return;
      }
      final now = _nowProvider();
      await _updateOccurrence(
        occurrence.copyWith(
          status: RoutineOccurrenceStatus.completed,
          completedAt: now,
          clearSkippedAt: true,
          clearMissedAt: true,
          updatedAt: now,
        ),
      );
    });
  }

  Future<void> skipOccurrence(String occurrenceId) async {
    await _run(() async {
      final occurrence = await _loadOccurrenceById(occurrenceId);
      if (occurrence == null ||
          occurrence.status == RoutineOccurrenceStatus.skipped) {
        return;
      }
      if (occurrence.status == RoutineOccurrenceStatus.completed) {
        return;
      }
      final now = _nowProvider();
      await _updateOccurrence(
        occurrence.copyWith(
          status: RoutineOccurrenceStatus.skipped,
          skippedAt: now,
          clearCompletedAt: true,
          clearMissedAt: true,
          updatedAt: now,
        ),
      );
    });
  }

  Future<void> snoozeOccurrence(
    String occurrenceId,
    DateTime newStart, {
    String? notes,
  }) async {
    await _run(() async {
      final occurrence = await _loadOccurrenceById(occurrenceId);
      if (occurrence == null ||
          occurrence.status == RoutineOccurrenceStatus.completed ||
          occurrence.status == RoutineOccurrenceStatus.skipped) {
        return;
      }
      await _updateOccurrence(
        _schedulingService.rescheduleOccurrence(
          occurrence: occurrence,
          newStart: newStart,
          notes: notes,
          now: _nowProvider(),
        ),
      );
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    if (state.isLoading) {
      throw StateError('Another routine occurrence action is already in progress.');
    }
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
