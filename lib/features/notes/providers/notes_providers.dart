import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/isar_providers.dart';
import '../data/notes_repository.dart';
import '../data/resources_repository.dart';
import '../domain/entity_attachments_cleanup_service.dart';
import '../domain/resource_link_service.dart';
import '../models/entity_note.dart';
import '../models/entity_resource.dart';

class EntityAttachmentTarget {
  const EntityAttachmentTarget({
    required this.entityType,
    required this.entityId,
  });

  final EntityAttachmentType entityType;
  final String entityId;

  @override
  bool operator ==(Object other) {
    return other is EntityAttachmentTarget &&
        other.entityType == entityType &&
        other.entityId == entityId;
  }

  @override
  int get hashCode => Object.hash(entityType, entityId);
}

final notesRepositoryProvider = FutureProvider<NotesRepository>((ref) async {
  final isar = await ref.watch(isarInstanceProvider.future);
  return NotesRepository(isar);
});

final resourcesRepositoryProvider = FutureProvider<ResourcesRepository>((
  ref,
) async {
  final isar = await ref.watch(isarInstanceProvider.future);
  return ResourcesRepository(isar);
});

final entityAttachmentsCleanupServiceProvider =
    FutureProvider<EntityAttachmentsCleanupService>((ref) async {
      final notesRepository = await ref.watch(notesRepositoryProvider.future);
      final resourcesRepository = await ref.watch(
        resourcesRepositoryProvider.future,
      );
      return EntityAttachmentsCleanupService(
        notesRepository: notesRepository,
        resourcesRepository: resourcesRepository,
      );
    });

final resourceLinkServiceProvider = Provider<ResourceLinkService>((ref) {
  return const ResourceLinkService();
});

final watchNotesForEntityProvider =
    StreamProvider.family<List<EntityNote>, EntityAttachmentTarget>((
      ref,
      target,
    ) async* {
      final repository = await ref.watch(notesRepositoryProvider.future);
      yield* repository.watchNotesForEntity(target.entityType, target.entityId);
    });

final watchResourcesForEntityProvider =
    StreamProvider.family<List<EntityResource>, EntityAttachmentTarget>((
      ref,
      target,
    ) async* {
      final repository = await ref.watch(resourcesRepositoryProvider.future);
      yield* repository.watchResourcesForEntity(
        target.entityType,
        target.entityId,
      );
    });

final watchTaskNotesProvider =
    StreamProvider.family<List<EntityNote>, String>((ref, taskId) async* {
      final repository = await ref.watch(notesRepositoryProvider.future);
      yield* repository.watchNotesForEntity(EntityAttachmentType.task, taskId);
    });

final watchGoalNotesProvider =
    StreamProvider.family<List<EntityNote>, String>((ref, goalId) async* {
      final repository = await ref.watch(notesRepositoryProvider.future);
      yield* repository.watchNotesForEntity(EntityAttachmentType.goal, goalId);
    });

final watchTaskResourcesProvider =
    StreamProvider.family<List<EntityResource>, String>((ref, taskId) async* {
      final repository = await ref.watch(resourcesRepositoryProvider.future);
      yield* repository.watchResourcesForEntity(
        EntityAttachmentType.task,
        taskId,
      );
    });

final watchGoalResourcesProvider =
    StreamProvider.family<List<EntityResource>, String>((ref, goalId) async* {
      final repository = await ref.watch(resourcesRepositoryProvider.future);
      yield* repository.watchResourcesForEntity(
        EntityAttachmentType.goal,
        goalId,
      );
    });

final notesActionControllerProvider =
    AsyncNotifierProvider<NotesActionController, void>(
      NotesActionController.new,
    );

class NotesActionController extends AsyncNotifier<void> {
  @override
  void build() {}

  Future<void> addNote(EntityNote note) => _run((repository) {
    return repository.addNote(note);
  });

  Future<void> updateNote(EntityNote note) => _run((repository) {
    return repository.updateNote(note);
  });

  Future<void> deleteNote(String id) => _run((repository) {
    return repository.deleteNote(id);
  });

  Future<void> setPinned(String id, bool isPinned) => _run((repository) {
    return repository.setPinned(id, isPinned);
  });

  Future<void> _run(Future<void> Function(NotesRepository repository) action) async {
    _ensureIdle();
    state = const AsyncLoading();
    try {
      final repository = await ref.read(notesRepositoryProvider.future);
      await action(repository);
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  void _ensureIdle() {
    if (state.isLoading) {
      throw StateError('Another note action is already in progress.');
    }
  }
}

final resourcesActionControllerProvider =
    AsyncNotifierProvider<ResourcesActionController, void>(
      ResourcesActionController.new,
    );

class ResourcesActionController extends AsyncNotifier<void> {
  @override
  void build() {}

  Future<void> addResource(EntityResource resource) => _run((repository) {
    return repository.addResource(resource);
  });

  Future<void> updateResource(EntityResource resource) => _run((repository) {
    return repository.updateResource(resource);
  });

  Future<void> deleteResource(String id) => _run((repository) {
    return repository.deleteResource(id);
  });

  Future<void> setPinned(String id, bool isPinned) => _run((repository) {
    return repository.setPinned(id, isPinned);
  });

  Future<void> _run(
    Future<void> Function(ResourcesRepository repository) action,
  ) async {
    _ensureIdle();
    state = const AsyncLoading();
    try {
      final repository = await ref.read(resourcesRepositoryProvider.future);
      await action(repository);
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  void _ensureIdle() {
    if (state.isLoading) {
      throw StateError('Another resource action is already in progress.');
    }
  }
}
