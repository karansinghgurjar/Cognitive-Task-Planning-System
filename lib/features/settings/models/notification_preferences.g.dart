// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_preferences.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetNotificationPreferencesCollection on Isar {
  IsarCollection<NotificationPreferences> get notificationPreferences =>
      this.collection();
}

const NotificationPreferencesSchema = CollectionSchema(
  name: r'NotificationPreferences',
  id: 4550166405663651190,
  properties: {
    r'autoSyncEnabled': PropertySchema(
      id: 0,
      name: r'autoSyncEnabled',
      type: IsarType.bool,
    ),
    r'backupReminderCadence': PropertySchema(
      id: 1,
      name: r'backupReminderCadence',
      type: IsarType.string,
      enumMap: _NotificationPreferencesbackupReminderCadenceEnumValueMap,
    ),
    r'backupReminderEnabled': PropertySchema(
      id: 2,
      name: r'backupReminderEnabled',
      type: IsarType.bool,
    ),
    r'dailySummaryEnabled': PropertySchema(
      id: 3,
      name: r'dailySummaryEnabled',
      type: IsarType.bool,
    ),
    r'dailySummaryHour': PropertySchema(
      id: 4,
      name: r'dailySummaryHour',
      type: IsarType.long,
    ),
    r'dailySummaryMinute': PropertySchema(
      id: 5,
      name: r'dailySummaryMinute',
      type: IsarType.long,
    ),
    r'deadlineWarningsEnabled': PropertySchema(
      id: 6,
      name: r'deadlineWarningsEnabled',
      type: IsarType.bool,
    ),
    r'reminderLeadTimeMinutes': PropertySchema(
      id: 7,
      name: r'reminderLeadTimeMinutes',
      type: IsarType.long,
    ),
    r'sessionRemindersEnabled': PropertySchema(
      id: 8,
      name: r'sessionRemindersEnabled',
      type: IsarType.bool,
    ),
    r'syncEnabled': PropertySchema(
      id: 9,
      name: r'syncEnabled',
      type: IsarType.bool,
    ),
    r'syncOnWifiOnly': PropertySchema(
      id: 10,
      name: r'syncOnWifiOnly',
      type: IsarType.bool,
    )
  },
  estimateSize: _notificationPreferencesEstimateSize,
  serialize: _notificationPreferencesSerialize,
  deserialize: _notificationPreferencesDeserialize,
  deserializeProp: _notificationPreferencesDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _notificationPreferencesGetId,
  getLinks: _notificationPreferencesGetLinks,
  attach: _notificationPreferencesAttach,
  version: '3.1.0+1',
);

int _notificationPreferencesEstimateSize(
  NotificationPreferences object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.backupReminderCadence.name.length * 3;
  return bytesCount;
}

void _notificationPreferencesSerialize(
  NotificationPreferences object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.autoSyncEnabled);
  writer.writeString(offsets[1], object.backupReminderCadence.name);
  writer.writeBool(offsets[2], object.backupReminderEnabled);
  writer.writeBool(offsets[3], object.dailySummaryEnabled);
  writer.writeLong(offsets[4], object.dailySummaryHour);
  writer.writeLong(offsets[5], object.dailySummaryMinute);
  writer.writeBool(offsets[6], object.deadlineWarningsEnabled);
  writer.writeLong(offsets[7], object.reminderLeadTimeMinutes);
  writer.writeBool(offsets[8], object.sessionRemindersEnabled);
  writer.writeBool(offsets[9], object.syncEnabled);
  writer.writeBool(offsets[10], object.syncOnWifiOnly);
}

NotificationPreferences _notificationPreferencesDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = NotificationPreferences(
    autoSyncEnabled: reader.readBoolOrNull(offsets[0]) ?? true,
    backupReminderCadence:
        _NotificationPreferencesbackupReminderCadenceValueEnumMap[
                reader.readStringOrNull(offsets[1])] ??
            BackupReminderCadence.weekly,
    backupReminderEnabled: reader.readBoolOrNull(offsets[2]) ?? false,
    dailySummaryEnabled: reader.readBoolOrNull(offsets[3]) ?? true,
    dailySummaryHour: reader.readLongOrNull(offsets[4]) ?? 7,
    dailySummaryMinute: reader.readLongOrNull(offsets[5]) ?? 0,
    deadlineWarningsEnabled: reader.readBoolOrNull(offsets[6]) ?? true,
    id: id,
    reminderLeadTimeMinutes: reader.readLongOrNull(offsets[7]) ?? 10,
    sessionRemindersEnabled: reader.readBoolOrNull(offsets[8]) ?? true,
    syncEnabled: reader.readBoolOrNull(offsets[9]) ?? false,
    syncOnWifiOnly: reader.readBoolOrNull(offsets[10]) ?? false,
  );
  return object;
}

P _notificationPreferencesDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 1:
      return (_NotificationPreferencesbackupReminderCadenceValueEnumMap[
              reader.readStringOrNull(offset)] ??
          BackupReminderCadence.weekly) as P;
    case 2:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 3:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 4:
      return (reader.readLongOrNull(offset) ?? 7) as P;
    case 5:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 6:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 7:
      return (reader.readLongOrNull(offset) ?? 10) as P;
    case 8:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 9:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 10:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _NotificationPreferencesbackupReminderCadenceEnumValueMap = {
  r'weekly': r'weekly',
  r'everyTwoWeeks': r'everyTwoWeeks',
  r'monthly': r'monthly',
};
const _NotificationPreferencesbackupReminderCadenceValueEnumMap = {
  r'weekly': BackupReminderCadence.weekly,
  r'everyTwoWeeks': BackupReminderCadence.everyTwoWeeks,
  r'monthly': BackupReminderCadence.monthly,
};

Id _notificationPreferencesGetId(NotificationPreferences object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _notificationPreferencesGetLinks(
    NotificationPreferences object) {
  return [];
}

void _notificationPreferencesAttach(
    IsarCollection<dynamic> col, Id id, NotificationPreferences object) {
  object.id = id;
}

extension NotificationPreferencesQueryWhereSort
    on QueryBuilder<NotificationPreferences, NotificationPreferences, QWhere> {
  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension NotificationPreferencesQueryWhere on QueryBuilder<
    NotificationPreferences, NotificationPreferences, QWhereClause> {
  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterWhereClause> idBetween(
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

extension NotificationPreferencesQueryFilter on QueryBuilder<
    NotificationPreferences, NotificationPreferences, QFilterCondition> {
  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> autoSyncEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'autoSyncEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> backupReminderCadenceEqualTo(
    BackupReminderCadence value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'backupReminderCadence',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> backupReminderCadenceGreaterThan(
    BackupReminderCadence value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'backupReminderCadence',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> backupReminderCadenceLessThan(
    BackupReminderCadence value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'backupReminderCadence',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> backupReminderCadenceBetween(
    BackupReminderCadence lower,
    BackupReminderCadence upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'backupReminderCadence',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> backupReminderCadenceStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'backupReminderCadence',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> backupReminderCadenceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'backupReminderCadence',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
          QAfterFilterCondition>
      backupReminderCadenceContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'backupReminderCadence',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
          QAfterFilterCondition>
      backupReminderCadenceMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'backupReminderCadence',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> backupReminderCadenceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'backupReminderCadence',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> backupReminderCadenceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'backupReminderCadence',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> backupReminderEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'backupReminderEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> dailySummaryEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dailySummaryEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> dailySummaryHourEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dailySummaryHour',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> dailySummaryHourGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dailySummaryHour',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> dailySummaryHourLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dailySummaryHour',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> dailySummaryHourBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dailySummaryHour',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> dailySummaryMinuteEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dailySummaryMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> dailySummaryMinuteGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dailySummaryMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> dailySummaryMinuteLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dailySummaryMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> dailySummaryMinuteBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dailySummaryMinute',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> deadlineWarningsEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deadlineWarningsEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
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

  QueryBuilder<NotificationPreferences, NotificationPreferences,
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

  QueryBuilder<NotificationPreferences, NotificationPreferences,
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

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> reminderLeadTimeMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reminderLeadTimeMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> reminderLeadTimeMinutesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reminderLeadTimeMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> reminderLeadTimeMinutesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reminderLeadTimeMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> reminderLeadTimeMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reminderLeadTimeMinutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> sessionRemindersEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sessionRemindersEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> syncEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> syncOnWifiOnlyEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncOnWifiOnly',
        value: value,
      ));
    });
  }
}

extension NotificationPreferencesQueryObject on QueryBuilder<
    NotificationPreferences, NotificationPreferences, QFilterCondition> {}

extension NotificationPreferencesQueryLinks on QueryBuilder<
    NotificationPreferences, NotificationPreferences, QFilterCondition> {}

extension NotificationPreferencesQuerySortBy
    on QueryBuilder<NotificationPreferences, NotificationPreferences, QSortBy> {
  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByAutoSyncEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoSyncEnabled', Sort.asc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByAutoSyncEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoSyncEnabled', Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByBackupReminderCadence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backupReminderCadence', Sort.asc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByBackupReminderCadenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backupReminderCadence', Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByBackupReminderEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backupReminderEnabled', Sort.asc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByBackupReminderEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backupReminderEnabled', Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByDailySummaryEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailySummaryEnabled', Sort.asc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByDailySummaryEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailySummaryEnabled', Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByDailySummaryHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailySummaryHour', Sort.asc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByDailySummaryHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailySummaryHour', Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByDailySummaryMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailySummaryMinute', Sort.asc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByDailySummaryMinuteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailySummaryMinute', Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByDeadlineWarningsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deadlineWarningsEnabled', Sort.asc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByDeadlineWarningsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deadlineWarningsEnabled', Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByReminderLeadTimeMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderLeadTimeMinutes', Sort.asc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByReminderLeadTimeMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderLeadTimeMinutes', Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortBySessionRemindersEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionRemindersEnabled', Sort.asc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortBySessionRemindersEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionRemindersEnabled', Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortBySyncEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncEnabled', Sort.asc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortBySyncEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncEnabled', Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortBySyncOnWifiOnly() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncOnWifiOnly', Sort.asc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortBySyncOnWifiOnlyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncOnWifiOnly', Sort.desc);
    });
  }
}

extension NotificationPreferencesQuerySortThenBy on QueryBuilder<
    NotificationPreferences, NotificationPreferences, QSortThenBy> {
  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByAutoSyncEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoSyncEnabled', Sort.asc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByAutoSyncEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoSyncEnabled', Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByBackupReminderCadence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backupReminderCadence', Sort.asc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByBackupReminderCadenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backupReminderCadence', Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByBackupReminderEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backupReminderEnabled', Sort.asc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByBackupReminderEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backupReminderEnabled', Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByDailySummaryEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailySummaryEnabled', Sort.asc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByDailySummaryEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailySummaryEnabled', Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByDailySummaryHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailySummaryHour', Sort.asc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByDailySummaryHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailySummaryHour', Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByDailySummaryMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailySummaryMinute', Sort.asc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByDailySummaryMinuteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailySummaryMinute', Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByDeadlineWarningsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deadlineWarningsEnabled', Sort.asc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByDeadlineWarningsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deadlineWarningsEnabled', Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByReminderLeadTimeMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderLeadTimeMinutes', Sort.asc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByReminderLeadTimeMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderLeadTimeMinutes', Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenBySessionRemindersEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionRemindersEnabled', Sort.asc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenBySessionRemindersEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionRemindersEnabled', Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenBySyncEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncEnabled', Sort.asc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenBySyncEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncEnabled', Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenBySyncOnWifiOnly() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncOnWifiOnly', Sort.asc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenBySyncOnWifiOnlyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncOnWifiOnly', Sort.desc);
    });
  }
}

extension NotificationPreferencesQueryWhereDistinct on QueryBuilder<
    NotificationPreferences, NotificationPreferences, QDistinct> {
  QueryBuilder<NotificationPreferences, NotificationPreferences, QDistinct>
      distinctByAutoSyncEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'autoSyncEnabled');
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QDistinct>
      distinctByBackupReminderCadence({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'backupReminderCadence',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QDistinct>
      distinctByBackupReminderEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'backupReminderEnabled');
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QDistinct>
      distinctByDailySummaryEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dailySummaryEnabled');
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QDistinct>
      distinctByDailySummaryHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dailySummaryHour');
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QDistinct>
      distinctByDailySummaryMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dailySummaryMinute');
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QDistinct>
      distinctByDeadlineWarningsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deadlineWarningsEnabled');
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QDistinct>
      distinctByReminderLeadTimeMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reminderLeadTimeMinutes');
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QDistinct>
      distinctBySessionRemindersEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sessionRemindersEnabled');
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QDistinct>
      distinctBySyncEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncEnabled');
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QDistinct>
      distinctBySyncOnWifiOnly() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncOnWifiOnly');
    });
  }
}

extension NotificationPreferencesQueryProperty on QueryBuilder<
    NotificationPreferences, NotificationPreferences, QQueryProperty> {
  QueryBuilder<NotificationPreferences, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<NotificationPreferences, bool, QQueryOperations>
      autoSyncEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'autoSyncEnabled');
    });
  }

  QueryBuilder<NotificationPreferences, BackupReminderCadence, QQueryOperations>
      backupReminderCadenceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'backupReminderCadence');
    });
  }

  QueryBuilder<NotificationPreferences, bool, QQueryOperations>
      backupReminderEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'backupReminderEnabled');
    });
  }

  QueryBuilder<NotificationPreferences, bool, QQueryOperations>
      dailySummaryEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dailySummaryEnabled');
    });
  }

  QueryBuilder<NotificationPreferences, int, QQueryOperations>
      dailySummaryHourProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dailySummaryHour');
    });
  }

  QueryBuilder<NotificationPreferences, int, QQueryOperations>
      dailySummaryMinuteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dailySummaryMinute');
    });
  }

  QueryBuilder<NotificationPreferences, bool, QQueryOperations>
      deadlineWarningsEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deadlineWarningsEnabled');
    });
  }

  QueryBuilder<NotificationPreferences, int, QQueryOperations>
      reminderLeadTimeMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reminderLeadTimeMinutes');
    });
  }

  QueryBuilder<NotificationPreferences, bool, QQueryOperations>
      sessionRemindersEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sessionRemindersEnabled');
    });
  }

  QueryBuilder<NotificationPreferences, bool, QQueryOperations>
      syncEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncEnabled');
    });
  }

  QueryBuilder<NotificationPreferences, bool, QQueryOperations>
      syncOnWifiOnlyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncOnWifiOnly');
    });
  }
}
