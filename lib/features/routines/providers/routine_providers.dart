import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/isar_providers.dart';
import '../../schedule/providers/schedule_providers.dart';
import '../../timetable/providers/timetable_providers.dart';
import '../data/routine_occurrence_repository.dart';
import '../data/routine_repository.dart';
import '../domain/routine_scheduling_service.dart';
import '../models/routine.dart';
import '../models/routine_occurrence.dart';

final routineRepositoryProvider = FutureProvider<RoutineRepository>((ref) async {
  final isar = await ref.watch(isarInstanceProvider.future);
  return RoutineRepository(isar);
});

final routineOccurrenceRepositoryProvider =
    FutureProvider<RoutineOccurrenceRepository>((ref) async {
  final isar = await ref.watch(isarInstanceProvider.future);
  return RoutineOccurrenceRepository(isar);
});

final routineSchedulingServiceProvider = Provider<RoutineSchedulingService>((ref) {
  return RoutineSchedulingService();
});

final watchAllRoutinesProvider = StreamProvider<List<Routine>>((ref) async* {
  final repository = await ref.watch(routineRepositoryProvider.future);
  yield* repository.watchAllRoutines();
});

final watchActiveRoutinesProvider = StreamProvider<List<Routine>>((ref) async* {
  final repository = await ref.watch(routineRepositoryProvider.future);
  yield* repository.watchActiveRoutines();
});

final watchAllRoutineOccurrencesProvider =
    StreamProvider<List<RoutineOccurrence>>((ref) async* {
  final repository = await ref.watch(routineOccurrenceRepositoryProvider.future);
  yield* repository.watchAllOccurrences();
});

class RoutinePreviewState {
  const RoutinePreviewState({
    required this.nextOccurrenceByRoutineId,
    required this.generatedCount,
    required this.skippedCount,
  });

  final Map<String, RoutineOccurrence?> nextOccurrenceByRoutineId;
  final int generatedCount;
  final int skippedCount;
}

final routinePreviewProvider = Provider<AsyncValue<RoutinePreviewState>>((ref) {
  final routinesAsync = ref.watch(watchAllRoutinesProvider);
  final slotsAsync = ref.watch(watchTimetableSlotsProvider);
  final sessionsAsync = ref.watch(watchAllSessionsProvider);
  final occurrencesAsync = ref.watch(watchAllRoutineOccurrencesProvider);

  return switch ((routinesAsync, slotsAsync, sessionsAsync, occurrencesAsync)) {
    (
      AsyncData(value: final routines),
      AsyncData(value: final slots),
      AsyncData(value: final sessions),
      AsyncData(value: final occurrences),
    ) =>
      AsyncData(() {
        final service = ref.read(routineSchedulingServiceProvider);
        final now = DateTime.now();
        final nextOccurrenceByRoutineId = <String, RoutineOccurrence?>{};
        var generatedCount = 0;
        var skippedCount = 0;

        for (final routine in routines) {
          final preview = service.nextOccurrencePreview(
            routine: routine,
            timetableSlots: slots,
            plannedSessions: sessions,
            existingOccurrences: occurrences,
            now: now,
          );
          nextOccurrenceByRoutineId[routine.id] = preview;
          if (preview != null) {
            generatedCount += 1;
          } else if (routine.isActive) {
            skippedCount += 1;
          }
        }

        return RoutinePreviewState(
          nextOccurrenceByRoutineId: nextOccurrenceByRoutineId,
          generatedCount: generatedCount,
          skippedCount: skippedCount,
        );
      }()),
    (AsyncError(:final error, :final stackTrace), _, _, _) => AsyncError(
      error,
      stackTrace,
    ),
    (_, AsyncError(:final error, :final stackTrace), _, _) => AsyncError(
      error,
      stackTrace,
    ),
    (_, _, AsyncError(:final error, :final stackTrace), _) => AsyncError(
      error,
      stackTrace,
    ),
    (_, _, _, AsyncError(:final error, :final stackTrace)) => AsyncError(
      error,
      stackTrace,
    ),
    _ => const AsyncLoading(),
  };
});

final routineRecommendationActionsProvider =
    Provider<AsyncValue<List<String>>>((ref) {
  final routinesAsync = ref.watch(watchActiveRoutinesProvider);
  final occurrencesAsync = ref.watch(watchAllRoutineOccurrencesProvider);

  return switch ((routinesAsync, occurrencesAsync)) {
    (
      AsyncData(value: final routines),
      AsyncData(value: final occurrences),
    ) =>
      AsyncData(_buildRoutineActions(routines, occurrences, DateTime.now())),
    (AsyncError(:final error, :final stackTrace), _) => AsyncError(
      error,
      stackTrace,
    ),
    (_, AsyncError(:final error, :final stackTrace)) => AsyncError(
      error,
      stackTrace,
    ),
    _ => const AsyncLoading(),
  };
});

List<String> _buildRoutineActions(
  List<Routine> routines,
  List<RoutineOccurrence> occurrences,
  DateTime now,
) {
  final actions = <String>[];
  if (routines.isEmpty) {
    return actions;
  }

  final horizonEnd = now.add(const Duration(days: 7));
  final upcomingOccurrences = occurrences.where((occurrence) {
    return occurrence.scheduledStart.isBefore(horizonEnd) &&
        occurrence.scheduledEnd.isAfter(now);
  }).toList();

  if (upcomingOccurrences.isEmpty) {
    actions.add(
      'Generate your next 7 days of routine blocks to protect repeated work.',
    );
  }

  final weeklyReviewRoutine = routines
      .where(
        (routine) =>
            routine.routineType == RoutineType.review ||
            routine.title.toLowerCase().contains('weekly review'),
      )
      .firstOrNull;
  if (weeklyReviewRoutine != null) {
    final weekEnd = now.add(Duration(days: DateTime.sunday - now.weekday + 1));
    final hasPendingReview = occurrences.any((occurrence) {
      return occurrence.routineId == weeklyReviewRoutine.id &&
          occurrence.scheduledStart.isBefore(weekEnd) &&
          occurrence.effectiveStatusAt(now) == RoutineOccurrenceStatus.pending;
    });
    if (!hasPendingReview) {
      actions.add('Protect a weekly review routine block before this week ends.');
    }
  }

  final totalWeeklyMinutes = routines.fold<int>(
    0,
    (sum, routine) => sum + (routine.durationMinutes * _weeklyOccurrences(routine)),
  );
  if (totalWeeklyMinutes > 16 * 60) {
    actions.add(
      'Your routine load is heavy. Reduce durations or weekdays if task planning starts feeling crowded.',
    );
  }

  return actions.toSet().toList();
}

int _weeklyOccurrences(Routine routine) {
  switch (routine.cadenceType) {
    case RoutineCadenceType.daily:
      return 7;
    case RoutineCadenceType.weekly:
    case RoutineCadenceType.customWeekdays:
      return routine.weekdays.length;
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

final routineActionControllerProvider =
    AsyncNotifierProvider<RoutineActionController, void>(
      RoutineActionController.new,
    );

class RoutineActionController extends AsyncNotifier<void> {
  @override
  void build() {}

  Future<void> addRoutine(Routine routine) async {
    await _run(() async {
      final repository = await ref.read(routineRepositoryProvider.future);
      await repository.addRoutine(routine);
      await _regenerateFutureOccurrences(days: 7);
    });
  }

  Future<void> updateRoutine(Routine routine) async {
    await _run(() async {
      final repository = await ref.read(routineRepositoryProvider.future);
      await repository.updateRoutine(routine);
      await _regenerateFutureOccurrences(days: 7);
    });
  }

  Future<void> deleteRoutine(String routineId) async {
    await _run(() async {
      final routineRepository = await ref.read(routineRepositoryProvider.future);
      final occurrenceRepository = await ref.read(
        routineOccurrenceRepositoryProvider.future,
      );
      await routineRepository.deleteRoutine(routineId);
      await occurrenceRepository.deleteForRoutine(routineId);
    });
  }

  Future<void> setActive(Routine routine, bool isActive) async {
    await updateRoutine(routine.copyWith(isActive: isActive));
  }

  Future<void> generateNext7Days() =>
      _run(() => _regenerateFutureOccurrences(days: 7));

  Future<void> generateNext30Days() =>
      _run(() => _regenerateFutureOccurrences(days: 30));

  Future<void> markOccurrenceCompleted(RoutineOccurrence occurrence) async {
    await _run(() async {
      final repository = await ref.read(routineOccurrenceRepositoryProvider.future);
      await repository.updateOccurrence(
        occurrence.copyWith(status: RoutineOccurrenceStatus.completed),
      );
    });
  }

  Future<void> markOccurrenceCancelled(RoutineOccurrence occurrence) async {
    await _run(() async {
      final repository = await ref.read(routineOccurrenceRepositoryProvider.future);
      await repository.updateOccurrence(
        occurrence.copyWith(status: RoutineOccurrenceStatus.cancelled),
      );
    });
  }

  Future<void> _regenerateFutureOccurrences({required int days}) async {
    final routineRepository = await ref.read(routineRepositoryProvider.future);
    final occurrenceRepository = await ref.read(
      routineOccurrenceRepositoryProvider.future,
    );
    final timetableRepository = await ref.read(timetableRepositoryProvider.future);
    final sessionRepository = await ref.read(plannedSessionRepositoryProvider.future);

    final routines = await routineRepository.getActiveRoutines();
    final slots = await timetableRepository.getAllSlots();
    final sessions = await sessionRepository.getAllSessions();
    final now = DateTime.now();
    final rangeEnd = now.add(Duration(days: days));
    final existingOccurrences = await occurrenceRepository.getOccurrencesInRange(
      now,
      rangeEnd,
    );

    final result = ref.read(routineSchedulingServiceProvider).generateOccurrences(
          routines: routines,
          timetableSlots: slots,
          plannedSessions: sessions,
          existingOccurrences: existingOccurrences,
          start: now,
          end: rangeEnd,
          now: now,
        );

    await occurrenceRepository.replaceFutureOccurrencesInRange(
      start: now,
      end: rangeEnd,
      newOccurrences: result.generatedOccurrences,
      keepCompleted: true,
    );
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

  void _ensureIdle() {
    if (state.isLoading) {
      throw StateError('Another routine action is already in progress.');
    }
  }
}
