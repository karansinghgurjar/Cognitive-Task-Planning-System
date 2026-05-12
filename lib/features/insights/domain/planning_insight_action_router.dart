import '../../routines/presentation/add_edit_routine_screen.dart';
import '../../routines/presentation/routine_detail_screen.dart';
import '../../review/presentation/weekly_review_screen.dart';
import '../../schedule/presentation/today_screen.dart';
import 'planning_insight_models.dart';

class InsightActionRoute {
  const InsightActionRoute({
    required this.destination,
    required this.requiresConfirmation,
    this.routineId,
    this.goalId,
    this.suggestedStartMinuteOfDay,
    this.suggestedDurationMinutes,
  });

  final InsightActionDestination destination;
  final bool requiresConfirmation;
  final String? routineId;
  final String? goalId;
  final int? suggestedStartMinuteOfDay;
  final int? suggestedDurationMinutes;
}

enum InsightActionDestination {
  none,
  routineDetail,
  routineEditor,
  weeklyReview,
  planner,
}

class PlanningInsightActionRouter {
  const PlanningInsightActionRouter();

  InsightActionRoute routeFor(InsightAction action) {
    switch (action.type) {
      case InsightActionType.editRoutine:
      case InsightActionType.shiftRoutineTime:
      case InsightActionType.reduceRoutineDuration:
      case InsightActionType.pauseRoutine:
      case InsightActionType.linkToGoal:
        return InsightActionRoute(
          destination: InsightActionDestination.routineEditor,
          requiresConfirmation: true,
          routineId: action.routineId,
          goalId: action.goalId,
          suggestedStartMinuteOfDay: action.suggestedStartMinuteOfDay,
          suggestedDurationMinutes: action.suggestedDurationMinutes,
        );
      case InsightActionType.createRecoveryBlock:
        return InsightActionRoute(
          destination: InsightActionDestination.routineDetail,
          requiresConfirmation: true,
          routineId: action.routineId,
        );
      case InsightActionType.openWeeklyPlanner:
        return const InsightActionRoute(
          destination: InsightActionDestination.weeklyReview,
          requiresConfirmation: false,
        );
      case InsightActionType.openPlanner:
        return const InsightActionRoute(
          destination: InsightActionDestination.planner,
          requiresConfirmation: false,
        );
      case InsightActionType.snoozeInsight:
      case InsightActionType.dismissInsight:
        return const InsightActionRoute(
          destination: InsightActionDestination.none,
          requiresConfirmation: false,
        );
    }
  }
}

Type get routineEditorScreenType => AddEditRoutineScreen;
Type get routineDetailScreenType => RoutineDetailScreen;
Type get weeklyReviewScreenType => WeeklyReviewScreen;
Type get plannerScreenType => TodayScreen;
