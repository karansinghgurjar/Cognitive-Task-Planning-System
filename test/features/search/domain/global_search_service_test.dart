import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/notes/models/entity_note.dart';
import 'package:study_flow/features/search/domain/global_search_service.dart';
import 'package:study_flow/features/search/domain/search_models.dart';

void main() {
  group('GlobalSearchService', () {
    const service = GlobalSearchService();

    test('ranks exact title matches above prefix and substring matches', () {
      final results = service.search(
        GlobalSearchData(
          records: [
            _record(
              id: 'task-1',
              title: 'Flutter',
              resultType: SearchResultType.task,
            ),
            _record(
              id: 'task-2',
              title: 'Flutter Basics',
              resultType: SearchResultType.task,
            ),
            _record(
              id: 'task-3',
              title: 'Learn Flutter animations',
              resultType: SearchResultType.task,
            ),
          ],
        ),
        'flutter',
      );

      expect(results.map((result) => result.entityId).toList(), [
        'task-1',
        'task-2',
        'task-3',
      ]);
    });

    test('matches case-insensitively', () {
      final results = service.search(
        GlobalSearchData(
          records: [
            _record(
              id: 'goal-1',
              title: 'DBMS Joins',
              resultType: SearchResultType.goal,
            ),
          ],
        ),
        'dbms',
      );

      expect(results, hasLength(1));
      expect(results.single.entityId, 'goal-1');
    });

    test('ranks prefix title matches above keyword-only matches', () {
      final results = service.search(
        GlobalSearchData(
          records: [
            _record(
              id: 'task-1',
              title: 'Sync Audit',
              resultType: SearchResultType.task,
            ),
            _record(
              id: 'review-1',
              title: 'Weekly Review',
              subtitle: 'Reflection',
              snippet: 'Plan a sync recovery pass this week',
              searchableTerms: const ['recovery', 'sync'],
              resultType: SearchResultType.weeklyReview,
            ),
          ],
        ),
        'sync',
      );

      expect(results.first.entityId, 'task-1');
      expect(results.last.entityId, 'review-1');
    });

    test('pushes archived results below active results when scores tie', () {
      final results = service.search(
        GlobalSearchData(
          records: [
            _record(
              id: 'task-1',
              title: 'Arrays',
              resultType: SearchResultType.task,
            ),
            _record(
              id: 'task-2',
              title: 'Arrays',
              resultType: SearchResultType.task,
              isArchived: true,
            ),
          ],
        ),
        'arrays',
      );

      expect(results.first.isArchived, isFalse);
      expect(results.last.isArchived, isTrue);
    });

    test('groups results in stable section order', () {
      final grouped = service.groupResults([
        _result(id: 'goal-1', type: SearchResultType.goal),
        _result(id: 'task-1', type: SearchResultType.task),
        _result(id: 'review-1', type: SearchResultType.weeklyReview),
      ]);

      expect(grouped.map((section) => section.type).toList(), [
        SearchResultType.task,
        SearchResultType.goal,
        SearchResultType.weeklyReview,
      ]);
    });

    test('returns empty results for an empty query', () {
      final results = service.search(
        GlobalSearchData(
          records: [
            _record(
              id: 'task-1',
              title: 'Anything',
              resultType: SearchResultType.task,
            ),
          ],
        ),
        '   ',
      );

      expect(results, isEmpty);
    });
  });
}

SearchableRecord _record({
  required String id,
  required String title,
  required SearchResultType resultType,
  String subtitle = '',
  String snippet = '',
  List<String> searchableTerms = const [],
  bool isArchived = false,
}) {
  return SearchableRecord(
    id: id,
    resultType: resultType,
    entityId: id,
    title: title,
    subtitle: subtitle,
    snippet: snippet,
    searchableTerms: searchableTerms,
    updatedAt: DateTime(2026, 4, 7),
    isArchived: isArchived,
  );
}

GlobalSearchResult _result({
  required String id,
  required SearchResultType type,
}) {
  return GlobalSearchResult(
    id: id,
    resultType: type,
    entityId: id,
    title: id,
    subtitle: '',
    snippet: '',
    score: 10,
    updatedAt: DateTime(2026, 4, 7),
    parentEntityType: EntityAttachmentType.task,
  );
}
