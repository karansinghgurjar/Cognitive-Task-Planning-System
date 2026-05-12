import 'package:isar/isar.dart';

import '../../goals/data/goal_repository.dart';
import '../../goals/models/goal_milestone.dart';
import '../../goals/models/learning_goal.dart';
import '../../knowledge/data/knowledge_repository.dart';
import '../../knowledge/models/knowledge_item.dart';
import '../../review/data/weekly_review_repository.dart';
import '../../review/models/weekly_review.dart';
import '../../routines/data/routine_repository.dart';
import '../../routines/domain/routine_enums.dart';
import '../../routines/domain/routine_generation_service.dart';
import '../../routines/domain/routine_repeat_rule.dart';
import '../../routines/models/routine.dart';
import '../../routines/models/routine_occurrence.dart';
import '../../schedule/data/planned_session_repository.dart';
import '../../schedule/models/planned_session.dart';
import '../../settings/data/settings_repository.dart';
import '../../settings/models/notification_preferences.dart';
import '../../tasks/data/task_repository.dart';
import '../../tasks/models/task.dart';
import '../../timetable/data/timetable_repository.dart';
import '../../timetable/models/timetable_slot.dart';

class DemoDataSummary {
  const DemoDataSummary({
    required this.goals,
    required this.tasks,
    required this.routines,
    required this.knowledgeItems,
    required this.sessions,
    required this.timetableSlots,
    required this.weeklyReviews,
  });

  final int goals;
  final int tasks;
  final int routines;
  final int knowledgeItems;
  final int sessions;
  final int timetableSlots;
  final int weeklyReviews;
}

class DemoWorkspaceData {
  const DemoWorkspaceData({
    required this.goals,
    required this.milestones,
    required this.tasks,
    required this.routines,
    required this.sessions,
    required this.knowledgeItems,
    required this.timetableSlots,
    required this.weeklyReviews,
    required this.preferences,
  });

  final List<LearningGoal> goals;
  final List<GoalMilestone> milestones;
  final List<Task> tasks;
  final List<Routine> routines;
  final List<PlannedSession> sessions;
  final List<KnowledgeItem> knowledgeItems;
  final List<TimetableSlot> timetableSlots;
  final List<WeeklyReview> weeklyReviews;
  final NotificationPreferences preferences;

  DemoDataSummary get summary => DemoDataSummary(
        goals: goals.length,
        tasks: tasks.length,
        routines: routines.length,
        knowledgeItems: knowledgeItems.length,
        sessions: sessions.length,
        timetableSlots: timetableSlots.length,
        weeklyReviews: weeklyReviews.length,
      );
}

class DemoDataService {
  DemoDataService({
    required Isar isar,
    required GoalRepository goalRepository,
    required TaskRepository taskRepository,
    required RoutineRepository routineRepository,
    required KnowledgeRepository knowledgeRepository,
    required PlannedSessionRepository sessionRepository,
    required TimetableRepository timetableRepository,
    required WeeklyReviewRepository weeklyReviewRepository,
    required SettingsRepository settingsRepository,
  })  : _isar = isar,
        _goalRepository = goalRepository,
        _taskRepository = taskRepository,
        _routineRepository = routineRepository,
        _knowledgeRepository = knowledgeRepository,
        _sessionRepository = sessionRepository,
        _timetableRepository = timetableRepository,
        _weeklyReviewRepository = weeklyReviewRepository,
        _settingsRepository = settingsRepository;

  static const idPrefix = 'demo-';

  final Isar _isar;
  final GoalRepository _goalRepository;
  final TaskRepository _taskRepository;
  final RoutineRepository _routineRepository;
  final KnowledgeRepository _knowledgeRepository;
  final PlannedSessionRepository _sessionRepository;
  final TimetableRepository _timetableRepository;
  final WeeklyReviewRepository _weeklyReviewRepository;
  final SettingsRepository _settingsRepository;

  DemoWorkspaceData buildSampleWorkspace({DateTime? now}) {
    final anchor = now ?? DateTime.now();
    final today = _day(anchor);
    final weekStart = today.subtract(Duration(days: today.weekday - 1));

    final thesisGoal = LearningGoal(
      id: '${idPrefix}goal-thesis',
      title: 'M.Tech Thesis Push',
      description: 'Keep research writing and experiment review moving every week.',
      goalType: GoalType.project,
      targetDate: today.add(const Duration(days: 75)),
      priority: 1,
      estimatedTotalMinutes: 7200,
      createdAt: today.subtract(const Duration(days: 24)),
    );
    final placementsGoal = LearningGoal(
      id: '${idPrefix}goal-placements',
      title: 'DSA Interview Prep',
      description: 'Prepare consistently for placements without wrecking weekday capacity.',
      goalType: GoalType.examPrep,
      targetDate: today.add(const Duration(days: 110)),
      priority: 1,
      estimatedTotalMinutes: 9600,
      createdAt: today.subtract(const Duration(days: 40)),
    );
    final fitnessGoal = LearningGoal(
      id: '${idPrefix}goal-fitness',
      title: 'Stay Physically Consistent',
      description: 'Use short routines that survive busy academic weeks.',
      goalType: GoalType.learning,
      targetDate: today.add(const Duration(days: 180)),
      priority: 2,
      estimatedTotalMinutes: 3600,
      createdAt: today.subtract(const Duration(days: 30)),
    );

    final milestones = <GoalMilestone>[
      GoalMilestone(
        id: '${idPrefix}milestone-thesis-1',
        goalId: thesisGoal.id,
        title: 'Literature synthesis draft',
        sequenceOrder: 1,
        estimatedMinutes: 720,
        createdAt: today.subtract(const Duration(days: 20)),
      ),
      GoalMilestone(
        id: '${idPrefix}milestone-thesis-2',
        goalId: thesisGoal.id,
        title: 'Methodology figure refresh',
        sequenceOrder: 2,
        estimatedMinutes: 360,
        createdAt: today.subtract(const Duration(days: 18)),
      ),
      GoalMilestone(
        id: '${idPrefix}milestone-dsa-1',
        goalId: placementsGoal.id,
        title: 'Arrays and binary search pass',
        sequenceOrder: 1,
        estimatedMinutes: 480,
        createdAt: today.subtract(const Duration(days: 14)),
      ),
      GoalMilestone(
        id: '${idPrefix}milestone-dsa-2',
        goalId: placementsGoal.id,
        title: 'Tree and graph confidence pass',
        sequenceOrder: 2,
        estimatedMinutes: 720,
        createdAt: today.subtract(const Duration(days: 12)),
      ),
    ];

    final tasks = <Task>[
      Task(
        id: '${idPrefix}task-thesis-reading',
        title: 'Review SAR methodology notes',
        description: 'Pull blockers into the next draft notes.',
        type: TaskType.reading,
        estimatedDurationMinutes: 60,
        dueDate: today.add(const Duration(days: 1)),
        priority: 1,
        goalId: thesisGoal.id,
        milestoneId: milestones.first.id,
        resourceTag: 'research',
        createdAt: today.subtract(const Duration(days: 6)),
      ),
      Task(
        id: '${idPrefix}task-dsa-graphs',
        title: 'Solve 3 graph problems',
        description: 'Focus on shortest path and traversal confidence.',
        type: TaskType.coding,
        estimatedDurationMinutes: 90,
        dueDate: today.add(const Duration(days: 2)),
        priority: 1,
        goalId: placementsGoal.id,
        milestoneId: milestones[3].id,
        resourceTag: 'placement-prep',
        createdAt: today.subtract(const Duration(days: 5)),
      ),
      Task(
        id: '${idPrefix}task-resume',
        title: 'Refresh resume project bullets',
        description: 'Tighten outcomes for thesis and Flutter work.',
        type: TaskType.project,
        estimatedDurationMinutes: 45,
        dueDate: today.add(const Duration(days: 4)),
        priority: 2,
        goalId: placementsGoal.id,
        resourceTag: 'career',
        createdAt: today.subtract(const Duration(days: 3)),
      ),
      Task(
        id: '${idPrefix}task-fitness-log',
        title: 'Log weekly mobility baseline',
        type: TaskType.misc,
        estimatedDurationMinutes: 20,
        dueDate: today.add(const Duration(days: 6)),
        priority: 3,
        goalId: fitnessGoal.id,
        resourceTag: 'health',
        createdAt: today.subtract(const Duration(days: 2)),
      ),
    ];

    final routines = <Routine>[
      Routine(
        id: '${idPrefix}routine-dsa',
        title: 'DSA Practice',
        description: 'Weekday problem solving block for placement prep.',
        createdAt: today.subtract(const Duration(days: 20)),
        anchorDate: weekStart,
        repeatRule: RoutineRepeatRule(type: RoutineRepeatType.weekdays),
        preferredStartMinuteOfDay: 20 * 60,
        preferredDurationMinutes: 60,
        isFlexible: false,
        linkedGoalId: placementsGoal.id,
        routineType: RoutineType.study,
        priority: 1,
        remindersEnabled: true,
        reminderLeadMinutes: 10,
      ),
      Routine(
        id: '${idPrefix}routine-thesis',
        title: 'Thesis Deep Work',
        description: 'Protected research writing block.',
        createdAt: today.subtract(const Duration(days: 18)),
        anchorDate: weekStart,
        repeatRule: RoutineRepeatRule(
          type: RoutineRepeatType.selectedWeekdays,
          weekdays: const [2, 4, 6],
        ),
        preferredStartMinuteOfDay: 9 * 60 + 30,
        preferredDurationMinutes: 90,
        isFlexible: true,
        timeWindowStartMinuteOfDay: 8 * 60,
        timeWindowEndMinuteOfDay: 14 * 60,
        linkedGoalId: thesisGoal.id,
        routineType: RoutineType.project,
        priority: 1,
      ),
      Routine(
        id: '${idPrefix}routine-fitness',
        title: 'Mobility Reset',
        description: 'Short consistency-first fitness block.',
        createdAt: today.subtract(const Duration(days: 15)),
        anchorDate: weekStart,
        repeatRule: RoutineRepeatRule(
          type: RoutineRepeatType.selectedWeekdays,
          weekdays: const [1, 3, 5],
        ),
        preferredStartMinuteOfDay: 7 * 60,
        preferredDurationMinutes: 25,
        isFlexible: false,
        linkedGoalId: fitnessGoal.id,
        routineType: RoutineType.health,
        priority: 2,
      ),
      Routine(
        id: '${idPrefix}routine-review',
        title: 'Weekly Review',
        description: 'Reset priorities before the next week gets noisy.',
        createdAt: today.subtract(const Duration(days: 10)),
        anchorDate: weekStart,
        repeatRule: RoutineRepeatRule(
          type: RoutineRepeatType.selectedWeekdays,
          weekdays: const [7],
        ),
        preferredStartMinuteOfDay: 18 * 60,
        preferredDurationMinutes: 45,
        isFlexible: true,
        linkedGoalId: thesisGoal.id,
        routineType: RoutineType.review,
        priority: 2,
      ),
    ];

    final sessions = <PlannedSession>[
      PlannedSession(
        id: '${idPrefix}session-thesis-1',
        taskId: '${idPrefix}task-thesis-reading',
        start: today.subtract(const Duration(days: 1)).add(const Duration(hours: 10)),
        end: today.subtract(const Duration(days: 1)).add(const Duration(hours: 11)),
        status: PlannedSessionStatus.completed,
        completed: true,
        actualMinutesFocused: 57,
      ),
      PlannedSession(
        id: '${idPrefix}session-dsa-1',
        taskId: '${idPrefix}task-dsa-graphs',
        start: today.subtract(const Duration(days: 2)).add(const Duration(hours: 20)),
        end: today.subtract(const Duration(days: 2)).add(const Duration(hours: 21, minutes: 30)),
        status: PlannedSessionStatus.completed,
        completed: true,
        actualMinutesFocused: 82,
      ),
      PlannedSession(
        id: '${idPrefix}session-resume',
        taskId: '${idPrefix}task-resume',
        start: today.add(const Duration(days: 1)).add(const Duration(hours: 19)),
        end: today.add(const Duration(days: 1)).add(const Duration(hours: 19, minutes: 45)),
        status: PlannedSessionStatus.pending,
      ),
    ];

    final knowledgeItems = <KnowledgeItem>[
      KnowledgeItem(
        id: '${idPrefix}knowledge-paper',
        title: 'SAR Paper Revision Notes',
        content: 'Need a cleaner methodology diagram and tighter experiment framing.',
        type: KnowledgeItemType.researchPaper,
        status: KnowledgeStatus.reviewing,
        priority: KnowledgePriority.high,
        createdAt: today.subtract(const Duration(days: 7)),
        dueReviewAt: today.add(const Duration(days: 1)),
        lastReviewedAt: today.subtract(const Duration(days: 2)),
        reviewCount: 2,
        reviewIntervalDays: 3,
        tags: const ['thesis', 'paper'],
        links: [
          EntityLink(entityId: thesisGoal.id, entityType: LinkedEntityType.goal),
          EntityLink(
            entityId: '${idPrefix}task-thesis-reading',
            entityType: LinkedEntityType.task,
          ),
        ],
      ),
      KnowledgeItem(
        id: '${idPrefix}knowledge-dsa',
        title: 'Graph Patterns Cheat Sheet',
        content: 'Revisit BFS shortest path, topo ordering, and union-find cues.',
        type: KnowledgeItemType.note,
        status: KnowledgeStatus.active,
        priority: KnowledgePriority.high,
        createdAt: today.subtract(const Duration(days: 10)),
        dueReviewAt: today,
        lastReviewedAt: today.subtract(const Duration(days: 3)),
        reviewCount: 4,
        reviewIntervalDays: 3,
        tags: const ['dsa', 'placements'],
        links: [
          EntityLink(entityId: placementsGoal.id, entityType: LinkedEntityType.goal),
          EntityLink(
            entityId: '${idPrefix}routine-dsa',
            entityType: LinkedEntityType.routine,
          ),
        ],
      ),
      KnowledgeItem(
        id: '${idPrefix}knowledge-fitness',
        title: 'Mobility Reset Checklist',
        content: 'Ankles, hips, thoracic spine, shoulder opener, quick walk cooldown.',
        type: KnowledgeItemType.resource,
        status: KnowledgeStatus.active,
        priority: KnowledgePriority.normal,
        createdAt: today.subtract(const Duration(days: 5)),
        tags: const ['fitness'],
        links: [
          EntityLink(entityId: fitnessGoal.id, entityType: LinkedEntityType.goal),
        ],
      ),
    ];

    final timetableSlots = <TimetableSlot>[
      for (final weekday in const [1, 2, 3, 4, 5])
        TimetableSlot(
          id: '${idPrefix}slot-class-$weekday',
          weekday: weekday,
          startHour: 10,
          startMinute: 0,
          endHour: 16,
          endMinute: 0,
          isBusy: true,
          label: 'Campus / lab',
        ),
      TimetableSlot(
        id: '${idPrefix}slot-sunday-family',
        weekday: 7,
        startHour: 12,
        startMinute: 0,
        endHour: 16,
        endMinute: 0,
        isBusy: true,
        label: 'Family time',
      ),
    ];

    final weeklyReviews = <WeeklyReview>[
      WeeklyReview(
        id: '${idPrefix}weekly-review-current',
        weekStart: weekStart,
        weekEnd: weekStart.add(const Duration(days: 6)),
        createdAt: today,
        summaryText: 'Research stayed steady, DSA recovered well, and fitness needs shorter blocks.',
        winsText: 'Two strong thesis sessions and better evening focus than last week.',
        challengesText: 'Late-night coding blocks slipped after heavy campus days.',
        nextWeekFocusText: 'Protect thesis mornings and shift DSA earlier on weekdays.',
      ),
    ];

    final preferences = NotificationPreferences(
      sessionRemindersEnabled: true,
      dailySummaryEnabled: true,
      deadlineWarningsEnabled: true,
      reminderLeadTimeMinutes: 10,
      dailySummaryHour: 7,
      dailySummaryMinute: 30,
      backupReminderEnabled: true,
      backupReminderCadence: BackupReminderCadence.weekly,
      themePreference: AppThemePreference.system,
      defaultPlanningHorizonDays: 7,
      routineGenerationHorizonDays: 30,
    );

    return DemoWorkspaceData(
      goals: [thesisGoal, placementsGoal, fitnessGoal],
      milestones: milestones,
      tasks: tasks,
      routines: routines,
      sessions: sessions,
      knowledgeItems: knowledgeItems,
      timetableSlots: timetableSlots,
      weeklyReviews: weeklyReviews,
      preferences: preferences,
    );
  }

  Future<bool> containsSampleData() async {
    return await _isar.learningGoals.filter().idStartsWith(idPrefix).count() > 0;
  }

  Future<DemoDataSummary> loadSampleData({DateTime? now}) async {
    final data = buildSampleWorkspace(now: now);

    for (final slot in data.timetableSlots) {
      await _upsertSlot(slot);
    }
    for (final goal in data.goals) {
      await _goalRepository.addGoal(goal);
    }
    for (final milestone in data.milestones) {
      await _goalRepository.addMilestone(milestone);
    }
    await _taskRepository.addTasks(data.tasks);
    for (final routine in data.routines) {
      await _routineRepository.saveRoutine(routine);
    }
    await _sessionRepository.addSessions(data.sessions);
    for (final item in data.knowledgeItems) {
      await _knowledgeRepository.addItem(item);
    }
    for (final review in data.weeklyReviews) {
      await _weeklyReviewRepository.saveReview(review);
    }

    final existingPreferences = await _settingsRepository.getPreferences();
    await _settingsRepository.updatePreferences(
      existingPreferences.copyWith(
        backupReminderEnabled: data.preferences.backupReminderEnabled,
        backupReminderCadence: data.preferences.backupReminderCadence,
        sessionRemindersEnabled: data.preferences.sessionRemindersEnabled,
        dailySummaryEnabled: data.preferences.dailySummaryEnabled,
        dailySummaryHour: data.preferences.dailySummaryHour,
        dailySummaryMinute: data.preferences.dailySummaryMinute,
        themePreference: data.preferences.themePreference,
        defaultPlanningHorizonDays: data.preferences.defaultPlanningHorizonDays,
        routineGenerationHorizonDays:
            data.preferences.routineGenerationHorizonDays,
      ),
    );

    final generation = RoutineGenerationService();
    final rangeNow = now ?? DateTime.now();
    final occurrences = <RoutineOccurrence>[];
    for (final routine in data.routines) {
      final dates = generation.computeOccurrenceDates(
        routine,
        startDate: _day(rangeNow).subtract(const Duration(days: 7)),
        endDate: _day(rangeNow).add(const Duration(days: 30)),
      );
      occurrences.addAll(
        generation.buildOccurrences(
          routine,
          dates,
          generatedAt: rangeNow,
        ),
      );
    }
    await _routineRepository.saveOccurrences(occurrences);

    return data.summary;
  }

  Future<int> clearSampleData() async {
    final tasks = await _isar.tasks.filter().idStartsWith(idPrefix).findAll();
    final goals = await _isar.learningGoals.filter().idStartsWith(idPrefix).findAll();
    final milestones = await _isar.goalMilestones.filter().idStartsWith(idPrefix).findAll();
    final sessions = await _isar.plannedSessions.filter().idStartsWith(idPrefix).findAll();
    final routines = await _isar.routines.filter().idStartsWith(idPrefix).findAll();
    final occurrences = await _isar.routineOccurrences.filter().idStartsWith(idPrefix).findAll();
    final knowledgeItems = await _isar.knowledgeItems.filter().idStartsWith(idPrefix).findAll();
    final reviews = await _isar.weeklyReviews.filter().idStartsWith(idPrefix).findAll();
    final slots = await _isar.timetableSlots.filter().idStartsWith(idPrefix).findAll();

    await _isar.writeTxn(() async {
      await _isar.plannedSessions.deleteAll(sessions.map((item) => item.isarId).toList());
      await _isar.tasks.deleteAll(tasks.map((item) => item.isarId).toList());
      await _isar.goalMilestones.deleteAll(milestones.map((item) => item.isarId).toList());
      await _isar.learningGoals.deleteAll(goals.map((item) => item.isarId).toList());
      await _isar.routineOccurrences.deleteAll(occurrences.map((item) => item.isarId).toList());
      await _isar.routines.deleteAll(routines.map((item) => item.isarId).toList());
      await _isar.knowledgeItems.deleteAll(knowledgeItems.map((item) => item.isarId).toList());
      await _isar.weeklyReviews.deleteAll(reviews.map((item) => item.isarId).toList());
      await _isar.timetableSlots.deleteAll(slots.map((item) => item.isarId).toList());
    });

    return tasks.length +
        goals.length +
        milestones.length +
        sessions.length +
        routines.length +
        occurrences.length +
        knowledgeItems.length +
        reviews.length +
        slots.length;
  }

  Future<void> _upsertSlot(TimetableSlot slot) async {
    final existing = await _isar.timetableSlots.filter().idEqualTo(slot.id).findFirst();
    if (existing == null) {
      await _timetableRepository.addSlot(slot);
    } else {
      slot.isarId = existing.isarId;
      await _timetableRepository.updateSlot(slot);
    }
  }

  DateTime _day(DateTime value) => DateTime(value.year, value.month, value.day);
}
