// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_record.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBackupRecordCollection on Isar {
  IsarCollection<BackupRecord> get backupRecords => this.collection();
}

const BackupRecordSchema = CollectionSchema(
  name: r'BackupRecord',
  id: -4075346009198954164,
  properties: {
    r'backupType': PropertySchema(
      id: 0,
      name: r'backupType',
      type: IsarType.string,
      enumMap: _BackupRecordbackupTypeEnumValueMap,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'filePath': PropertySchema(
      id: 2,
      name: r'filePath',
      type: IsarType.string,
    ),
    r'recordCount': PropertySchema(
      id: 3,
      name: r'recordCount',
      type: IsarType.long,
    ),
    r'status': PropertySchema(
      id: 4,
      name: r'status',
      type: IsarType.string,
      enumMap: _BackupRecordstatusEnumValueMap,
    )
  },
  estimateSize: _backupRecordEstimateSize,
  serialize: _backupRecordSerialize,
  deserialize: _backupRecordDeserialize,
  deserializeProp: _backupRecordDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _backupRecordGetId,
  getLinks: _backupRecordGetLinks,
  attach: _backupRecordAttach,
  version: '3.1.0+1',
);

int _backupRecordEstimateSize(
  BackupRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.backupType.name.length * 3;
  {
    final value = object.filePath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.status.name.length * 3;
  return bytesCount;
}

void _backupRecordSerialize(
  BackupRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.backupType.name);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeString(offsets[2], object.filePath);
  writer.writeLong(offsets[3], object.recordCount);
  writer.writeString(offsets[4], object.status.name);
}

BackupRecord _backupRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BackupRecord(
    backupType: _BackupRecordbackupTypeValueEnumMap[
            reader.readStringOrNull(offsets[0])] ??
        BackupRecordType.fullJson,
    createdAt: reader.readDateTime(offsets[1]),
    filePath: reader.readStringOrNull(offsets[2]),
    recordCount: reader.readLong(offsets[3]),
    status:
        _BackupRecordstatusValueEnumMap[reader.readStringOrNull(offsets[4])] ??
            BackupRecordStatus.success,
  );
  object.id = id;
  return object;
}

P _backupRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (_BackupRecordbackupTypeValueEnumMap[
              reader.readStringOrNull(offset)] ??
          BackupRecordType.fullJson) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (_BackupRecordstatusValueEnumMap[
              reader.readStringOrNull(offset)] ??
          BackupRecordStatus.success) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _BackupRecordbackupTypeEnumValueMap = {
  r'fullJson': r'fullJson',
  r'tasksCsv': r'tasksCsv',
  r'sessionsCsv': r'sessionsCsv',
  r'goalsCsv': r'goalsCsv',
  r'analyticsCsv': r'analyticsCsv',
  r'integrityReport': r'integrityReport',
};
const _BackupRecordbackupTypeValueEnumMap = {
  r'fullJson': BackupRecordType.fullJson,
  r'tasksCsv': BackupRecordType.tasksCsv,
  r'sessionsCsv': BackupRecordType.sessionsCsv,
  r'goalsCsv': BackupRecordType.goalsCsv,
  r'analyticsCsv': BackupRecordType.analyticsCsv,
  r'integrityReport': BackupRecordType.integrityReport,
};
const _BackupRecordstatusEnumValueMap = {
  r'success': r'success',
  r'failed': r'failed',
  r'cancelled': r'cancelled',
};
const _BackupRecordstatusValueEnumMap = {
  r'success': BackupRecordStatus.success,
  r'failed': BackupRecordStatus.failed,
  r'cancelled': BackupRecordStatus.cancelled,
};

Id _backupRecordGetId(BackupRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _backupRecordGetLinks(BackupRecord object) {
  return [];
}

void _backupRecordAttach(
    IsarCollection<dynamic> col, Id id, BackupRecord object) {
  object.id = id;
}

extension BackupRecordQueryWhereSort
    on QueryBuilder<BackupRecord, BackupRecord, QWhere> {
  QueryBuilder<BackupRecord, BackupRecord, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension BackupRecordQueryWhere
    on QueryBuilder<BackupRecord, BackupRecord, QWhereClause> {
  QueryBuilder<BackupRecord, BackupRecord, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension BackupRecordQueryFilter
    on QueryBuilder<BackupRecord, BackupRecord, QFilterCondition> {
  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
      backupTypeEqualTo(
    BackupRecordType value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'backupType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
      backupTypeGreaterThan(
    BackupRecordType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'backupType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
      backupTypeLessThan(
    BackupRecordType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'backupType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
      backupTypeBetween(
    BackupRecordType lower,
    BackupRecordType upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'backupType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
      backupTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'backupType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
      backupTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'backupType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
      backupTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'backupType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
      backupTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'backupType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
      backupTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'backupType',
        value: '',
      ));
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
      backupTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'backupType',
        value: '',
      ));
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
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

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
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

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
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

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
      filePathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'filePath',
      ));
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
      filePathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'filePath',
      ));
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
      filePathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'filePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
      filePathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'filePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
      filePathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'filePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
      filePathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'filePath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
      filePathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'filePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
      filePathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'filePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
      filePathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'filePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
      filePathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'filePath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
      filePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'filePath',
        value: '',
      ));
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
      filePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'filePath',
        value: '',
      ));
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
      recordCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recordCount',
        value: value,
      ));
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
      recordCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'recordCount',
        value: value,
      ));
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
      recordCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'recordCount',
        value: value,
      ));
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
      recordCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'recordCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition> statusEqualTo(
    BackupRecordStatus value, {
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

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
      statusGreaterThan(
    BackupRecordStatus value, {
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

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
      statusLessThan(
    BackupRecordStatus value, {
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

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition> statusBetween(
    BackupRecordStatus lower,
    BackupRecordStatus upper, {
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

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
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

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
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

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
      statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition> statusMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
      statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
      statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }
}

extension BackupRecordQueryObject
    on QueryBuilder<BackupRecord, BackupRecord, QFilterCondition> {}

extension BackupRecordQueryLinks
    on QueryBuilder<BackupRecord, BackupRecord, QFilterCondition> {}

extension BackupRecordQuerySortBy
    on QueryBuilder<BackupRecord, BackupRecord, QSortBy> {
  QueryBuilder<BackupRecord, BackupRecord, QAfterSortBy> sortByBackupType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backupType', Sort.asc);
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterSortBy>
      sortByBackupTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backupType', Sort.desc);
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterSortBy> sortByFilePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filePath', Sort.asc);
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterSortBy> sortByFilePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filePath', Sort.desc);
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterSortBy> sortByRecordCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordCount', Sort.asc);
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterSortBy>
      sortByRecordCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordCount', Sort.desc);
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }
}

extension BackupRecordQuerySortThenBy
    on QueryBuilder<BackupRecord, BackupRecord, QSortThenBy> {
  QueryBuilder<BackupRecord, BackupRecord, QAfterSortBy> thenByBackupType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backupType', Sort.asc);
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterSortBy>
      thenByBackupTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backupType', Sort.desc);
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterSortBy> thenByFilePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filePath', Sort.asc);
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterSortBy> thenByFilePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filePath', Sort.desc);
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterSortBy> thenByRecordCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordCount', Sort.asc);
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterSortBy>
      thenByRecordCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordCount', Sort.desc);
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }
}

extension BackupRecordQueryWhereDistinct
    on QueryBuilder<BackupRecord, BackupRecord, QDistinct> {
  QueryBuilder<BackupRecord, BackupRecord, QDistinct> distinctByBackupType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'backupType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QDistinct> distinctByFilePath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'filePath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QDistinct> distinctByRecordCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recordCount');
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QDistinct> distinctByStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }
}

extension BackupRecordQueryProperty
    on QueryBuilder<BackupRecord, BackupRecord, QQueryProperty> {
  QueryBuilder<BackupRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<BackupRecord, BackupRecordType, QQueryOperations>
      backupTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'backupType');
    });
  }

  QueryBuilder<BackupRecord, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<BackupRecord, String?, QQueryOperations> filePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'filePath');
    });
  }

  QueryBuilder<BackupRecord, int, QQueryOperations> recordCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recordCount');
    });
  }

  QueryBuilder<BackupRecord, BackupRecordStatus, QQueryOperations>
      statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }
}
