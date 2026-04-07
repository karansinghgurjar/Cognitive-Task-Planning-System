import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:study_flow/features/notes/data/notes_repository.dart';
import 'package:study_flow/features/notes/data/resources_repository.dart';
import 'package:study_flow/features/notes/domain/entity_attachments_cleanup_service.dart';
import 'package:study_flow/features/notes/models/entity_note.dart';

void main() {
  test('deleteForEntity clears both notes and resources for the entity', () async {
    final notesRepository = _MockNotesRepository();
    final resourcesRepository = _MockResourcesRepository();

    when(
      () => notesRepository.deleteForEntity(EntityAttachmentType.task, 'task-1'),
    ).thenAnswer((_) async {});
    when(
      () => resourcesRepository.deleteForEntity(
        EntityAttachmentType.task,
        'task-1',
      ),
    ).thenAnswer((_) async {});

    final service = EntityAttachmentsCleanupService(
      notesRepository: notesRepository,
      resourcesRepository: resourcesRepository,
    );

    await service.deleteForEntity(EntityAttachmentType.task, 'task-1');

    verifyInOrder([
      () => notesRepository.deleteForEntity(EntityAttachmentType.task, 'task-1'),
      () => resourcesRepository.deleteForEntity(
        EntityAttachmentType.task,
        'task-1',
      ),
    ]);
  });
}

class _MockNotesRepository extends Mock implements NotesRepository {}

class _MockResourcesRepository extends Mock implements ResourcesRepository {}
