import '../domain/routine_date_utils.dart';

class RoutineHistoryAccessWindow {
  const RoutineHistoryAccessWindow({
    required this.startDate,
    required this.endDate,
  });

  final DateTime startDate;
  final DateTime endDate;
}

class RoutineHistoryPolicyService {
  const RoutineHistoryPolicyService({
    this.activePlanningHorizonDays = 30,
    this.recentHistoryDays = 60,
    this.deepHistoryDays = 365,
  });

  final int activePlanningHorizonDays;
  final int recentHistoryDays;
  final int deepHistoryDays;

  RoutineHistoryAccessWindow activePlanningWindow({DateTime? now}) {
    final anchor = normalizeDate(now ?? DateTime.now());
    return RoutineHistoryAccessWindow(
      startDate: anchor.subtract(const Duration(days: 7)),
      endDate: anchor.add(Duration(days: activePlanningHorizonDays)),
    );
  }

  RoutineHistoryAccessWindow recentHistoryWindow({DateTime? now}) {
    final anchor = normalizeDate(now ?? DateTime.now());
    return RoutineHistoryAccessWindow(
      startDate: anchor.subtract(Duration(days: recentHistoryDays)),
      endDate: anchor.add(Duration(days: activePlanningHorizonDays)),
    );
  }

  RoutineHistoryAccessWindow deepHistoryWindow({DateTime? now}) {
    final anchor = normalizeDate(now ?? DateTime.now());
    return RoutineHistoryAccessWindow(
      startDate: anchor.subtract(Duration(days: deepHistoryDays)),
      endDate: anchor.add(Duration(days: activePlanningHorizonDays)),
    );
  }
}
