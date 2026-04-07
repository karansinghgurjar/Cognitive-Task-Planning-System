import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/notes/data/notes_repository.dart';
import 'package:study_flow/features/notes/data/resources_repository.dart';
import 'package:study_flow/features/notes/models/entity_note.dart';
import 'package:study_flow/features/notes/models/entity_resource.dart';

void main() {
  test('sortEntityNotes places pinned and newer notes first', () {
    final notes = [
      EntityNote(
        id: 'older',
        entityType: EntityAttachmentType.task,
        entityId: 'task-1',
        content: 'Older note',
        createdAt: DateTime(2026, 4, 6, 8),
      ),
      EntityNote(
        id: 'newer',
        entityType: EntityAttachmentType.task,
        entityId: 'task-1',
        content: 'Newer note',
        createdAt: DateTime(2026, 4, 6, 9),
      ),
      EntityNote(
        id: 'pinned',
        entityType: EntityAttachmentType.task,
        entityId: 'task-1',
        content: 'Pinned note',
        createdAt: DateTime(2026, 4, 5, 8),
        isPinned: true,
      ),
    ];

    notes.sort(sortEntityNotes);

    expect(notes.map((note) => note.id).toList(), ['pinned', 'newer', 'older']);
  });

  test('sortEntityResources places pinned and recently updated resources first', () {
    final resources = [
      EntityResource(
        id: 'older',
        entityType: EntityAttachmentType.goal,
        entityId: 'goal-1',
        title: 'Article',
        resourceType: EntityResourceType.article,
        createdAt: DateTime(2026, 4, 6, 8),
      ),
      EntityResource(
        id: 'updated',
        entityType: EntityAttachmentType.goal,
        entityId: 'goal-1',
        title: 'Video',
        resourceType: EntityResourceType.video,
        createdAt: DateTime(2026, 4, 6, 7),
        updatedAt: DateTime(2026, 4, 6, 10),
      ),
      EntityResource(
        id: 'pinned',
        entityType: EntityAttachmentType.goal,
        entityId: 'goal-1',
        title: 'Repo',
        resourceType: EntityResourceType.repo,
        createdAt: DateTime(2026, 4, 5, 8),
        isPinned: true,
      ),
    ];

    resources.sort(sortEntityResources);

    expect(
      resources.map((resource) => resource.id).toList(),
      ['pinned', 'updated', 'older'],
    );
  });
}
