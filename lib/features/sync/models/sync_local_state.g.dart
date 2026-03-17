// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_local_state.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSyncLocalStateCollection on Isar {
  IsarCollection<SyncLocalState> get syncLocalStates => this.collection();
}

const SyncLocalStateSchema = CollectionSchema(
  name: r'SyncLocalState',
  id: 5132879646491231100,
  properties: {
    r'bootstrapMessage': PropertySchema(
      id: 0,
      name: r'bootstrapMessage',
      type: IsarType.string,
    ),
    r'bootstrapPending': PropertySchema(
      id: 1,
      name: r'bootstrapPending',
      type: IsarType.bool,
    ),
    r'deviceId': PropertySchema(
      id: 2,
      name: r'deviceId',
      type: IsarType.string,
    ),
    r'lastPullAt': PropertySchema(
      id: 3,
      name: r'lastPullAt',
      type: IsarType.dateTime,
    ),
    r'lastSyncAt': PropertySchema(
      id: 4,
      name: r'lastSyncAt',
      type: IsarType.dateTime,
    ),
    r'lastSyncError': PropertySchema(
      id: 5,
      name: r'lastSyncError',
      type: IsarType.string,
    ),
    r'lastUserId': PropertySchema(
      id: 6,
      name: r'lastUserId',
      type: IsarType.string,
    )
  },
  estimateSize: _syncLocalStateEstimateSize,
  serialize: _syncLocalStateSerialize,
  deserialize: _syncLocalStateDeserialize,
  deserializeProp: _syncLocalStateDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _syncLocalStateGetId,
  getLinks: _syncLocalStateGetLinks,
  attach: _syncLocalStateAttach,
  version: '3.1.0+1',
);

int _syncLocalStateEstimateSize(
  SyncLocalState object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.bootstrapMessage;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.deviceId.length * 3;
  {
    final value = object.lastSyncError;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.lastUserId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _syncLocalStateSerialize(
  SyncLocalState object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.bootstrapMessage);
  writer.writeBool(offsets[1], object.bootstrapPending);
  writer.writeString(offsets[2], object.deviceId);
  writer.writeDateTime(offsets[3], object.lastPullAt);
  writer.writeDateTime(offsets[4], object.lastSyncAt);
  writer.writeString(offsets[5], object.lastSyncError);
  writer.writeString(offsets[6], object.lastUserId);
}

SyncLocalState _syncLocalStateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SyncLocalState(
    bootstrapMessage: reader.readStringOrNull(offsets[0]),
    bootstrapPending: reader.readBoolOrNull(offsets[1]) ?? false,
    deviceId: reader.readString(offsets[2]),
    id: id,
    lastPullAt: reader.readDateTimeOrNull(offsets[3]),
    lastSyncAt: reader.readDateTimeOrNull(offsets[4]),
    lastSyncError: reader.readStringOrNull(offsets[5]),
    lastUserId: reader.readStringOrNull(offsets[6]),
  );
  return object;
}

P _syncLocalStateDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _syncLocalStateGetId(SyncLocalState object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _syncLocalStateGetLinks(SyncLocalState object) {
  return [];
}

void _syncLocalStateAttach(
    IsarCollection<dynamic> col, Id id, SyncLocalState object) {
  object.id = id;
}

extension SyncLocalStateQueryWhereSort
    on QueryBuilder<SyncLocalState, SyncLocalState, QWhere> {
  QueryBuilder<SyncLocalState, SyncLocalState, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SyncLocalStateQueryWhere
    on QueryBuilder<SyncLocalState, SyncLocalState, QWhereClause> {
  QueryBuilder<SyncLocalState, SyncLocalState, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterWhereClause> idBetween(
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

extension SyncLocalStateQueryFilter
    on QueryBuilder<SyncLocalState, SyncLocalState, QFilterCondition> {
  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition>
      bootstrapMessageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'bootstrapMessage',
      ));
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition>
      bootstrapMessageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'bootstrapMessage',
      ));
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition>
      bootstrapMessageEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bootstrapMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition>
      bootstrapMessageGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bootstrapMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition>
      bootstrapMessageLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bootstrapMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition>
      bootstrapMessageBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bootstrapMessage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition>
      bootstrapMessageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'bootstrapMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition>
      bootstrapMessageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'bootstrapMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition>
      bootstrapMessageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'bootstrapMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition>
      bootstrapMessageMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'bootstrapMessage',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition>
      bootstrapMessageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bootstrapMessage',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition>
      bootstrapMessageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'bootstrapMessage',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition>
      bootstrapPendingEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bootstrapPending',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition>
      deviceIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition>
      deviceIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition>
      deviceIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition>
      deviceIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deviceId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition>
      deviceIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition>
      deviceIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition>
      deviceIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition>
      deviceIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'deviceId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition>
      deviceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition>
      deviceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'deviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition> idBetween(
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

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition>
      lastPullAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastPullAt',
      ));
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition>
      lastPullAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastPullAt',
      ));
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition>
      lastPullAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastPullAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition>
      lastPullAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastPullAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition>
      lastPullAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastPullAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition>
      lastPullAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastPullAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition>
      lastSyncAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastSyncAt',
      ));
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition>
      lastSyncAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastSyncAt',
      ));
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition>
      lastSyncAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSyncAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition>
      lastSyncAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastSyncAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition>
      lastSyncAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastSyncAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition>
      lastSyncAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastSyncAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition>
      lastSyncErrorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastSyncError',
      ));
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition>
      lastSyncErrorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastSyncError',
      ));
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition>
      lastSyncErrorEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSyncError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition>
      lastSyncErrorGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastSyncError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition>
      lastSyncErrorLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastSyncError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition>
      lastSyncErrorBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastSyncError',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition>
      lastSyncErrorStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lastSyncError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition>
      lastSyncErrorEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lastSyncError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition>
      lastSyncErrorContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastSyncError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition>
      lastSyncErrorMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastSyncError',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition>
      lastSyncErrorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSyncError',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition>
      lastSyncErrorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastSyncError',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition>
      lastUserIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastUserId',
      ));
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition>
      lastUserIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastUserId',
      ));
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition>
      lastUserIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition>
      lastUserIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition>
      lastUserIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition>
      lastUserIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastUserId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition>
      lastUserIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lastUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition>
      lastUserIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lastUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition>
      lastUserIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition>
      lastUserIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastUserId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition>
      lastUserIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUserId',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterFilterCondition>
      lastUserIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastUserId',
        value: '',
      ));
    });
  }
}

extension SyncLocalStateQueryObject
    on QueryBuilder<SyncLocalState, SyncLocalState, QFilterCondition> {}

extension SyncLocalStateQueryLinks
    on QueryBuilder<SyncLocalState, SyncLocalState, QFilterCondition> {}

extension SyncLocalStateQuerySortBy
    on QueryBuilder<SyncLocalState, SyncLocalState, QSortBy> {
  QueryBuilder<SyncLocalState, SyncLocalState, QAfterSortBy>
      sortByBootstrapMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bootstrapMessage', Sort.asc);
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterSortBy>
      sortByBootstrapMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bootstrapMessage', Sort.desc);
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterSortBy>
      sortByBootstrapPending() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bootstrapPending', Sort.asc);
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterSortBy>
      sortByBootstrapPendingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bootstrapPending', Sort.desc);
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterSortBy> sortByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterSortBy>
      sortByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterSortBy>
      sortByLastPullAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPullAt', Sort.asc);
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterSortBy>
      sortByLastPullAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPullAt', Sort.desc);
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterSortBy>
      sortByLastSyncAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncAt', Sort.asc);
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterSortBy>
      sortByLastSyncAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncAt', Sort.desc);
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterSortBy>
      sortByLastSyncError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncError', Sort.asc);
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterSortBy>
      sortByLastSyncErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncError', Sort.desc);
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterSortBy>
      sortByLastUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUserId', Sort.asc);
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterSortBy>
      sortByLastUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUserId', Sort.desc);
    });
  }
}

extension SyncLocalStateQuerySortThenBy
    on QueryBuilder<SyncLocalState, SyncLocalState, QSortThenBy> {
  QueryBuilder<SyncLocalState, SyncLocalState, QAfterSortBy>
      thenByBootstrapMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bootstrapMessage', Sort.asc);
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterSortBy>
      thenByBootstrapMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bootstrapMessage', Sort.desc);
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterSortBy>
      thenByBootstrapPending() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bootstrapPending', Sort.asc);
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterSortBy>
      thenByBootstrapPendingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bootstrapPending', Sort.desc);
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterSortBy> thenByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterSortBy>
      thenByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterSortBy>
      thenByLastPullAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPullAt', Sort.asc);
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterSortBy>
      thenByLastPullAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPullAt', Sort.desc);
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterSortBy>
      thenByLastSyncAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncAt', Sort.asc);
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterSortBy>
      thenByLastSyncAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncAt', Sort.desc);
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterSortBy>
      thenByLastSyncError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncError', Sort.asc);
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterSortBy>
      thenByLastSyncErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncError', Sort.desc);
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterSortBy>
      thenByLastUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUserId', Sort.asc);
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QAfterSortBy>
      thenByLastUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUserId', Sort.desc);
    });
  }
}

extension SyncLocalStateQueryWhereDistinct
    on QueryBuilder<SyncLocalState, SyncLocalState, QDistinct> {
  QueryBuilder<SyncLocalState, SyncLocalState, QDistinct>
      distinctByBootstrapMessage({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bootstrapMessage',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QDistinct>
      distinctByBootstrapPending() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bootstrapPending');
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QDistinct> distinctByDeviceId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deviceId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QDistinct>
      distinctByLastPullAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastPullAt');
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QDistinct>
      distinctByLastSyncAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSyncAt');
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QDistinct>
      distinctByLastSyncError({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSyncError',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncLocalState, SyncLocalState, QDistinct> distinctByLastUserId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUserId', caseSensitive: caseSensitive);
    });
  }
}

extension SyncLocalStateQueryProperty
    on QueryBuilder<SyncLocalState, SyncLocalState, QQueryProperty> {
  QueryBuilder<SyncLocalState, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SyncLocalState, String?, QQueryOperations>
      bootstrapMessageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bootstrapMessage');
    });
  }

  QueryBuilder<SyncLocalState, bool, QQueryOperations>
      bootstrapPendingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bootstrapPending');
    });
  }

  QueryBuilder<SyncLocalState, String, QQueryOperations> deviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deviceId');
    });
  }

  QueryBuilder<SyncLocalState, DateTime?, QQueryOperations>
      lastPullAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastPullAt');
    });
  }

  QueryBuilder<SyncLocalState, DateTime?, QQueryOperations>
      lastSyncAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSyncAt');
    });
  }

  QueryBuilder<SyncLocalState, String?, QQueryOperations>
      lastSyncErrorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSyncError');
    });
  }

  QueryBuilder<SyncLocalState, String?, QQueryOperations> lastUserIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUserId');
    });
  }
}
