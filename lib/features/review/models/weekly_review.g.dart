// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weekly_review.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetWeeklyReviewCollection on Isar {
  IsarCollection<WeeklyReview> get weeklyReviews => this.collection();
}

const WeeklyReviewSchema = CollectionSchema(
  name: r'WeeklyReview',
  id: 1740939263748820166,
  properties: {
    r'challengesText': PropertySchema(
      id: 0,
      name: r'challengesText',
      type: IsarType.string,
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
    r'isLocked': PropertySchema(
      id: 3,
      name: r'isLocked',
      type: IsarType.bool,
    ),
    r'nextWeekFocusText': PropertySchema(
      id: 4,
      name: r'nextWeekFocusText',
      type: IsarType.string,
    ),
    r'summaryText': PropertySchema(
      id: 5,
      name: r'summaryText',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 6,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'weekEnd': PropertySchema(
      id: 7,
      name: r'weekEnd',
      type: IsarType.dateTime,
    ),
    r'weekStart': PropertySchema(
      id: 8,
      name: r'weekStart',
      type: IsarType.dateTime,
    ),
    r'winsText': PropertySchema(
      id: 9,
      name: r'winsText',
      type: IsarType.string,
    )
  },
  estimateSize: _weeklyReviewEstimateSize,
  serialize: _weeklyReviewSerialize,
  deserialize: _weeklyReviewDeserialize,
  deserializeProp: _weeklyReviewDeserializeProp,
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
    r'weekStart': IndexSchema(
      id: 6730028936290595099,
      name: r'weekStart',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'weekStart',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _weeklyReviewGetId,
  getLinks: _weeklyReviewGetLinks,
  attach: _weeklyReviewAttach,
  version: '3.1.0+1',
);

int _weeklyReviewEstimateSize(
  WeeklyReview object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.challengesText;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.id.length * 3;
  {
    final value = object.nextWeekFocusText;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.summaryText;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.winsText;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _weeklyReviewSerialize(
  WeeklyReview object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.challengesText);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeString(offsets[2], object.id);
  writer.writeBool(offsets[3], object.isLocked);
  writer.writeString(offsets[4], object.nextWeekFocusText);
  writer.writeString(offsets[5], object.summaryText);
  writer.writeDateTime(offsets[6], object.updatedAt);
  writer.writeDateTime(offsets[7], object.weekEnd);
  writer.writeDateTime(offsets[8], object.weekStart);
  writer.writeString(offsets[9], object.winsText);
}

WeeklyReview _weeklyReviewDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = WeeklyReview(
    challengesText: reader.readStringOrNull(offsets[0]),
    createdAt: reader.readDateTime(offsets[1]),
    id: reader.readString(offsets[2]),
    isLocked: reader.readBoolOrNull(offsets[3]) ?? false,
    nextWeekFocusText: reader.readStringOrNull(offsets[4]),
    summaryText: reader.readStringOrNull(offsets[5]),
    updatedAt: reader.readDateTimeOrNull(offsets[6]),
    weekEnd: reader.readDateTime(offsets[7]),
    weekStart: reader.readDateTime(offsets[8]),
    winsText: reader.readStringOrNull(offsets[9]),
  );
  object.isarId = id;
  return object;
}

P _weeklyReviewDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _weeklyReviewGetId(WeeklyReview object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _weeklyReviewGetLinks(WeeklyReview object) {
  return [];
}

void _weeklyReviewAttach(
    IsarCollection<dynamic> col, Id id, WeeklyReview object) {
  object.isarId = id;
}

extension WeeklyReviewByIndex on IsarCollection<WeeklyReview> {
  Future<WeeklyReview?> getById(String id) {
    return getByIndex(r'id', [id]);
  }

  WeeklyReview? getByIdSync(String id) {
    return getByIndexSync(r'id', [id]);
  }

  Future<bool> deleteById(String id) {
    return deleteByIndex(r'id', [id]);
  }

  bool deleteByIdSync(String id) {
    return deleteByIndexSync(r'id', [id]);
  }

  Future<List<WeeklyReview?>> getAllById(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndex(r'id', values);
  }

  List<WeeklyReview?> getAllByIdSync(List<String> idValues) {
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

  Future<Id> putById(WeeklyReview object) {
    return putByIndex(r'id', object);
  }

  Id putByIdSync(WeeklyReview object, {bool saveLinks = true}) {
    return putByIndexSync(r'id', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllById(List<WeeklyReview> objects) {
    return putAllByIndex(r'id', objects);
  }

  List<Id> putAllByIdSync(List<WeeklyReview> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'id', objects, saveLinks: saveLinks);
  }

  Future<WeeklyReview?> getByWeekStart(DateTime weekStart) {
    return getByIndex(r'weekStart', [weekStart]);
  }

  WeeklyReview? getByWeekStartSync(DateTime weekStart) {
    return getByIndexSync(r'weekStart', [weekStart]);
  }

  Future<bool> deleteByWeekStart(DateTime weekStart) {
    return deleteByIndex(r'weekStart', [weekStart]);
  }

  bool deleteByWeekStartSync(DateTime weekStart) {
    return deleteByIndexSync(r'weekStart', [weekStart]);
  }

  Future<List<WeeklyReview?>> getAllByWeekStart(
      List<DateTime> weekStartValues) {
    final values = weekStartValues.map((e) => [e]).toList();
    return getAllByIndex(r'weekStart', values);
  }

  List<WeeklyReview?> getAllByWeekStartSync(List<DateTime> weekStartValues) {
    final values = weekStartValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'weekStart', values);
  }

  Future<int> deleteAllByWeekStart(List<DateTime> weekStartValues) {
    final values = weekStartValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'weekStart', values);
  }

  int deleteAllByWeekStartSync(List<DateTime> weekStartValues) {
    final values = weekStartValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'weekStart', values);
  }

  Future<Id> putByWeekStart(WeeklyReview object) {
    return putByIndex(r'weekStart', object);
  }

  Id putByWeekStartSync(WeeklyReview object, {bool saveLinks = true}) {
    return putByIndexSync(r'weekStart', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByWeekStart(List<WeeklyReview> objects) {
    return putAllByIndex(r'weekStart', objects);
  }

  List<Id> putAllByWeekStartSync(List<WeeklyReview> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'weekStart', objects, saveLinks: saveLinks);
  }
}

extension WeeklyReviewQueryWhereSort
    on QueryBuilder<WeeklyReview, WeeklyReview, QWhere> {
  QueryBuilder<WeeklyReview, WeeklyReview, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterWhere> anyWeekStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'weekStart'),
      );
    });
  }
}

extension WeeklyReviewQueryWhere
    on QueryBuilder<WeeklyReview, WeeklyReview, QWhereClause> {
  QueryBuilder<WeeklyReview, WeeklyReview, QAfterWhereClause> isarIdEqualTo(
      Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterWhereClause> isarIdNotEqualTo(
      Id isarId) {
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

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterWhereClause> isarIdGreaterThan(
      Id isarId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterWhereClause> isarIdLessThan(
      Id isarId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterWhereClause> isarIdBetween(
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

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterWhereClause> idEqualTo(
      String id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'id',
        value: [id],
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterWhereClause> weekStartEqualTo(
      DateTime weekStart) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'weekStart',
        value: [weekStart],
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterWhereClause>
      weekStartNotEqualTo(DateTime weekStart) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'weekStart',
              lower: [],
              upper: [weekStart],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'weekStart',
              lower: [weekStart],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'weekStart',
              lower: [weekStart],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'weekStart',
              lower: [],
              upper: [weekStart],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterWhereClause>
      weekStartGreaterThan(
    DateTime weekStart, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'weekStart',
        lower: [weekStart],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterWhereClause> weekStartLessThan(
    DateTime weekStart, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'weekStart',
        lower: [],
        upper: [weekStart],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterWhereClause> weekStartBetween(
    DateTime lowerWeekStart,
    DateTime upperWeekStart, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'weekStart',
        lower: [lowerWeekStart],
        includeLower: includeLower,
        upper: [upperWeekStart],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension WeeklyReviewQueryFilter
    on QueryBuilder<WeeklyReview, WeeklyReview, QFilterCondition> {
  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      challengesTextIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'challengesText',
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      challengesTextIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'challengesText',
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      challengesTextEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'challengesText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      challengesTextGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'challengesText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      challengesTextLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'challengesText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      challengesTextBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'challengesText',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      challengesTextStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'challengesText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      challengesTextEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'challengesText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      challengesTextContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'challengesText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      challengesTextMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'challengesText',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      challengesTextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'challengesText',
        value: '',
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      challengesTextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'challengesText',
        value: '',
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
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

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
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

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
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

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition> idEqualTo(
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

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition> idBetween(
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

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition> idStartsWith(
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

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition> idEndsWith(
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

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition> idContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition> idMatches(
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

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition> idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      isLockedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isLocked',
        value: value,
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition> isarIdEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
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

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
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

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition> isarIdBetween(
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

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      nextWeekFocusTextIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'nextWeekFocusText',
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      nextWeekFocusTextIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'nextWeekFocusText',
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      nextWeekFocusTextEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nextWeekFocusText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      nextWeekFocusTextGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nextWeekFocusText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      nextWeekFocusTextLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nextWeekFocusText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      nextWeekFocusTextBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nextWeekFocusText',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      nextWeekFocusTextStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'nextWeekFocusText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      nextWeekFocusTextEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'nextWeekFocusText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      nextWeekFocusTextContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nextWeekFocusText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      nextWeekFocusTextMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nextWeekFocusText',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      nextWeekFocusTextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nextWeekFocusText',
        value: '',
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      nextWeekFocusTextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nextWeekFocusText',
        value: '',
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      summaryTextIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'summaryText',
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      summaryTextIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'summaryText',
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      summaryTextEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'summaryText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      summaryTextGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'summaryText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      summaryTextLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'summaryText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      summaryTextBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'summaryText',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      summaryTextStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'summaryText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      summaryTextEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'summaryText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      summaryTextContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'summaryText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      summaryTextMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'summaryText',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      summaryTextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'summaryText',
        value: '',
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      summaryTextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'summaryText',
        value: '',
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      updatedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
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

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
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

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
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

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      weekEndEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weekEnd',
        value: value,
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      weekEndGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'weekEnd',
        value: value,
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      weekEndLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'weekEnd',
        value: value,
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      weekEndBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'weekEnd',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      weekStartEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weekStart',
        value: value,
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      weekStartGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'weekStart',
        value: value,
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      weekStartLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'weekStart',
        value: value,
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      weekStartBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'weekStart',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      winsTextIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'winsText',
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      winsTextIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'winsText',
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      winsTextEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'winsText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      winsTextGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'winsText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      winsTextLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'winsText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      winsTextBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'winsText',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      winsTextStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'winsText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      winsTextEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'winsText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      winsTextContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'winsText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      winsTextMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'winsText',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      winsTextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'winsText',
        value: '',
      ));
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterFilterCondition>
      winsTextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'winsText',
        value: '',
      ));
    });
  }
}

extension WeeklyReviewQueryObject
    on QueryBuilder<WeeklyReview, WeeklyReview, QFilterCondition> {}

extension WeeklyReviewQueryLinks
    on QueryBuilder<WeeklyReview, WeeklyReview, QFilterCondition> {}

extension WeeklyReviewQuerySortBy
    on QueryBuilder<WeeklyReview, WeeklyReview, QSortBy> {
  QueryBuilder<WeeklyReview, WeeklyReview, QAfterSortBy>
      sortByChallengesText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'challengesText', Sort.asc);
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterSortBy>
      sortByChallengesTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'challengesText', Sort.desc);
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterSortBy> sortByIsLocked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLocked', Sort.asc);
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterSortBy> sortByIsLockedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLocked', Sort.desc);
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterSortBy>
      sortByNextWeekFocusText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextWeekFocusText', Sort.asc);
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterSortBy>
      sortByNextWeekFocusTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextWeekFocusText', Sort.desc);
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterSortBy> sortBySummaryText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'summaryText', Sort.asc);
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterSortBy>
      sortBySummaryTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'summaryText', Sort.desc);
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterSortBy> sortByWeekEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weekEnd', Sort.asc);
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterSortBy> sortByWeekEndDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weekEnd', Sort.desc);
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterSortBy> sortByWeekStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weekStart', Sort.asc);
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterSortBy> sortByWeekStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weekStart', Sort.desc);
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterSortBy> sortByWinsText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'winsText', Sort.asc);
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterSortBy> sortByWinsTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'winsText', Sort.desc);
    });
  }
}

extension WeeklyReviewQuerySortThenBy
    on QueryBuilder<WeeklyReview, WeeklyReview, QSortThenBy> {
  QueryBuilder<WeeklyReview, WeeklyReview, QAfterSortBy>
      thenByChallengesText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'challengesText', Sort.asc);
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterSortBy>
      thenByChallengesTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'challengesText', Sort.desc);
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterSortBy> thenByIsLocked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLocked', Sort.asc);
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterSortBy> thenByIsLockedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLocked', Sort.desc);
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterSortBy> thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterSortBy>
      thenByNextWeekFocusText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextWeekFocusText', Sort.asc);
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterSortBy>
      thenByNextWeekFocusTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextWeekFocusText', Sort.desc);
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterSortBy> thenBySummaryText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'summaryText', Sort.asc);
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterSortBy>
      thenBySummaryTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'summaryText', Sort.desc);
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterSortBy> thenByWeekEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weekEnd', Sort.asc);
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterSortBy> thenByWeekEndDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weekEnd', Sort.desc);
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterSortBy> thenByWeekStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weekStart', Sort.asc);
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterSortBy> thenByWeekStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weekStart', Sort.desc);
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterSortBy> thenByWinsText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'winsText', Sort.asc);
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QAfterSortBy> thenByWinsTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'winsText', Sort.desc);
    });
  }
}

extension WeeklyReviewQueryWhereDistinct
    on QueryBuilder<WeeklyReview, WeeklyReview, QDistinct> {
  QueryBuilder<WeeklyReview, WeeklyReview, QDistinct> distinctByChallengesText(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'challengesText',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QDistinct> distinctById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QDistinct> distinctByIsLocked() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isLocked');
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QDistinct>
      distinctByNextWeekFocusText({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nextWeekFocusText',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QDistinct> distinctBySummaryText(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'summaryText', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QDistinct> distinctByWeekEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weekEnd');
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QDistinct> distinctByWeekStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weekStart');
    });
  }

  QueryBuilder<WeeklyReview, WeeklyReview, QDistinct> distinctByWinsText(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'winsText', caseSensitive: caseSensitive);
    });
  }
}

extension WeeklyReviewQueryProperty
    on QueryBuilder<WeeklyReview, WeeklyReview, QQueryProperty> {
  QueryBuilder<WeeklyReview, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<WeeklyReview, String?, QQueryOperations>
      challengesTextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'challengesText');
    });
  }

  QueryBuilder<WeeklyReview, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<WeeklyReview, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<WeeklyReview, bool, QQueryOperations> isLockedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isLocked');
    });
  }

  QueryBuilder<WeeklyReview, String?, QQueryOperations>
      nextWeekFocusTextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nextWeekFocusText');
    });
  }

  QueryBuilder<WeeklyReview, String?, QQueryOperations> summaryTextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'summaryText');
    });
  }

  QueryBuilder<WeeklyReview, DateTime?, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<WeeklyReview, DateTime, QQueryOperations> weekEndProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weekEnd');
    });
  }

  QueryBuilder<WeeklyReview, DateTime, QQueryOperations> weekStartProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weekStart');
    });
  }

  QueryBuilder<WeeklyReview, String?, QQueryOperations> winsTextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'winsText');
    });
  }
}
