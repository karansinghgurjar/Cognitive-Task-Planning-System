import 'package:isar/isar.dart';

import '../domain/routine_enums.dart';
import '../domain/routine_repeat_rule.dart';

part 'routine_template.g.dart';

@collection
class RoutineTemplate {
  RoutineTemplate({
    required this.id,
    required String name,
    this.description,
    this.category = 'general',
    List<RoutineTemplateItem> items = const [],
    required this.createdAt,
    DateTime? updatedAt,
    this.isBuiltIn = false,
    this.starterPackId,
    this.starterPackName,
    this.setupNotes,
    this.estimatedWeeklyMinutes,
    List<String> tags = const [],
  }) : name = name.trim(),
       updatedAt = updatedAt ?? createdAt,
       items = List<RoutineTemplateItem>.from(items),
       tags = List<String>.from(tags) {
    if (name.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Template name is required.');
    }
  }

  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String id;

  late String name;
  String? description;
  late String category;
  late List<RoutineTemplateItem> items;
  late DateTime createdAt;
  DateTime? updatedAt;
  late bool isBuiltIn;
  String? starterPackId;
  String? starterPackName;
  String? setupNotes;
  int? estimatedWeeklyMinutes;
  late List<String> tags;

  RoutineTemplate copyWith({
    String? id,
    String? name,
    String? description,
    bool clearDescription = false,
    String? category,
    List<RoutineTemplateItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isBuiltIn,
    String? starterPackId,
    bool clearStarterPackId = false,
    String? starterPackName,
    bool clearStarterPackName = false,
    String? setupNotes,
    bool clearSetupNotes = false,
    int? estimatedWeeklyMinutes,
    bool clearEstimatedWeeklyMinutes = false,
    List<String>? tags,
  }) {
    final template = RoutineTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: clearDescription ? null : description ?? this.description,
      category: category ?? this.category,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
      starterPackId: clearStarterPackId
          ? null
          : starterPackId ?? this.starterPackId,
      starterPackName: clearStarterPackName
          ? null
          : starterPackName ?? this.starterPackName,
      setupNotes: clearSetupNotes ? null : setupNotes ?? this.setupNotes,
      estimatedWeeklyMinutes: clearEstimatedWeeklyMinutes
          ? null
          : estimatedWeeklyMinutes ?? this.estimatedWeeklyMinutes,
      tags: tags ?? this.tags,
    )..isarId = isarId;
    return template;
  }
}

@embedded
class RoutineTemplateItem {
  RoutineTemplateItem({
    String title = '',
    this.description,
    RoutineRepeatRule? initialRepeatRule,
    this.preferredStartMinuteOfDay,
    this.preferredDurationMinutes,
    this.timeWindowStartMinuteOfDay,
    this.timeWindowEndMinuteOfDay,
    this.isFlexible = true,
    this.autoRescheduleMissed = false,
    this.countsTowardConsistency = true,
    this.suggestedGoalTag,
    this.suggestedProjectTag,
    this.categoryId,
    List<String> tagIds = const [],
    this.routineType = RoutineType.custom,
    this.priority = 3,
    this.energyType,
    this.colorHex,
    this.iconName,
    this.remindersEnabled = false,
    this.reminderLeadMinutes,
  }) : title = title.trim(),
       tagIds = List<String>.from(tagIds) {
    repeatRule = initialRepeatRule ?? RoutineRepeatRule();
    if (title.isEmpty) {
      throw ArgumentError.value(title, 'title', 'Template item title is required.');
    }
  }

  late String title;
  String? description;
  late RoutineRepeatRule repeatRule;
  int? preferredStartMinuteOfDay;
  int? preferredDurationMinutes;
  int? timeWindowStartMinuteOfDay;
  int? timeWindowEndMinuteOfDay;
  late bool isFlexible;
  late bool autoRescheduleMissed;
  late bool countsTowardConsistency;
  String? suggestedGoalTag;
  String? suggestedProjectTag;
  String? categoryId;
  late List<String> tagIds;

  @Enumerated(EnumType.name)
  late RoutineType routineType;

  late int priority;
  String? energyType;
  String? colorHex;
  String? iconName;
  late bool remindersEnabled;
  int? reminderLeadMinutes;

  RoutineTemplateItem copyWith({
    String? title,
    String? description,
    bool clearDescription = false,
    RoutineRepeatRule? repeatRule,
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
    String? suggestedGoalTag,
    bool clearSuggestedGoalTag = false,
    String? suggestedProjectTag,
    bool clearSuggestedProjectTag = false,
    String? categoryId,
    bool clearCategoryId = false,
    List<String>? tagIds,
    RoutineType? routineType,
    int? priority,
    String? energyType,
    bool clearEnergyType = false,
    String? colorHex,
    bool clearColorHex = false,
    String? iconName,
    bool clearIconName = false,
    bool? remindersEnabled,
    int? reminderLeadMinutes,
    bool clearReminderLeadMinutes = false,
  }) {
    return RoutineTemplateItem(
      title: title ?? this.title,
      description: clearDescription ? null : description ?? this.description,
      initialRepeatRule: repeatRule ?? this.repeatRule,
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
      autoRescheduleMissed: autoRescheduleMissed ?? this.autoRescheduleMissed,
      countsTowardConsistency:
          countsTowardConsistency ?? this.countsTowardConsistency,
      suggestedGoalTag: clearSuggestedGoalTag
          ? null
          : suggestedGoalTag ?? this.suggestedGoalTag,
      suggestedProjectTag: clearSuggestedProjectTag
          ? null
          : suggestedProjectTag ?? this.suggestedProjectTag,
      categoryId: clearCategoryId ? null : categoryId ?? this.categoryId,
      tagIds: tagIds ?? this.tagIds,
      routineType: routineType ?? this.routineType,
      priority: priority ?? this.priority,
      energyType: clearEnergyType ? null : energyType ?? this.energyType,
      colorHex: clearColorHex ? null : colorHex ?? this.colorHex,
      iconName: clearIconName ? null : iconName ?? this.iconName,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      reminderLeadMinutes: clearReminderLeadMinutes
          ? null
          : reminderLeadMinutes ?? this.reminderLeadMinutes,
    );
  }
}
