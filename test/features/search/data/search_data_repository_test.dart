import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/goals/models/learning_goal.dart';
import 'package:study_flow/features/notes/models/entity_note.dart';
import 'package:study_flow/features/quick_capture/models/quick_capture_item.dart';
import 'package:study_flow/features/review/models/weekly_review.dart';
import 'package:study_flow/features/search/data/search_data_repository.dart';
import 'package:study_flow/features/search/domain/search_models.dart';
import 'package:study_flow/features/tasks/models/task.dart';

void main() {
  group('SearchDataRepository', () {
    const repository = SearchDataRepository();

    test('builds searchable records for all supported entity types', () {
      final data = repository.buildSearchData(
        tasks: [
          Task(
            id: 'task-1',
            title: 'Revise Flutter',
            description: 'Cover animation widgets',
            type: TaskType.study,
            estimatedDurationMinutes: 60,
            priority: 3,
            createdAt: DateTime(2026, 4, 1),
          ),
        ],
        goals: [
          LearningGoal(
            id: 'goal-1',
            title: 'Master DBMS',
            description: 'Prepare for exam questions',
            goalType: GoalType.examPrep,
            priority: 4,
            createdAt: DateTime(2026, 4, 1),
          ),
        ],
        notes: [
          EntityNote(
            id: 'note-1',
            entityType: EntityAttachmentType.task,
            entityId: 'task-1',
            title: 'Traversal reminder',
            content: 'Focus on recursive patterns first.',
            createdAt: DateTime(2026, 4, 2),
          ),
        ],
        captures: [
          QuickCaptureItem(
            id: 'capture-1',
            rawText: 'Sync ideas for weekly review',
            createdAt: DateTime(2026, 4, 3),
          ),
        ],
        weeklyReviews: [
          WeeklyReview(
            id: 'review-1',
            weekStart: DateTime(2026, 3, 30),
            weekEnd: DateTime(2026, 4, 5),
            createdAt: DateTime(2026, 4, 6),
            summaryText: 'A solid review week.',
            winsText: 'Finished arrays practice.',
          ),
        ],
      );

      expect(data.records, hasLength(5));
      expect(
        data.records.map((record) => record.resultType).toSet(),
        {
          SearchResultType.task,
          SearchResultType.goal,
          SearchResultType.note,
          SearchResultType.capture,
          SearchResultType.weeklyReview,
        },
      );
    });

    test('uses a readable snippet and fallback title for tasks', () {
      final data = repository.buildSearchData(
        tasks: [
          Task(
            id: 'task-1',
            title: '   ',
            description: 'A' * 120,
            type: TaskType.reading,
            estimatedDurationMinutes: 45,
            priority: 2,
            createdAt: DateTime(2026, 4, 1),
          ),
        ],
        goals: const [],
        notes: const [],
        captures: const [],
        weeklyReviews: const [],
      );

      final record = data.records.single;
      expect(record.title, 'Untitled Task');
      expect(record.snippet.length, lessThanOrEqualTo(90));
      expect(record.snippet, endsWith('…'));
    });

    test('skips archived notes from the search dataset', () {
      final data = repository.buildSearchData(
        tasks: const [],
        goals: const [],
        notes: [
          EntityNote(
            id: 'note-1',
            entityType: EntityAttachmentType.goal,
            entityId: 'goal-1',
            title: 'Archived',
            content: 'Do not show this.',
            createdAt: DateTime(2026, 4, 2),
            isArchived: true,
          ),
        ],
        captures: const [],
        weeklyReviews: const [],
      );

      expect(data.records, isEmpty);
    });

    test('marks archived goals and tasks in search records', () {
      final data = repository.buildSearchData(
        tasks: [
          Task(
            id: 'task-1',
            title: 'Old task',
            type: TaskType.misc,
            estimatedDurationMinutes: 30,
            priority: 1,
            createdAt: DateTime(2026, 4, 1),
            isArchived: true,
          ),
        ],
        goals: [
          LearningGoal(
            id: 'goal-1',
            title: 'Old goal',
            goalType: GoalType.project,
            priority: 3,
            status: GoalStatus.archived,
            createdAt: DateTime(2026, 4, 1),
          ),
        ],
        notes: const [],
        captures: const [],
        weeklyReviews: const [],
      );

      expect(data.records.every((record) => record.isArchived), isTrue);
    });

    test('preserves note parent metadata for safe navigation', () {
      final data = repository.buildSearchData(
        tasks: const [],
        goals: const [],
        notes: [
          EntityNote(
            id: 'note-1',
            entityType: EntityAttachmentType.goal,
            entityId: 'goal-99',
            content: 'Use this paper as reference.',
            createdAt: DateTime(2026, 4, 2),
          ),
        ],
        captures: const [],
        weeklyReviews: const [],
      );

      final noteRecord = data.records.single;
      expect(noteRecord.parentEntityType, EntityAttachmentType.goal);
      expect(noteRecord.parentEntityId, 'goal-99');
      expect(noteRecord.title, 'Untitled Note');
    });

    test('builds searchable weekly review snippets from reflection fields', () {
      final data = repository.buildSearchData(
        tasks: const [],
        goals: const [],
        notes: const [],
        captures: const [],
        weeklyReviews: [
          WeeklyReview(
            id: 'review-1',
            weekStart: DateTime(2026, 3, 30),
            weekEnd: DateTime(2026, 4, 5),
            createdAt: DateTime(2026, 4, 6),
            summaryText: 'Weekly review summary',
            winsText: 'Wins section',
            challengesText: 'Challenges section',
            nextWeekFocusText: 'Next focus section',
          ),
        ],
      );

      final reviewRecord = data.records.single;
      expect(reviewRecord.title, 'Weekly Review 03/30 - 04/05');
      expect(reviewRecord.snippet, contains('Weekly review summary'));
      expect(reviewRecord.searchableTerms, contains('weekly review'));
    });
  });
}
