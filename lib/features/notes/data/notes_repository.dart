import 'package:isar/isar.dart';

import '../models/entity_note.dart';

class NotesRepository {
  NotesRepository(this._isar);

  final Isar _isar;

  Future<void> addNote(EntityNote note) async {
    final noteToStore = note.copyWith(updatedAt: note.updatedAt ?? note.createdAt);
    await _isar.writeTxn(() async {
      await _isar.entityNotes.put(noteToStore);
    });
  }

  Future<void> updateNote(EntityNote note) async {
    await _isar.writeTxn(() async {
      await _isar.entityNotes.put(note.copyWith(updatedAt: DateTime.now()));
    });
  }

  Future<void> deleteNote(String id) async {
    final note = await _isar.entityNotes.filter().idEqualTo(id).findFirst();
    if (note == null) {
      return;
    }
    await _isar.writeTxn(() async {
      await _isar.entityNotes.delete(note.isarId);
    });
  }

  Future<void> setPinned(String id, bool isPinned) async {
    final note = await _isar.entityNotes.filter().idEqualTo(id).findFirst();
    if (note == null) {
      return;
    }
    await updateNote(note.copyWith(isPinned: isPinned));
  }

  Future<void> deleteForEntity(
    EntityAttachmentType entityType,
    String entityId,
  ) async {
    final notes = await _isar.entityNotes
        .filter()
        .entityTypeEqualTo(entityType)
        .and()
        .entityIdEqualTo(entityId)
        .findAll();
    if (notes.isEmpty) {
      return;
    }
    await _isar.writeTxn(() async {
      await _isar.entityNotes.deleteAll(notes.map((item) => item.isarId).toList());
    });
  }

  Future<List<EntityNote>> getAllNotes() async {
    final notes = await _isar.entityNotes.where().findAll();
    notes.sort(sortEntityNotes);
    return notes;
  }

  Stream<List<EntityNote>> watchNotesForEntity(
    EntityAttachmentType entityType,
    String entityId,
  ) {
    return _isar.entityNotes.watchLazy(fireImmediately: true).asyncMap((_) async {
      final notes = await _isar.entityNotes
          .filter()
          .entityTypeEqualTo(entityType)
          .and()
          .entityIdEqualTo(entityId)
          .findAll();
      notes.sort(sortEntityNotes);
      return notes.where((note) => !note.isArchived).toList();
    });
  }
}

int sortEntityNotes(EntityNote left, EntityNote right) {
  if (left.isPinned != right.isPinned) {
    return left.isPinned ? -1 : 1;
  }
  final leftUpdated = left.updatedAt ?? left.createdAt;
  final rightUpdated = right.updatedAt ?? right.createdAt;
  final updatedCompare = rightUpdated.compareTo(leftUpdated);
  if (updatedCompare != 0) {
    return updatedCompare;
  }
  return right.createdAt.compareTo(left.createdAt);
}
