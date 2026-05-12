// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'knowledge_item.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetKnowledgeItemCollection on Isar {
  IsarCollection<KnowledgeItem> get knowledgeItems => this.collection();
}

const KnowledgeItemSchema = CollectionSchema(
  name: r'KnowledgeItem',
  id: -64976049666290598,
  properties: {
    r'content': PropertySchema(id: 0, name: r'content', type: IsarType.string),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'dueReviewAt': PropertySchema(
      id: 2,
      name: r'dueReviewAt',
      type: IsarType.dateTime,
    ),
    r'externalReference': PropertySchema(
      id: 3,
      name: r'externalReference',
      type: IsarType.string,
    ),
    r'hasStaleLinks': PropertySchema(
      id: 4,
      name: r'hasStaleLinks',
      type: IsarType.bool,
    ),
    r'id': PropertySchema(id: 5, name: r'id', type: IsarType.string),
    r'isDueForReview': PropertySchema(
      id: 6,
      name: r'isDueForReview',
      type: IsarType.bool,
    ),
    r'lastReviewedAt': PropertySchema(
      id: 7,
      name: r'lastReviewedAt',
      type: IsarType.dateTime,
    ),
    r'links': PropertySchema(
      id: 8,
      name: r'links',
      type: IsarType.objectList,
      target: r'EntityLink',
    ),
    r'localFilePath': PropertySchema(
      id: 9,
      name: r'localFilePath',
      type: IsarType.string,
    ),
    r'priority': PropertySchema(
      id: 10,
      name: r'priority',
      type: IsarType.string,
      enumMap: _KnowledgeItempriorityEnumValueMap,
    ),
    r'reviewCount': PropertySchema(
      id: 11,
      name: r'reviewCount',
      type: IsarType.long,
    ),
    r'reviewIntervalDays': PropertySchema(
      id: 12,
      name: r'reviewIntervalDays',
      type: IsarType.long,
    ),
    r'sourceUrl': PropertySchema(
      id: 13,
      name: r'sourceUrl',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 14,
      name: r'status',
      type: IsarType.string,
      enumMap: _KnowledgeItemstatusEnumValueMap,
    ),
    r'tags': PropertySchema(id: 15, name: r'tags', type: IsarType.stringList),
    r'title': PropertySchema(id: 16, name: r'title', type: IsarType.string),
    r'type': PropertySchema(
      id: 17,
      name: r'type',
      type: IsarType.string,
      enumMap: _KnowledgeItemtypeEnumValueMap,
    ),
    r'updatedAt': PropertySchema(
      id: 18,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
  },
  estimateSize: _knowledgeItemEstimateSize,
  serialize: _knowledgeItemSerialize,
  deserialize: _knowledgeItemDeserialize,
  deserializeProp: _knowledgeItemDeserializeProp,
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
        ),
      ],
    ),
    r'title': IndexSchema(
      id: -7636685945352118059,
      name: r'title',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'title',
          type: IndexType.hash,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {r'EntityLink': EntityLinkSchema},
  getId: _knowledgeItemGetId,
  getLinks: _knowledgeItemGetLinks,
  attach: _knowledgeItemAttach,
  version: '3.1.0+1',
);

int _knowledgeItemEstimateSize(
  KnowledgeItem object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.content;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.externalReference;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.id.length * 3;
  bytesCount += 3 + object.links.length * 3;
  {
    final offsets = allOffsets[EntityLink]!;
    for (var i = 0; i < object.links.length; i++) {
      final value = object.links[i];
      bytesCount += EntityLinkSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  {
    final value = object.localFilePath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.priority.name.length * 3;
  {
    final value = object.sourceUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.status.name.length * 3;
  bytesCount += 3 + object.tags.length * 3;
  {
    for (var i = 0; i < object.tags.length; i++) {
      final value = object.tags[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.title.length * 3;
  bytesCount += 3 + object.type.name.length * 3;
  return bytesCount;
}

void _knowledgeItemSerialize(
  KnowledgeItem object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.content);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeDateTime(offsets[2], object.dueReviewAt);
  writer.writeString(offsets[3], object.externalReference);
  writer.writeBool(offsets[4], object.hasStaleLinks);
  writer.writeString(offsets[5], object.id);
  writer.writeBool(offsets[6], object.isDueForReview);
  writer.writeDateTime(offsets[7], object.lastReviewedAt);
  writer.writeObjectList<EntityLink>(
    offsets[8],
    allOffsets,
    EntityLinkSchema.serialize,
    object.links,
  );
  writer.writeString(offsets[9], object.localFilePath);
  writer.writeString(offsets[10], object.priority.name);
  writer.writeLong(offsets[11], object.reviewCount);
  writer.writeLong(offsets[12], object.reviewIntervalDays);
  writer.writeString(offsets[13], object.sourceUrl);
  writer.writeString(offsets[14], object.status.name);
  writer.writeStringList(offsets[15], object.tags);
  writer.writeString(offsets[16], object.title);
  writer.writeString(offsets[17], object.type.name);
  writer.writeDateTime(offsets[18], object.updatedAt);
}

KnowledgeItem _knowledgeItemDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = KnowledgeItem(
    content: reader.readStringOrNull(offsets[0]),
    createdAt: reader.readDateTime(offsets[1]),
    dueReviewAt: reader.readDateTimeOrNull(offsets[2]),
    externalReference: reader.readStringOrNull(offsets[3]),
    id: reader.readString(offsets[5]),
    lastReviewedAt: reader.readDateTimeOrNull(offsets[7]),
    links:
        reader.readObjectList<EntityLink>(
          offsets[8],
          EntityLinkSchema.deserialize,
          allOffsets,
          EntityLink(),
        ) ??
        const <EntityLink>[],
    localFilePath: reader.readStringOrNull(offsets[9]),
    priority:
        _KnowledgeItempriorityValueEnumMap[reader.readStringOrNull(
          offsets[10],
        )] ??
        KnowledgePriority.normal,
    reviewCount: reader.readLongOrNull(offsets[11]) ?? 0,
    reviewIntervalDays: reader.readLongOrNull(offsets[12]),
    sourceUrl: reader.readStringOrNull(offsets[13]),
    status:
        _KnowledgeItemstatusValueEnumMap[reader.readStringOrNull(
          offsets[14],
        )] ??
        KnowledgeStatus.inbox,
    tags: reader.readStringList(offsets[15]) ?? const <String>[],
    title: reader.readString(offsets[16]),
    type:
        _KnowledgeItemtypeValueEnumMap[reader.readStringOrNull(offsets[17])] ??
        KnowledgeItemType.note,
    updatedAt: reader.readDateTimeOrNull(offsets[18]),
  );
  object.isarId = id;
  return object;
}

P _knowledgeItemDeserializeProp<P>(
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
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 8:
      return (reader.readObjectList<EntityLink>(
                offset,
                EntityLinkSchema.deserialize,
                allOffsets,
                EntityLink(),
              ) ??
              const <EntityLink>[])
          as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (_KnowledgeItempriorityValueEnumMap[reader.readStringOrNull(
                offset,
              )] ??
              KnowledgePriority.normal)
          as P;
    case 11:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 12:
      return (reader.readLongOrNull(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
      return (_KnowledgeItemstatusValueEnumMap[reader.readStringOrNull(
                offset,
              )] ??
              KnowledgeStatus.inbox)
          as P;
    case 15:
      return (reader.readStringList(offset) ?? const <String>[]) as P;
    case 16:
      return (reader.readString(offset)) as P;
    case 17:
      return (_KnowledgeItemtypeValueEnumMap[reader.readStringOrNull(offset)] ??
              KnowledgeItemType.note)
          as P;
    case 18:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _KnowledgeItempriorityEnumValueMap = {
  r'low': r'low',
  r'normal': r'normal',
  r'high': r'high',
};
const _KnowledgeItempriorityValueEnumMap = {
  r'low': KnowledgePriority.low,
  r'normal': KnowledgePriority.normal,
  r'high': KnowledgePriority.high,
};
const _KnowledgeItemstatusEnumValueMap = {
  r'inbox': r'inbox',
  r'active': r'active',
  r'reviewing': r'reviewing',
  r'completed': r'completed',
  r'archived': r'archived',
};
const _KnowledgeItemstatusValueEnumMap = {
  r'inbox': KnowledgeStatus.inbox,
  r'active': KnowledgeStatus.active,
  r'reviewing': KnowledgeStatus.reviewing,
  r'completed': KnowledgeStatus.completed,
  r'archived': KnowledgeStatus.archived,
};
const _KnowledgeItemtypeEnumValueMap = {
  r'note': r'note',
  r'resource': r'resource',
  r'researchPaper': r'researchPaper',
  r'book': r'book',
  r'article': r'article',
  r'video': r'video',
  r'course': r'course',
  r'codeSnippet': r'codeSnippet',
  r'idea': r'idea',
  r'question': r'question',
};
const _KnowledgeItemtypeValueEnumMap = {
  r'note': KnowledgeItemType.note,
  r'resource': KnowledgeItemType.resource,
  r'researchPaper': KnowledgeItemType.researchPaper,
  r'book': KnowledgeItemType.book,
  r'article': KnowledgeItemType.article,
  r'video': KnowledgeItemType.video,
  r'course': KnowledgeItemType.course,
  r'codeSnippet': KnowledgeItemType.codeSnippet,
  r'idea': KnowledgeItemType.idea,
  r'question': KnowledgeItemType.question,
};

Id _knowledgeItemGetId(KnowledgeItem object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _knowledgeItemGetLinks(KnowledgeItem object) {
  return [];
}

void _knowledgeItemAttach(
  IsarCollection<dynamic> col,
  Id id,
  KnowledgeItem object,
) {
  object.isarId = id;
}

extension KnowledgeItemByIndex on IsarCollection<KnowledgeItem> {
  Future<KnowledgeItem?> getById(String id) {
    return getByIndex(r'id', [id]);
  }

  KnowledgeItem? getByIdSync(String id) {
    return getByIndexSync(r'id', [id]);
  }

  Future<bool> deleteById(String id) {
    return deleteByIndex(r'id', [id]);
  }

  bool deleteByIdSync(String id) {
    return deleteByIndexSync(r'id', [id]);
  }

  Future<List<KnowledgeItem?>> getAllById(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndex(r'id', values);
  }

  List<KnowledgeItem?> getAllByIdSync(List<String> idValues) {
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

  Future<Id> putById(KnowledgeItem object) {
    return putByIndex(r'id', object);
  }

  Id putByIdSync(KnowledgeItem object, {bool saveLinks = true}) {
    return putByIndexSync(r'id', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllById(List<KnowledgeItem> objects) {
    return putAllByIndex(r'id', objects);
  }

  List<Id> putAllByIdSync(
    List<KnowledgeItem> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'id', objects, saveLinks: saveLinks);
  }
}

extension KnowledgeItemQueryWhereSort
    on QueryBuilder<KnowledgeItem, KnowledgeItem, QWhere> {
  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension KnowledgeItemQueryWhere
    on QueryBuilder<KnowledgeItem, KnowledgeItem, QWhereClause> {
  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterWhereClause> isarIdEqualTo(
    Id isarId,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(lower: isarId, upper: isarId),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterWhereClause>
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

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterWhereClause>
  isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterWhereClause> isarIdLessThan(
    Id isarId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterWhereClause> isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerIsarId,
          includeLower: includeLower,
          upper: upperIsarId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterWhereClause> idEqualTo(
    String id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'id', value: [id]),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterWhereClause> idNotEqualTo(
    String id,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'id',
                lower: [],
                upper: [id],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'id',
                lower: [id],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'id',
                lower: [id],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'id',
                lower: [],
                upper: [id],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterWhereClause> titleEqualTo(
    String title,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'title', value: [title]),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterWhereClause> titleNotEqualTo(
    String title,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'title',
                lower: [],
                upper: [title],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'title',
                lower: [title],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'title',
                lower: [title],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'title',
                lower: [],
                upper: [title],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension KnowledgeItemQueryFilter
    on QueryBuilder<KnowledgeItem, KnowledgeItem, QFilterCondition> {
  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  contentIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'content'),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  contentIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'content'),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  contentEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'content',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  contentGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'content',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  contentLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'content',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  contentBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'content',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  contentStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'content',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  contentEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'content',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  contentContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'content',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  contentMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'content',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  contentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'content', value: ''),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  contentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'content', value: ''),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  createdAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  createdAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'createdAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  dueReviewAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'dueReviewAt'),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  dueReviewAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'dueReviewAt'),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  dueReviewAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'dueReviewAt', value: value),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  dueReviewAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'dueReviewAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  dueReviewAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'dueReviewAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  dueReviewAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'dueReviewAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  externalReferenceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'externalReference'),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  externalReferenceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'externalReference'),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  externalReferenceEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'externalReference',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  externalReferenceGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'externalReference',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  externalReferenceLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'externalReference',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  externalReferenceBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'externalReference',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  externalReferenceStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'externalReference',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  externalReferenceEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'externalReference',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  externalReferenceContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'externalReference',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  externalReferenceMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'externalReference',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  externalReferenceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'externalReference', value: ''),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  externalReferenceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'externalReference', value: ''),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  hasStaleLinksEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'hasStaleLinks', value: value),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition> idEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'id',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  idGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition> idLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition> idBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  idStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'id',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition> idEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'id',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition> idContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'id',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition> idMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'id',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: ''),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'id', value: ''),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  isDueForReviewEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isDueForReview', value: value),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isarId', value: value),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  isarIdGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'isarId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  isarIdLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'isarId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'isarId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  lastReviewedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastReviewedAt'),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  lastReviewedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastReviewedAt'),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  lastReviewedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastReviewedAt', value: value),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  lastReviewedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastReviewedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  lastReviewedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastReviewedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  lastReviewedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastReviewedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  linksLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'links', length, true, length, true);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  linksIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'links', 0, true, 0, true);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  linksIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'links', 0, false, 999999, true);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  linksLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'links', 0, true, length, include);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  linksLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'links', length, include, 999999, true);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  linksLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'links',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  localFilePathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'localFilePath'),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  localFilePathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'localFilePath'),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  localFilePathEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'localFilePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  localFilePathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'localFilePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  localFilePathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'localFilePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  localFilePathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'localFilePath',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  localFilePathStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'localFilePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  localFilePathEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'localFilePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  localFilePathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'localFilePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  localFilePathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'localFilePath',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  localFilePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'localFilePath', value: ''),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  localFilePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'localFilePath', value: ''),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  priorityEqualTo(KnowledgePriority value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'priority',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  priorityGreaterThan(
    KnowledgePriority value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'priority',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  priorityLessThan(
    KnowledgePriority value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'priority',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  priorityBetween(
    KnowledgePriority lower,
    KnowledgePriority upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'priority',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  priorityStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'priority',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  priorityEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'priority',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  priorityContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'priority',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  priorityMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'priority',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  priorityIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'priority', value: ''),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  priorityIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'priority', value: ''),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  reviewCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'reviewCount', value: value),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  reviewCountGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'reviewCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  reviewCountLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'reviewCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  reviewCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'reviewCount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  reviewIntervalDaysIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'reviewIntervalDays'),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  reviewIntervalDaysIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'reviewIntervalDays'),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  reviewIntervalDaysEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'reviewIntervalDays', value: value),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  reviewIntervalDaysGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'reviewIntervalDays',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  reviewIntervalDaysLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'reviewIntervalDays',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  reviewIntervalDaysBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'reviewIntervalDays',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  sourceUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'sourceUrl'),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  sourceUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'sourceUrl'),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  sourceUrlEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'sourceUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  sourceUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sourceUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  sourceUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sourceUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  sourceUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sourceUrl',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  sourceUrlStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'sourceUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  sourceUrlEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'sourceUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  sourceUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'sourceUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  sourceUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'sourceUrl',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  sourceUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sourceUrl', value: ''),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  sourceUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'sourceUrl', value: ''),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  statusEqualTo(KnowledgeStatus value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  statusGreaterThan(
    KnowledgeStatus value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  statusLessThan(
    KnowledgeStatus value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  statusBetween(
    KnowledgeStatus lower,
    KnowledgeStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'status',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  statusStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  statusEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'status',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'status', value: ''),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'status', value: ''),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  tagsElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'tags',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  tagsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'tags',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  tagsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'tags',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  tagsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'tags',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  tagsElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'tags',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  tagsElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'tags',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  tagsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'tags',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  tagsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'tags',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  tagsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'tags', value: ''),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  tagsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'tags', value: ''),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  tagsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'tags', length, true, length, true);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  tagsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'tags', 0, true, 0, true);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  tagsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'tags', 0, false, 999999, true);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  tagsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'tags', 0, true, length, include);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  tagsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'tags', length, include, 999999, true);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  tagsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  titleEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'title',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  titleStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  titleEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'title',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition> typeEqualTo(
    KnowledgeItemType value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  typeGreaterThan(
    KnowledgeItemType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  typeLessThan(
    KnowledgeItemType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition> typeBetween(
    KnowledgeItemType lower,
    KnowledgeItemType upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'type',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  typeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  typeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  typeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition> typeMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'type',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'type', value: ''),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'type', value: ''),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'updatedAt'),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'updatedAt'),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  updatedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  updatedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  updatedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  updatedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'updatedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension KnowledgeItemQueryObject
    on QueryBuilder<KnowledgeItem, KnowledgeItem, QFilterCondition> {
  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterFilterCondition>
  linksElement(FilterQuery<EntityLink> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'links');
    });
  }
}

extension KnowledgeItemQueryLinks
    on QueryBuilder<KnowledgeItem, KnowledgeItem, QFilterCondition> {}

extension KnowledgeItemQuerySortBy
    on QueryBuilder<KnowledgeItem, KnowledgeItem, QSortBy> {
  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy> sortByContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.asc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy> sortByContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.desc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy>
  sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy> sortByDueReviewAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueReviewAt', Sort.asc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy>
  sortByDueReviewAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueReviewAt', Sort.desc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy>
  sortByExternalReference() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'externalReference', Sort.asc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy>
  sortByExternalReferenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'externalReference', Sort.desc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy>
  sortByHasStaleLinks() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasStaleLinks', Sort.asc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy>
  sortByHasStaleLinksDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasStaleLinks', Sort.desc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy>
  sortByIsDueForReview() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDueForReview', Sort.asc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy>
  sortByIsDueForReviewDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDueForReview', Sort.desc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy>
  sortByLastReviewedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReviewedAt', Sort.asc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy>
  sortByLastReviewedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReviewedAt', Sort.desc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy>
  sortByLocalFilePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localFilePath', Sort.asc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy>
  sortByLocalFilePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localFilePath', Sort.desc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy> sortByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.asc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy>
  sortByPriorityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.desc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy> sortByReviewCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewCount', Sort.asc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy>
  sortByReviewCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewCount', Sort.desc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy>
  sortByReviewIntervalDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewIntervalDays', Sort.asc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy>
  sortByReviewIntervalDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewIntervalDays', Sort.desc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy> sortBySourceUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceUrl', Sort.asc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy>
  sortBySourceUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceUrl', Sort.desc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy>
  sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension KnowledgeItemQuerySortThenBy
    on QueryBuilder<KnowledgeItem, KnowledgeItem, QSortThenBy> {
  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy> thenByContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.asc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy> thenByContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.desc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy>
  thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy> thenByDueReviewAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueReviewAt', Sort.asc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy>
  thenByDueReviewAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueReviewAt', Sort.desc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy>
  thenByExternalReference() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'externalReference', Sort.asc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy>
  thenByExternalReferenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'externalReference', Sort.desc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy>
  thenByHasStaleLinks() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasStaleLinks', Sort.asc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy>
  thenByHasStaleLinksDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasStaleLinks', Sort.desc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy>
  thenByIsDueForReview() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDueForReview', Sort.asc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy>
  thenByIsDueForReviewDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDueForReview', Sort.desc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy> thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy>
  thenByLastReviewedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReviewedAt', Sort.asc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy>
  thenByLastReviewedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReviewedAt', Sort.desc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy>
  thenByLocalFilePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localFilePath', Sort.asc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy>
  thenByLocalFilePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localFilePath', Sort.desc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy> thenByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.asc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy>
  thenByPriorityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.desc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy> thenByReviewCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewCount', Sort.asc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy>
  thenByReviewCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewCount', Sort.desc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy>
  thenByReviewIntervalDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewIntervalDays', Sort.asc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy>
  thenByReviewIntervalDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewIntervalDays', Sort.desc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy> thenBySourceUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceUrl', Sort.asc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy>
  thenBySourceUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceUrl', Sort.desc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QAfterSortBy>
  thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension KnowledgeItemQueryWhereDistinct
    on QueryBuilder<KnowledgeItem, KnowledgeItem, QDistinct> {
  QueryBuilder<KnowledgeItem, KnowledgeItem, QDistinct> distinctByContent({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'content', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QDistinct>
  distinctByDueReviewAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dueReviewAt');
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QDistinct>
  distinctByExternalReference({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'externalReference',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QDistinct>
  distinctByHasStaleLinks() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasStaleLinks');
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QDistinct> distinctById({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QDistinct>
  distinctByIsDueForReview() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDueForReview');
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QDistinct>
  distinctByLastReviewedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastReviewedAt');
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QDistinct>
  distinctByLocalFilePath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'localFilePath',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QDistinct> distinctByPriority({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'priority', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QDistinct>
  distinctByReviewCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reviewCount');
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QDistinct>
  distinctByReviewIntervalDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reviewIntervalDays');
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QDistinct> distinctBySourceUrl({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QDistinct> distinctByStatus({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QDistinct> distinctByTags() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tags');
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QDistinct> distinctByTitle({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QDistinct> distinctByType({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItem, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension KnowledgeItemQueryProperty
    on QueryBuilder<KnowledgeItem, KnowledgeItem, QQueryProperty> {
  QueryBuilder<KnowledgeItem, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<KnowledgeItem, String?, QQueryOperations> contentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'content');
    });
  }

  QueryBuilder<KnowledgeItem, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<KnowledgeItem, DateTime?, QQueryOperations>
  dueReviewAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dueReviewAt');
    });
  }

  QueryBuilder<KnowledgeItem, String?, QQueryOperations>
  externalReferenceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'externalReference');
    });
  }

  QueryBuilder<KnowledgeItem, bool, QQueryOperations> hasStaleLinksProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasStaleLinks');
    });
  }

  QueryBuilder<KnowledgeItem, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<KnowledgeItem, bool, QQueryOperations> isDueForReviewProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDueForReview');
    });
  }

  QueryBuilder<KnowledgeItem, DateTime?, QQueryOperations>
  lastReviewedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastReviewedAt');
    });
  }

  QueryBuilder<KnowledgeItem, List<EntityLink>, QQueryOperations>
  linksProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'links');
    });
  }

  QueryBuilder<KnowledgeItem, String?, QQueryOperations>
  localFilePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'localFilePath');
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgePriority, QQueryOperations>
  priorityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'priority');
    });
  }

  QueryBuilder<KnowledgeItem, int, QQueryOperations> reviewCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reviewCount');
    });
  }

  QueryBuilder<KnowledgeItem, int?, QQueryOperations>
  reviewIntervalDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reviewIntervalDays');
    });
  }

  QueryBuilder<KnowledgeItem, String?, QQueryOperations> sourceUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceUrl');
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeStatus, QQueryOperations>
  statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<KnowledgeItem, List<String>, QQueryOperations> tagsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tags');
    });
  }

  QueryBuilder<KnowledgeItem, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<KnowledgeItem, KnowledgeItemType, QQueryOperations>
  typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }

  QueryBuilder<KnowledgeItem, DateTime?, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const EntityLinkSchema = Schema(
  name: r'EntityLink',
  id: 1494033247261595588,
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
      enumMap: _EntityLinkentityTypeEnumValueMap,
    ),
    r'isStale': PropertySchema(id: 2, name: r'isStale', type: IsarType.bool),
    r'relationLabel': PropertySchema(
      id: 3,
      name: r'relationLabel',
      type: IsarType.string,
    ),
  },
  estimateSize: _entityLinkEstimateSize,
  serialize: _entityLinkSerialize,
  deserialize: _entityLinkDeserialize,
  deserializeProp: _entityLinkDeserializeProp,
);

int _entityLinkEstimateSize(
  EntityLink object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.entityId.length * 3;
  bytesCount += 3 + object.entityType.name.length * 3;
  {
    final value = object.relationLabel;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _entityLinkSerialize(
  EntityLink object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.entityId);
  writer.writeString(offsets[1], object.entityType.name);
  writer.writeBool(offsets[2], object.isStale);
  writer.writeString(offsets[3], object.relationLabel);
}

EntityLink _entityLinkDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = EntityLink(
    entityId: reader.readStringOrNull(offsets[0]) ?? '',
    entityType:
        _EntityLinkentityTypeValueEnumMap[reader.readStringOrNull(
          offsets[1],
        )] ??
        LinkedEntityType.task,
    isStale: reader.readBoolOrNull(offsets[2]) ?? false,
    relationLabel: reader.readStringOrNull(offsets[3]),
  );
  return object;
}

P _entityLinkDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset) ?? '') as P;
    case 1:
      return (_EntityLinkentityTypeValueEnumMap[reader.readStringOrNull(
                offset,
              )] ??
              LinkedEntityType.task)
          as P;
    case 2:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _EntityLinkentityTypeEnumValueMap = {
  r'goal': r'goal',
  r'project': r'project',
  r'task': r'task',
  r'routine': r'routine',
  r'routineOccurrence': r'routineOccurrence',
  r'focusSession': r'focusSession',
  r'milestone': r'milestone',
};
const _EntityLinkentityTypeValueEnumMap = {
  r'goal': LinkedEntityType.goal,
  r'project': LinkedEntityType.project,
  r'task': LinkedEntityType.task,
  r'routine': LinkedEntityType.routine,
  r'routineOccurrence': LinkedEntityType.routineOccurrence,
  r'focusSession': LinkedEntityType.focusSession,
  r'milestone': LinkedEntityType.milestone,
};

extension EntityLinkQueryFilter
    on QueryBuilder<EntityLink, EntityLink, QFilterCondition> {
  QueryBuilder<EntityLink, EntityLink, QAfterFilterCondition> entityIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'entityId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EntityLink, EntityLink, QAfterFilterCondition>
  entityIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'entityId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EntityLink, EntityLink, QAfterFilterCondition> entityIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'entityId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EntityLink, EntityLink, QAfterFilterCondition> entityIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'entityId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EntityLink, EntityLink, QAfterFilterCondition>
  entityIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'entityId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EntityLink, EntityLink, QAfterFilterCondition> entityIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'entityId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EntityLink, EntityLink, QAfterFilterCondition> entityIdContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'entityId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EntityLink, EntityLink, QAfterFilterCondition> entityIdMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'entityId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EntityLink, EntityLink, QAfterFilterCondition>
  entityIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'entityId', value: ''),
      );
    });
  }

  QueryBuilder<EntityLink, EntityLink, QAfterFilterCondition>
  entityIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'entityId', value: ''),
      );
    });
  }

  QueryBuilder<EntityLink, EntityLink, QAfterFilterCondition> entityTypeEqualTo(
    LinkedEntityType value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'entityType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EntityLink, EntityLink, QAfterFilterCondition>
  entityTypeGreaterThan(
    LinkedEntityType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'entityType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EntityLink, EntityLink, QAfterFilterCondition>
  entityTypeLessThan(
    LinkedEntityType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'entityType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EntityLink, EntityLink, QAfterFilterCondition> entityTypeBetween(
    LinkedEntityType lower,
    LinkedEntityType upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'entityType',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EntityLink, EntityLink, QAfterFilterCondition>
  entityTypeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'entityType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EntityLink, EntityLink, QAfterFilterCondition>
  entityTypeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'entityType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EntityLink, EntityLink, QAfterFilterCondition>
  entityTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'entityType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EntityLink, EntityLink, QAfterFilterCondition> entityTypeMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'entityType',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EntityLink, EntityLink, QAfterFilterCondition>
  entityTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'entityType', value: ''),
      );
    });
  }

  QueryBuilder<EntityLink, EntityLink, QAfterFilterCondition>
  entityTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'entityType', value: ''),
      );
    });
  }

  QueryBuilder<EntityLink, EntityLink, QAfterFilterCondition> isStaleEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isStale', value: value),
      );
    });
  }

  QueryBuilder<EntityLink, EntityLink, QAfterFilterCondition>
  relationLabelIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'relationLabel'),
      );
    });
  }

  QueryBuilder<EntityLink, EntityLink, QAfterFilterCondition>
  relationLabelIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'relationLabel'),
      );
    });
  }

  QueryBuilder<EntityLink, EntityLink, QAfterFilterCondition>
  relationLabelEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'relationLabel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EntityLink, EntityLink, QAfterFilterCondition>
  relationLabelGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'relationLabel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EntityLink, EntityLink, QAfterFilterCondition>
  relationLabelLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'relationLabel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EntityLink, EntityLink, QAfterFilterCondition>
  relationLabelBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'relationLabel',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EntityLink, EntityLink, QAfterFilterCondition>
  relationLabelStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'relationLabel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EntityLink, EntityLink, QAfterFilterCondition>
  relationLabelEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'relationLabel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EntityLink, EntityLink, QAfterFilterCondition>
  relationLabelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'relationLabel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EntityLink, EntityLink, QAfterFilterCondition>
  relationLabelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'relationLabel',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EntityLink, EntityLink, QAfterFilterCondition>
  relationLabelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'relationLabel', value: ''),
      );
    });
  }

  QueryBuilder<EntityLink, EntityLink, QAfterFilterCondition>
  relationLabelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'relationLabel', value: ''),
      );
    });
  }
}

extension EntityLinkQueryObject
    on QueryBuilder<EntityLink, EntityLink, QFilterCondition> {}
