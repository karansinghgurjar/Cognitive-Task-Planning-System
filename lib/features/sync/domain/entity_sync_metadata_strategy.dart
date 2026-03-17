class EntitySyncMetadataStrategy {
  const EntitySyncMetadataStrategy({
    required this.entityName,
    required this.stableIdField,
    required this.futureFields,
    required this.mergeStrategyNote,
  });

  final String entityName;
  final String stableIdField;
  final List<String> futureFields;
  final String mergeStrategyNote;
}
