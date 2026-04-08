// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routine_occurrence.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetRoutineOccurrenceCollection on Isar {
  IsarCollection<RoutineOccurrence> get routineOccurrences => this.collection();
}

const RoutineOccurrenceSchema = CollectionSchema(
  name: r'RoutineOccurrence',
  id: 9068139044438769895,
  properties: {
    r'completedAt': PropertySchema(
      id: 0,
      name: r'completedAt',
      type: IsarType.dateTime,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'id': PropertySchema(
      id: 2,
      name: r'id',
      type: IsarType.string,
    ),
    r'missedAt': PropertySchema(
      id: 3,
      name: r'missedAt',
      type: IsarType.dateTime,
    ),
    r'notes': PropertySchema(
      id: 4,
      name: r'notes',
      type: IsarType.string,
    ),
    r'occurrenceDate': PropertySchema(
      id: 5,
      name: r'occurrenceDate',
      type: IsarType.dateTime,
    ),
    r'occurrenceKey': PropertySchema(
      id: 6,
      name: r'occurrenceKey',
      type: IsarType.string,
    ),
    r'routineId': PropertySchema(
      id: 7,
      name: r'routineId',
      type: IsarType.string,
    ),
    r'scheduledEnd': PropertySchema(
      id: 8,
      name: r'scheduledEnd',
      type: IsarType.dateTime,
    ),
    r'scheduledStart': PropertySchema(
      id: 9,
      name: r'scheduledStart',
      type: IsarType.dateTime,
    ),
    r'skippedAt': PropertySchema(
      id: 10,
      name: r'skippedAt',
      type: IsarType.dateTime,
    ),
    r'sourceTaskId': PropertySchema(
      id: 11,
      name: r'sourceTaskId',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 12,
      name: r'status',
      type: IsarType.string,
      enumMap: _RoutineOccurrencestatusEnumValueMap,
    ),
    r'updatedAt': PropertySchema(
      id: 13,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _routineOccurrenceEstimateSize,
  serialize: _routineOccurrenceSerialize,
  deserialize: _routineOccurrenceDeserialize,
  deserializeProp: _routineOccurrenceDeserializeProp,
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
    ),
    r'routineId': IndexSchema(
      id: -7971259615846791236,
      name: r'routineId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'routineId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'occurrenceKey': IndexSchema(
      id: 1905454298359628696,
      name: r'occurrenceKey',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'occurrenceKey',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'occurrenceDate': IndexSchema(
      id: 7253513228793877556,
      name: r'occurrenceDate',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'occurrenceDate',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _routineOccurrenceGetId,
  getLinks: _routineOccurrenceGetLinks,
  attach: _routineOccurrenceAttach,
  version: '3.1.0+1',
);

int _routineOccurrenceEstimateSize(
  RoutineOccurrence object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.id.length * 3;
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.occurrenceKey.length * 3;
  bytesCount += 3 + object.routineId.length * 3;
  {
    final value = object.sourceTaskId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.status.name.length * 3;
  return bytesCount;
}

void _routineOccurrenceSerialize(
  RoutineOccurrence object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.completedAt);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeString(offsets[2], object.id);
  writer.writeDateTime(offsets[3], object.missedAt);
  writer.writeString(offsets[4], object.notes);
  writer.writeDateTime(offsets[5], object.occurrenceDate);
  writer.writeString(offsets[6], object.occurrenceKey);
  writer.writeString(offsets[7], object.routineId);
  writer.writeDateTime(offsets[8], object.scheduledEnd);
  writer.writeDateTime(offsets[9], object.scheduledStart);
  writer.writeDateTime(offsets[10], object.skippedAt);
  writer.writeString(offsets[11], object.sourceTaskId);
  writer.writeString(offsets[12], object.status.name);
  writer.writeDateTime(offsets[13], object.updatedAt);
}

RoutineOccurrence _routineOccurrenceDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = RoutineOccurrence(
    completedAt: reader.readDateTimeOrNull(offsets[0]),
    createdAt: reader.readDateTime(offsets[1]),
    id: reader.readString(offsets[2]),
    missedAt: reader.readDateTimeOrNull(offsets[3]),
    notes: reader.readStringOrNull(offsets[4]),
    occurrenceDate: reader.readDateTime(offsets[5]),
    routineId: reader.readString(offsets[7]),
    scheduledEnd: reader.readDateTimeOrNull(offsets[8]),
    scheduledStart: reader.readDateTimeOrNull(offsets[9]),
    skippedAt: reader.readDateTimeOrNull(offsets[10]),
    sourceTaskId: reader.readStringOrNull(offsets[11]),
    status: _RoutineOccurrencestatusValueEnumMap[
            reader.readStringOrNull(offsets[12])] ??
        RoutineOccurrenceStatus.pending,
    updatedAt: reader.readDateTimeOrNull(offsets[13]),
  );
  object.isarId = id;
  object.occurrenceKey = reader.readString(offsets[6]);
  return object;
}

P _routineOccurrenceDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 9:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 10:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (_RoutineOccurrencestatusValueEnumMap[
              reader.readStringOrNull(offset)] ??
          RoutineOccurrenceStatus.pending) as P;
    case 13:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _RoutineOccurrencestatusEnumValueMap = {
  r'pending': r'pending',
  r'completed': r'completed',
  r'skipped': r'skipped',
  r'missed': r'missed',
};
const _RoutineOccurrencestatusValueEnumMap = {
  r'pending': RoutineOccurrenceStatus.pending,
  r'completed': RoutineOccurrenceStatus.completed,
  r'skipped': RoutineOccurrenceStatus.skipped,
  r'missed': RoutineOccurrenceStatus.missed,
};

Id _routineOccurrenceGetId(RoutineOccurrence object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _routineOccurrenceGetLinks(
    RoutineOccurrence object) {
  return [];
}

void _routineOccurrenceAttach(
    IsarCollection<dynamic> col, Id id, RoutineOccurrence object) {
  object.isarId = id;
}

extension RoutineOccurrenceByIndex on IsarCollection<RoutineOccurrence> {
  Future<RoutineOccurrence?> getById(String id) {
    return getByIndex(r'id', [id]);
  }

  RoutineOccurrence? getByIdSync(String id) {
    return getByIndexSync(r'id', [id]);
  }

  Future<bool> deleteById(String id) {
    return deleteByIndex(r'id', [id]);
  }

  bool deleteByIdSync(String id) {
    return deleteByIndexSync(r'id', [id]);
  }

  Future<List<RoutineOccurrence?>> getAllById(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndex(r'id', values);
  }

  List<RoutineOccurrence?> getAllByIdSync(List<String> idValues) {
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

  Future<Id> putById(RoutineOccurrence object) {
    return putByIndex(r'id', object);
  }

  Id putByIdSync(RoutineOccurrence object, {bool saveLinks = true}) {
    return putByIndexSync(r'id', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllById(List<RoutineOccurrence> objects) {
    return putAllByIndex(r'id', objects);
  }

  List<Id> putAllByIdSync(List<RoutineOccurrence> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'id', objects, saveLinks: saveLinks);
  }

  Future<RoutineOccurrence?> getByOccurrenceKey(String occurrenceKey) {
    return getByIndex(r'occurrenceKey', [occurrenceKey]);
  }

  RoutineOccurrence? getByOccurrenceKeySync(String occurrenceKey) {
    return getByIndexSync(r'occurrenceKey', [occurrenceKey]);
  }

  Future<bool> deleteByOccurrenceKey(String occurrenceKey) {
    return deleteByIndex(r'occurrenceKey', [occurrenceKey]);
  }

  bool deleteByOccurrenceKeySync(String occurrenceKey) {
    return deleteByIndexSync(r'occurrenceKey', [occurrenceKey]);
  }

  Future<List<RoutineOccurrence?>> getAllByOccurrenceKey(
      List<String> occurrenceKeyValues) {
    final values = occurrenceKeyValues.map((e) => [e]).toList();
    return getAllByIndex(r'occurrenceKey', values);
  }

  List<RoutineOccurrence?> getAllByOccurrenceKeySync(
      List<String> occurrenceKeyValues) {
    final values = occurrenceKeyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'occurrenceKey', values);
  }

  Future<int> deleteAllByOccurrenceKey(List<String> occurrenceKeyValues) {
    final values = occurrenceKeyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'occurrenceKey', values);
  }

  int deleteAllByOccurrenceKeySync(List<String> occurrenceKeyValues) {
    final values = occurrenceKeyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'occurrenceKey', values);
  }

  Future<Id> putByOccurrenceKey(RoutineOccurrence object) {
    return putByIndex(r'occurrenceKey', object);
  }

  Id putByOccurrenceKeySync(RoutineOccurrence object, {bool saveLinks = true}) {
    return putByIndexSync(r'occurrenceKey', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByOccurrenceKey(List<RoutineOccurrence> objects) {
    return putAllByIndex(r'occurrenceKey', objects);
  }

  List<Id> putAllByOccurrenceKeySync(List<RoutineOccurrence> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'occurrenceKey', objects, saveLinks: saveLinks);
  }
}

extension RoutineOccurrenceQueryWhereSort
    on QueryBuilder<RoutineOccurrence, RoutineOccurrence, QWhere> {
  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterWhere>
      anyOccurrenceDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'occurrenceDate'),
      );
    });
  }
}

extension RoutineOccurrenceQueryWhere
    on QueryBuilder<RoutineOccurrence, RoutineOccurrence, QWhereClause> {
  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterWhereClause>
      isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterWhereClause>
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

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterWhereClause>
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

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterWhereClause>
      idEqualTo(String id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'id',
        value: [id],
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterWhereClause>
      idNotEqualTo(String id) {
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

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterWhereClause>
      routineIdEqualTo(String routineId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'routineId',
        value: [routineId],
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterWhereClause>
      routineIdNotEqualTo(String routineId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'routineId',
              lower: [],
              upper: [routineId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'routineId',
              lower: [routineId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'routineId',
              lower: [routineId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'routineId',
              lower: [],
              upper: [routineId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterWhereClause>
      occurrenceKeyEqualTo(String occurrenceKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'occurrenceKey',
        value: [occurrenceKey],
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterWhereClause>
      occurrenceKeyNotEqualTo(String occurrenceKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'occurrenceKey',
              lower: [],
              upper: [occurrenceKey],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'occurrenceKey',
              lower: [occurrenceKey],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'occurrenceKey',
              lower: [occurrenceKey],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'occurrenceKey',
              lower: [],
              upper: [occurrenceKey],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterWhereClause>
      occurrenceDateEqualTo(DateTime occurrenceDate) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'occurrenceDate',
        value: [occurrenceDate],
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterWhereClause>
      occurrenceDateNotEqualTo(DateTime occurrenceDate) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'occurrenceDate',
              lower: [],
              upper: [occurrenceDate],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'occurrenceDate',
              lower: [occurrenceDate],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'occurrenceDate',
              lower: [occurrenceDate],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'occurrenceDate',
              lower: [],
              upper: [occurrenceDate],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterWhereClause>
      occurrenceDateGreaterThan(
    DateTime occurrenceDate, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'occurrenceDate',
        lower: [occurrenceDate],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterWhereClause>
      occurrenceDateLessThan(
    DateTime occurrenceDate, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'occurrenceDate',
        lower: [],
        upper: [occurrenceDate],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterWhereClause>
      occurrenceDateBetween(
    DateTime lowerOccurrenceDate,
    DateTime upperOccurrenceDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'occurrenceDate',
        lower: [lowerOccurrenceDate],
        includeLower: includeLower,
        upper: [upperOccurrenceDate],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension RoutineOccurrenceQueryFilter
    on QueryBuilder<RoutineOccurrence, RoutineOccurrence, QFilterCondition> {
  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      completedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'completedAt',
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      completedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'completedAt',
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      completedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      completedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'completedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      completedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'completedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      completedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'completedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      idEqualTo(
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

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
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

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
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

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
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

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
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

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      idContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      idMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'id',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
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

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
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

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
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

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      missedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'missedAt',
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      missedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'missedAt',
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      missedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'missedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      missedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'missedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      missedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'missedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      missedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'missedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      notesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      notesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      notesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      notesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      notesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      notesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      notesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      notesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      occurrenceDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'occurrenceDate',
        value: value,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      occurrenceDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'occurrenceDate',
        value: value,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      occurrenceDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'occurrenceDate',
        value: value,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      occurrenceDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'occurrenceDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      occurrenceKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'occurrenceKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      occurrenceKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'occurrenceKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      occurrenceKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'occurrenceKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      occurrenceKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'occurrenceKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      occurrenceKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'occurrenceKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      occurrenceKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'occurrenceKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      occurrenceKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'occurrenceKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      occurrenceKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'occurrenceKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      occurrenceKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'occurrenceKey',
        value: '',
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      occurrenceKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'occurrenceKey',
        value: '',
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      routineIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'routineId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      routineIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'routineId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      routineIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'routineId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      routineIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'routineId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      routineIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'routineId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      routineIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'routineId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      routineIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'routineId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      routineIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'routineId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      routineIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'routineId',
        value: '',
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      routineIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'routineId',
        value: '',
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      scheduledEndIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'scheduledEnd',
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      scheduledEndIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'scheduledEnd',
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      scheduledEndEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scheduledEnd',
        value: value,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      scheduledEndGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'scheduledEnd',
        value: value,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      scheduledEndLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'scheduledEnd',
        value: value,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      scheduledEndBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'scheduledEnd',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      scheduledStartIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'scheduledStart',
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      scheduledStartIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'scheduledStart',
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      scheduledStartEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scheduledStart',
        value: value,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      scheduledStartGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'scheduledStart',
        value: value,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      scheduledStartLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'scheduledStart',
        value: value,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      scheduledStartBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'scheduledStart',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      skippedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'skippedAt',
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      skippedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'skippedAt',
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      skippedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'skippedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      skippedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'skippedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      skippedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'skippedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      skippedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'skippedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      sourceTaskIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sourceTaskId',
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      sourceTaskIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sourceTaskId',
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      sourceTaskIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceTaskId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      sourceTaskIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sourceTaskId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      sourceTaskIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sourceTaskId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      sourceTaskIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sourceTaskId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      sourceTaskIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sourceTaskId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      sourceTaskIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sourceTaskId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      sourceTaskIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sourceTaskId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      sourceTaskIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sourceTaskId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      sourceTaskIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceTaskId',
        value: '',
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      sourceTaskIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sourceTaskId',
        value: '',
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      statusEqualTo(
    RoutineOccurrenceStatus value, {
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

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      statusGreaterThan(
    RoutineOccurrenceStatus value, {
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

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      statusLessThan(
    RoutineOccurrenceStatus value, {
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

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      statusBetween(
    RoutineOccurrenceStatus lower,
    RoutineOccurrenceStatus upper, {
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

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
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

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
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

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      updatedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      updatedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension RoutineOccurrenceQueryObject
    on QueryBuilder<RoutineOccurrence, RoutineOccurrence, QFilterCondition> {}

extension RoutineOccurrenceQueryLinks
    on QueryBuilder<RoutineOccurrence, RoutineOccurrence, QFilterCondition> {}

extension RoutineOccurrenceQuerySortBy
    on QueryBuilder<RoutineOccurrence, RoutineOccurrence, QSortBy> {
  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      sortByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      sortByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      sortByMissedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'missedAt', Sort.asc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      sortByMissedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'missedAt', Sort.desc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      sortByOccurrenceDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'occurrenceDate', Sort.asc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      sortByOccurrenceDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'occurrenceDate', Sort.desc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      sortByOccurrenceKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'occurrenceKey', Sort.asc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      sortByOccurrenceKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'occurrenceKey', Sort.desc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      sortByRoutineId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'routineId', Sort.asc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      sortByRoutineIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'routineId', Sort.desc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      sortByScheduledEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledEnd', Sort.asc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      sortByScheduledEndDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledEnd', Sort.desc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      sortByScheduledStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledStart', Sort.asc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      sortByScheduledStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledStart', Sort.desc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      sortBySkippedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skippedAt', Sort.asc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      sortBySkippedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skippedAt', Sort.desc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      sortBySourceTaskId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceTaskId', Sort.asc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      sortBySourceTaskIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceTaskId', Sort.desc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension RoutineOccurrenceQuerySortThenBy
    on QueryBuilder<RoutineOccurrence, RoutineOccurrence, QSortThenBy> {
  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      thenByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      thenByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      thenByMissedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'missedAt', Sort.asc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      thenByMissedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'missedAt', Sort.desc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      thenByOccurrenceDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'occurrenceDate', Sort.asc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      thenByOccurrenceDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'occurrenceDate', Sort.desc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      thenByOccurrenceKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'occurrenceKey', Sort.asc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      thenByOccurrenceKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'occurrenceKey', Sort.desc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      thenByRoutineId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'routineId', Sort.asc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      thenByRoutineIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'routineId', Sort.desc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      thenByScheduledEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledEnd', Sort.asc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      thenByScheduledEndDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledEnd', Sort.desc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      thenByScheduledStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledStart', Sort.asc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      thenByScheduledStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledStart', Sort.desc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      thenBySkippedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skippedAt', Sort.asc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      thenBySkippedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skippedAt', Sort.desc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      thenBySourceTaskId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceTaskId', Sort.asc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      thenBySourceTaskIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceTaskId', Sort.desc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension RoutineOccurrenceQueryWhereDistinct
    on QueryBuilder<RoutineOccurrence, RoutineOccurrence, QDistinct> {
  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QDistinct>
      distinctByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completedAt');
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QDistinct> distinctById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QDistinct>
      distinctByMissedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'missedAt');
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QDistinct> distinctByNotes(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QDistinct>
      distinctByOccurrenceDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'occurrenceDate');
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QDistinct>
      distinctByOccurrenceKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'occurrenceKey',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QDistinct>
      distinctByRoutineId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'routineId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QDistinct>
      distinctByScheduledEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'scheduledEnd');
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QDistinct>
      distinctByScheduledStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'scheduledStart');
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QDistinct>
      distinctBySkippedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'skippedAt');
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QDistinct>
      distinctBySourceTaskId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceTaskId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QDistinct>
      distinctByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension RoutineOccurrenceQueryProperty
    on QueryBuilder<RoutineOccurrence, RoutineOccurrence, QQueryProperty> {
  QueryBuilder<RoutineOccurrence, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<RoutineOccurrence, DateTime?, QQueryOperations>
      completedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completedAt');
    });
  }

  QueryBuilder<RoutineOccurrence, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<RoutineOccurrence, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<RoutineOccurrence, DateTime?, QQueryOperations>
      missedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'missedAt');
    });
  }

  QueryBuilder<RoutineOccurrence, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<RoutineOccurrence, DateTime, QQueryOperations>
      occurrenceDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'occurrenceDate');
    });
  }

  QueryBuilder<RoutineOccurrence, String, QQueryOperations>
      occurrenceKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'occurrenceKey');
    });
  }

  QueryBuilder<RoutineOccurrence, String, QQueryOperations>
      routineIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'routineId');
    });
  }

  QueryBuilder<RoutineOccurrence, DateTime?, QQueryOperations>
      scheduledEndProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scheduledEnd');
    });
  }

  QueryBuilder<RoutineOccurrence, DateTime?, QQueryOperations>
      scheduledStartProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scheduledStart');
    });
  }

  QueryBuilder<RoutineOccurrence, DateTime?, QQueryOperations>
      skippedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'skippedAt');
    });
  }

  QueryBuilder<RoutineOccurrence, String?, QQueryOperations>
      sourceTaskIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceTaskId');
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrenceStatus, QQueryOperations>
      statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<RoutineOccurrence, DateTime?, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
