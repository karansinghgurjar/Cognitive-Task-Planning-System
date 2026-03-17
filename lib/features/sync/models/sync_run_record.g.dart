// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_run_record.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSyncRunRecordCollection on Isar {
  IsarCollection<SyncRunRecord> get syncRunRecords => this.collection();
}

const SyncRunRecordSchema = CollectionSchema(
  name: r'SyncRunRecord',
  id: -6590517417092163507,
  properties: {
    r'conflictCount': PropertySchema(
      id: 0,
      name: r'conflictCount',
      type: IsarType.long,
    ),
    r'errorSummary': PropertySchema(
      id: 1,
      name: r'errorSummary',
      type: IsarType.string,
    ),
    r'finishedAt': PropertySchema(
      id: 2,
      name: r'finishedAt',
      type: IsarType.dateTime,
    ),
    r'pulledCount': PropertySchema(
      id: 3,
      name: r'pulledCount',
      type: IsarType.long,
    ),
    r'pushedCount': PropertySchema(
      id: 4,
      name: r'pushedCount',
      type: IsarType.long,
    ),
    r'startedAt': PropertySchema(
      id: 5,
      name: r'startedAt',
      type: IsarType.dateTime,
    ),
    r'status': PropertySchema(
      id: 6,
      name: r'status',
      type: IsarType.string,
      enumMap: _SyncRunRecordstatusEnumValueMap,
    )
  },
  estimateSize: _syncRunRecordEstimateSize,
  serialize: _syncRunRecordSerialize,
  deserialize: _syncRunRecordDeserialize,
  deserializeProp: _syncRunRecordDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'startedAt': IndexSchema(
      id: 8114395319341636597,
      name: r'startedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'startedAt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _syncRunRecordGetId,
  getLinks: _syncRunRecordGetLinks,
  attach: _syncRunRecordAttach,
  version: '3.1.0+1',
);

int _syncRunRecordEstimateSize(
  SyncRunRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.errorSummary;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.status.name.length * 3;
  return bytesCount;
}

void _syncRunRecordSerialize(
  SyncRunRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.conflictCount);
  writer.writeString(offsets[1], object.errorSummary);
  writer.writeDateTime(offsets[2], object.finishedAt);
  writer.writeLong(offsets[3], object.pulledCount);
  writer.writeLong(offsets[4], object.pushedCount);
  writer.writeDateTime(offsets[5], object.startedAt);
  writer.writeString(offsets[6], object.status.name);
}

SyncRunRecord _syncRunRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SyncRunRecord(
    conflictCount: reader.readLong(offsets[0]),
    errorSummary: reader.readStringOrNull(offsets[1]),
    finishedAt: reader.readDateTime(offsets[2]),
    pulledCount: reader.readLong(offsets[3]),
    pushedCount: reader.readLong(offsets[4]),
    startedAt: reader.readDateTime(offsets[5]),
    status:
        _SyncRunRecordstatusValueEnumMap[reader.readStringOrNull(offsets[6])] ??
            SyncRunStatus.success,
  );
  object.isarId = id;
  return object;
}

P _syncRunRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (_SyncRunRecordstatusValueEnumMap[
              reader.readStringOrNull(offset)] ??
          SyncRunStatus.success) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _SyncRunRecordstatusEnumValueMap = {
  r'success': r'success',
  r'failed': r'failed',
  r'skipped': r'skipped',
};
const _SyncRunRecordstatusValueEnumMap = {
  r'success': SyncRunStatus.success,
  r'failed': SyncRunStatus.failed,
  r'skipped': SyncRunStatus.skipped,
};

Id _syncRunRecordGetId(SyncRunRecord object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _syncRunRecordGetLinks(SyncRunRecord object) {
  return [];
}

void _syncRunRecordAttach(
    IsarCollection<dynamic> col, Id id, SyncRunRecord object) {
  object.isarId = id;
}

extension SyncRunRecordQueryWhereSort
    on QueryBuilder<SyncRunRecord, SyncRunRecord, QWhere> {
  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterWhere> anyStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'startedAt'),
      );
    });
  }
}

extension SyncRunRecordQueryWhere
    on QueryBuilder<SyncRunRecord, SyncRunRecord, QWhereClause> {
  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterWhereClause> isarIdEqualTo(
      Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterWhereClause>
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

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterWhereClause> isarIdLessThan(
      Id isarId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterWhereClause> isarIdBetween(
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

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterWhereClause>
      startedAtEqualTo(DateTime startedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'startedAt',
        value: [startedAt],
      ));
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterWhereClause>
      startedAtNotEqualTo(DateTime startedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'startedAt',
              lower: [],
              upper: [startedAt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'startedAt',
              lower: [startedAt],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'startedAt',
              lower: [startedAt],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'startedAt',
              lower: [],
              upper: [startedAt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterWhereClause>
      startedAtGreaterThan(
    DateTime startedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'startedAt',
        lower: [startedAt],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterWhereClause>
      startedAtLessThan(
    DateTime startedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'startedAt',
        lower: [],
        upper: [startedAt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterWhereClause>
      startedAtBetween(
    DateTime lowerStartedAt,
    DateTime upperStartedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'startedAt',
        lower: [lowerStartedAt],
        includeLower: includeLower,
        upper: [upperStartedAt],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SyncRunRecordQueryFilter
    on QueryBuilder<SyncRunRecord, SyncRunRecord, QFilterCondition> {
  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterFilterCondition>
      conflictCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'conflictCount',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterFilterCondition>
      conflictCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'conflictCount',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterFilterCondition>
      conflictCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'conflictCount',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterFilterCondition>
      conflictCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'conflictCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterFilterCondition>
      errorSummaryIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'errorSummary',
      ));
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterFilterCondition>
      errorSummaryIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'errorSummary',
      ));
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterFilterCondition>
      errorSummaryEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'errorSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterFilterCondition>
      errorSummaryGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'errorSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterFilterCondition>
      errorSummaryLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'errorSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterFilterCondition>
      errorSummaryBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'errorSummary',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterFilterCondition>
      errorSummaryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'errorSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterFilterCondition>
      errorSummaryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'errorSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterFilterCondition>
      errorSummaryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'errorSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterFilterCondition>
      errorSummaryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'errorSummary',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterFilterCondition>
      errorSummaryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'errorSummary',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterFilterCondition>
      errorSummaryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'errorSummary',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterFilterCondition>
      finishedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'finishedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterFilterCondition>
      finishedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'finishedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterFilterCondition>
      finishedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'finishedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterFilterCondition>
      finishedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'finishedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterFilterCondition>
      isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterFilterCondition>
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

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterFilterCondition>
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

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterFilterCondition>
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

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterFilterCondition>
      pulledCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pulledCount',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterFilterCondition>
      pulledCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pulledCount',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterFilterCondition>
      pulledCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pulledCount',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterFilterCondition>
      pulledCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pulledCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterFilterCondition>
      pushedCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pushedCount',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterFilterCondition>
      pushedCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pushedCount',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterFilterCondition>
      pushedCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pushedCount',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterFilterCondition>
      pushedCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pushedCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterFilterCondition>
      startedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterFilterCondition>
      startedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterFilterCondition>
      startedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterFilterCondition>
      startedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterFilterCondition>
      statusEqualTo(
    SyncRunStatus value, {
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

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterFilterCondition>
      statusGreaterThan(
    SyncRunStatus value, {
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

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterFilterCondition>
      statusLessThan(
    SyncRunStatus value, {
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

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterFilterCondition>
      statusBetween(
    SyncRunStatus lower,
    SyncRunStatus upper, {
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

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterFilterCondition>
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

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterFilterCondition>
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

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterFilterCondition>
      statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterFilterCondition>
      statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterFilterCondition>
      statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterFilterCondition>
      statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }
}

extension SyncRunRecordQueryObject
    on QueryBuilder<SyncRunRecord, SyncRunRecord, QFilterCondition> {}

extension SyncRunRecordQueryLinks
    on QueryBuilder<SyncRunRecord, SyncRunRecord, QFilterCondition> {}

extension SyncRunRecordQuerySortBy
    on QueryBuilder<SyncRunRecord, SyncRunRecord, QSortBy> {
  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterSortBy>
      sortByConflictCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conflictCount', Sort.asc);
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterSortBy>
      sortByConflictCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conflictCount', Sort.desc);
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterSortBy>
      sortByErrorSummary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorSummary', Sort.asc);
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterSortBy>
      sortByErrorSummaryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorSummary', Sort.desc);
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterSortBy> sortByFinishedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finishedAt', Sort.asc);
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterSortBy>
      sortByFinishedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finishedAt', Sort.desc);
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterSortBy> sortByPulledCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pulledCount', Sort.asc);
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterSortBy>
      sortByPulledCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pulledCount', Sort.desc);
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterSortBy> sortByPushedCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pushedCount', Sort.asc);
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterSortBy>
      sortByPushedCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pushedCount', Sort.desc);
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterSortBy> sortByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.asc);
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterSortBy>
      sortByStartedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.desc);
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }
}

extension SyncRunRecordQuerySortThenBy
    on QueryBuilder<SyncRunRecord, SyncRunRecord, QSortThenBy> {
  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterSortBy>
      thenByConflictCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conflictCount', Sort.asc);
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterSortBy>
      thenByConflictCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conflictCount', Sort.desc);
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterSortBy>
      thenByErrorSummary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorSummary', Sort.asc);
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterSortBy>
      thenByErrorSummaryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorSummary', Sort.desc);
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterSortBy> thenByFinishedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finishedAt', Sort.asc);
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterSortBy>
      thenByFinishedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finishedAt', Sort.desc);
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterSortBy> thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterSortBy> thenByPulledCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pulledCount', Sort.asc);
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterSortBy>
      thenByPulledCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pulledCount', Sort.desc);
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterSortBy> thenByPushedCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pushedCount', Sort.asc);
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterSortBy>
      thenByPushedCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pushedCount', Sort.desc);
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterSortBy> thenByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.asc);
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterSortBy>
      thenByStartedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.desc);
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }
}

extension SyncRunRecordQueryWhereDistinct
    on QueryBuilder<SyncRunRecord, SyncRunRecord, QDistinct> {
  QueryBuilder<SyncRunRecord, SyncRunRecord, QDistinct>
      distinctByConflictCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'conflictCount');
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QDistinct> distinctByErrorSummary(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'errorSummary', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QDistinct> distinctByFinishedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'finishedAt');
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QDistinct>
      distinctByPulledCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pulledCount');
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QDistinct>
      distinctByPushedCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pushedCount');
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QDistinct> distinctByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startedAt');
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunRecord, QDistinct> distinctByStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }
}

extension SyncRunRecordQueryProperty
    on QueryBuilder<SyncRunRecord, SyncRunRecord, QQueryProperty> {
  QueryBuilder<SyncRunRecord, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<SyncRunRecord, int, QQueryOperations> conflictCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'conflictCount');
    });
  }

  QueryBuilder<SyncRunRecord, String?, QQueryOperations>
      errorSummaryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'errorSummary');
    });
  }

  QueryBuilder<SyncRunRecord, DateTime, QQueryOperations> finishedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'finishedAt');
    });
  }

  QueryBuilder<SyncRunRecord, int, QQueryOperations> pulledCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pulledCount');
    });
  }

  QueryBuilder<SyncRunRecord, int, QQueryOperations> pushedCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pushedCount');
    });
  }

  QueryBuilder<SyncRunRecord, DateTime, QQueryOperations> startedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startedAt');
    });
  }

  QueryBuilder<SyncRunRecord, SyncRunStatus, QQueryOperations>
      statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }
}
