// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'planned_session.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPlannedSessionCollection on Isar {
  IsarCollection<PlannedSession> get plannedSessions => this.collection();
}

const PlannedSessionSchema = CollectionSchema(
  name: r'PlannedSession',
  id: -662277018486409028,
  properties: {
    r'actualMinutesFocused': PropertySchema(
      id: 0,
      name: r'actualMinutesFocused',
      type: IsarType.long,
    ),
    r'blocksScheduling': PropertySchema(
      id: 1,
      name: r'blocksScheduling',
      type: IsarType.bool,
    ),
    r'completed': PropertySchema(
      id: 2,
      name: r'completed',
      type: IsarType.bool,
    ),
    r'end': PropertySchema(
      id: 3,
      name: r'end',
      type: IsarType.dateTime,
    ),
    r'id': PropertySchema(
      id: 4,
      name: r'id',
      type: IsarType.string,
    ),
    r'isCancelled': PropertySchema(
      id: 5,
      name: r'isCancelled',
      type: IsarType.bool,
    ),
    r'isCompleted': PropertySchema(
      id: 6,
      name: r'isCompleted',
      type: IsarType.bool,
    ),
    r'isInProgress': PropertySchema(
      id: 7,
      name: r'isInProgress',
      type: IsarType.bool,
    ),
    r'isMissed': PropertySchema(
      id: 8,
      name: r'isMissed',
      type: IsarType.bool,
    ),
    r'isPending': PropertySchema(
      id: 9,
      name: r'isPending',
      type: IsarType.bool,
    ),
    r'plannedDurationMinutes': PropertySchema(
      id: 10,
      name: r'plannedDurationMinutes',
      type: IsarType.long,
    ),
    r'start': PropertySchema(
      id: 11,
      name: r'start',
      type: IsarType.dateTime,
    ),
    r'status': PropertySchema(
      id: 12,
      name: r'status',
      type: IsarType.string,
      enumMap: _PlannedSessionstatusEnumValueMap,
    ),
    r'taskId': PropertySchema(
      id: 13,
      name: r'taskId',
      type: IsarType.string,
    )
  },
  estimateSize: _plannedSessionEstimateSize,
  serialize: _plannedSessionSerialize,
  deserialize: _plannedSessionDeserialize,
  deserializeProp: _plannedSessionDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'id': IndexSchema(
      id: -3268401673993471357,
      name: r'id',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'id',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _plannedSessionGetId,
  getLinks: _plannedSessionGetLinks,
  attach: _plannedSessionAttach,
  version: '3.1.0+1',
);

int _plannedSessionEstimateSize(
  PlannedSession object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.id.length * 3;
  bytesCount += 3 + object.status.name.length * 3;
  bytesCount += 3 + object.taskId.length * 3;
  return bytesCount;
}

void _plannedSessionSerialize(
  PlannedSession object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.actualMinutesFocused);
  writer.writeBool(offsets[1], object.blocksScheduling);
  writer.writeBool(offsets[2], object.completed);
  writer.writeDateTime(offsets[3], object.end);
  writer.writeString(offsets[4], object.id);
  writer.writeBool(offsets[5], object.isCancelled);
  writer.writeBool(offsets[6], object.isCompleted);
  writer.writeBool(offsets[7], object.isInProgress);
  writer.writeBool(offsets[8], object.isMissed);
  writer.writeBool(offsets[9], object.isPending);
  writer.writeLong(offsets[10], object.plannedDurationMinutes);
  writer.writeDateTime(offsets[11], object.start);
  writer.writeString(offsets[12], object.status.name);
  writer.writeString(offsets[13], object.taskId);
}

PlannedSession _plannedSessionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PlannedSession(
    actualMinutesFocused: reader.readLongOrNull(offsets[0]) ?? 0,
    completed: reader.readBoolOrNull(offsets[2]) ?? false,
    end: reader.readDateTime(offsets[3]),
    id: reader.readString(offsets[4]),
    start: reader.readDateTime(offsets[11]),
    status: _PlannedSessionstatusValueEnumMap[
            reader.readStringOrNull(offsets[12])] ??
        PlannedSessionStatus.pending,
    taskId: reader.readString(offsets[13]),
  );
  object.isarId = id;
  return object;
}

P _plannedSessionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readBool(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    case 11:
      return (reader.readDateTime(offset)) as P;
    case 12:
      return (_PlannedSessionstatusValueEnumMap[
              reader.readStringOrNull(offset)] ??
          PlannedSessionStatus.pending) as P;
    case 13:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _PlannedSessionstatusEnumValueMap = {
  r'pending': r'pending',
  r'inProgress': r'inProgress',
  r'completed': r'completed',
  r'missed': r'missed',
  r'cancelled': r'cancelled',
};
const _PlannedSessionstatusValueEnumMap = {
  r'pending': PlannedSessionStatus.pending,
  r'inProgress': PlannedSessionStatus.inProgress,
  r'completed': PlannedSessionStatus.completed,
  r'missed': PlannedSessionStatus.missed,
  r'cancelled': PlannedSessionStatus.cancelled,
};

Id _plannedSessionGetId(PlannedSession object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _plannedSessionGetLinks(PlannedSession object) {
  return [];
}

void _plannedSessionAttach(
    IsarCollection<dynamic> col, Id id, PlannedSession object) {
  object.isarId = id;
}

extension PlannedSessionByIndex on IsarCollection<PlannedSession> {
  Future<PlannedSession?> getById(String id) {
    return getByIndex(r'id', [id]);
  }

  PlannedSession? getByIdSync(String id) {
    return getByIndexSync(r'id', [id]);
  }

  Future<bool> deleteById(String id) {
    return deleteByIndex(r'id', [id]);
  }

  bool deleteByIdSync(String id) {
    return deleteByIndexSync(r'id', [id]);
  }

  Future<List<PlannedSession?>> getAllById(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndex(r'id', values);
  }

  List<PlannedSession?> getAllByIdSync(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'id', values);
  }

  Future<int> deleteAllById(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'id', values);
  }

  int deleteAllByIdSync(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'id', values);
  }

  Future<Id> putById(PlannedSession object) {
    return putByIndex(r'id', object);
  }

  Id putByIdSync(PlannedSession object, {bool saveLinks = true}) {
    return putByIndexSync(r'id', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllById(List<PlannedSession> objects) {
    return putAllByIndex(r'id', objects);
  }

  List<Id> putAllByIdSync(List<PlannedSession> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'id', objects, saveLinks: saveLinks);
  }
}

extension PlannedSessionQueryWhereSort
    on QueryBuilder<PlannedSession, PlannedSession, QWhere> {
  QueryBuilder<PlannedSession, PlannedSession, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PlannedSessionQueryWhere
    on QueryBuilder<PlannedSession, PlannedSession, QWhereClause> {
  QueryBuilder<PlannedSession, PlannedSession, QAfterWhereClause> isarIdEqualTo(
      Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterWhereClause>
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

  QueryBuilder<PlannedSession, PlannedSession, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterWhereClause> isarIdBetween(
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

  QueryBuilder<PlannedSession, PlannedSession, QAfterWhereClause> idEqualTo(
      String id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'id',
        value: [id],
      ));
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterWhereClause> idNotEqualTo(
      String id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [],
              upper: [id],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [id],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [id],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [],
              upper: [id],
              includeUpper: false,
            ));
      }
    });
  }
}

extension PlannedSessionQueryFilter
    on QueryBuilder<PlannedSession, PlannedSession, QFilterCondition> {
  QueryBuilder<PlannedSession, PlannedSession, QAfterFilterCondition>
      actualMinutesFocusedEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actualMinutesFocused',
        value: value,
      ));
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterFilterCondition>
      actualMinutesFocusedGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'actualMinutesFocused',
        value: value,
      ));
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterFilterCondition>
      actualMinutesFocusedLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'actualMinutesFocused',
        value: value,
      ));
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterFilterCondition>
      actualMinutesFocusedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'actualMinutesFocused',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterFilterCondition>
      blocksSchedulingEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'blocksScheduling',
        value: value,
      ));
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterFilterCondition>
      completedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completed',
        value: value,
      ));
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterFilterCondition>
      endEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'end',
        value: value,
      ));
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterFilterCondition>
      endGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'end',
        value: value,
      ));
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterFilterCondition>
      endLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'end',
        value: value,
      ));
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterFilterCondition>
      endBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'end',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterFilterCondition> idEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterFilterCondition>
      idGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterFilterCondition>
      idLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterFilterCondition> idBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterFilterCondition>
      idStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterFilterCondition>
      idEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterFilterCondition>
      idContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterFilterCondition> idMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'id',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterFilterCondition>
      idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterFilterCondition>
      idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterFilterCondition>
      isCancelledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isCancelled',
        value: value,
      ));
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterFilterCondition>
      isCompletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isCompleted',
        value: value,
      ));
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterFilterCondition>
      isInProgressEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isInProgress',
        value: value,
      ));
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterFilterCondition>
      isMissedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isMissed',
        value: value,
      ));
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterFilterCondition>
      isPendingEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isPending',
        value: value,
      ));
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterFilterCondition>
      isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterFilterCondition>
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

  QueryBuilder<PlannedSession, PlannedSession, QAfterFilterCondition>
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

  QueryBuilder<PlannedSession, PlannedSession, QAfterFilterCondition>
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

  QueryBuilder<PlannedSession, PlannedSession, QAfterFilterCondition>
      plannedDurationMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'plannedDurationMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterFilterCondition>
      plannedDurationMinutesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'plannedDurationMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterFilterCondition>
      plannedDurationMinutesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'plannedDurationMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterFilterCondition>
      plannedDurationMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'plannedDurationMinutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterFilterCondition>
      startEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'start',
        value: value,
      ));
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterFilterCondition>
      startGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'start',
        value: value,
      ));
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterFilterCondition>
      startLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'start',
        value: value,
      ));
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterFilterCondition>
      startBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'start',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterFilterCondition>
      statusEqualTo(
    PlannedSessionStatus value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterFilterCondition>
      statusGreaterThan(
    PlannedSessionStatus value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterFilterCondition>
      statusLessThan(
    PlannedSessionStatus value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterFilterCondition>
      statusBetween(
    PlannedSessionStatus lower,
    PlannedSessionStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterFilterCondition>
      statusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterFilterCondition>
      statusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterFilterCondition>
      statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterFilterCondition>
      statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterFilterCondition>
      statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterFilterCondition>
      statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterFilterCondition>
      taskIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'taskId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterFilterCondition>
      taskIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'taskId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterFilterCondition>
      taskIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'taskId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterFilterCondition>
      taskIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'taskId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterFilterCondition>
      taskIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'taskId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterFilterCondition>
      taskIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'taskId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterFilterCondition>
      taskIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'taskId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterFilterCondition>
      taskIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'taskId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterFilterCondition>
      taskIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'taskId',
        value: '',
      ));
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterFilterCondition>
      taskIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'taskId',
        value: '',
      ));
    });
  }
}

extension PlannedSessionQueryObject
    on QueryBuilder<PlannedSession, PlannedSession, QFilterCondition> {}

extension PlannedSessionQueryLinks
    on QueryBuilder<PlannedSession, PlannedSession, QFilterCondition> {}

extension PlannedSessionQuerySortBy
    on QueryBuilder<PlannedSession, PlannedSession, QSortBy> {
  QueryBuilder<PlannedSession, PlannedSession, QAfterSortBy>
      sortByActualMinutesFocused() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualMinutesFocused', Sort.asc);
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterSortBy>
      sortByActualMinutesFocusedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualMinutesFocused', Sort.desc);
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterSortBy>
      sortByBlocksScheduling() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blocksScheduling', Sort.asc);
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterSortBy>
      sortByBlocksSchedulingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blocksScheduling', Sort.desc);
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterSortBy> sortByCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completed', Sort.asc);
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterSortBy>
      sortByCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completed', Sort.desc);
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterSortBy> sortByEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'end', Sort.asc);
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterSortBy> sortByEndDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'end', Sort.desc);
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterSortBy>
      sortByIsCancelled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCancelled', Sort.asc);
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterSortBy>
      sortByIsCancelledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCancelled', Sort.desc);
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterSortBy>
      sortByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.asc);
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterSortBy>
      sortByIsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.desc);
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterSortBy>
      sortByIsInProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isInProgress', Sort.asc);
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterSortBy>
      sortByIsInProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isInProgress', Sort.desc);
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterSortBy> sortByIsMissed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMissed', Sort.asc);
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterSortBy>
      sortByIsMissedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMissed', Sort.desc);
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterSortBy> sortByIsPending() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPending', Sort.asc);
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterSortBy>
      sortByIsPendingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPending', Sort.desc);
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterSortBy>
      sortByPlannedDurationMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plannedDurationMinutes', Sort.asc);
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterSortBy>
      sortByPlannedDurationMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plannedDurationMinutes', Sort.desc);
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterSortBy> sortByStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'start', Sort.asc);
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterSortBy> sortByStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'start', Sort.desc);
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterSortBy> sortByTaskId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskId', Sort.asc);
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterSortBy>
      sortByTaskIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskId', Sort.desc);
    });
  }
}

extension PlannedSessionQuerySortThenBy
    on QueryBuilder<PlannedSession, PlannedSession, QSortThenBy> {
  QueryBuilder<PlannedSession, PlannedSession, QAfterSortBy>
      thenByActualMinutesFocused() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualMinutesFocused', Sort.asc);
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterSortBy>
      thenByActualMinutesFocusedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualMinutesFocused', Sort.desc);
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterSortBy>
      thenByBlocksScheduling() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blocksScheduling', Sort.asc);
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterSortBy>
      thenByBlocksSchedulingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blocksScheduling', Sort.desc);
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterSortBy> thenByCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completed', Sort.asc);
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterSortBy>
      thenByCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completed', Sort.desc);
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterSortBy> thenByEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'end', Sort.asc);
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterSortBy> thenByEndDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'end', Sort.desc);
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterSortBy>
      thenByIsCancelled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCancelled', Sort.asc);
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterSortBy>
      thenByIsCancelledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCancelled', Sort.desc);
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterSortBy>
      thenByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.asc);
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterSortBy>
      thenByIsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.desc);
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterSortBy>
      thenByIsInProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isInProgress', Sort.asc);
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterSortBy>
      thenByIsInProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isInProgress', Sort.desc);
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterSortBy> thenByIsMissed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMissed', Sort.asc);
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterSortBy>
      thenByIsMissedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMissed', Sort.desc);
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterSortBy> thenByIsPending() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPending', Sort.asc);
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterSortBy>
      thenByIsPendingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPending', Sort.desc);
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterSortBy>
      thenByPlannedDurationMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plannedDurationMinutes', Sort.asc);
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterSortBy>
      thenByPlannedDurationMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plannedDurationMinutes', Sort.desc);
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterSortBy> thenByStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'start', Sort.asc);
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterSortBy> thenByStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'start', Sort.desc);
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterSortBy> thenByTaskId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskId', Sort.asc);
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QAfterSortBy>
      thenByTaskIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskId', Sort.desc);
    });
  }
}

extension PlannedSessionQueryWhereDistinct
    on QueryBuilder<PlannedSession, PlannedSession, QDistinct> {
  QueryBuilder<PlannedSession, PlannedSession, QDistinct>
      distinctByActualMinutesFocused() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'actualMinutesFocused');
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QDistinct>
      distinctByBlocksScheduling() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'blocksScheduling');
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QDistinct>
      distinctByCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completed');
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QDistinct> distinctByEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'end');
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QDistinct> distinctById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QDistinct>
      distinctByIsCancelled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isCancelled');
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QDistinct>
      distinctByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isCompleted');
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QDistinct>
      distinctByIsInProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isInProgress');
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QDistinct> distinctByIsMissed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isMissed');
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QDistinct>
      distinctByIsPending() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isPending');
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QDistinct>
      distinctByPlannedDurationMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'plannedDurationMinutes');
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QDistinct> distinctByStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'start');
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QDistinct> distinctByStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PlannedSession, PlannedSession, QDistinct> distinctByTaskId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'taskId', caseSensitive: caseSensitive);
    });
  }
}

extension PlannedSessionQueryProperty
    on QueryBuilder<PlannedSession, PlannedSession, QQueryProperty> {
  QueryBuilder<PlannedSession, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<PlannedSession, int, QQueryOperations>
      actualMinutesFocusedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'actualMinutesFocused');
    });
  }

  QueryBuilder<PlannedSession, bool, QQueryOperations>
      blocksSchedulingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'blocksScheduling');
    });
  }

  QueryBuilder<PlannedSession, bool, QQueryOperations> completedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completed');
    });
  }

  QueryBuilder<PlannedSession, DateTime, QQueryOperations> endProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'end');
    });
  }

  QueryBuilder<PlannedSession, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PlannedSession, bool, QQueryOperations> isCancelledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isCancelled');
    });
  }

  QueryBuilder<PlannedSession, bool, QQueryOperations> isCompletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isCompleted');
    });
  }

  QueryBuilder<PlannedSession, bool, QQueryOperations> isInProgressProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isInProgress');
    });
  }

  QueryBuilder<PlannedSession, bool, QQueryOperations> isMissedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isMissed');
    });
  }

  QueryBuilder<PlannedSession, bool, QQueryOperations> isPendingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isPending');
    });
  }

  QueryBuilder<PlannedSession, int, QQueryOperations>
      plannedDurationMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'plannedDurationMinutes');
    });
  }

  QueryBuilder<PlannedSession, DateTime, QQueryOperations> startProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'start');
    });
  }

  QueryBuilder<PlannedSession, PlannedSessionStatus, QQueryOperations>
      statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<PlannedSession, String, QQueryOperations> taskIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'taskId');
    });
  }
}
