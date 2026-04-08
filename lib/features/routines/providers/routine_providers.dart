import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/isar_providers.dart';
import '../../tasks/models/task.dart';
import '../../tasks/providers/task_providers.dart';
import '../data/routine_occurrence_repository.dart';
import '../data/routine_repository.dart';
import '../domain/routine_enums.dart';
import '../domain/routine_generation_service.dart';
import '../domain/routine_scheduling_service.dart';
import '../domain/routine_sync_service.dart';
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

final routineGenerationServiceProvider = Provider<RoutineGenerationService>((ref) {
  return RoutineGenerationService();
});

final routineSchedulingServiceProvider = Provider<RoutineSchedulingService>((ref) {
  return RoutineSchedulingService(
    generationService: ref.read(routineGenerationServiceProvider),
  );
});

final routineSyncServiceProvider = FutureProvider<RoutineSyncService>((ref) async {
  final repository = await ref.watch(routineRepositoryProvider.future);
  return RoutineSyncService(
    persistence: repository,
    generationService: ref.read(routineGenerationServiceProvider),
  );
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
  final occurrencesAsync = ref.watch(watchAllRoutineOccurrencesProvider);

  return switch ((routinesAsync, occurrencesAsync)) {
    (
      AsyncData(value: final routines),
      AsyncData(value: final occurrences),
    ) =>
      AsyncData(() {
        final now = DateTime.now();
        final nextOccurrenceByRoutineId = <String, RoutineOccurrence?>{};
        var generatedCount = 0;
        var skippedCount = 0;

        for (final routine in routines) {
          final preview = _findNextOccurrence(routine, occurrences, now);
          nextOccurrenceByRoutineId[routine.id] = preview;
          if (preview != null) {
            generatedCount += 1;
          } else if (routine.generatesOccurrences) {
            skippedCount += 1;
          }
        }

        return RoutinePreviewState(
          nextOccurrenceByRoutineId: nextOccurrenceByRoutineId,
          generatedCount: generatedCount,
          skippedCount: skippedCount,
        );
      }()),
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

RoutineOccurrence? _findNextOccurrence(
  Routine routine,
  List<RoutineOccurrence> occurrences,
  DateTime now,
) {
  final matching = occurrences
      .where((item) => item.routineId == routine.id)
      .where(
        (item) =>
            item.effectiveStatusAt(now) == RoutineOccurrenceStatus.pending &&
            !item.occurrenceDate.isBefore(DateTime(now.year, now.month, now.day)),
      )
      .toList()
    ..sort((left, right) => left.occurrenceDate.compareTo(right.occurrenceDate));
  return matching.isEmpty ? null : matching.first;
}

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

  final horizonEnd = DateTime(now.year, now.month, now.day).add(
    const Duration(days: 7),
  );
  final upcomingOccurrences = occurrences.where((occurrence) {
    return !occurrence.occurrenceDate.isAfter(horizonEnd) &&
        occurrence.effectiveStatusAt(now) == RoutineOccurrenceStatus.pending;
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
          occurrence.occurrenceDate.isBefore(weekEnd) &&
          occurrence.effectiveStatusAt(now) == RoutineOccurrenceStatus.pending;
    });
    if (!hasPendingReview) {
      actions.add('Protect a weekly review routine block before this week ends.');
    }
  }

  final totalWeeklyMinutes = routines.fold<int>(
    0,
    (sum, routine) =>
        sum + ((routine.preferredDurationMinutes ?? 0) * _weeklyOccurrences(routine)),
  );
  if (totalWeeklyMinutes > 16 * 60) {
    actions.add(
      'Your routine load is heavy. Reduce durations or weekdays if task planning starts feeling crowded.',
    );
  }

  return actions.toSet().toList();
}

int _weeklyOccurrences(Routine routine) {
  switch (routine.repeatRule.type) {
    case RoutineRepeatType.daily:
      return 7;
    case RoutineRepeatType.weekdays:
      return 5;
    case RoutineRepeatType.selectedWeekdays:
      return routine.repeatRule.weekdays.length;
    case RoutineRepeatType.weekly:
      return 1;
    case RoutineRepeatType.monthly:
      return 1;
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
      await repository.saveRoutine(routine);
      await _syncFutureOccurrences(days: 30);
    });
  }

  Future<void> updateRoutine(Routine routine) async {
    await _run(() async {
      final repository = await ref.read(routineRepositoryProvider.future);
      await repository.updateRoutine(routine);
      await _syncFutureOccurrences(days: 30);
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

  Future<void> setArchived(Routine routine, bool isArchived) async {
    await updateRoutine(
      routine.copyWith(
        isArchived: isArchived,
        archivedAt: isArchived ? DateTime.now() : null,
        clearArchivedAt: !isArchived,
      ),
    );
  }

  Future<void> generateNext7Days() => _run(() => _syncFutureOccurrences(days: 7));

  Future<void> generateNext30Days() =>
      _run(() => _syncFutureOccurrences(days: 30));

  Future<void> markOccurrenceCompleted(RoutineOccurrence occurrence) async {
    await _run(() async {
      final repository = await ref.read(routineOccurrenceRepositoryProvider.future);
      await repository.updateOccurrence(
        occurrence.copyWith(
          status: RoutineOccurrenceStatus.completed,
          completedAt: DateTime.now(),
          clearSkippedAt: true,
          clearMissedAt: true,
          updatedAt: DateTime.now(),
        ),
      );
    });
  }

  Future<void> markOccurrenceSkipped(RoutineOccurrence occurrence) async {
    await _run(() async {
      final repository = await ref.read(routineOccurrenceRepositoryProvider.future);
      await repository.updateOccurrence(
        occurrence.copyWith(
          status: RoutineOccurrenceStatus.skipped,
          skippedAt: DateTime.now(),
          clearCompletedAt: true,
          clearMissedAt: true,
          updatedAt: DateTime.now(),
        ),
      );
    });
  }

  Future<void> snoozeOccurrence(
    RoutineOccurrence occurrence,
    DateTime newStart, {
    String? notes,
  }) async {
    await _run(() async {
      final repository = await ref.read(routineOccurrenceRepositoryProvider.future);
      final service = ref.read(routineSchedulingServiceProvider);
      await repository.updateOccurrence(
        service.rescheduleOccurrence(
          occurrence: occurrence,
          newStart: newStart,
          notes: notes,
          now: DateTime.now(),
        ),
      );
    });
  }

  Future<Task> convertOccurrenceToTask({
    required Routine routine,
    required RoutineOccurrence occurrence,
  }) async {
    late Task createdTask;
    await _run(() async {
      final taskRepository = await ref.read(taskRepositoryProvider.future);
      final occurrenceRepository = await ref.read(
        routineOccurrenceRepositoryProvider.future,
      );
      final now = DateTime.now();
      createdTask = Task(
        id: occurrence.id,
        title: routine.title,
        description: routine.description,
        type: _taskTypeForRoutine(routine),
        estimatedDurationMinutes:
            occurrence.durationMinutes ?? routine.preferredDurationMinutes ?? 30,
        dueDate: occurrence.scheduledEnd,
        priority: routine.priority,
        goalId: routine.linkedGoalId,
        resourceTag: routine.categoryId,
        createdAt: now,
        updatedAt: now,
      );
      await taskRepository.addTask(createdTask);
      await occurrenceRepository.updateOccurrence(
        occurrence.copyWith(
          status: RoutineOccurrenceStatus.skipped,
          sourceTaskId: createdTask.id,
          skippedAt: now,
          notes: 'Converted to task',
          updatedAt: now,
        ),
      );
    });
    return createdTask;
  }

  Future<void> _syncFutureOccurrences({required int days}) async {
    final syncService = await ref.read(routineSyncServiceProvider.future);
    final now = DateTime.now();
    await syncService.syncAllRoutines(
      startDate: now.subtract(const Duration(days: 7)),
      endDate: now.add(Duration(days: days)),
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

TaskType _taskTypeForRoutine(Routine routine) {
  switch (routine.routineType) {
    case RoutineType.study:
      return TaskType.study;
    case RoutineType.project:
      return TaskType.project;
    case RoutineType.review:
      return TaskType.reading;
    case RoutineType.health:
    case RoutineType.custom:
      return TaskType.misc;
  }
}
