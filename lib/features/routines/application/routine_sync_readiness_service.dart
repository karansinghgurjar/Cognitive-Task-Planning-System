import '../models/routine.dart';
import '../models/routine_group.dart';
import '../models/routine_occurrence.dart';
import '../models/routine_template.dart';

class RoutineSyncReadinessDescriptor {
  const RoutineSyncReadinessDescriptor({
    required this.entityName,
    required this.stableId,
    required this.lastModifiedAt,
    required this.conflictStrategy,
    required this.tombstoneStrategy,
  });

  final String entityName;
  final String stableId;
  final DateTime lastModifiedAt;
  final String conflictStrategy;
  final String tombstoneStrategy;
}

class RoutineSyncReadinessService {
  const RoutineSyncReadinessService();

  RoutineSyncReadinessDescriptor describeRoutine(Routine routine) {
    return RoutineSyncReadinessDescriptor(
      entityName: 'routine',
      stableId: routine.id,
      lastModifiedAt: routine.updatedAt ?? routine.createdAt,
      conflictStrategy:
          'Last-write-wins for display fields; keep manual overrides and archive state explicit.',
      tombstoneStrategy:
          'Prefer tombstone-ready archive semantics over naive hard delete for synced environments.',
    );
  }

  RoutineSyncReadinessDescriptor describeOccurrence(RoutineOccurrence occurrence) {
    return RoutineSyncReadinessDescriptor(
      entityName: 'routine_occurrence',
      stableId: occurrence.occurrenceKey,
      lastModifiedAt: occurrence.updatedAt ?? occurrence.createdAt,
      conflictStrategy:
          'Never downgrade terminal statuses; manual reschedules override auto-schedule.',
      tombstoneStrategy:
          'Occurrence identity is routineId+date; deletion should preserve a tombstone remotely.',
    );
  }

  RoutineSyncReadinessDescriptor describeTemplate(RoutineTemplate template) {
    return RoutineSyncReadinessDescriptor(
      entityName: 'routine_template',
      stableId: template.id,
      lastModifiedAt: template.updatedAt ?? template.createdAt,
      conflictStrategy: 'Last-write-wins for editable template fields.',
      tombstoneStrategy:
          'Soft-delete friendly for cross-device template removal and restore.',
    );
  }

  RoutineSyncReadinessDescriptor describeGroup(RoutineGroup group) {
    return RoutineSyncReadinessDescriptor(
      entityName: 'routine_group',
      stableId: group.id,
      lastModifiedAt: group.updatedAt ?? group.createdAt,
      conflictStrategy:
          'Last-write-wins for name/description, union-safe handling for routine membership.',
      tombstoneStrategy:
          'Group deletion should not delete routines and should remain tombstone-ready.',
    );
  }
}
