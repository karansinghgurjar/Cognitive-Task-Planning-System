import 'package:isar/isar.dart';

part 'routine_group.g.dart';

@collection
class RoutineGroup {
  RoutineGroup({
    required this.id,
    required String name,
    this.description,
    List<String> routineIds = const [],
    required this.createdAt,
    DateTime? updatedAt,
    this.colorHex,
    this.iconName,
    this.linkedGoalId,
    this.linkedProjectId,
    this.isArchived = false,
  }) : name = name.trim(),
       routineIds = List<String>.from(routineIds),
       updatedAt = updatedAt ?? createdAt {
    if (name.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Routine group name is required.');
    }
  }

  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String id;

  late String name;
  String? description;
  late List<String> routineIds;
  late DateTime createdAt;
  DateTime? updatedAt;
  String? colorHex;
  String? iconName;
  String? linkedGoalId;
  String? linkedProjectId;
  late bool isArchived;

  RoutineGroup copyWith({
    String? id,
    String? name,
    String? description,
    bool clearDescription = false,
    List<String>? routineIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? colorHex,
    bool clearColorHex = false,
    String? iconName,
    bool clearIconName = false,
    String? linkedGoalId,
    bool clearLinkedGoalId = false,
    String? linkedProjectId,
    bool clearLinkedProjectId = false,
    bool? isArchived,
  }) {
    final group = RoutineGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      description: clearDescription ? null : description ?? this.description,
      routineIds: routineIds ?? this.routineIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      colorHex: clearColorHex ? null : colorHex ?? this.colorHex,
      iconName: clearIconName ? null : iconName ?? this.iconName,
      linkedGoalId: clearLinkedGoalId
          ? null
          : linkedGoalId ?? this.linkedGoalId,
      linkedProjectId: clearLinkedProjectId
          ? null
          : linkedProjectId ?? this.linkedProjectId,
      isArchived: isArchived ?? this.isArchived,
    )..isarId = isarId;
    return group;
  }
}
