import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/planning_assistant/application/services/planning_draft_generator.dart';
import 'package:study_flow/features/planning_assistant/domain/models/parsed_planning_intent.dart';
import 'package:study_flow/features/routines/domain/routine_enums.dart';

void main() {
  group('PlanningDraftGenerator', () {
    const generator = PlanningDraftGenerator();

    test('creates realistic placement-prep draft with support structures', () {
      final draft = generator.generate(
        ParsedPlanningIntent(
          rawInput: 'I want to prepare for placements over the next 3 months.',
          goals: const <GoalIntent>[
            GoalIntent(
              title: 'Placement Preparation',
              type: GoalIntentType.examPrep,
            ),
          ],
          routines: const <RoutineIntent>[
            RoutineIntent(
              title: 'DSA Practice',
              routineType: RoutineType.study,
              durationMinutes: 60,
              preferredDays: <int>[
                DateTime.monday,
                DateTime.tuesday,
                DateTime.wednesday,
                DateTime.thursday,
                DateTime.friday,
              ],
              preferredStartMinuteOfDay: 20 * 60,
              repeatType: RoutineRepeatType.weekdays,
              isFlexible: false,
            ),
          ],
          tasks: const <TaskIntent>[],
          horizon: const TimeHorizon(value: 3, unit: TimeHorizonUnit.months),
          intensity: PlanningIntensityLevel.balanced,
          constraints: const <PlanningConstraint>[],
          confidence: 0.9,
          ambiguities: const <String>[],
          assumptions: const <String>[],
        ),
      );

      expect(draft.goals, hasLength(1));
      expect(draft.routines.length, greaterThanOrEqualTo(2));
      expect(
        draft.tasks.any((task) => task.title.contains('Track Topic Coverage')),
        isTrue,
      );
      expect(draft.explanations, isNotEmpty);
    });

    test('generates overload warning for unrealistic weekly load', () {
      final draft = generator.generate(
        ParsedPlanningIntent(
          rawInput: 'I want an aggressive daily routine with lots of work.',
          goals: const <GoalIntent>[
            GoalIntent(title: 'Custom System', type: GoalIntentType.custom),
          ],
          routines: const <RoutineIntent>[
            RoutineIntent(
              title: 'Main Block',
              routineType: RoutineType.study,
              durationMinutes: 180,
              preferredDays: <int>[
                DateTime.monday,
                DateTime.tuesday,
                DateTime.wednesday,
                DateTime.thursday,
                DateTime.friday,
                DateTime.saturday,
                DateTime.sunday,
              ],
              repeatType: RoutineRepeatType.daily,
              isFlexible: false,
            ),
            RoutineIntent(
              title: 'Second Block',
              routineType: RoutineType.project,
              durationMinutes: 120,
              preferredDays: <int>[
                DateTime.monday,
                DateTime.tuesday,
                DateTime.wednesday,
                DateTime.thursday,
                DateTime.friday,
              ],
              preferredStartMinuteOfDay: 19 * 60,
              repeatType: RoutineRepeatType.weekdays,
              isFlexible: false,
            ),
          ],
          tasks: const <TaskIntent>[],
          horizon: const TimeHorizon(value: 6, unit: TimeHorizonUnit.weeks),
          intensity: PlanningIntensityLevel.aggressive,
          constraints: const <PlanningConstraint>[],
          confidence: 0.9,
          ambiguities: const <String>[],
          assumptions: const <String>[],
        ),
      );

      expect(
        draft.warnings.any((warning) => warning.message.contains('dense')),
        isTrue,
      );
      expect(draft.loadEstimate.weeklyMinutes, greaterThan(14 * 60));
    });
  });
}
