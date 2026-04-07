import '../../goals/models/learning_goal.dart';
import '../../notes/models/entity_note.dart';
import '../../quick_capture/models/quick_capture_item.dart';
import '../../review/models/weekly_review.dart';
import '../../tasks/models/task.dart';
import '../domain/search_models.dart';

class SearchDataRepository {
  const SearchDataRepository();

  GlobalSearchData buildSearchData({
    required List<Task> tasks,
    required List<LearningGoal> goals,
    required List<EntityNote> notes,
    required List<QuickCaptureItem> captures,
    required List<WeeklyReview> weeklyReviews,
  }) {
    final records = <SearchableRecord>[
      ...tasks.map(_taskRecord),
      ...goals.map(_goalRecord),
      ...notes.where((note) => !note.isArchived).map(_noteRecord),
      ...captures.map(_captureRecord),
      ...weeklyReviews.map(_weeklyReviewRecord),
    ];
    return GlobalSearchData(records: records);
  }

  SearchableRecord _taskRecord(Task task) {
    return SearchableRecord(
      id: 'task:${task.id}',
      resultType: SearchResultType.task,
      entityId: task.id,
      title: task.title.trim().isEmpty ? 'Untitled Task' : task.title,
      subtitle: task.description?.trim().isNotEmpty == true
          ? 'Task'
          : 'Task${task.resourceTag?.trim().isNotEmpty == true ? ' • ${task.resourceTag}' : ''}',
      snippet: _truncate(
        task.description?.trim().isNotEmpty == true
            ? task.description!
            : task.resourceTag ?? '',
      ),
      searchableTerms: [
        task.title,
        task.description ?? '',
        task.resourceTag ?? '',
      ],
      updatedAt: task.updatedAt ?? task.createdAt,
      isArchived: task.isArchived,
    );
  }

  SearchableRecord _goalRecord(LearningGoal goal) {
    return SearchableRecord(
      id: 'goal:${goal.id}',
      resultType: SearchResultType.goal,
      entityId: goal.id,
      title: goal.title.trim().isEmpty ? 'Untitled Goal' : goal.title,
      subtitle: goal.goalType.label,
      snippet: _truncate(goal.description ?? ''),
      searchableTerms: [
        goal.title,
        goal.description ?? '',
      ],
      updatedAt: goal.completedAt ?? goal.createdAt,
      isArchived: goal.status == GoalStatus.archived,
    );
  }

  SearchableRecord _noteRecord(EntityNote note) {
    final title = note.title?.trim();
    return SearchableRecord(
      id: 'note:${note.id}',
      resultType: SearchResultType.note,
      entityId: note.id,
      title: title == null || title.isEmpty ? 'Untitled Note' : title,
      subtitle: '${note.entityType.label} Note',
      snippet: _truncate(note.content),
      searchableTerms: [
        note.title ?? '',
        note.content,
      ],
      updatedAt: note.updatedAt ?? note.createdAt,
      parentEntityType: note.entityType,
      parentEntityId: note.entityId,
    );
  }

  SearchableRecord _captureRecord(QuickCaptureItem item) {
    return SearchableRecord(
      id: 'capture:${item.id}',
      resultType: SearchResultType.capture,
      entityId: item.id,
      title: _truncate(item.rawText, maxLength: 60),
      subtitle: item.isProcessed
          ? 'Processed Quick Capture'
          : 'Quick Capture Inbox',
      snippet: _truncate(item.rawText, maxLength: 120),
      searchableTerms: [item.rawText],
      updatedAt: item.updatedAt ?? item.createdAt,
      isArchived: item.isArchived,
    );
  }

  SearchableRecord _weeklyReviewRecord(WeeklyReview review) {
    final combinedSnippet = [
      review.summaryText,
      review.winsText,
      review.challengesText,
      review.nextWeekFocusText,
    ].whereType<String>().where((value) => value.trim().isNotEmpty).join(' ');
    return SearchableRecord(
      id: 'weeklyReview:${review.id}',
      resultType: SearchResultType.weeklyReview,
      entityId: review.id,
      title: 'Weekly Review ${_weekLabel(review)}',
      subtitle: 'Weekly Reflection',
      snippet: _truncate(combinedSnippet),
      searchableTerms: [
        review.summaryText ?? '',
        review.winsText ?? '',
        review.challengesText ?? '',
        review.nextWeekFocusText ?? '',
        'weekly review',
      ],
      updatedAt: review.updatedAt ?? review.createdAt,
      weekStart: review.weekStart,
    );
  }

  String _truncate(String value, {int maxLength = 90}) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return '';
    }
    if (trimmed.length <= maxLength) {
      return trimmed;
    }
    return '${trimmed.substring(0, maxLength - 1)}…';
  }

  String _weekLabel(WeeklyReview review) {
    final startMonth = review.weekStart.month.toString().padLeft(2, '0');
    final startDay = review.weekStart.day.toString().padLeft(2, '0');
    final endMonth = review.weekEnd.month.toString().padLeft(2, '0');
    final endDay = review.weekEnd.day.toString().padLeft(2, '0');
    return '$startMonth/$startDay - $endMonth/$endDay';
  }
}
