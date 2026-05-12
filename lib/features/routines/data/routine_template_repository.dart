import 'package:isar/isar.dart';

import '../../sync/data/sync_mutation_recorder.dart';
import '../../sync/domain/sync_models.dart';
import '../models/routine_template.dart';

class RoutineTemplateRepository {
  RoutineTemplateRepository(
    this._isar, {
    SyncMutationRecorder syncMutationRecorder =
        const NoopSyncMutationRecorder(),
  }) : _syncMutationRecorder = syncMutationRecorder;

  final Isar _isar;
  final SyncMutationRecorder _syncMutationRecorder;

  Future<List<RoutineTemplate>> getAllTemplates() async {
    final templates = await _isar.routineTemplates.where().findAll();
    templates.sort((left, right) => left.name.compareTo(right.name));
    return templates;
  }

  Future<RoutineTemplate?> getById(String id) {
    return _isar.routineTemplates.filter().idEqualTo(id).findFirst();
  }

  Future<void> saveTemplate(RoutineTemplate template) async {
    final templateToStore = template.copyWith(
      updatedAt: template.updatedAt ?? template.createdAt,
    );
    await _isar.writeTxn(() async {
      await _isar.routineTemplates.put(templateToStore);
    });
    await _syncMutationRecorder.recordUpsert(
      entityType: SyncEntityType.routineTemplate,
      entityId: templateToStore.id,
      entity: templateToStore,
      operationType: SyncOperationType.update,
    );
  }

  Future<void> deleteTemplate(String id) async {
    final template = await getById(id);
    if (template == null) {
      return;
    }
    await _isar.writeTxn(() async {
      await _isar.routineTemplates.delete(template.isarId);
    });
    await _syncMutationRecorder.recordDelete(
      entityType: SyncEntityType.routineTemplate,
      entityId: id,
    );
  }

  Stream<List<RoutineTemplate>> watchTemplates() {
    return _isar.routineTemplates.watchLazy(fireImmediately: true).asyncMap((_) {
      return getAllTemplates();
    });
  }
}