// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_state.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetOnboardingStateRecordCollection on Isar {
  IsarCollection<OnboardingStateRecord> get onboardingStateRecords =>
      this.collection();
}

const OnboardingStateRecordSchema = CollectionSchema(
  name: r'OnboardingStateRecord',
  id: -2435717051148747945,
  properties: {
    r'completedAt': PropertySchema(
      id: 0,
      name: r'completedAt',
      type: IsarType.dateTime,
    ),
    r'hasBeenSeen': PropertySchema(
      id: 1,
      name: r'hasBeenSeen',
      type: IsarType.bool,
    ),
    r'isCompleted': PropertySchema(
      id: 2,
      name: r'isCompleted',
      type: IsarType.bool,
    ),
    r'lastViewedAt': PropertySchema(
      id: 3,
      name: r'lastViewedAt',
      type: IsarType.dateTime,
    ),
    r'skippedAt': PropertySchema(
      id: 4,
      name: r'skippedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _onboardingStateRecordEstimateSize,
  serialize: _onboardingStateRecordSerialize,
  deserialize: _onboardingStateRecordDeserialize,
  deserializeProp: _onboardingStateRecordDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _onboardingStateRecordGetId,
  getLinks: _onboardingStateRecordGetLinks,
  attach: _onboardingStateRecordAttach,
  version: '3.1.0+1',
);

int _onboardingStateRecordEstimateSize(
  OnboardingStateRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _onboardingStateRecordSerialize(
  OnboardingStateRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.completedAt);
  writer.writeBool(offsets[1], object.hasBeenSeen);
  writer.writeBool(offsets[2], object.isCompleted);
  writer.writeDateTime(offsets[3], object.lastViewedAt);
  writer.writeDateTime(offsets[4], object.skippedAt);
}

OnboardingStateRecord _onboardingStateRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = OnboardingStateRecord(
    completedAt: reader.readDateTimeOrNull(offsets[0]),
    hasBeenSeen: reader.readBoolOrNull(offsets[1]) ?? false,
    id: id,
    isCompleted: reader.readBoolOrNull(offsets[2]) ?? false,
    lastViewedAt: reader.readDateTimeOrNull(offsets[3]),
    skippedAt: reader.readDateTimeOrNull(offsets[4]),
  );
  return object;
}

P _onboardingStateRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 2:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _onboardingStateRecordGetId(OnboardingStateRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _onboardingStateRecordGetLinks(
    OnboardingStateRecord object) {
  return [];
}

void _onboardingStateRecordAttach(
    IsarCollection<dynamic> col, Id id, OnboardingStateRecord object) {
  object.id = id;
}

extension OnboardingStateRecordQueryWhereSort
    on QueryBuilder<OnboardingStateRecord, OnboardingStateRecord, QWhere> {
  QueryBuilder<OnboardingStateRecord, OnboardingStateRecord, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension OnboardingStateRecordQueryWhere on QueryBuilder<OnboardingStateRecord,
    OnboardingStateRecord, QWhereClause> {
  QueryBuilder<OnboardingStateRecord, OnboardingStateRecord, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<OnboardingStateRecord, OnboardingStateRecord, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<OnboardingStateRecord, OnboardingStateRecord, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<OnboardingStateRecord, OnboardingStateRecord, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<OnboardingStateRecord, OnboardingStateRecord, QAfterWhereClause>
      idBetween(
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

extension OnboardingStateRecordQueryFilter on QueryBuilder<
    OnboardingStateRecord, OnboardingStateRecord, QFilterCondition> {
  QueryBuilder<OnboardingStateRecord, OnboardingStateRecord,
      QAfterFilterCondition> completedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'completedAt',
      ));
    });
  }

  QueryBuilder<OnboardingStateRecord, OnboardingStateRecord,
      QAfterFilterCondition> completedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'completedAt',
      ));
    });
  }

  QueryBuilder<OnboardingStateRecord, OnboardingStateRecord,
      QAfterFilterCondition> completedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<OnboardingStateRecord, OnboardingStateRecord,
      QAfterFilterCondition> completedAtGreaterThan(
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

  QueryBuilder<OnboardingStateRecord, OnboardingStateRecord,
      QAfterFilterCondition> completedAtLessThan(
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

  QueryBuilder<OnboardingStateRecord, OnboardingStateRecord,
      QAfterFilterCondition> completedAtBetween(
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

  QueryBuilder<OnboardingStateRecord, OnboardingStateRecord,
      QAfterFilterCondition> hasBeenSeenEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hasBeenSeen',
        value: value,
      ));
    });
  }

  QueryBuilder<OnboardingStateRecord, OnboardingStateRecord,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<OnboardingStateRecord, OnboardingStateRecord,
      QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<OnboardingStateRecord, OnboardingStateRecord,
      QAfterFilterCondition> idLessThan(
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

  QueryBuilder<OnboardingStateRecord, OnboardingStateRecord,
      QAfterFilterCondition> idBetween(
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

  QueryBuilder<OnboardingStateRecord, OnboardingStateRecord,
      QAfterFilterCondition> isCompletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isCompleted',
        value: value,
      ));
    });
  }

  QueryBuilder<OnboardingStateRecord, OnboardingStateRecord,
      QAfterFilterCondition> lastViewedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastViewedAt',
      ));
    });
  }

  QueryBuilder<OnboardingStateRecord, OnboardingStateRecord,
      QAfterFilterCondition> lastViewedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastViewedAt',
      ));
    });
  }

  QueryBuilder<OnboardingStateRecord, OnboardingStateRecord,
      QAfterFilterCondition> lastViewedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastViewedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<OnboardingStateRecord, OnboardingStateRecord,
      QAfterFilterCondition> lastViewedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastViewedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<OnboardingStateRecord, OnboardingStateRecord,
      QAfterFilterCondition> lastViewedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastViewedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<OnboardingStateRecord, OnboardingStateRecord,
      QAfterFilterCondition> lastViewedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastViewedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<OnboardingStateRecord, OnboardingStateRecord,
      QAfterFilterCondition> skippedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'skippedAt',
      ));
    });
  }

  QueryBuilder<OnboardingStateRecord, OnboardingStateRecord,
      QAfterFilterCondition> skippedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'skippedAt',
      ));
    });
  }

  QueryBuilder<OnboardingStateRecord, OnboardingStateRecord,
      QAfterFilterCondition> skippedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'skippedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<OnboardingStateRecord, OnboardingStateRecord,
      QAfterFilterCondition> skippedAtGreaterThan(
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

  QueryBuilder<OnboardingStateRecord, OnboardingStateRecord,
      QAfterFilterCondition> skippedAtLessThan(
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

  QueryBuilder<OnboardingStateRecord, OnboardingStateRecord,
      QAfterFilterCondition> skippedAtBetween(
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
}

extension OnboardingStateRecordQueryObject on QueryBuilder<
    OnboardingStateRecord, OnboardingStateRecord, QFilterCondition> {}

extension OnboardingStateRecordQueryLinks on QueryBuilder<OnboardingStateRecord,
    OnboardingStateRecord, QFilterCondition> {}

extension OnboardingStateRecordQuerySortBy
    on QueryBuilder<OnboardingStateRecord, OnboardingStateRecord, QSortBy> {
  QueryBuilder<OnboardingStateRecord, OnboardingStateRecord, QAfterSortBy>
      sortByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<OnboardingStateRecord, OnboardingStateRecord, QAfterSortBy>
      sortByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }

  QueryBuilder<OnboardingStateRecord, OnboardingStateRecord, QAfterSortBy>
      sortByHasBeenSeen() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasBeenSeen', Sort.asc);
    });
  }

  QueryBuilder<OnboardingStateRecord, OnboardingStateRecord, QAfterSortBy>
      sortByHasBeenSeenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasBeenSeen', Sort.desc);
    });
  }

  QueryBuilder<OnboardingStateRecord, OnboardingStateRecord, QAfterSortBy>
      sortByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.asc);
    });
  }

  QueryBuilder<OnboardingStateRecord, OnboardingStateRecord, QAfterSortBy>
      sortByIsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.desc);
    });
  }

  QueryBuilder<OnboardingStateRecord, OnboardingStateRecord, QAfterSortBy>
      sortByLastViewedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastViewedAt', Sort.asc);
    });
  }

  QueryBuilder<OnboardingStateRecord, OnboardingStateRecord, QAfterSortBy>
      sortByLastViewedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastViewedAt', Sort.desc);
    });
  }

  QueryBuilder<OnboardingStateRecord, OnboardingStateRecord, QAfterSortBy>
      sortBySkippedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skippedAt', Sort.asc);
    });
  }

  QueryBuilder<OnboardingStateRecord, OnboardingStateRecord, QAfterSortBy>
      sortBySkippedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skippedAt', Sort.desc);
    });
  }
}

extension OnboardingStateRecordQuerySortThenBy
    on QueryBuilder<OnboardingStateRecord, OnboardingStateRecord, QSortThenBy> {
  QueryBuilder<OnboardingStateRecord, OnboardingStateRecord, QAfterSortBy>
      thenByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<OnboardingStateRecord, OnboardingStateRecord, QAfterSortBy>
      thenByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }

  QueryBuilder<OnboardingStateRecord, OnboardingStateRecord, QAfterSortBy>
      thenByHasBeenSeen() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasBeenSeen', Sort.asc);
    });
  }

  QueryBuilder<OnboardingStateRecord, OnboardingStateRecord, QAfterSortBy>
      thenByHasBeenSeenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasBeenSeen', Sort.desc);
    });
  }

  QueryBuilder<OnboardingStateRecord, OnboardingStateRecord, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<OnboardingStateRecord, OnboardingStateRecord, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<OnboardingStateRecord, OnboardingStateRecord, QAfterSortBy>
      thenByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.asc);
    });
  }

  QueryBuilder<OnboardingStateRecord, OnboardingStateRecord, QAfterSortBy>
      thenByIsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.desc);
    });
  }

  QueryBuilder<OnboardingStateRecord, OnboardingStateRecord, QAfterSortBy>
      thenByLastViewedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastViewedAt', Sort.asc);
    });
  }

  QueryBuilder<OnboardingStateRecord, OnboardingStateRecord, QAfterSortBy>
      thenByLastViewedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastViewedAt', Sort.desc);
    });
  }

  QueryBuilder<OnboardingStateRecord, OnboardingStateRecord, QAfterSortBy>
      thenBySkippedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skippedAt', Sort.asc);
    });
  }

  QueryBuilder<OnboardingStateRecord, OnboardingStateRecord, QAfterSortBy>
      thenBySkippedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skippedAt', Sort.desc);
    });
  }
}

extension OnboardingStateRecordQueryWhereDistinct
    on QueryBuilder<OnboardingStateRecord, OnboardingStateRecord, QDistinct> {
  QueryBuilder<OnboardingStateRecord, OnboardingStateRecord, QDistinct>
      distinctByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completedAt');
    });
  }

  QueryBuilder<OnboardingStateRecord, OnboardingStateRecord, QDistinct>
      distinctByHasBeenSeen() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasBeenSeen');
    });
  }

  QueryBuilder<OnboardingStateRecord, OnboardingStateRecord, QDistinct>
      distinctByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isCompleted');
    });
  }

  QueryBuilder<OnboardingStateRecord, OnboardingStateRecord, QDistinct>
      distinctByLastViewedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastViewedAt');
    });
  }

  QueryBuilder<OnboardingStateRecord, OnboardingStateRecord, QDistinct>
      distinctBySkippedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'skippedAt');
    });
  }
}

extension OnboardingStateRecordQueryProperty on QueryBuilder<
    OnboardingStateRecord, OnboardingStateRecord, QQueryProperty> {
  QueryBuilder<OnboardingStateRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<OnboardingStateRecord, DateTime?, QQueryOperations>
      completedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completedAt');
    });
  }

  QueryBuilder<OnboardingStateRecord, bool, QQueryOperations>
      hasBeenSeenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasBeenSeen');
    });
  }

  QueryBuilder<OnboardingStateRecord, bool, QQueryOperations>
      isCompletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isCompleted');
    });
  }

  QueryBuilder<OnboardingStateRecord, DateTime?, QQueryOperations>
      lastViewedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastViewedAt');
    });
  }

  QueryBuilder<OnboardingStateRecord, DateTime?, QQueryOperations>
      skippedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'skippedAt');
    });
  }
}
