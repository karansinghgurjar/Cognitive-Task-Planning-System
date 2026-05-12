import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/planning_assistant/application/services/intent_extraction_service.dart';
import 'package:study_flow/features/planning_assistant/domain/models/parsed_planning_intent.dart';

void main() {
  group('IntentExtractionService', () {
    const service = IntentExtractionService();

    test(
      'extracts goal, horizon, duration, weekdays, and evening preference',
      () {
        final intent = service.extract(
          'I want to prepare for GATE over the next 4 months with 1 hour daily on weekdays in the evening.',
        );

        expect(intent.goals, hasLength(1));
        expect(intent.goals.first.title, 'GATE Preparation');
        expect(intent.horizon?.unit, TimeHorizonUnit.months);
        expect(intent.horizon?.value, 4);
        expect(intent.routines, isNotEmpty);
        expect(intent.routines.first.durationMinutes, 60);
        expect(intent.routines.first.preferredStartMinuteOfDay, 19 * 60);
        expect(
          intent.routines.first.preferredDays,
          containsAll(<int>[DateTime.monday, DateTime.friday]),
        );
        expect(intent.confidence, greaterThan(0.7));
      },
    );

    test('detects workout routine and after-office constraint', () {
      final intent = service.extract(
        'Help me create a consistent workout routine after office on weekdays.',
      );

      expect(intent.goals.first.type, GoalIntentType.fitness);
      expect(intent.routines.first.routineType.name, 'health');
      expect(
        intent.constraints.any(
          (constraint) => constraint.value == 'after office',
        ),
        isTrue,
      );
    });

    test('preserves ambiguity when request is too vague', () {
      final intent = service.extract('I want to study more.');

      expect(intent.ambiguities, isNotEmpty);
      expect(intent.confidence, lessThan(0.7));
    });

    test('detects aggressive intensity and explicit before-9pm constraint', () {
      final intent = service.extract(
        'I need an aggressive plan to improve DSA before placements, but only before 9 pm.',
      );

      expect(intent.intensity, PlanningIntensityLevel.aggressive);
      expect(
        intent.constraints.any(
          (constraint) =>
              constraint.type == PlanningConstraintType.unavailableAfter,
        ),
        isTrue,
      );
    });
  });
}
