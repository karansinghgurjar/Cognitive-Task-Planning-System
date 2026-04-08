import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'routine_reconciliation_service.dart';
import '../domain/routine_enums.dart';
import '../domain/routine_repeat_rule.dart';
import '../domain/routine_repository.dart';
import '../domain/routine_sync_service.dart';
import '../models/routine.dart';
import '../models/routine_occurrence.dart';

typedef RoutineRepositoryLoader = Future<RoutineRepositoryContract> Function();
typedef RoutineOccurrenceDelete = Future<void> Function(String routineId);
typedef RoutineOccurrencesLoader =
    Future<List<RoutineOccurrence>> Function(String routineId);
typedef RoutineOccurrencesSaver =
    Future<void> Function(List<RoutineOccurrence> occurrences);
typedef RoutineOccurrenceDeleteByIds =
    Future<void> Function(List<String> occurrenceIds);
typedef RoutineSyncLoader = Future<RoutineSyncService> Function();
typedef RoutineReconciliationLoader =
    Future<RoutineReconciliationService> Function();
typedef RoutineReplanHook = Future<void> Function(String routineId);

class RoutineFormState {
  const RoutineFormState({
    required this.mode,
    required this.initialRoutine,
    required this.title,
    required this.description,
    required this.repeatType,
    required this.interval,
    required this.selectedWeekdays,
    required this.anchorDate,
    required this.monthlyDayOfMonth,
    required this.preferredStartMinuteOfDay,
    required this.preferredDurationMinutes,
    required this.timeWindowStartMinuteOfDay,
    required this.timeWindowEndMinuteOfDay,
    required this.isFlexible,
    required this.autoRescheduleMissed,
    required this.countsTowardConsistency,
    required this.routineTypeIndex,
    required this.remindersEnabled,
    required this.reminderLeadMinutes,
    required this.isSaving,
    required this.validationErrors,
    required this.hasUnsavedChanges,
  });

  final RoutineFormMode mode;
  final Routine? initialRoutine;
  final String title;
  final String description;
  final RoutineRepeatType repeatType;
  final int interval;
  final Set<int> selectedWeekdays;
  final DateTime anchorDate;
  final int? monthlyDayOfMonth;
  final int? preferredStartMinuteOfDay;
  final int? preferredDurationMinutes;
  final int? timeWindowStartMinuteOfDay;
  final int? timeWindowEndMinuteOfDay;
  final bool isFlexible;
  final bool autoRescheduleMissed;
  final bool countsTowardConsistency;
  final int routineTypeIndex;
  final bool remindersEnabled;
  final int? reminderLeadMinutes;
  final bool isSaving;
  final Map<String, String> validationErrors;
  final bool hasUnsavedChanges;

  bool get isEditMode => mode == RoutineFormMode.edit;

  RoutineFormState copyWith({
    RoutineFormMode? mode,
    Routine? initialRoutine,
    String? title,
    String? description,
    RoutineRepeatType? repeatType,
    int? interval,
    Set<int>? selectedWeekdays,
    DateTime? anchorDate,
    int? monthlyDayOfMonth,
    bool clearMonthlyDayOfMonth = false,
    int? preferredStartMinuteOfDay,
    bool clearPreferredStartMinuteOfDay = false,
    int? preferredDurationMinutes,
    bool clearPreferredDurationMinutes = false,
    int? timeWindowStartMinuteOfDay,
    bool clearTimeWindowStartMinuteOfDay = false,
    int? timeWindowEndMinuteOfDay,
    bool clearTimeWindowEndMinuteOfDay = false,
    bool? isFlexible,
    bool? autoRescheduleMissed,
    bool? countsTowardConsistency,
    int? routineTypeIndex,
    bool? remindersEnabled,
    int? reminderLeadMinutes,
    bool clearReminderLeadMinutes = false,
    bool? isSaving,
    Map<String, String>? validationErrors,
    bool? hasUnsavedChanges,
  }) {
    return RoutineFormState(
      mode: mode ?? this.mode,
      initialRoutine: initialRoutine ?? this.initialRoutine,
      title: title ?? this.title,
      description: description ?? this.description,
      repeatType: repeatType ?? this.repeatType,
      interval: interval ?? this.interval,
      selectedWeekdays: selectedWeekdays ?? this.selectedWeekdays,
      anchorDate: anchorDate ?? this.anchorDate,
      monthlyDayOfMonth: clearMonthlyDayOfMonth
          ? null
          : monthlyDayOfMonth ?? this.monthlyDayOfMonth,
      preferredStartMinuteOfDay: clearPreferredStartMinuteOfDay
          ? null
          : preferredStartMinuteOfDay ?? this.preferredStartMinuteOfDay,
      preferredDurationMinutes: clearPreferredDurationMinutes
          ? null
          : preferredDurationMinutes ?? this.preferredDurationMinutes,
      timeWindowStartMinuteOfDay: clearTimeWindowStartMinuteOfDay
          ? null
          : timeWindowStartMinuteOfDay ?? this.timeWindowStartMinuteOfDay,
      timeWindowEndMinuteOfDay: clearTimeWindowEndMinuteOfDay
          ? null
          : timeWindowEndMinuteOfDay ?? this.timeWindowEndMinuteOfDay,
      isFlexible: isFlexible ?? this.isFlexible,
      autoRescheduleMissed:
          autoRescheduleMissed ?? this.autoRescheduleMissed,
      countsTowardConsistency:
          countsTowardConsistency ?? this.countsTowardConsistency,
      routineTypeIndex: routineTypeIndex ?? this.routineTypeIndex,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      reminderLeadMinutes: clearReminderLeadMinutes
          ? null
          : reminderLeadMinutes ?? this.reminderLeadMinutes,
      isSaving: isSaving ?? this.isSaving,
      validationErrors: validationErrors ?? this.validationErrors,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
    );
  }
}

enum RoutineFormMode { create, edit }

class RoutineFormController extends StateNotifier<RoutineFormState> {
  RoutineFormController({
    required RoutineRepositoryLoader loadRepository,
    required RoutineOccurrenceDelete deleteOccurrencesForRoutine,
    RoutineOccurrencesLoader? loadOccurrencesForRoutine,
    RoutineOccurrencesSaver? saveOccurrences,
    RoutineOccurrenceDeleteByIds? deleteOccurrenceIds,
    required RoutineSyncLoader loadSyncService,
    RoutineReconciliationLoader? loadReconciliationService,
    RoutineReplanHook? replanRoutineOccurrences,
    required DateTime Function() nowProvider,
    String Function()? idGenerator,
    Routine? initialRoutine,
  }) : _loadRepository = loadRepository,
       _deleteOccurrencesForRoutine = deleteOccurrencesForRoutine,
       _loadOccurrencesForRoutine =
           loadOccurrencesForRoutine ?? _emptyOccurrenceLoader,
       _saveOccurrences = saveOccurrences ?? _noopOccurrenceSaver,
       _deleteOccurrenceIds = deleteOccurrenceIds ?? _noopDeleteOccurrenceIds,
       _loadSyncService = loadSyncService,
       _loadReconciliationService =
           loadReconciliationService ?? _defaultReconciliationLoader,
       _replanRoutineOccurrences =
           replanRoutineOccurrences ?? _noopReplanRoutineOccurrences,
       _nowProvider = nowProvider,
       _idGenerator = idGenerator ?? const Uuid().v4,
       super(_buildInitialState(initialRoutine, nowProvider()));

  final RoutineRepositoryLoader _loadRepository;
  final RoutineOccurrenceDelete _deleteOccurrencesForRoutine;
  final RoutineOccurrencesLoader _loadOccurrencesForRoutine;
  final RoutineOccurrencesSaver _saveOccurrences;
  final RoutineOccurrenceDeleteByIds _deleteOccurrenceIds;
  final RoutineSyncLoader _loadSyncService;
  final RoutineReconciliationLoader _loadReconciliationService;
  final RoutineReplanHook _replanRoutineOccurrences;
  final DateTime Function() _nowProvider;
  final String Function() _idGenerator;

  static Future<List<RoutineOccurrence>> _emptyOccurrenceLoader(
    String routineId,
  ) async => const [];

  static Future<void> _noopOccurrenceSaver(
    List<RoutineOccurrence> occurrences,
  ) async {}

  static Future<void> _noopDeleteOccurrenceIds(
    List<String> occurrenceIds,
  ) async {}

  static Future<RoutineReconciliationService> _defaultReconciliationLoader() async {
    return RoutineReconciliationService();
  }

  static Future<void> _noopReplanRoutineOccurrences(String routineId) async {}

  static RoutineFormState _buildInitialState(
    Routine? routine,
    DateTime now,
  ) {
    if (routine == null) {
      return RoutineFormState(
        mode: RoutineFormMode.create,
        initialRoutine: null,
        title: '',
        description: '',
        repeatType: RoutineRepeatType.daily,
        interval: 1,
        selectedWeekdays: const <int>{},
        anchorDate: DateTime(now.year, now.month, now.day),
        monthlyDayOfMonth: null,
        preferredStartMinuteOfDay: null,
        preferredDurationMinutes: null,
        timeWindowStartMinuteOfDay: null,
        timeWindowEndMinuteOfDay: null,
        isFlexible: true,
        autoRescheduleMissed: true,
        countsTowardConsistency: true,
        routineTypeIndex: 4,
        remindersEnabled: false,
        reminderLeadMinutes: 10,
        isSaving: false,
        validationErrors: const {},
        hasUnsavedChanges: false,
      );
    }

    return RoutineFormState(
      mode: RoutineFormMode.edit,
      initialRoutine: routine,
      title: routine.title,
      description: routine.description ?? '',
      repeatType: routine.repeatRule.type,
      interval: routine.repeatRule.interval,
      selectedWeekdays: routine.repeatRule.weekdays.toSet(),
      anchorDate: routine.anchorDate,
      monthlyDayOfMonth: routine.repeatRule.dayOfMonth,
      preferredStartMinuteOfDay: routine.preferredStartMinuteOfDay,
      preferredDurationMinutes: routine.preferredDurationMinutes,
      timeWindowStartMinuteOfDay: routine.timeWindowStartMinuteOfDay,
      timeWindowEndMinuteOfDay: routine.timeWindowEndMinuteOfDay,
      isFlexible: routine.isFlexible,
      autoRescheduleMissed: routine.autoRescheduleMissed,
      countsTowardConsistency: routine.countsTowardConsistency,
      routineTypeIndex: routine.routineType.index,
      remindersEnabled: routine.remindersEnabled,
      reminderLeadMinutes: routine.reminderLeadMinutes ?? 10,
      isSaving: false,
      validationErrors: const {},
      hasUnsavedChanges: false,
    );
  }

  void setTitle(String value) => _update(state.copyWith(title: value));

  void setDescription(String value) =>
      _update(state.copyWith(description: value));

  void setRepeatType(RoutineRepeatType value) {
    _update(
      state.copyWith(
        repeatType: value,
        selectedWeekdays: value == RoutineRepeatType.selectedWeekdays
            ? state.selectedWeekdays
            : <int>{},
        monthlyDayOfMonth: value == RoutineRepeatType.monthly
            ? state.monthlyDayOfMonth
            : null,
        clearMonthlyDayOfMonth: value != RoutineRepeatType.monthly,
      ),
    );
  }

  void setInterval(int value) => _update(state.copyWith(interval: value));

  void toggleWeekday(int weekday) {
    final next = {...state.selectedWeekdays};
    if (!next.add(weekday)) {
      next.remove(weekday);
    }
    _update(state.copyWith(selectedWeekdays: next));
  }

  void setAnchorDate(DateTime value) =>
      _update(state.copyWith(anchorDate: DateTime(value.year, value.month, value.day)));

  void setMonthlyDayOfMonth(int? value) => _update(
        state.copyWith(
          monthlyDayOfMonth: value,
          clearMonthlyDayOfMonth: value == null,
        ),
      );

  void setPreferredStartMinuteOfDay(int? value) => _update(
        state.copyWith(
          preferredStartMinuteOfDay: value,
          clearPreferredStartMinuteOfDay: value == null,
        ),
      );

  void setPreferredDurationMinutes(int? value) => _update(
        state.copyWith(
          preferredDurationMinutes: value,
          clearPreferredDurationMinutes: value == null,
        ),
      );

  void setTimeWindowStartMinuteOfDay(int? value) => _update(
        state.copyWith(
          timeWindowStartMinuteOfDay: value,
          clearTimeWindowStartMinuteOfDay: value == null,
        ),
      );

  void setTimeWindowEndMinuteOfDay(int? value) => _update(
        state.copyWith(
          timeWindowEndMinuteOfDay: value,
          clearTimeWindowEndMinuteOfDay: value == null,
        ),
      );

  void setFlexible(bool value) => _update(state.copyWith(isFlexible: value));

  void setAutoRescheduleMissed(bool value) =>
      _update(state.copyWith(autoRescheduleMissed: value));

  void setCountsTowardConsistency(bool value) =>
      _update(state.copyWith(countsTowardConsistency: value));

  void setRoutineTypeIndex(int value) =>
      _update(state.copyWith(routineTypeIndex: value));

  void setRemindersEnabled(bool value) => _update(
        state.copyWith(
          remindersEnabled: value,
          reminderLeadMinutes: value ? state.reminderLeadMinutes ?? 10 : null,
          clearReminderLeadMinutes: !value,
        ),
      );

  void setReminderLeadMinutes(int? value) => _update(
        state.copyWith(
          reminderLeadMinutes: value,
          clearReminderLeadMinutes: value == null,
        ),
      );

  Map<String, String> validate() {
    final errors = <String, String>{};
    if (state.title.trim().isEmpty) {
      errors['title'] = 'Title is required.';
    }
    if (state.interval < 1) {
      errors['interval'] = 'Interval must be at least 1.';
    }
    if (state.repeatType == RoutineRepeatType.selectedWeekdays &&
        state.selectedWeekdays.isEmpty) {
      errors['selectedWeekdays'] = 'Choose at least one weekday.';
    }
    if (state.preferredDurationMinutes != null &&
        state.preferredDurationMinutes! <= 0) {
      errors['preferredDurationMinutes'] =
          'Duration must be greater than 0.';
    }
    if (state.timeWindowStartMinuteOfDay != null &&
        state.timeWindowEndMinuteOfDay != null &&
        state.timeWindowStartMinuteOfDay! >= state.timeWindowEndMinuteOfDay!) {
      errors['timeWindow'] = 'Window start must be earlier than window end.';
    }
    if (state.remindersEnabled &&
        (state.reminderLeadMinutes == null || state.reminderLeadMinutes! < 0)) {
      errors['reminderLeadMinutes'] = 'Reminder lead time must be 0 or greater.';
    }
    state = state.copyWith(validationErrors: errors);
    return errors;
  }

  Future<Routine?> save() async {
    if (state.isSaving) {
      return null;
    }
    if (validate().isNotEmpty) {
      return null;
    }

    final now = _nowProvider();
    state = state.copyWith(isSaving: true);
    try {
      final repository = await _loadRepository();
      final syncService = await _loadSyncService();
      final reconciliationService = await _loadReconciliationService();
      final routine = _buildRoutine(now);

      if (state.isEditMode) {
        final initialRoutine = state.initialRoutine!;
        final existingOccurrences = await _loadOccurrencesForRoutine(initialRoutine.id);
        await repository.updateRoutine(routine);
        final plan = reconciliationService.reconcile(
          previousRoutine: initialRoutine,
          nextRoutine: routine,
          existingOccurrences: existingOccurrences,
          now: now,
        );
        await _deleteOccurrenceIds(plan.occurrenceIdsToRemove);
        await _saveOccurrences(plan.occurrencesToUpsert);
        if (!routine.isArchived) {
          await syncService.syncRoutine(
            routine.id,
            startDate: now.subtract(const Duration(days: 7)),
            endDate: now.add(const Duration(days: 30)),
          );
        }
        if (plan.shouldRunSchedulingIntegration) {
          await _replanRoutineOccurrences(routine.id);
        }
      } else {
        await repository.saveRoutine(routine);
        await syncService.syncRoutine(
          routine.id,
          startDate: now.subtract(const Duration(days: 7)),
          endDate: now.add(const Duration(days: 30)),
        );
        await _replanRoutineOccurrences(routine.id);
      }
      state = _buildInitialState(routine, now);
      return routine;
    } finally {
      if (mounted) {
        state = state.copyWith(isSaving: false);
      }
    }
  }

  Future<void> archive() async {
    final routine = state.initialRoutine;
    if (routine == null || state.isSaving) {
      return;
    }
    state = state.copyWith(isSaving: true);
    try {
      final repository = await _loadRepository();
      final now = _nowProvider();
      if (routine.isArchived) {
        await repository.unarchiveRoutine(routine.id);
        final syncService = await _loadSyncService();
        await syncService.syncRoutine(
          routine.id,
          startDate: now.subtract(const Duration(days: 7)),
          endDate: now.add(const Duration(days: 30)),
        );
        await _replanRoutineOccurrences(routine.id);
      } else {
        final futurePendingIds = (await _loadOccurrencesForRoutine(routine.id))
            .where(
              (occurrence) =>
                  occurrence.status == RoutineOccurrenceStatus.pending &&
                  !occurrence.occurrenceDate.isBefore(
                    DateTime(now.year, now.month, now.day),
                  ),
            )
            .map((occurrence) => occurrence.id)
            .toList();
        await repository.archiveRoutine(routine.id);
        await _deleteOccurrenceIds(futurePendingIds);
      }
      final updated = (await repository.getRoutineById(routine.id)) ?? routine;
      state = _buildInitialState(updated, _nowProvider());
    } finally {
      if (mounted) {
        state = state.copyWith(isSaving: false);
      }
    }
  }

  Future<void> delete() async {
    final routine = state.initialRoutine;
    if (routine == null || state.isSaving) {
      return;
    }
    state = state.copyWith(isSaving: true);
    try {
      final repository = await _loadRepository();
      await repository.deleteRoutine(routine.id);
      await _deleteOccurrencesForRoutine(routine.id);
      state = _buildInitialState(null, _nowProvider());
    } finally {
      if (mounted) {
        state = state.copyWith(isSaving: false);
      }
    }
  }

  Routine _buildRoutine(DateTime now) {
    final initial = state.initialRoutine;
    final repeatRule = RoutineRepeatRule(
      type: state.repeatType,
      interval: state.interval,
      weekdays: state.repeatType == RoutineRepeatType.selectedWeekdays
          ? (state.selectedWeekdays.toList()..sort())
          : const [],
      dayOfMonth: state.repeatType == RoutineRepeatType.monthly
          ? state.monthlyDayOfMonth
          : null,
    );

    return initial?.copyWith(
          title: state.title.trim(),
          description: _normalizeOptional(state.description),
          clearDescription: _normalizeOptional(state.description) == null,
          updatedAt: now,
          anchorDate: state.anchorDate,
          repeatRule: repeatRule,
          preferredStartMinuteOfDay: state.preferredStartMinuteOfDay,
          clearPreferredStartMinuteOfDay:
              state.preferredStartMinuteOfDay == null,
          preferredDurationMinutes: state.preferredDurationMinutes,
          clearPreferredDurationMinutes:
              state.preferredDurationMinutes == null,
          timeWindowStartMinuteOfDay: state.timeWindowStartMinuteOfDay,
          clearTimeWindowStartMinuteOfDay:
              state.timeWindowStartMinuteOfDay == null,
          timeWindowEndMinuteOfDay: state.timeWindowEndMinuteOfDay,
          clearTimeWindowEndMinuteOfDay:
              state.timeWindowEndMinuteOfDay == null,
          isFlexible: state.isFlexible,
          autoRescheduleMissed: state.autoRescheduleMissed,
          countsTowardConsistency: state.countsTowardConsistency,
          routineType: RoutineType.values[state.routineTypeIndex],
          categoryId: RoutineType.values[state.routineTypeIndex].defaultCategoryTag,
          remindersEnabled: state.remindersEnabled,
          reminderLeadMinutes:
              state.remindersEnabled ? state.reminderLeadMinutes : null,
          clearReminderLeadMinutes: !state.remindersEnabled,
        ) ??
        Routine(
          id: _idGenerator(),
          title: state.title.trim(),
          description: _normalizeOptional(state.description),
          createdAt: now,
          updatedAt: now,
          anchorDate: state.anchorDate,
          repeatRule: repeatRule,
          preferredStartMinuteOfDay: state.preferredStartMinuteOfDay,
          preferredDurationMinutes: state.preferredDurationMinutes,
          timeWindowStartMinuteOfDay: state.timeWindowStartMinuteOfDay,
          timeWindowEndMinuteOfDay: state.timeWindowEndMinuteOfDay,
          isFlexible: state.isFlexible,
          autoRescheduleMissed: state.autoRescheduleMissed,
          countsTowardConsistency: state.countsTowardConsistency,
          routineType: RoutineType.values[state.routineTypeIndex],
          categoryId: RoutineType.values[state.routineTypeIndex].defaultCategoryTag,
          remindersEnabled: state.remindersEnabled,
          reminderLeadMinutes:
              state.remindersEnabled ? state.reminderLeadMinutes : null,
        );
  }

  void _update(RoutineFormState nextState) {
    state = nextState.copyWith(
      hasUnsavedChanges: true,
      validationErrors: const {},
    );
  }

  String? _normalizeOptional(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
