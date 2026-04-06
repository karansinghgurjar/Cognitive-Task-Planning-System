// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quick_capture_item.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetQuickCaptureItemCollection on Isar {
  IsarCollection<QuickCaptureItem> get quickCaptureItems => this.collection();
}

const QuickCaptureItemSchema = CollectionSchema(
  name: r'QuickCaptureItem',
  id: -6602267377194712760,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'id': PropertySchema(
      id: 1,
      name: r'id',
      type: IsarType.string,
    ),
    r'isArchived': PropertySchema(
      id: 2,
      name: r'isArchived',
      type: IsarType.bool,
    ),
    r'isProcessed': PropertySchema(
      id: 3,
      name: r'isProcessed',
      type: IsarType.bool,
    ),
    r'linkedEntityId': PropertySchema(
      id: 4,
      name: r'linkedEntityId',
      type: IsarType.string,
    ),
    r'processedAt': PropertySchema(
      id: 5,
      name: r'processedAt',
      type: IsarType.dateTime,
    ),
    r'processedEntityType': PropertySchema(
      id: 6,
      name: r'processedEntityType',
      type: IsarType.string,
      enumMap: _QuickCaptureItemprocessedEntityTypeEnumValueMap,
    ),
    r'rawText': PropertySchema(
      id: 7,
      name: r'rawText',
      type: IsarType.string,
    ),
    r'suggestedType': PropertySchema(
      id: 8,
      name: r'suggestedType',
      type: IsarType.string,
      enumMap: _QuickCaptureItemsuggestedTypeEnumValueMap,
    ),
    r'updatedAt': PropertySchema(
      id: 9,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _quickCaptureItemEstimateSize,
  serialize: _quickCaptureItemSerialize,
  deserialize: _quickCaptureItemDeserialize,
  deserializeProp: _quickCaptureItemDeserializeProp,
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
  getId: _quickCaptureItemGetId,
  getLinks: _quickCaptureItemGetLinks,
  attach: _quickCaptureItemAttach,
  version: '3.1.0+1',
);

int _quickCaptureItemEstimateSize(
  QuickCaptureItem object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.id.length * 3;
  {
    final value = object.linkedEntityId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.processedEntityType;
    if (value != null) {
      bytesCount += 3 + value.name.length * 3;
    }
  }
  bytesCount += 3 + object.rawText.length * 3;
  bytesCount += 3 + object.suggestedType.name.length * 3;
  return bytesCount;
}

void _quickCaptureItemSerialize(
  QuickCaptureItem object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeString(offsets[1], object.id);
  writer.writeBool(offsets[2], object.isArchived);
  writer.writeBool(offsets[3], object.isProcessed);
  writer.writeString(offsets[4], object.linkedEntityId);
  writer.writeDateTime(offsets[5], object.processedAt);
  writer.writeString(offsets[6], object.processedEntityType?.name);
  writer.writeString(offsets[7], object.rawText);
  writer.writeString(offsets[8], object.suggestedType.name);
  writer.writeDateTime(offsets[9], object.updatedAt);
}

QuickCaptureItem _quickCaptureItemDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = QuickCaptureItem(
    createdAt: reader.readDateTime(offsets[0]),
    id: reader.readString(offsets[1]),
    isArchived: reader.readBoolOrNull(offsets[2]) ?? false,
    isProcessed: reader.readBoolOrNull(offsets[3]) ?? false,
    linkedEntityId: reader.readStringOrNull(offsets[4]),
    processedAt: reader.readDateTimeOrNull(offsets[5]),
    processedEntityType: _QuickCaptureItemprocessedEntityTypeValueEnumMap[
        reader.readStringOrNull(offsets[6])],
    rawText: reader.readString(offsets[7]),
    suggestedType: _QuickCaptureItemsuggestedTypeValueEnumMap[
            reader.readStringOrNull(offsets[8])] ??
        QuickCaptureSuggestedType.unknown,
    updatedAt: reader.readDateTimeOrNull(offsets[9]),
  );
  object.isarId = id;
  return object;
}

P _quickCaptureItemDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 3:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (_QuickCaptureItemprocessedEntityTypeValueEnumMap[
          reader.readStringOrNull(offset)]) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (_QuickCaptureItemsuggestedTypeValueEnumMap[
              reader.readStringOrNull(offset)] ??
          QuickCaptureSuggestedType.unknown) as P;
    case 9:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _QuickCaptureItemprocessedEntityTypeEnumValueMap = {
  r'task': r'task',
  r'goal': r'goal',
  r'note': r'note',
};
const _QuickCaptureItemprocessedEntityTypeValueEnumMap = {
  r'task': QuickCaptureProcessedEntityType.task,
  r'goal': QuickCaptureProcessedEntityType.goal,
  r'note': QuickCaptureProcessedEntityType.note,
};
const _QuickCaptureItemsuggestedTypeEnumValueMap = {
  r'task': r'task',
  r'goal': r'goal',
  r'note': r'note',
  r'unknown': r'unknown',
};
const _QuickCaptureItemsuggestedTypeValueEnumMap = {
  r'task': QuickCaptureSuggestedType.task,
  r'goal': QuickCaptureSuggestedType.goal,
  r'note': QuickCaptureSuggestedType.note,
  r'unknown': QuickCaptureSuggestedType.unknown,
};

Id _quickCaptureItemGetId(QuickCaptureItem object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _quickCaptureItemGetLinks(QuickCaptureItem object) {
  return [];
}

void _quickCaptureItemAttach(
    IsarCollection<dynamic> col, Id id, QuickCaptureItem object) {
  object.isarId = id;
}

extension QuickCaptureItemByIndex on IsarCollection<QuickCaptureItem> {
  Future<QuickCaptureItem?> getById(String id) {
    return getByIndex(r'id', [id]);
  }

  QuickCaptureItem? getByIdSync(String id) {
    return getByIndexSync(r'id', [id]);
  }

  Future<bool> deleteById(String id) {
    return deleteByIndex(r'id', [id]);
  }

  bool deleteByIdSync(String id) {
    return deleteByIndexSync(r'id', [id]);
  }

  Future<List<QuickCaptureItem?>> getAllById(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndex(r'id', values);
  }

  List<QuickCaptureItem?> getAllByIdSync(List<String> idValues) {
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

  Future<Id> putById(QuickCaptureItem object) {
    return putByIndex(r'id', object);
  }

  Id putByIdSync(QuickCaptureItem object, {bool saveLinks = true}) {
    return putByIndexSync(r'id', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllById(List<QuickCaptureItem> objects) {
    return putAllByIndex(r'id', objects);
  }

  List<Id> putAllByIdSync(List<QuickCaptureItem> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'id', objects, saveLinks: saveLinks);
  }
}

extension QuickCaptureItemQueryWhereSort
    on QueryBuilder<QuickCaptureItem, QuickCaptureItem, QWhere> {
  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension QuickCaptureItemQueryWhere
    on QueryBuilder<QuickCaptureItem, QuickCaptureItem, QWhereClause> {
  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterWhereClause>
      isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterWhereClause>
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

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterWhereClause>
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

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterWhereClause> idEqualTo(
      String id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'id',
        value: [id],
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterWhereClause>
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
}

extension QuickCaptureItemQueryFilter
    on QueryBuilder<QuickCaptureItem, QuickCaptureItem, QFilterCondition> {
  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
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

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
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

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
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

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
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

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
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

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
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

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
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

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
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

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
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

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
      idContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
      idMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'id',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
      idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
      idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
      isArchivedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isArchived',
        value: value,
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
      isProcessedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isProcessed',
        value: value,
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
      isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
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

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
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

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
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

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
      linkedEntityIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'linkedEntityId',
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
      linkedEntityIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'linkedEntityId',
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
      linkedEntityIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'linkedEntityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
      linkedEntityIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'linkedEntityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
      linkedEntityIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'linkedEntityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
      linkedEntityIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'linkedEntityId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
      linkedEntityIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'linkedEntityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
      linkedEntityIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'linkedEntityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
      linkedEntityIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'linkedEntityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
      linkedEntityIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'linkedEntityId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
      linkedEntityIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'linkedEntityId',
        value: '',
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
      linkedEntityIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'linkedEntityId',
        value: '',
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
      processedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'processedAt',
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
      processedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'processedAt',
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
      processedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'processedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
      processedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'processedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
      processedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'processedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
      processedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'processedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
      processedEntityTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'processedEntityType',
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
      processedEntityTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'processedEntityType',
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
      processedEntityTypeEqualTo(
    QuickCaptureProcessedEntityType? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'processedEntityType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
      processedEntityTypeGreaterThan(
    QuickCaptureProcessedEntityType? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'processedEntityType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
      processedEntityTypeLessThan(
    QuickCaptureProcessedEntityType? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'processedEntityType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
      processedEntityTypeBetween(
    QuickCaptureProcessedEntityType? lower,
    QuickCaptureProcessedEntityType? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'processedEntityType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
      processedEntityTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'processedEntityType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
      processedEntityTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'processedEntityType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
      processedEntityTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'processedEntityType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
      processedEntityTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'processedEntityType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
      processedEntityTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'processedEntityType',
        value: '',
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
      processedEntityTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'processedEntityType',
        value: '',
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
      rawTextEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rawText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
      rawTextGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'rawText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
      rawTextLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'rawText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
      rawTextBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'rawText',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
      rawTextStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'rawText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
      rawTextEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'rawText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
      rawTextContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'rawText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
      rawTextMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'rawText',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
      rawTextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rawText',
        value: '',
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
      rawTextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'rawText',
        value: '',
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
      suggestedTypeEqualTo(
    QuickCaptureSuggestedType value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'suggestedType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
      suggestedTypeGreaterThan(
    QuickCaptureSuggestedType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'suggestedType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
      suggestedTypeLessThan(
    QuickCaptureSuggestedType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'suggestedType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
      suggestedTypeBetween(
    QuickCaptureSuggestedType lower,
    QuickCaptureSuggestedType upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'suggestedType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
      suggestedTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'suggestedType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
      suggestedTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'suggestedType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
      suggestedTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'suggestedType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
      suggestedTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'suggestedType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
      suggestedTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'suggestedType',
        value: '',
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
      suggestedTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'suggestedType',
        value: '',
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
      updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
      updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
      updatedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
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

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
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

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterFilterCondition>
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

extension QuickCaptureItemQueryObject
    on QueryBuilder<QuickCaptureItem, QuickCaptureItem, QFilterCondition> {}

extension QuickCaptureItemQueryLinks
    on QueryBuilder<QuickCaptureItem, QuickCaptureItem, QFilterCondition> {}

extension QuickCaptureItemQuerySortBy
    on QueryBuilder<QuickCaptureItem, QuickCaptureItem, QSortBy> {
  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterSortBy>
      sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterSortBy>
      sortByIsArchived() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isArchived', Sort.asc);
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterSortBy>
      sortByIsArchivedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isArchived', Sort.desc);
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterSortBy>
      sortByIsProcessed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isProcessed', Sort.asc);
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterSortBy>
      sortByIsProcessedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isProcessed', Sort.desc);
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterSortBy>
      sortByLinkedEntityId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedEntityId', Sort.asc);
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterSortBy>
      sortByLinkedEntityIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedEntityId', Sort.desc);
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterSortBy>
      sortByProcessedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'processedAt', Sort.asc);
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterSortBy>
      sortByProcessedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'processedAt', Sort.desc);
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterSortBy>
      sortByProcessedEntityType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'processedEntityType', Sort.asc);
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterSortBy>
      sortByProcessedEntityTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'processedEntityType', Sort.desc);
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterSortBy>
      sortByRawText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawText', Sort.asc);
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterSortBy>
      sortByRawTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawText', Sort.desc);
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterSortBy>
      sortBySuggestedType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'suggestedType', Sort.asc);
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterSortBy>
      sortBySuggestedTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'suggestedType', Sort.desc);
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension QuickCaptureItemQuerySortThenBy
    on QueryBuilder<QuickCaptureItem, QuickCaptureItem, QSortThenBy> {
  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterSortBy>
      thenByIsArchived() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isArchived', Sort.asc);
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterSortBy>
      thenByIsArchivedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isArchived', Sort.desc);
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterSortBy>
      thenByIsProcessed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isProcessed', Sort.asc);
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterSortBy>
      thenByIsProcessedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isProcessed', Sort.desc);
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterSortBy>
      thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterSortBy>
      thenByLinkedEntityId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedEntityId', Sort.asc);
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterSortBy>
      thenByLinkedEntityIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedEntityId', Sort.desc);
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterSortBy>
      thenByProcessedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'processedAt', Sort.asc);
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterSortBy>
      thenByProcessedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'processedAt', Sort.desc);
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterSortBy>
      thenByProcessedEntityType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'processedEntityType', Sort.asc);
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterSortBy>
      thenByProcessedEntityTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'processedEntityType', Sort.desc);
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterSortBy>
      thenByRawText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawText', Sort.asc);
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterSortBy>
      thenByRawTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawText', Sort.desc);
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterSortBy>
      thenBySuggestedType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'suggestedType', Sort.asc);
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterSortBy>
      thenBySuggestedTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'suggestedType', Sort.desc);
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension QuickCaptureItemQueryWhereDistinct
    on QueryBuilder<QuickCaptureItem, QuickCaptureItem, QDistinct> {
  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QDistinct> distinctById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QDistinct>
      distinctByIsArchived() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isArchived');
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QDistinct>
      distinctByIsProcessed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isProcessed');
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QDistinct>
      distinctByLinkedEntityId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'linkedEntityId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QDistinct>
      distinctByProcessedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'processedAt');
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QDistinct>
      distinctByProcessedEntityType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'processedEntityType',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QDistinct> distinctByRawText(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rawText', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QDistinct>
      distinctBySuggestedType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'suggestedType',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureItem, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension QuickCaptureItemQueryProperty
    on QueryBuilder<QuickCaptureItem, QuickCaptureItem, QQueryProperty> {
  QueryBuilder<QuickCaptureItem, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<QuickCaptureItem, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<QuickCaptureItem, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<QuickCaptureItem, bool, QQueryOperations> isArchivedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isArchived');
    });
  }

  QueryBuilder<QuickCaptureItem, bool, QQueryOperations> isProcessedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isProcessed');
    });
  }

  QueryBuilder<QuickCaptureItem, String?, QQueryOperations>
      linkedEntityIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'linkedEntityId');
    });
  }

  QueryBuilder<QuickCaptureItem, DateTime?, QQueryOperations>
      processedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'processedAt');
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureProcessedEntityType?,
      QQueryOperations> processedEntityTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'processedEntityType');
    });
  }

  QueryBuilder<QuickCaptureItem, String, QQueryOperations> rawTextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rawText');
    });
  }

  QueryBuilder<QuickCaptureItem, QuickCaptureSuggestedType, QQueryOperations>
      suggestedTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'suggestedType');
    });
  }

  QueryBuilder<QuickCaptureItem, DateTime?, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
