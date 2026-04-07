import '../data/notes_repository.dart';
import '../data/resources_repository.dart';
import '../models/entity_note.dart';

class EntityAttachmentsCleanupService {
  const EntityAttachmentsCleanupService({
    required this.notesRepository,
    required this.resourcesRepository,
  });

  final NotesRepository notesRepository;
  final ResourcesRepository resourcesRepository;

  Future<void> deleteForEntity(
    EntityAttachmentType entityType,
    String entityId,
  ) async {
    await notesRepository.deleteForEntity(entityType, entityId);
    await resourcesRepository.deleteForEntity(entityType, entityId);
  }
}
