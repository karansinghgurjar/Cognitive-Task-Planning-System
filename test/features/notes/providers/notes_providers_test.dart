import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:study_flow/features/notes/data/notes_repository.dart';
import 'package:study_flow/features/notes/data/resources_repository.dart';
import 'package:study_flow/features/notes/models/entity_note.dart';
import 'package:study_flow/features/notes/models/entity_resource.dart';
import 'package:study_flow/features/notes/providers/notes_providers.dart';

void main() {
  group('NotesActionController', () {
    test('forwards note CRUD and pin actions to the repository', () async {
      final repository = _MockNotesRepository();
      final note = EntityNote(
        id: 'note-1',
        entityType: EntityAttachmentType.task,
        entityId: 'task-1',
        title: 'Focus',
        content: 'Revise recursion patterns.',
        createdAt: DateTime(2026, 4, 7, 10),
      );

      when(() => repository.addNote(note)).thenAnswer((_) async {});
      when(() => repository.updateNote(note)).thenAnswer((_) async {});
      when(() => repository.deleteNote('note-1')).thenAnswer((_) async {});
      when(() => repository.setPinned('note-1', true)).thenAnswer((_) async {});

      final container = ProviderContainer(
        overrides: [
          notesRepositoryProvider.overrideWith((ref) async => repository),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(notesActionControllerProvider.notifier);
      await controller.addNote(note);
      await controller.updateNote(note);
      await controller.setPinned('note-1', true);
      await controller.deleteNote('note-1');

      verify(() => repository.addNote(note)).called(1);
      verify(() => repository.updateNote(note)).called(1);
      verify(() => repository.setPinned('note-1', true)).called(1);
      verify(() => repository.deleteNote('note-1')).called(1);
    });
  });

  group('ResourcesActionController', () {
    test('forwards resource CRUD and pin actions to the repository', () async {
      final repository = _MockResourcesRepository();
      final resource = EntityResource(
        id: 'resource-1',
        entityType: EntityAttachmentType.goal,
        entityId: 'goal-1',
        title: 'Repo',
        url: 'https://github.com/example/project',
        resourceType: EntityResourceType.repo,
        createdAt: DateTime(2026, 4, 7, 11),
      );

      when(() => repository.addResource(resource)).thenAnswer((_) async {});
      when(() => repository.updateResource(resource)).thenAnswer((_) async {});
      when(
        () => repository.deleteResource('resource-1'),
      ).thenAnswer((_) async {});
      when(
        () => repository.setPinned('resource-1', true),
      ).thenAnswer((_) async {});

      final container = ProviderContainer(
        overrides: [
          resourcesRepositoryProvider.overrideWith((ref) async => repository),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(
        resourcesActionControllerProvider.notifier,
      );
      await controller.addResource(resource);
      await controller.updateResource(resource);
      await controller.setPinned('resource-1', true);
      await controller.deleteResource('resource-1');

      verify(() => repository.addResource(resource)).called(1);
      verify(() => repository.updateResource(resource)).called(1);
      verify(() => repository.setPinned('resource-1', true)).called(1);
      verify(() => repository.deleteResource('resource-1')).called(1);
    });
  });
}

class _MockNotesRepository extends Mock implements NotesRepository {}

class _MockResourcesRepository extends Mock implements ResourcesRepository {}
