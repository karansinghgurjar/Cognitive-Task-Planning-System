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
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'durationMinutes': PropertySchema(
      id: 1,
      name: r'durationMinutes',
      type: IsarType.long,
    ),
    r'id': PropertySchema(
      id: 2,
      name: r'id',
      type: IsarType.string,
    ),
    r'isCompleted': PropertySchema(
      id: 3,
      name: r'isCompleted',
      type: IsarType.bool,
    ),
    r'linkedPlannedSessionId': PropertySchema(
      id: 4,
      name: r'linkedPlannedSessionId',
      type: IsarType.string,
    ),
    r'routineId': PropertySchema(
      id: 5,
      name: r'routineId',
      type: IsarType.string,
    ),
    r'scheduledEnd': PropertySchema(
      id: 6,
      name: r'scheduledEnd',
      type: IsarType.dateTime,
    ),
    r'scheduledStart': PropertySchema(
      id: 7,
      name: r'scheduledStart',
      type: IsarType.dateTime,
    ),
    r'status': PropertySchema(
      id: 8,
      name: r'status',
      type: IsarType.string,
      enumMap: _RoutineOccurrencestatusEnumValueMap,
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
    final value = object.linkedPlannedSessionId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.routineId.length * 3;
  bytesCount += 3 + object.status.name.length * 3;
  return bytesCount;
}

void _routineOccurrenceSerialize(
  RoutineOccurrence object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeLong(offsets[1], object.durationMinutes);
  writer.writeString(offsets[2], object.id);
  writer.writeBool(offsets[3], object.isCompleted);
  writer.writeString(offsets[4], object.linkedPlannedSessionId);
  writer.writeString(offsets[5], object.routineId);
  writer.writeDateTime(offsets[6], object.scheduledEnd);
  writer.writeDateTime(offsets[7], object.scheduledStart);
  writer.writeString(offsets[8], object.status.name);
}

RoutineOccurrence _routineOccurrenceDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = RoutineOccurrence(
    createdAt: reader.readDateTime(offsets[0]),
    id: reader.readString(offsets[2]),
    linkedPlannedSessionId: reader.readStringOrNull(offsets[4]),
    routineId: reader.readString(offsets[5]),
    scheduledEnd: reader.readDateTime(offsets[6]),
    scheduledStart: reader.readDateTime(offsets[7]),
    status: _RoutineOccurrencestatusValueEnumMap[
            reader.readStringOrNull(offsets[8])] ??
        RoutineOccurrenceStatus.pending,
  );
  object.isarId = id;
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
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readDateTime(offset)) as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    case 8:
      return (_RoutineOccurrencestatusValueEnumMap[
              reader.readStringOrNull(offset)] ??
          RoutineOccurrenceStatus.pending) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _RoutineOccurrencestatusEnumValueMap = {
  r'pending': r'pending',
  r'completed': r'completed',
  r'missed': r'missed',
  r'cancelled': r'cancelled',
};
const _RoutineOccurrencestatusValueEnumMap = {
  r'pending': RoutineOccurrenceStatus.pending,
  r'completed': RoutineOccurrenceStatus.completed,
  r'missed': RoutineOccurrenceStatus.missed,
  r'cancelled': RoutineOccurrenceStatus.cancelled,
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
}

extension RoutineOccurrenceQueryWhereSort
    on QueryBuilder<RoutineOccurrence, RoutineOccurrence, QWhere> {
  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
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
}

extension RoutineOccurrenceQueryFilter
    on QueryBuilder<RoutineOccurrence, RoutineOccurrence, QFilterCondition> {
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
      durationMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'durationMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      durationMinutesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'durationMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      durationMinutesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'durationMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      durationMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'durationMinutes',
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
      isCompletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isCompleted',
        value: value,
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
      linkedPlannedSessionIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'linkedPlannedSessionId',
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      linkedPlannedSessionIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'linkedPlannedSessionId',
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      linkedPlannedSessionIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'linkedPlannedSessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      linkedPlannedSessionIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'linkedPlannedSessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      linkedPlannedSessionIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'linkedPlannedSessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      linkedPlannedSessionIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'linkedPlannedSessionId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      linkedPlannedSessionIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'linkedPlannedSessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      linkedPlannedSessionIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'linkedPlannedSessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      linkedPlannedSessionIdContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'linkedPlannedSessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      linkedPlannedSessionIdMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'linkedPlannedSessionId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      linkedPlannedSessionIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'linkedPlannedSessionId',
        value: '',
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      linkedPlannedSessionIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'linkedPlannedSessionId',
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
      scheduledEndEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scheduledEnd',
        value: value,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      scheduledEndGreaterThan(
    DateTime value, {
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
    DateTime value, {
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
    DateTime lower,
    DateTime upper, {
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
      scheduledStartEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scheduledStart',
        value: value,
      ));
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterFilterCondition>
      scheduledStartGreaterThan(
    DateTime value, {
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
    DateTime value, {
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
    DateTime lower,
    DateTime upper, {
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
}

extension RoutineOccurrenceQueryObject
    on QueryBuilder<RoutineOccurrence, RoutineOccurrence, QFilterCondition> {}

extension RoutineOccurrenceQueryLinks
    on QueryBuilder<RoutineOccurrence, RoutineOccurrence, QFilterCondition> {}

extension RoutineOccurrenceQuerySortBy
    on QueryBuilder<RoutineOccurrence, RoutineOccurrence, QSortBy> {
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

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      sortByDurationMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMinutes', Sort.asc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      sortByDurationMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMinutes', Sort.desc);
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
      sortByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.asc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      sortByIsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.desc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      sortByLinkedPlannedSessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedPlannedSessionId', Sort.asc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      sortByLinkedPlannedSessionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedPlannedSessionId', Sort.desc);
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
}

extension RoutineOccurrenceQuerySortThenBy
    on QueryBuilder<RoutineOccurrence, RoutineOccurrence, QSortThenBy> {
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

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      thenByDurationMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMinutes', Sort.asc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      thenByDurationMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMinutes', Sort.desc);
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
      thenByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.asc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      thenByIsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.desc);
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
      thenByLinkedPlannedSessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedPlannedSessionId', Sort.asc);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QAfterSortBy>
      thenByLinkedPlannedSessionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedPlannedSessionId', Sort.desc);
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
}

extension RoutineOccurrenceQueryWhereDistinct
    on QueryBuilder<RoutineOccurrence, RoutineOccurrence, QDistinct> {
  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QDistinct>
      distinctByDurationMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'durationMinutes');
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QDistinct> distinctById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QDistinct>
      distinctByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isCompleted');
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrence, QDistinct>
      distinctByLinkedPlannedSessionId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'linkedPlannedSessionId',
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
      distinctByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
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

  QueryBuilder<RoutineOccurrence, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<RoutineOccurrence, int, QQueryOperations>
      durationMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'durationMinutes');
    });
  }

  QueryBuilder<RoutineOccurrence, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<RoutineOccurrence, bool, QQueryOperations>
      isCompletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isCompleted');
    });
  }

  QueryBuilder<RoutineOccurrence, String?, QQueryOperations>
      linkedPlannedSessionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'linkedPlannedSessionId');
    });
  }

  QueryBuilder<RoutineOccurrence, String, QQueryOperations>
      routineIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'routineId');
    });
  }

  QueryBuilder<RoutineOccurrence, DateTime, QQueryOperations>
      scheduledEndProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scheduledEnd');
    });
  }

  QueryBuilder<RoutineOccurrence, DateTime, QQueryOperations>
      scheduledStartProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scheduledStart');
    });
  }

  QueryBuilder<RoutineOccurrence, RoutineOccurrenceStatus, QQueryOperations>
      statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }
}
