import 'dart:math' as math;

import 'package:uuid/uuid.dart';

import '../domain/routine_date_utils.dart';
import '../domain/routine_enums.dart';
import '../domain/routine_generation_service.dart';
import '../models/routine.dart';
import '../models/routine_template.dart';

class RoutineTemplateApplyOptions {
  const RoutineTemplateApplyOptions({
    required this.anchorDate,
    this.timeShiftMinutes = 0,
    this.goalId,
    this.projectId,
  });

  final DateTime anchorDate;
  final int timeShiftMinutes;
  final String? goalId;
  final String? projectId;
}

class RoutineTemplatePreview {
  const RoutineTemplatePreview({
    required this.template,
    required this.totalWeeklyMinutes,
    required this.fixedItemCount,
    required this.flexibleItemCount,
  });

  final RoutineTemplate template;
  final int totalWeeklyMinutes;
  final int fixedItemCount;
  final int flexibleItemCount;
}

class RoutineTemplateService {
  RoutineTemplateService({
    String Function()? idGenerator,
    RoutineGenerationService? generationService,
  }) : _idGenerator = idGenerator ?? const Uuid().v4,
       _generationService = generationService ?? RoutineGenerationService();

  final String Function() _idGenerator;
  final RoutineGenerationService _generationService;

  RoutineTemplatePreview buildPreview(RoutineTemplate template) {
    var fixedItemCount = 0;
    var flexibleItemCount = 0;
    var weeklyMinutes = 0;
    for (final item in template.items) {
      if (item.isFlexible) {
        flexibleItemCount += 1;
      } else {
        fixedItemCount += 1;
      }
      weeklyMinutes +=
          (item.preferredDurationMinutes ?? 0) * _weeklyOccurrences(item);
    }
    return RoutineTemplatePreview(
      template: template,
      totalWeeklyMinutes: weeklyMinutes,
      fixedItemCount: fixedItemCount,
      flexibleItemCount: flexibleItemCount,
    );
  }

  List<Routine> applyTemplate(
    RoutineTemplate template, {
    required RoutineTemplateApplyOptions options,
    DateTime? now,
  }) {
    final createdAt = now ?? DateTime.now();
    return template.items.map((item) {
      return Routine(
        id: _idGenerator(),
        title: item.title,
        description: item.description,
        createdAt: createdAt,
        updatedAt: createdAt,
        anchorDate: normalizeDate(options.anchorDate),
        repeatRule: item.repeatRule.copyWith(),
        preferredStartMinuteOfDay: _shiftMinute(
          item.preferredStartMinuteOfDay,
          options.timeShiftMinutes,
        ),
        preferredDurationMinutes: item.preferredDurationMinutes,
        timeWindowStartMinuteOfDay: _shiftMinute(
          item.timeWindowStartMinuteOfDay,
          options.timeShiftMinutes,
        ),
        timeWindowEndMinuteOfDay: _shiftMinute(
          item.timeWindowEndMinuteOfDay,
          options.timeShiftMinutes,
        ),
        isFlexible: item.isFlexible,
        autoRescheduleMissed: item.autoRescheduleMissed,
        countsTowardConsistency: item.countsTowardConsistency,
        linkedGoalId: options.goalId,
        linkedProjectId: options.projectId,
        sourceTemplateId: template.id,
        categoryId: item.categoryId,
        tagIds: item.tagIds,
        routineType: item.routineType,
        isActive: true,
        priority: item.priority,
        energyType: item.energyType,
        colorHex: item.colorHex,
        iconName: item.iconName,
        remindersEnabled: item.remindersEnabled,
        reminderLeadMinutes: item.reminderLeadMinutes,
      );
    }).toList();
  }

  RoutineTemplate buildTemplateFromRoutines({
    required String name,
    String? description,
    String category = 'custom',
    required List<Routine> routines,
    bool isBuiltIn = false,
    DateTime? now,
  }) {
    final timestamp = now ?? DateTime.now();
    return RoutineTemplate(
      id: _idGenerator(),
      name: name,
      description: description,
      category: category,
      createdAt: timestamp,
      updatedAt: timestamp,
      isBuiltIn: isBuiltIn,
      items: routines
          .map(
            (routine) => RoutineTemplateItem(
              title: routine.title,
              description: routine.description,
              initialRepeatRule: routine.repeatRule.copyWith(),
              preferredStartMinuteOfDay: routine.preferredStartMinuteOfDay,
              preferredDurationMinutes: routine.preferredDurationMinutes,
              timeWindowStartMinuteOfDay: routine.timeWindowStartMinuteOfDay,
              timeWindowEndMinuteOfDay: routine.timeWindowEndMinuteOfDay,
              isFlexible: routine.isFlexible,
              autoRescheduleMissed: routine.autoRescheduleMissed,
              countsTowardConsistency: routine.countsTowardConsistency,
              categoryId: routine.categoryId,
              tagIds: routine.tagIds,
              routineType: routine.routineType,
              priority: routine.priority,
              energyType: routine.energyType,
              colorHex: routine.colorHex,
              iconName: routine.iconName,
              remindersEnabled: routine.remindersEnabled,
              reminderLeadMinutes: routine.reminderLeadMinutes,
            ),
          )
          .toList(),
    );
  }

  List<DateTime> previewUpcomingDates(
    RoutineTemplate template, {
    required DateTime anchorDate,
    required int days,
  }) {
    final endDate = normalizeDate(anchorDate).add(
      Duration(days: math.max(0, days - 1)),
    );
    final dates = <DateTime>[];
    for (final routine in applyTemplate(
      template,
      options: RoutineTemplateApplyOptions(anchorDate: anchorDate),
      now: anchorDate,
    )) {
      dates.addAll(
        _generationService.computeOccurrenceDates(
          routine,
          startDate: anchorDate,
          endDate: endDate,
        ),
      );
    }
    dates.sort();
    return dates;
  }

  int _weeklyOccurrences(RoutineTemplateItem item) {
    switch (item.repeatRule.type) {
      case RoutineRepeatType.daily:
        return 7;
      case RoutineRepeatType.weekdays:
        return 5;
      case RoutineRepeatType.selectedWeekdays:
        return item.repeatRule.weekdays.length;
      case RoutineRepeatType.weekly:
      case RoutineRepeatType.monthly:
        return 1;
    }
  }

  int? _shiftMinute(int? value, int shift) {
    if (value == null) {
      return null;
    }
    final shifted = (value + shift) % 1440;
    return shifted < 0 ? shifted + 1440 : shifted;
  }
}
