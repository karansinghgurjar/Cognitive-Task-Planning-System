import '../domain/ai_planner_service.dart';

abstract class AiPlannerAdapter implements AiPlannerService {
  const AiPlannerAdapter();

  String get adapterLabel;
}
