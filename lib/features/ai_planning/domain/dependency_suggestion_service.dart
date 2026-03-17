import 'ai_planning_models.dart';

class DependencySuggestionService {
  const DependencySuggestionService();

  List<DependencyDraft> suggestDependencies(
    List<TaskDraft> tasks,
    ParsedGoalPrompt parsed,
  ) {
    final dependencies = <DependencyDraft>[];

    for (var index = 1; index < tasks.length; index++) {
      final current = tasks[index];
      final previous = tasks[index - 1];
      if (current.milestoneDraftId == previous.milestoneDraftId) {
        dependencies.add(
          DependencyDraft(
            taskDraftId: current.id,
            dependsOnTaskDraftId: previous.id,
            reason: 'Keep milestone work in sequence.',
          ),
        );
      }
    }

    void addByContains(
      String taskNeedle,
      String dependencyNeedle,
      String reason,
    ) {
      final task = _findByContains(tasks, taskNeedle);
      final dependency = _findByContains(tasks, dependencyNeedle);
      if (task == null || dependency == null || task.id == dependency.id) {
        return;
      }
      if (dependencies.any(
        (item) =>
            item.taskDraftId == task.id &&
            item.dependsOnTaskDraftId == dependency.id,
      )) {
        return;
      }
      dependencies.add(
        DependencyDraft(
          taskDraftId: task.id,
          dependsOnTaskDraftId: dependency.id,
          reason: reason,
        ),
      );
    }

    if (parsed.keywords.contains('flutter')) {
      addByContains('widget', 'dart', 'Widgets are easier after Dart basics.');
      addByContains(
        'riverpod',
        'widget',
        'State management builds on widget fundamentals.',
      );
      addByContains(
        'navigation',
        'riverpod',
        'Persistence is easier after state is in place.',
      );
      addByContains(
        'mini project',
        'store local',
        'The project should come after core app building blocks.',
      );
    }

    if (parsed.keywords.contains('dsa')) {
      addByContains(
        'linked',
        'arrays',
        'Linked structures should follow array and string basics.',
      );
      addByContains(
        'trees',
        'linked',
        'Trees typically build on linear data structures.',
      );
      addByContains(
        'graphs',
        'trees',
        'Graphs usually come after tree traversal practice.',
      );
      addByContains(
        'mock',
        'graphs',
        'Mocks should come after core topic coverage.',
      );
    }

    if (parsed.isProject) {
      addByContains(
        'paper',
        'evaluation',
        'Paper writing should follow experiments and evaluation.',
      );
      addByContains(
        'submission',
        'paper',
        'Submission comes after the final write-up.',
      );
    }

    return _deduplicate(dependencies);
  }

  TaskDraft? _findByContains(List<TaskDraft> tasks, String needle) {
    final normalizedNeedle = needle.toLowerCase();
    for (final task in tasks) {
      if (task.title.toLowerCase().contains(normalizedNeedle)) {
        return task;
      }
    }
    return null;
  }

  List<DependencyDraft> _deduplicate(List<DependencyDraft> dependencies) {
    final unique = <String, DependencyDraft>{};
    for (final dependency in dependencies) {
      final key =
          '${dependency.taskDraftId}:${dependency.dependsOnTaskDraftId}';
      unique[key] = dependency;
    }
    return unique.values.toList();
  }
}
