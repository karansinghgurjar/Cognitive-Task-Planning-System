import '../domain/routine_enums.dart';
import '../domain/routine_repeat_rule.dart';
import '../models/routine_template.dart';

class RoutineStarterPack {
  const RoutineStarterPack({
    required this.id,
    required this.name,
    required this.description,
    required this.template,
    required this.estimatedWeeklyMinutes,
    required this.tags,
    this.setupNotes,
  });

  final String id;
  final String name;
  final String description;
  final RoutineTemplate template;
  final int estimatedWeeklyMinutes;
  final List<String> tags;
  final String? setupNotes;
}

class RoutineStarterPackService {
  const RoutineStarterPackService();

  List<RoutineStarterPack> getBuiltInPacks({DateTime? now}) {
    final createdAt = now ?? DateTime.now();
    return [
      RoutineStarterPack(
        id: 'study-pack',
        name: 'Exam Prep Pack',
        description: 'Daily study cadence with spaced revision and a weekly review.',
        estimatedWeeklyMinutes: 690,
        tags: const ['study', 'exam', 'planning'],
        setupNotes: 'Best when paired with one goal such as semester exams or interview prep.',
        template: RoutineTemplate(
          id: 'builtin-study-pack',
          name: 'Exam Prep Pack',
          description: 'Structured routine system for sustained exam preparation.',
          category: 'study',
          isBuiltIn: true,
          starterPackId: 'study-pack',
          starterPackName: 'Exam Prep Pack',
          setupNotes: 'Shift the times together if you study later in the day.',
          estimatedWeeklyMinutes: 690,
          tags: const ['study', 'exam'],
          createdAt: createdAt,
          items: [
            RoutineTemplateItem(
              title: 'Daily Deep Study',
              initialRepeatRule: RoutineRepeatRule(type: RoutineRepeatType.weekdays),
              preferredStartMinuteOfDay: 18 * 60,
              preferredDurationMinutes: 90,
              isFlexible: false,
              routineType: RoutineType.study,
            ),
            RoutineTemplateItem(
              title: 'Revision Sprint',
              initialRepeatRule: RoutineRepeatRule(
                type: RoutineRepeatType.selectedWeekdays,
                weekdays: [1, 3, 5],
              ),
              preferredStartMinuteOfDay: 20 * 60,
              preferredDurationMinutes: 45,
              isFlexible: true,
              routineType: RoutineType.review,
            ),
            RoutineTemplateItem(
              title: 'Weekly Review',
              initialRepeatRule: RoutineRepeatRule(type: RoutineRepeatType.weekly),
              preferredStartMinuteOfDay: 17 * 60,
              preferredDurationMinutes: 60,
              isFlexible: false,
              routineType: RoutineType.review,
            ),
          ],
        ),
      ),
      RoutineStarterPack(
        id: 'fitness-pack',
        name: 'Fitness + Recovery Pack',
        description: 'Balanced workout, mobility, and recovery structure.',
        estimatedWeeklyMinutes: 360,
        tags: const ['fitness', 'wellness'],
        template: RoutineTemplate(
          id: 'builtin-fitness-pack',
          name: 'Fitness + Recovery Pack',
          description: 'Workout split with recovery support.',
          category: 'health',
          isBuiltIn: true,
          starterPackId: 'fitness-pack',
          starterPackName: 'Fitness + Recovery Pack',
          estimatedWeeklyMinutes: 360,
          tags: const ['fitness', 'health'],
          createdAt: createdAt,
          items: [
            RoutineTemplateItem(
              title: 'Strength Session',
              initialRepeatRule: RoutineRepeatRule(
                type: RoutineRepeatType.selectedWeekdays,
                weekdays: [1, 3, 5],
              ),
              preferredStartMinuteOfDay: 6 * 60 + 30,
              preferredDurationMinutes: 60,
              isFlexible: false,
              routineType: RoutineType.health,
            ),
            RoutineTemplateItem(
              title: 'Mobility Reset',
              initialRepeatRule: RoutineRepeatRule(type: RoutineRepeatType.daily),
              preferredStartMinuteOfDay: 21 * 60,
              preferredDurationMinutes: 15,
              isFlexible: true,
              routineType: RoutineType.health,
            ),
            RoutineTemplateItem(
              title: 'Recovery Walk',
              initialRepeatRule: RoutineRepeatRule(type: RoutineRepeatType.weekly),
              preferredStartMinuteOfDay: 8 * 60,
              preferredDurationMinutes: 75,
              isFlexible: true,
              routineType: RoutineType.health,
            ),
          ],
        ),
      ),
      RoutineStarterPack(
        id: 'research-pack',
        name: 'Research System',
        description: 'Reading, writing, and synthesis loop for thesis or long-form work.',
        estimatedWeeklyMinutes: 570,
        tags: const ['research', 'deep-work'],
        template: RoutineTemplate(
          id: 'builtin-research-pack',
          name: 'Research System',
          description: 'Recurring reading and synthesis workflow.',
          category: 'research',
          isBuiltIn: true,
          starterPackId: 'research-pack',
          starterPackName: 'Research System',
          estimatedWeeklyMinutes: 570,
          tags: const ['research', 'deep-work'],
          createdAt: createdAt,
          items: [
            RoutineTemplateItem(
              title: 'Research Reading',
              initialRepeatRule: RoutineRepeatRule(
                type: RoutineRepeatType.selectedWeekdays,
                weekdays: [2, 4, 6],
              ),
              preferredStartMinuteOfDay: 7 * 60,
              preferredDurationMinutes: 60,
              isFlexible: true,
              routineType: RoutineType.study,
            ),
            RoutineTemplateItem(
              title: 'Writing Block',
              initialRepeatRule: RoutineRepeatRule(
                type: RoutineRepeatType.selectedWeekdays,
                weekdays: [1, 3, 5],
              ),
              preferredStartMinuteOfDay: 9 * 60,
              preferredDurationMinutes: 90,
              isFlexible: false,
              routineType: RoutineType.project,
            ),
            RoutineTemplateItem(
              title: 'Weekly Synthesis',
              initialRepeatRule: RoutineRepeatRule(type: RoutineRepeatType.weekly),
              preferredStartMinuteOfDay: 18 * 60,
              preferredDurationMinutes: 120,
              isFlexible: false,
              routineType: RoutineType.review,
            ),
          ],
        ),
      ),
    ];
  }
}
