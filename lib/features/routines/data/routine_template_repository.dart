import 'package:isar/isar.dart';

import '../models/routine_template.dart';

class RoutineTemplateRepository {
  RoutineTemplateRepository(this._isar);

  final Isar _isar;

  Future<List<RoutineTemplate>> getAllTemplates() async {
    final templates = await _isar.routineTemplates.where().findAll();
    templates.sort((left, right) => left.name.compareTo(right.name));
    return templates;
  }

  Future<RoutineTemplate?> getById(String id) {
    return _isar.routineTemplates.filter().idEqualTo(id).findFirst();
  }

  Future<void> saveTemplate(RoutineTemplate template) async {
    await _isar.writeTxn(() async {
      await _isar.routineTemplates.put(template);
    });
  }

  Future<void> deleteTemplate(String id) async {
    final template = await getById(id);
    if (template == null) {
      return;
    }
    await _isar.writeTxn(() async {
      await _isar.routineTemplates.delete(template.isarId);
    });
  }

  Stream<List<RoutineTemplate>> watchTemplates() {
    return _isar.routineTemplates.watchLazy(fireImmediately: true).asyncMap((_) {
      return getAllTemplates();
    });
  }
}
