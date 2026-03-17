import 'entity_sync_metadata_strategy.dart';

class SyncReadinessNotes {
  const SyncReadinessNotes._();

  static const strategies = [
    EntitySyncMetadataStrategy(
      entityName: 'Task',
      stableIdField: 'id',
      futureFields: ['updatedAt', 'lastModifiedAt', 'syncStatus'],
      mergeStrategyNote:
          'Task conflicts should prefer the newest explicit completion state, then newest content edits.',
    ),
    EntitySyncMetadataStrategy(
      entityName: 'PlannedSession',
      stableIdField: 'id',
      futureFields: ['updatedAt', 'syncStatus'],
      mergeStrategyNote:
          'Completed sessions should win over pending states unless they are explicitly cancelled later.',
    ),
    EntitySyncMetadataStrategy(
      entityName: 'LearningGoal',
      stableIdField: 'id',
      futureFields: ['updatedAt', 'syncStatus'],
      mergeStrategyNote:
          'Goal content changes can use last-write-wins while progress remains derived from tasks and sessions.',
    ),
    EntitySyncMetadataStrategy(
      entityName: 'TimetableSlot',
      stableIdField: 'id',
      futureFields: ['updatedAt', 'syncStatus'],
      mergeStrategyNote:
          'Timetable slots should merge by slot id and prefer the latest edited interval definition.',
    ),
  ];
}
