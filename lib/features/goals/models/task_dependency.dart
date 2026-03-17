import 'package:isar/isar.dart';

part 'task_dependency.g.dart';

@collection
class TaskDependency {
  TaskDependency({
    required this.id,
    required this.taskId,
    required this.dependsOnTaskId,
    required this.createdAt,
  });

  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String id;

  @Index()
  late String taskId;

  @Index()
  late String dependsOnTaskId;

  late DateTime createdAt;

  TaskDependency copyWith({
    String? id,
    String? taskId,
    String? dependsOnTaskId,
    DateTime? createdAt,
  }) {
    final dependency = TaskDependency(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      dependsOnTaskId: dependsOnTaskId ?? this.dependsOnTaskId,
      createdAt: createdAt ?? this.createdAt,
    )..isarId = isarId;

    return dependency;
  }
}
