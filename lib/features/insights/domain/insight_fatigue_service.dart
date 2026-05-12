import 'planning_insight_models.dart';

class InsightSuppressionState {
  const InsightSuppressionState({
    this.dismissedInsightIds = const <String>{},
    this.snoozedUntilByInsightId = const <String, DateTime>{},
    this.cooldownUntilByFatigueKey = const <String, DateTime>{},
    this.disabledTypeEntityKeys = const <String>{},
  });

  final Set<String> dismissedInsightIds;
  final Map<String, DateTime> snoozedUntilByInsightId;
  final Map<String, DateTime> cooldownUntilByFatigueKey;
  final Set<String> disabledTypeEntityKeys;

  InsightSuppressionState copyWith({
    Set<String>? dismissedInsightIds,
    Map<String, DateTime>? snoozedUntilByInsightId,
    Map<String, DateTime>? cooldownUntilByFatigueKey,
    Set<String>? disabledTypeEntityKeys,
  }) {
    return InsightSuppressionState(
      dismissedInsightIds: dismissedInsightIds ?? this.dismissedInsightIds,
      snoozedUntilByInsightId:
          snoozedUntilByInsightId ?? this.snoozedUntilByInsightId,
      cooldownUntilByFatigueKey:
          cooldownUntilByFatigueKey ?? this.cooldownUntilByFatigueKey,
      disabledTypeEntityKeys:
          disabledTypeEntityKeys ?? this.disabledTypeEntityKeys,
    );
  }
}

class InsightFatigueService {
  const InsightFatigueService({this.defaultCooldown = const Duration(days: 7)});

  final Duration defaultCooldown;

  List<PlanningInsight> filterInsights({
    required List<PlanningInsight> insights,
    required InsightSuppressionState suppression,
    required DateTime now,
  }) {
    return insights.where((insight) {
      if (suppression.dismissedInsightIds.contains(insight.id)) {
        return false;
      }
      final snoozedUntil = suppression.snoozedUntilByInsightId[insight.id];
      if (snoozedUntil != null && snoozedUntil.isAfter(now)) {
        return false;
      }
      final cooldownUntil =
          suppression.cooldownUntilByFatigueKey[insight.fatigueKey];
      if (cooldownUntil != null && cooldownUntil.isAfter(now)) {
        return false;
      }
      if (suppression.disabledTypeEntityKeys.contains(typeEntityKey(insight))) {
        return false;
      }
      return true;
    }).toList();
  }

  InsightSuppressionState dismiss(
    InsightSuppressionState state,
    PlanningInsight insight,
    DateTime now,
  ) {
    return state.copyWith(
      dismissedInsightIds: {...state.dismissedInsightIds, insight.id},
      cooldownUntilByFatigueKey: {
        ...state.cooldownUntilByFatigueKey,
        insight.fatigueKey: now.add(defaultCooldown),
      },
    );
  }

  InsightSuppressionState snooze(
    InsightSuppressionState state,
    PlanningInsight insight,
    DateTime until,
  ) {
    return state.copyWith(
      snoozedUntilByInsightId: {
        ...state.snoozedUntilByInsightId,
        insight.id: until,
      },
    );
  }

  InsightSuppressionState disableTypeForEntity(
    InsightSuppressionState state,
    PlanningInsight insight,
  ) {
    return state.copyWith(
      disabledTypeEntityKeys: {
        ...state.disabledTypeEntityKeys,
        typeEntityKey(insight),
      },
    );
  }

  String typeEntityKey(PlanningInsight insight) {
    return [
      insight.type.name,
      insight.relatedRoutineId ?? insight.relatedGoalId ?? 'global',
    ].join(':');
  }
}
