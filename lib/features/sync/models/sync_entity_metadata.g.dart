// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_entity_metadata.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSyncEntityMetadataCollection on Isar {
  IsarCollection<SyncEntityMetadata> get syncEntityMetadatas =>
      this.collection();
}

const SyncEntityMetadataSchema = CollectionSchema(
  name: r'SyncEntityMetadata',
  id: -2667925680672254894,
  properties: {
    r'entityId': PropertySchema(
      id: 0,
      name: r'entityId',
      type: IsarType.string,
    ),
    r'entityType': PropertySchema(
      id: 1,
      name: r'entityType',
      type: IsarType.string,
      enumMap: _SyncEntityMetadataentityTypeEnumValueMap,
    ),
    r'isDeleted': PropertySchema(
      id: 2,
      name: r'isDeleted',
      type: IsarType.bool,
    ),
    r'lastConflictSummary': PropertySchema(
      id: 3,
      name: r'lastConflictSummary',
      type: IsarType.string,
    ),
    r'lastError': PropertySchema(
      id: 4,
      name: r'lastError',
      type: IsarType.string,
    ),
    r'lastModifiedAt': PropertySchema(
      id: 5,
      name: r'lastModifiedAt',
      type: IsarType.dateTime,
    ),
    r'lastModifiedByDeviceId': PropertySchema(
      id: 6,
      name: r'lastModifiedByDeviceId',
      type: IsarType.string,
    ),
    r'lastSyncedAt': PropertySchema(
      id: 7,
      name: r'lastSyncedAt',
      type: IsarType.dateTime,
    ),
    r'syncKey': PropertySchema(
      id: 8,
      name: r'syncKey',
      type: IsarType.string,
    ),
    r'syncState': PropertySchema(
      id: 9,
      name: r'syncState',
      type: IsarType.string,
      enumMap: _SyncEntityMetadatasyncStateEnumValueMap,
    )
  },
  estimateSize: _syncEntityMetadataEstimateSize,
  serialize: _syncEntityMetadataSerialize,
  deserialize: _syncEntityMetadataDeserialize,
  deserializeProp: _syncEntityMetadataDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'syncKey': IndexSchema(
      id: -4971009725215132130,
      name: r'syncKey',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'syncKey',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'entityId': IndexSchema(
      id: 745355021660786263,
      name: r'entityId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'entityId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _syncEntityMetadataGetId,
  getLinks: _syncEntityMetadataGetLinks,
  attach: _syncEntityMetadataAttach,
  version: '3.1.0+1',
);

int _syncEntityMetadataEstimateSize(
  SyncEntityMetadata object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.entityId.length * 3;
  bytesCount += 3 + object.entityType.name.length * 3;
  {
    final value = object.lastConflictSummary;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.lastError;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.lastModifiedByDeviceId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.syncKey.length * 3;
  bytesCount += 3 + object.syncState.name.length * 3;
  return bytesCount;
}

void _syncEntityMetadataSerialize(
  SyncEntityMetadata object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.entityId);
  writer.writeString(offsets[1], object.entityType.name);
  writer.writeBool(offsets[2], object.isDeleted);
  writer.writeString(offsets[3], object.lastConflictSummary);
  writer.writeString(offsets[4], object.lastError);
  writer.writeDateTime(offsets[5], object.lastModifiedAt);
  writer.writeString(offsets[6], object.lastModifiedByDeviceId);
  writer.writeDateTime(offsets[7], object.lastSyncedAt);
  writer.writeString(offsets[8], object.syncKey);
  writer.writeString(offsets[9], object.syncState.name);
}

SyncEntityMetadata _syncEntityMetadataDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SyncEntityMetadata(
    entityId: reader.readString(offsets[0]),
    entityType: _SyncEntityMetadataentityTypeValueEnumMap[
            reader.readStringOrNull(offsets[1])] ??
        SyncEntityType.task,
    isDeleted: reader.readBoolOrNull(offsets[2]) ?? false,
    lastConflictSummary: reader.readStringOrNull(offsets[3]),
    lastError: reader.readStringOrNull(offsets[4]),
    lastModifiedAt: reader.readDateTime(offsets[5]),
    lastModifiedByDeviceId: reader.readStringOrNull(offsets[6]),
    lastSyncedAt: reader.readDateTimeOrNull(offsets[7]),
    syncKey: reader.readString(offsets[8]),
    syncState: _SyncEntityMetadatasyncStateValueEnumMap[
            reader.readStringOrNull(offsets[9])] ??
        SyncState.localOnly,
  );
  object.isarId = id;
  return object;
}

P _syncEntityMetadataDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (_SyncEntityMetadataentityTypeValueEnumMap[
              reader.readStringOrNull(offset)] ??
          SyncEntityType.task) as P;
    case 2:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (_SyncEntityMetadatasyncStateValueEnumMap[
              reader.readStringOrNull(offset)] ??
          SyncState.localOnly) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _SyncEntityMetadataentityTypeEnumValueMap = {
  r'task': r'task',
  r'timetableSlot': r'timetableSlot',
  r'plannedSession': r'plannedSession',
  r'learningGoal': r'learningGoal',
  r'goalMilestone': r'goalMilestone',
  r'taskDependency': r'taskDependency',
  r'notificationPreferences': r'notificationPreferences',
};
const _SyncEntityMetadataentityTypeValueEnumMap = {
  r'task': SyncEntityType.task,
  r'timetableSlot': SyncEntityType.timetableSlot,
  r'plannedSession': SyncEntityType.plannedSession,
  r'learningGoal': SyncEntityType.learningGoal,
  r'goalMilestone': SyncEntityType.goalMilestone,
  r'taskDependency': SyncEntityType.taskDependency,
  r'notificationPreferences': SyncEntityType.notificationPreferences,
};
const _SyncEntityMetadatasyncStateEnumValueMap = {
  r'localOnly': r'localOnly',
  r'pendingPush': r'pendingPush',
  r'synced': r'synced',
  r'conflict': r'conflict',
  r'failed': r'failed',
  r'deleted': r'deleted',
};
const _SyncEntityMetadatasyncStateValueEnumMap = {
  r'localOnly': SyncState.localOnly,
  r'pendingPush': SyncState.pendingPush,
  r'synced': SyncState.synced,
  r'conflict': SyncState.conflict,
  r'failed': SyncState.failed,
  r'deleted': SyncState.deleted,
};

Id _syncEntityMetadataGetId(SyncEntityMetadata object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _syncEntityMetadataGetLinks(
    SyncEntityMetadata object) {
  return [];
}

void _syncEntityMetadataAttach(
    IsarCollection<dynamic> col, Id id, SyncEntityMetadata object) {
  object.isarId = id;
}

extension SyncEntityMetadataByIndex on IsarCollection<SyncEntityMetadata> {
  Future<SyncEntityMetadata?> getBySyncKey(String syncKey) {
    return getByIndex(r'syncKey', [syncKey]);
  }

  SyncEntityMetadata? getBySyncKeySync(String syncKey) {
    return getByIndexSync(r'syncKey', [syncKey]);
  }

  Future<bool> deleteBySyncKey(String syncKey) {
    return deleteByIndex(r'syncKey', [syncKey]);
  }

  bool deleteBySyncKeySync(String syncKey) {
    return deleteByIndexSync(r'syncKey', [syncKey]);
  }

  Future<List<SyncEntityMetadata?>> getAllBySyncKey(
      List<String> syncKeyValues) {
    final values = syncKeyValues.map((e) => [e]).toList();
    return getAllByIndex(r'syncKey', values);
  }

  List<SyncEntityMetadata?> getAllBySyncKeySync(List<String> syncKeyValues) {
    final values = syncKeyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'syncKey', values);
  }

  Future<int> deleteAllBySyncKey(List<String> syncKeyValues) {
    final values = syncKeyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'syncKey', values);
  }

  int deleteAllBySyncKeySync(List<String> syncKeyValues) {
    final values = syncKeyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'syncKey', values);
  }

  Future<Id> putBySyncKey(SyncEntityMetadata object) {
    return putByIndex(r'syncKey', object);
  }

  Id putBySyncKeySync(SyncEntityMetadata object, {bool saveLinks = true}) {
    return putByIndexSync(r'syncKey', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllBySyncKey(List<SyncEntityMetadata> objects) {
    return putAllByIndex(r'syncKey', objects);
  }

  List<Id> putAllBySyncKeySync(List<SyncEntityMetadata> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'syncKey', objects, saveLinks: saveLinks);
  }
}

extension SyncEntityMetadataQueryWhereSort
    on QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QWhere> {
  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterWhere>
      anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SyncEntityMetadataQueryWhere
    on QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QWhereClause> {
  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterWhereClause>
      isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterWhereClause>
      isarIdNotEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterWhereClause>
      isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIsarId,
        includeLower: includeLower,
        upper: upperIsarId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterWhereClause>
      syncKeyEqualTo(String syncKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'syncKey',
        value: [syncKey],
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterWhereClause>
      syncKeyNotEqualTo(String syncKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'syncKey',
              lower: [],
              upper: [syncKey],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'syncKey',
              lower: [syncKey],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'syncKey',
              lower: [syncKey],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'syncKey',
              lower: [],
              upper: [syncKey],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterWhereClause>
      entityIdEqualTo(String entityId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'entityId',
        value: [entityId],
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterWhereClause>
      entityIdNotEqualTo(String entityId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entityId',
              lower: [],
              upper: [entityId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entityId',
              lower: [entityId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entityId',
              lower: [entityId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entityId',
              lower: [],
              upper: [entityId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension SyncEntityMetadataQueryFilter
    on QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QFilterCondition> {
  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      entityIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      entityIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'entityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      entityIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'entityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      entityIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'entityId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      entityIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'entityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      entityIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'entityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      entityIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'entityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      entityIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'entityId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      entityIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entityId',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      entityIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'entityId',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      entityTypeEqualTo(
    SyncEntityType value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entityType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      entityTypeGreaterThan(
    SyncEntityType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'entityType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      entityTypeLessThan(
    SyncEntityType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'entityType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      entityTypeBetween(
    SyncEntityType lower,
    SyncEntityType upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'entityType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      entityTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'entityType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      entityTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'entityType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      entityTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'entityType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      entityTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'entityType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      entityTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entityType',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      entityTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'entityType',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      isDeletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isDeleted',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      lastConflictSummaryIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastConflictSummary',
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      lastConflictSummaryIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastConflictSummary',
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      lastConflictSummaryEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastConflictSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      lastConflictSummaryGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastConflictSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      lastConflictSummaryLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastConflictSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      lastConflictSummaryBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastConflictSummary',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      lastConflictSummaryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lastConflictSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      lastConflictSummaryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lastConflictSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      lastConflictSummaryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastConflictSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      lastConflictSummaryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastConflictSummary',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      lastConflictSummaryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastConflictSummary',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      lastConflictSummaryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastConflictSummary',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      lastErrorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastError',
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      lastErrorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastError',
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      lastErrorEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      lastErrorGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      lastErrorLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      lastErrorBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastError',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      lastErrorStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lastError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      lastErrorEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lastError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      lastErrorContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      lastErrorMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastError',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      lastErrorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastError',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      lastErrorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastError',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      lastModifiedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastModifiedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      lastModifiedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastModifiedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      lastModifiedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastModifiedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      lastModifiedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastModifiedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      lastModifiedByDeviceIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastModifiedByDeviceId',
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      lastModifiedByDeviceIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastModifiedByDeviceId',
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      lastModifiedByDeviceIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastModifiedByDeviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      lastModifiedByDeviceIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastModifiedByDeviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      lastModifiedByDeviceIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastModifiedByDeviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      lastModifiedByDeviceIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastModifiedByDeviceId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      lastModifiedByDeviceIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lastModifiedByDeviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      lastModifiedByDeviceIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lastModifiedByDeviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      lastModifiedByDeviceIdContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastModifiedByDeviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      lastModifiedByDeviceIdMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastModifiedByDeviceId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      lastModifiedByDeviceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastModifiedByDeviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      lastModifiedByDeviceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastModifiedByDeviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      lastSyncedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastSyncedAt',
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      lastSyncedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastSyncedAt',
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      lastSyncedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSyncedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      lastSyncedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastSyncedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      lastSyncedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastSyncedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      lastSyncedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastSyncedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      syncKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      syncKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'syncKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      syncKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'syncKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      syncKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'syncKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      syncKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'syncKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      syncKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'syncKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      syncKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'syncKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      syncKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'syncKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      syncKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncKey',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      syncKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'syncKey',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      syncStateEqualTo(
    SyncState value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncState',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      syncStateGreaterThan(
    SyncState value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'syncState',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      syncStateLessThan(
    SyncState value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'syncState',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      syncStateBetween(
    SyncState lower,
    SyncState upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'syncState',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      syncStateStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'syncState',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      syncStateEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'syncState',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      syncStateContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'syncState',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      syncStateMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'syncState',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      syncStateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncState',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterFilterCondition>
      syncStateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'syncState',
        value: '',
      ));
    });
  }
}

extension SyncEntityMetadataQueryObject
    on QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QFilterCondition> {}

extension SyncEntityMetadataQueryLinks
    on QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QFilterCondition> {}

extension SyncEntityMetadataQuerySortBy
    on QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QSortBy> {
  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterSortBy>
      sortByEntityId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityId', Sort.asc);
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterSortBy>
      sortByEntityIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityId', Sort.desc);
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterSortBy>
      sortByEntityType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityType', Sort.asc);
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterSortBy>
      sortByEntityTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityType', Sort.desc);
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterSortBy>
      sortByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterSortBy>
      sortByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterSortBy>
      sortByLastConflictSummary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastConflictSummary', Sort.asc);
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterSortBy>
      sortByLastConflictSummaryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastConflictSummary', Sort.desc);
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterSortBy>
      sortByLastError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.asc);
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterSortBy>
      sortByLastErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.desc);
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterSortBy>
      sortByLastModifiedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModifiedAt', Sort.asc);
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterSortBy>
      sortByLastModifiedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModifiedAt', Sort.desc);
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterSortBy>
      sortByLastModifiedByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModifiedByDeviceId', Sort.asc);
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterSortBy>
      sortByLastModifiedByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModifiedByDeviceId', Sort.desc);
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterSortBy>
      sortByLastSyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.asc);
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterSortBy>
      sortByLastSyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.desc);
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterSortBy>
      sortBySyncKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncKey', Sort.asc);
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterSortBy>
      sortBySyncKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncKey', Sort.desc);
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterSortBy>
      sortBySyncState() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncState', Sort.asc);
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterSortBy>
      sortBySyncStateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncState', Sort.desc);
    });
  }
}

extension SyncEntityMetadataQuerySortThenBy
    on QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QSortThenBy> {
  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterSortBy>
      thenByEntityId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityId', Sort.asc);
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterSortBy>
      thenByEntityIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityId', Sort.desc);
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterSortBy>
      thenByEntityType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityType', Sort.asc);
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterSortBy>
      thenByEntityTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityType', Sort.desc);
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterSortBy>
      thenByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterSortBy>
      thenByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterSortBy>
      thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterSortBy>
      thenByLastConflictSummary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastConflictSummary', Sort.asc);
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterSortBy>
      thenByLastConflictSummaryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastConflictSummary', Sort.desc);
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterSortBy>
      thenByLastError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.asc);
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterSortBy>
      thenByLastErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.desc);
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterSortBy>
      thenByLastModifiedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModifiedAt', Sort.asc);
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterSortBy>
      thenByLastModifiedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModifiedAt', Sort.desc);
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterSortBy>
      thenByLastModifiedByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModifiedByDeviceId', Sort.asc);
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterSortBy>
      thenByLastModifiedByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModifiedByDeviceId', Sort.desc);
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterSortBy>
      thenByLastSyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.asc);
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterSortBy>
      thenByLastSyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.desc);
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterSortBy>
      thenBySyncKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncKey', Sort.asc);
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterSortBy>
      thenBySyncKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncKey', Sort.desc);
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterSortBy>
      thenBySyncState() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncState', Sort.asc);
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QAfterSortBy>
      thenBySyncStateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncState', Sort.desc);
    });
  }
}

extension SyncEntityMetadataQueryWhereDistinct
    on QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QDistinct> {
  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QDistinct>
      distinctByEntityId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'entityId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QDistinct>
      distinctByEntityType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'entityType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QDistinct>
      distinctByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDeleted');
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QDistinct>
      distinctByLastConflictSummary({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastConflictSummary',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QDistinct>
      distinctByLastError({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastError', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QDistinct>
      distinctByLastModifiedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastModifiedAt');
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QDistinct>
      distinctByLastModifiedByDeviceId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastModifiedByDeviceId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QDistinct>
      distinctByLastSyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSyncedAt');
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QDistinct>
      distinctBySyncKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QDistinct>
      distinctBySyncState({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncState', caseSensitive: caseSensitive);
    });
  }
}

extension SyncEntityMetadataQueryProperty
    on QueryBuilder<SyncEntityMetadata, SyncEntityMetadata, QQueryProperty> {
  QueryBuilder<SyncEntityMetadata, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<SyncEntityMetadata, String, QQueryOperations>
      entityIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entityId');
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncEntityType, QQueryOperations>
      entityTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entityType');
    });
  }

  QueryBuilder<SyncEntityMetadata, bool, QQueryOperations> isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDeleted');
    });
  }

  QueryBuilder<SyncEntityMetadata, String?, QQueryOperations>
      lastConflictSummaryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastConflictSummary');
    });
  }

  QueryBuilder<SyncEntityMetadata, String?, QQueryOperations>
      lastErrorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastError');
    });
  }

  QueryBuilder<SyncEntityMetadata, DateTime, QQueryOperations>
      lastModifiedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastModifiedAt');
    });
  }

  QueryBuilder<SyncEntityMetadata, String?, QQueryOperations>
      lastModifiedByDeviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastModifiedByDeviceId');
    });
  }

  QueryBuilder<SyncEntityMetadata, DateTime?, QQueryOperations>
      lastSyncedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSyncedAt');
    });
  }

  QueryBuilder<SyncEntityMetadata, String, QQueryOperations> syncKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncKey');
    });
  }

  QueryBuilder<SyncEntityMetadata, SyncState, QQueryOperations>
      syncStateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncState');
    });
  }
}
