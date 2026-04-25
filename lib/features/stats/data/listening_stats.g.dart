// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listening_stats.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDailyListeningStatsCollection on Isar {
  IsarCollection<DailyListeningStats> get dailyListeningStats =>
      this.collection();
}

const DailyListeningStatsSchema = CollectionSchema(
  name: r'DailyListeningStats',
  id: 1382497801070008415,
  properties: {
    r'booksListened': PropertySchema(
      id: 0,
      name: r'booksListened',
      type: IsarType.stringList,
    ),
    r'date': PropertySchema(
      id: 1,
      name: r'date',
      type: IsarType.string,
    ),
    r'listeningSessions': PropertySchema(
      id: 2,
      name: r'listeningSessions',
      type: IsarType.long,
    ),
    r'totalHours': PropertySchema(
      id: 3,
      name: r'totalHours',
      type: IsarType.double,
    ),
    r'totalSecondsListened': PropertySchema(
      id: 4,
      name: r'totalSecondsListened',
      type: IsarType.long,
    )
  },
  estimateSize: _dailyListeningStatsEstimateSize,
  serialize: _dailyListeningStatsSerialize,
  deserialize: _dailyListeningStatsDeserialize,
  deserializeProp: _dailyListeningStatsDeserializeProp,
  idName: r'id',
  indexes: {
    r'date': IndexSchema(
      id: -7552997827385218417,
      name: r'date',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'date',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _dailyListeningStatsGetId,
  getLinks: _dailyListeningStatsGetLinks,
  attach: _dailyListeningStatsAttach,
  version: '3.1.0+1',
);

int _dailyListeningStatsEstimateSize(
  DailyListeningStats object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.booksListened.length * 3;
  {
    for (var i = 0; i < object.booksListened.length; i++) {
      final value = object.booksListened[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.date.length * 3;
  return bytesCount;
}

void _dailyListeningStatsSerialize(
  DailyListeningStats object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeStringList(offsets[0], object.booksListened);
  writer.writeString(offsets[1], object.date);
  writer.writeLong(offsets[2], object.listeningSessions);
  writer.writeDouble(offsets[3], object.totalHours);
  writer.writeLong(offsets[4], object.totalSecondsListened);
}

DailyListeningStats _dailyListeningStatsDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DailyListeningStats(
    booksListened: reader.readStringList(offsets[0]) ?? const [],
    date: reader.readString(offsets[1]),
    listeningSessions: reader.readLongOrNull(offsets[2]) ?? 0,
    totalSecondsListened: reader.readLongOrNull(offsets[4]) ?? 0,
  );
  object.id = id;
  return object;
}

P _dailyListeningStatsDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringList(offset) ?? const []) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _dailyListeningStatsGetId(DailyListeningStats object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _dailyListeningStatsGetLinks(
    DailyListeningStats object) {
  return [];
}

void _dailyListeningStatsAttach(
    IsarCollection<dynamic> col, Id id, DailyListeningStats object) {
  object.id = id;
}

extension DailyListeningStatsByIndex on IsarCollection<DailyListeningStats> {
  Future<DailyListeningStats?> getByDate(String date) {
    return getByIndex(r'date', [date]);
  }

  DailyListeningStats? getByDateSync(String date) {
    return getByIndexSync(r'date', [date]);
  }

  Future<bool> deleteByDate(String date) {
    return deleteByIndex(r'date', [date]);
  }

  bool deleteByDateSync(String date) {
    return deleteByIndexSync(r'date', [date]);
  }

  Future<List<DailyListeningStats?>> getAllByDate(List<String> dateValues) {
    final values = dateValues.map((e) => [e]).toList();
    return getAllByIndex(r'date', values);
  }

  List<DailyListeningStats?> getAllByDateSync(List<String> dateValues) {
    final values = dateValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'date', values);
  }

  Future<int> deleteAllByDate(List<String> dateValues) {
    final values = dateValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'date', values);
  }

  int deleteAllByDateSync(List<String> dateValues) {
    final values = dateValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'date', values);
  }

  Future<Id> putByDate(DailyListeningStats object) {
    return putByIndex(r'date', object);
  }

  Id putByDateSync(DailyListeningStats object, {bool saveLinks = true}) {
    return putByIndexSync(r'date', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByDate(List<DailyListeningStats> objects) {
    return putAllByIndex(r'date', objects);
  }

  List<Id> putAllByDateSync(List<DailyListeningStats> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'date', objects, saveLinks: saveLinks);
  }
}

extension DailyListeningStatsQueryWhereSort
    on QueryBuilder<DailyListeningStats, DailyListeningStats, QWhere> {
  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension DailyListeningStatsQueryWhere
    on QueryBuilder<DailyListeningStats, DailyListeningStats, QWhereClause> {
  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterWhereClause>
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

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterWhereClause>
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

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterWhereClause>
      dateEqualTo(String date) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'date',
        value: [date],
      ));
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterWhereClause>
      dateNotEqualTo(String date) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [],
              upper: [date],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [date],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [date],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [],
              upper: [date],
              includeUpper: false,
            ));
      }
    });
  }
}

extension DailyListeningStatsQueryFilter on QueryBuilder<DailyListeningStats,
    DailyListeningStats, QFilterCondition> {
  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterFilterCondition>
      booksListenedElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'booksListened',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterFilterCondition>
      booksListenedElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'booksListened',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterFilterCondition>
      booksListenedElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'booksListened',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterFilterCondition>
      booksListenedElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'booksListened',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterFilterCondition>
      booksListenedElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'booksListened',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterFilterCondition>
      booksListenedElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'booksListened',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterFilterCondition>
      booksListenedElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'booksListened',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterFilterCondition>
      booksListenedElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'booksListened',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterFilterCondition>
      booksListenedElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'booksListened',
        value: '',
      ));
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterFilterCondition>
      booksListenedElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'booksListened',
        value: '',
      ));
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterFilterCondition>
      booksListenedLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'booksListened',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterFilterCondition>
      booksListenedIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'booksListened',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterFilterCondition>
      booksListenedIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'booksListened',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterFilterCondition>
      booksListenedLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'booksListened',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterFilterCondition>
      booksListenedLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'booksListened',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterFilterCondition>
      booksListenedLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'booksListened',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterFilterCondition>
      dateEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterFilterCondition>
      dateGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'date',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterFilterCondition>
      dateLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'date',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterFilterCondition>
      dateBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'date',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterFilterCondition>
      dateStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'date',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterFilterCondition>
      dateEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'date',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterFilterCondition>
      dateContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'date',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterFilterCondition>
      dateMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'date',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterFilterCondition>
      dateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: '',
      ));
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterFilterCondition>
      dateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'date',
        value: '',
      ));
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterFilterCondition>
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

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterFilterCondition>
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

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterFilterCondition>
      listeningSessionsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'listeningSessions',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterFilterCondition>
      listeningSessionsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'listeningSessions',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterFilterCondition>
      listeningSessionsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'listeningSessions',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterFilterCondition>
      listeningSessionsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'listeningSessions',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterFilterCondition>
      totalHoursEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalHours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterFilterCondition>
      totalHoursGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalHours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterFilterCondition>
      totalHoursLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalHours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterFilterCondition>
      totalHoursBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalHours',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterFilterCondition>
      totalSecondsListenedEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalSecondsListened',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterFilterCondition>
      totalSecondsListenedGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalSecondsListened',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterFilterCondition>
      totalSecondsListenedLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalSecondsListened',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterFilterCondition>
      totalSecondsListenedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalSecondsListened',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension DailyListeningStatsQueryObject on QueryBuilder<DailyListeningStats,
    DailyListeningStats, QFilterCondition> {}

extension DailyListeningStatsQueryLinks on QueryBuilder<DailyListeningStats,
    DailyListeningStats, QFilterCondition> {}

extension DailyListeningStatsQuerySortBy
    on QueryBuilder<DailyListeningStats, DailyListeningStats, QSortBy> {
  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterSortBy>
      sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterSortBy>
      sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterSortBy>
      sortByListeningSessions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'listeningSessions', Sort.asc);
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterSortBy>
      sortByListeningSessionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'listeningSessions', Sort.desc);
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterSortBy>
      sortByTotalHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalHours', Sort.asc);
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterSortBy>
      sortByTotalHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalHours', Sort.desc);
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterSortBy>
      sortByTotalSecondsListened() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSecondsListened', Sort.asc);
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterSortBy>
      sortByTotalSecondsListenedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSecondsListened', Sort.desc);
    });
  }
}

extension DailyListeningStatsQuerySortThenBy
    on QueryBuilder<DailyListeningStats, DailyListeningStats, QSortThenBy> {
  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterSortBy>
      thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterSortBy>
      thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterSortBy>
      thenByListeningSessions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'listeningSessions', Sort.asc);
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterSortBy>
      thenByListeningSessionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'listeningSessions', Sort.desc);
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterSortBy>
      thenByTotalHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalHours', Sort.asc);
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterSortBy>
      thenByTotalHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalHours', Sort.desc);
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterSortBy>
      thenByTotalSecondsListened() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSecondsListened', Sort.asc);
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QAfterSortBy>
      thenByTotalSecondsListenedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSecondsListened', Sort.desc);
    });
  }
}

extension DailyListeningStatsQueryWhereDistinct
    on QueryBuilder<DailyListeningStats, DailyListeningStats, QDistinct> {
  QueryBuilder<DailyListeningStats, DailyListeningStats, QDistinct>
      distinctByBooksListened() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'booksListened');
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QDistinct>
      distinctByDate({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QDistinct>
      distinctByListeningSessions() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'listeningSessions');
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QDistinct>
      distinctByTotalHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalHours');
    });
  }

  QueryBuilder<DailyListeningStats, DailyListeningStats, QDistinct>
      distinctByTotalSecondsListened() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalSecondsListened');
    });
  }
}

extension DailyListeningStatsQueryProperty
    on QueryBuilder<DailyListeningStats, DailyListeningStats, QQueryProperty> {
  QueryBuilder<DailyListeningStats, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DailyListeningStats, List<String>, QQueryOperations>
      booksListenedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'booksListened');
    });
  }

  QueryBuilder<DailyListeningStats, String, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<DailyListeningStats, int, QQueryOperations>
      listeningSessionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'listeningSessions');
    });
  }

  QueryBuilder<DailyListeningStats, double, QQueryOperations>
      totalHoursProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalHours');
    });
  }

  QueryBuilder<DailyListeningStats, int, QQueryOperations>
      totalSecondsListenedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalSecondsListened');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAuthorStatsCollection on Isar {
  IsarCollection<AuthorStats> get authorStats => this.collection();
}

const AuthorStatsSchema = CollectionSchema(
  name: r'AuthorStats',
  id: -6582786283573320068,
  properties: {
    r'authorName': PropertySchema(
      id: 0,
      name: r'authorName',
      type: IsarType.string,
    ),
    r'bookTitles': PropertySchema(
      id: 1,
      name: r'bookTitles',
      type: IsarType.stringList,
    ),
    r'booksCompleted': PropertySchema(
      id: 2,
      name: r'booksCompleted',
      type: IsarType.long,
    ),
    r'booksStarted': PropertySchema(
      id: 3,
      name: r'booksStarted',
      type: IsarType.long,
    ),
    r'totalHours': PropertySchema(
      id: 4,
      name: r'totalHours',
      type: IsarType.double,
    ),
    r'totalSecondsListened': PropertySchema(
      id: 5,
      name: r'totalSecondsListened',
      type: IsarType.long,
    )
  },
  estimateSize: _authorStatsEstimateSize,
  serialize: _authorStatsSerialize,
  deserialize: _authorStatsDeserialize,
  deserializeProp: _authorStatsDeserializeProp,
  idName: r'id',
  indexes: {
    r'authorName': IndexSchema(
      id: -8957794046943539008,
      name: r'authorName',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'authorName',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _authorStatsGetId,
  getLinks: _authorStatsGetLinks,
  attach: _authorStatsAttach,
  version: '3.1.0+1',
);

int _authorStatsEstimateSize(
  AuthorStats object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.authorName.length * 3;
  bytesCount += 3 + object.bookTitles.length * 3;
  {
    for (var i = 0; i < object.bookTitles.length; i++) {
      final value = object.bookTitles[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _authorStatsSerialize(
  AuthorStats object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.authorName);
  writer.writeStringList(offsets[1], object.bookTitles);
  writer.writeLong(offsets[2], object.booksCompleted);
  writer.writeLong(offsets[3], object.booksStarted);
  writer.writeDouble(offsets[4], object.totalHours);
  writer.writeLong(offsets[5], object.totalSecondsListened);
}

AuthorStats _authorStatsDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AuthorStats(
    authorName: reader.readString(offsets[0]),
    bookTitles: reader.readStringList(offsets[1]) ?? const [],
    booksCompleted: reader.readLongOrNull(offsets[2]) ?? 0,
    booksStarted: reader.readLongOrNull(offsets[3]) ?? 0,
    totalSecondsListened: reader.readLongOrNull(offsets[5]) ?? 0,
  );
  object.id = id;
  return object;
}

P _authorStatsDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readStringList(offset) ?? const []) as P;
    case 2:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 3:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    case 5:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _authorStatsGetId(AuthorStats object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _authorStatsGetLinks(AuthorStats object) {
  return [];
}

void _authorStatsAttach(
    IsarCollection<dynamic> col, Id id, AuthorStats object) {
  object.id = id;
}

extension AuthorStatsByIndex on IsarCollection<AuthorStats> {
  Future<AuthorStats?> getByAuthorName(String authorName) {
    return getByIndex(r'authorName', [authorName]);
  }

  AuthorStats? getByAuthorNameSync(String authorName) {
    return getByIndexSync(r'authorName', [authorName]);
  }

  Future<bool> deleteByAuthorName(String authorName) {
    return deleteByIndex(r'authorName', [authorName]);
  }

  bool deleteByAuthorNameSync(String authorName) {
    return deleteByIndexSync(r'authorName', [authorName]);
  }

  Future<List<AuthorStats?>> getAllByAuthorName(List<String> authorNameValues) {
    final values = authorNameValues.map((e) => [e]).toList();
    return getAllByIndex(r'authorName', values);
  }

  List<AuthorStats?> getAllByAuthorNameSync(List<String> authorNameValues) {
    final values = authorNameValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'authorName', values);
  }

  Future<int> deleteAllByAuthorName(List<String> authorNameValues) {
    final values = authorNameValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'authorName', values);
  }

  int deleteAllByAuthorNameSync(List<String> authorNameValues) {
    final values = authorNameValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'authorName', values);
  }

  Future<Id> putByAuthorName(AuthorStats object) {
    return putByIndex(r'authorName', object);
  }

  Id putByAuthorNameSync(AuthorStats object, {bool saveLinks = true}) {
    return putByIndexSync(r'authorName', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByAuthorName(List<AuthorStats> objects) {
    return putAllByIndex(r'authorName', objects);
  }

  List<Id> putAllByAuthorNameSync(List<AuthorStats> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'authorName', objects, saveLinks: saveLinks);
  }
}

extension AuthorStatsQueryWhereSort
    on QueryBuilder<AuthorStats, AuthorStats, QWhere> {
  QueryBuilder<AuthorStats, AuthorStats, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AuthorStatsQueryWhere
    on QueryBuilder<AuthorStats, AuthorStats, QWhereClause> {
  QueryBuilder<AuthorStats, AuthorStats, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<AuthorStats, AuthorStats, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterWhereClause> idBetween(
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

  QueryBuilder<AuthorStats, AuthorStats, QAfterWhereClause> authorNameEqualTo(
      String authorName) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'authorName',
        value: [authorName],
      ));
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterWhereClause>
      authorNameNotEqualTo(String authorName) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'authorName',
              lower: [],
              upper: [authorName],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'authorName',
              lower: [authorName],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'authorName',
              lower: [authorName],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'authorName',
              lower: [],
              upper: [authorName],
              includeUpper: false,
            ));
      }
    });
  }
}

extension AuthorStatsQueryFilter
    on QueryBuilder<AuthorStats, AuthorStats, QFilterCondition> {
  QueryBuilder<AuthorStats, AuthorStats, QAfterFilterCondition>
      authorNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'authorName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterFilterCondition>
      authorNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'authorName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterFilterCondition>
      authorNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'authorName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterFilterCondition>
      authorNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'authorName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterFilterCondition>
      authorNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'authorName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterFilterCondition>
      authorNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'authorName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterFilterCondition>
      authorNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'authorName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterFilterCondition>
      authorNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'authorName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterFilterCondition>
      authorNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'authorName',
        value: '',
      ));
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterFilterCondition>
      authorNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'authorName',
        value: '',
      ));
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterFilterCondition>
      bookTitlesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bookTitles',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterFilterCondition>
      bookTitlesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bookTitles',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterFilterCondition>
      bookTitlesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bookTitles',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterFilterCondition>
      bookTitlesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bookTitles',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterFilterCondition>
      bookTitlesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'bookTitles',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterFilterCondition>
      bookTitlesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'bookTitles',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterFilterCondition>
      bookTitlesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'bookTitles',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterFilterCondition>
      bookTitlesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'bookTitles',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterFilterCondition>
      bookTitlesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bookTitles',
        value: '',
      ));
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterFilterCondition>
      bookTitlesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'bookTitles',
        value: '',
      ));
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterFilterCondition>
      bookTitlesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'bookTitles',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterFilterCondition>
      bookTitlesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'bookTitles',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterFilterCondition>
      bookTitlesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'bookTitles',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterFilterCondition>
      bookTitlesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'bookTitles',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterFilterCondition>
      bookTitlesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'bookTitles',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterFilterCondition>
      bookTitlesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'bookTitles',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterFilterCondition>
      booksCompletedEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'booksCompleted',
        value: value,
      ));
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterFilterCondition>
      booksCompletedGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'booksCompleted',
        value: value,
      ));
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterFilterCondition>
      booksCompletedLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'booksCompleted',
        value: value,
      ));
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterFilterCondition>
      booksCompletedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'booksCompleted',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterFilterCondition>
      booksStartedEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'booksStarted',
        value: value,
      ));
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterFilterCondition>
      booksStartedGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'booksStarted',
        value: value,
      ));
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterFilterCondition>
      booksStartedLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'booksStarted',
        value: value,
      ));
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterFilterCondition>
      booksStartedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'booksStarted',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<AuthorStats, AuthorStats, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<AuthorStats, AuthorStats, QAfterFilterCondition> idBetween(
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

  QueryBuilder<AuthorStats, AuthorStats, QAfterFilterCondition>
      totalHoursEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalHours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterFilterCondition>
      totalHoursGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalHours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterFilterCondition>
      totalHoursLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalHours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterFilterCondition>
      totalHoursBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalHours',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterFilterCondition>
      totalSecondsListenedEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalSecondsListened',
        value: value,
      ));
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterFilterCondition>
      totalSecondsListenedGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalSecondsListened',
        value: value,
      ));
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterFilterCondition>
      totalSecondsListenedLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalSecondsListened',
        value: value,
      ));
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterFilterCondition>
      totalSecondsListenedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalSecondsListened',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AuthorStatsQueryObject
    on QueryBuilder<AuthorStats, AuthorStats, QFilterCondition> {}

extension AuthorStatsQueryLinks
    on QueryBuilder<AuthorStats, AuthorStats, QFilterCondition> {}

extension AuthorStatsQuerySortBy
    on QueryBuilder<AuthorStats, AuthorStats, QSortBy> {
  QueryBuilder<AuthorStats, AuthorStats, QAfterSortBy> sortByAuthorName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'authorName', Sort.asc);
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterSortBy> sortByAuthorNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'authorName', Sort.desc);
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterSortBy> sortByBooksCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'booksCompleted', Sort.asc);
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterSortBy>
      sortByBooksCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'booksCompleted', Sort.desc);
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterSortBy> sortByBooksStarted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'booksStarted', Sort.asc);
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterSortBy>
      sortByBooksStartedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'booksStarted', Sort.desc);
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterSortBy> sortByTotalHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalHours', Sort.asc);
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterSortBy> sortByTotalHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalHours', Sort.desc);
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterSortBy>
      sortByTotalSecondsListened() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSecondsListened', Sort.asc);
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterSortBy>
      sortByTotalSecondsListenedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSecondsListened', Sort.desc);
    });
  }
}

extension AuthorStatsQuerySortThenBy
    on QueryBuilder<AuthorStats, AuthorStats, QSortThenBy> {
  QueryBuilder<AuthorStats, AuthorStats, QAfterSortBy> thenByAuthorName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'authorName', Sort.asc);
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterSortBy> thenByAuthorNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'authorName', Sort.desc);
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterSortBy> thenByBooksCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'booksCompleted', Sort.asc);
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterSortBy>
      thenByBooksCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'booksCompleted', Sort.desc);
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterSortBy> thenByBooksStarted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'booksStarted', Sort.asc);
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterSortBy>
      thenByBooksStartedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'booksStarted', Sort.desc);
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterSortBy> thenByTotalHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalHours', Sort.asc);
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterSortBy> thenByTotalHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalHours', Sort.desc);
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterSortBy>
      thenByTotalSecondsListened() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSecondsListened', Sort.asc);
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QAfterSortBy>
      thenByTotalSecondsListenedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSecondsListened', Sort.desc);
    });
  }
}

extension AuthorStatsQueryWhereDistinct
    on QueryBuilder<AuthorStats, AuthorStats, QDistinct> {
  QueryBuilder<AuthorStats, AuthorStats, QDistinct> distinctByAuthorName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'authorName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QDistinct> distinctByBookTitles() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bookTitles');
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QDistinct> distinctByBooksCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'booksCompleted');
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QDistinct> distinctByBooksStarted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'booksStarted');
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QDistinct> distinctByTotalHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalHours');
    });
  }

  QueryBuilder<AuthorStats, AuthorStats, QDistinct>
      distinctByTotalSecondsListened() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalSecondsListened');
    });
  }
}

extension AuthorStatsQueryProperty
    on QueryBuilder<AuthorStats, AuthorStats, QQueryProperty> {
  QueryBuilder<AuthorStats, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AuthorStats, String, QQueryOperations> authorNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'authorName');
    });
  }

  QueryBuilder<AuthorStats, List<String>, QQueryOperations>
      bookTitlesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bookTitles');
    });
  }

  QueryBuilder<AuthorStats, int, QQueryOperations> booksCompletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'booksCompleted');
    });
  }

  QueryBuilder<AuthorStats, int, QQueryOperations> booksStartedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'booksStarted');
    });
  }

  QueryBuilder<AuthorStats, double, QQueryOperations> totalHoursProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalHours');
    });
  }

  QueryBuilder<AuthorStats, int, QQueryOperations>
      totalSecondsListenedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalSecondsListened');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBookCompletionStatsCollection on Isar {
  IsarCollection<BookCompletionStats> get bookCompletionStats =>
      this.collection();
}

const BookCompletionStatsSchema = CollectionSchema(
  name: r'BookCompletionStats',
  id: 301941356970487199,
  properties: {
    r'author': PropertySchema(
      id: 0,
      name: r'author',
      type: IsarType.string,
    ),
    r'bookPath': PropertySchema(
      id: 1,
      name: r'bookPath',
      type: IsarType.string,
    ),
    r'bookTitle': PropertySchema(
      id: 2,
      name: r'bookTitle',
      type: IsarType.string,
    ),
    r'completedDate': PropertySchema(
      id: 3,
      name: r'completedDate',
      type: IsarType.dateTime,
    ),
    r'isCompleted': PropertySchema(
      id: 4,
      name: r'isCompleted',
      type: IsarType.bool,
    ),
    r'startedDate': PropertySchema(
      id: 5,
      name: r'startedDate',
      type: IsarType.dateTime,
    ),
    r'totalHours': PropertySchema(
      id: 6,
      name: r'totalHours',
      type: IsarType.double,
    ),
    r'totalSecondsListened': PropertySchema(
      id: 7,
      name: r'totalSecondsListened',
      type: IsarType.long,
    )
  },
  estimateSize: _bookCompletionStatsEstimateSize,
  serialize: _bookCompletionStatsSerialize,
  deserialize: _bookCompletionStatsDeserialize,
  deserializeProp: _bookCompletionStatsDeserializeProp,
  idName: r'id',
  indexes: {
    r'bookPath': IndexSchema(
      id: -1443576583343870635,
      name: r'bookPath',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'bookPath',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _bookCompletionStatsGetId,
  getLinks: _bookCompletionStatsGetLinks,
  attach: _bookCompletionStatsAttach,
  version: '3.1.0+1',
);

int _bookCompletionStatsEstimateSize(
  BookCompletionStats object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.author;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.bookPath.length * 3;
  bytesCount += 3 + object.bookTitle.length * 3;
  return bytesCount;
}

void _bookCompletionStatsSerialize(
  BookCompletionStats object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.author);
  writer.writeString(offsets[1], object.bookPath);
  writer.writeString(offsets[2], object.bookTitle);
  writer.writeDateTime(offsets[3], object.completedDate);
  writer.writeBool(offsets[4], object.isCompleted);
  writer.writeDateTime(offsets[5], object.startedDate);
  writer.writeDouble(offsets[6], object.totalHours);
  writer.writeLong(offsets[7], object.totalSecondsListened);
}

BookCompletionStats _bookCompletionStatsDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BookCompletionStats(
    author: reader.readStringOrNull(offsets[0]),
    bookPath: reader.readString(offsets[1]),
    bookTitle: reader.readString(offsets[2]),
    completedDate: reader.readDateTimeOrNull(offsets[3]),
    isCompleted: reader.readBoolOrNull(offsets[4]) ?? false,
    startedDate: reader.readDateTimeOrNull(offsets[5]),
    totalSecondsListened: reader.readLongOrNull(offsets[7]) ?? 0,
  );
  object.id = id;
  return object;
}

P _bookCompletionStatsDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    case 7:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _bookCompletionStatsGetId(BookCompletionStats object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _bookCompletionStatsGetLinks(
    BookCompletionStats object) {
  return [];
}

void _bookCompletionStatsAttach(
    IsarCollection<dynamic> col, Id id, BookCompletionStats object) {
  object.id = id;
}

extension BookCompletionStatsByIndex on IsarCollection<BookCompletionStats> {
  Future<BookCompletionStats?> getByBookPath(String bookPath) {
    return getByIndex(r'bookPath', [bookPath]);
  }

  BookCompletionStats? getByBookPathSync(String bookPath) {
    return getByIndexSync(r'bookPath', [bookPath]);
  }

  Future<bool> deleteByBookPath(String bookPath) {
    return deleteByIndex(r'bookPath', [bookPath]);
  }

  bool deleteByBookPathSync(String bookPath) {
    return deleteByIndexSync(r'bookPath', [bookPath]);
  }

  Future<List<BookCompletionStats?>> getAllByBookPath(
      List<String> bookPathValues) {
    final values = bookPathValues.map((e) => [e]).toList();
    return getAllByIndex(r'bookPath', values);
  }

  List<BookCompletionStats?> getAllByBookPathSync(List<String> bookPathValues) {
    final values = bookPathValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'bookPath', values);
  }

  Future<int> deleteAllByBookPath(List<String> bookPathValues) {
    final values = bookPathValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'bookPath', values);
  }

  int deleteAllByBookPathSync(List<String> bookPathValues) {
    final values = bookPathValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'bookPath', values);
  }

  Future<Id> putByBookPath(BookCompletionStats object) {
    return putByIndex(r'bookPath', object);
  }

  Id putByBookPathSync(BookCompletionStats object, {bool saveLinks = true}) {
    return putByIndexSync(r'bookPath', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByBookPath(List<BookCompletionStats> objects) {
    return putAllByIndex(r'bookPath', objects);
  }

  List<Id> putAllByBookPathSync(List<BookCompletionStats> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'bookPath', objects, saveLinks: saveLinks);
  }
}

extension BookCompletionStatsQueryWhereSort
    on QueryBuilder<BookCompletionStats, BookCompletionStats, QWhere> {
  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension BookCompletionStatsQueryWhere
    on QueryBuilder<BookCompletionStats, BookCompletionStats, QWhereClause> {
  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterWhereClause>
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

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterWhereClause>
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

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterWhereClause>
      bookPathEqualTo(String bookPath) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'bookPath',
        value: [bookPath],
      ));
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterWhereClause>
      bookPathNotEqualTo(String bookPath) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookPath',
              lower: [],
              upper: [bookPath],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookPath',
              lower: [bookPath],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookPath',
              lower: [bookPath],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookPath',
              lower: [],
              upper: [bookPath],
              includeUpper: false,
            ));
      }
    });
  }
}

extension BookCompletionStatsQueryFilter on QueryBuilder<BookCompletionStats,
    BookCompletionStats, QFilterCondition> {
  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterFilterCondition>
      authorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'author',
      ));
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterFilterCondition>
      authorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'author',
      ));
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterFilterCondition>
      authorEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'author',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterFilterCondition>
      authorGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'author',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterFilterCondition>
      authorLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'author',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterFilterCondition>
      authorBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'author',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterFilterCondition>
      authorStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'author',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterFilterCondition>
      authorEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'author',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterFilterCondition>
      authorContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'author',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterFilterCondition>
      authorMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'author',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterFilterCondition>
      authorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'author',
        value: '',
      ));
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterFilterCondition>
      authorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'author',
        value: '',
      ));
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterFilterCondition>
      bookPathEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bookPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterFilterCondition>
      bookPathGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bookPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterFilterCondition>
      bookPathLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bookPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterFilterCondition>
      bookPathBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bookPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterFilterCondition>
      bookPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'bookPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterFilterCondition>
      bookPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'bookPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterFilterCondition>
      bookPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'bookPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterFilterCondition>
      bookPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'bookPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterFilterCondition>
      bookPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bookPath',
        value: '',
      ));
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterFilterCondition>
      bookPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'bookPath',
        value: '',
      ));
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterFilterCondition>
      bookTitleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bookTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterFilterCondition>
      bookTitleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bookTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterFilterCondition>
      bookTitleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bookTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterFilterCondition>
      bookTitleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bookTitle',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterFilterCondition>
      bookTitleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'bookTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterFilterCondition>
      bookTitleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'bookTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterFilterCondition>
      bookTitleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'bookTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterFilterCondition>
      bookTitleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'bookTitle',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterFilterCondition>
      bookTitleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bookTitle',
        value: '',
      ));
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterFilterCondition>
      bookTitleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'bookTitle',
        value: '',
      ));
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterFilterCondition>
      completedDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'completedDate',
      ));
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterFilterCondition>
      completedDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'completedDate',
      ));
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterFilterCondition>
      completedDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completedDate',
        value: value,
      ));
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterFilterCondition>
      completedDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'completedDate',
        value: value,
      ));
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterFilterCondition>
      completedDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'completedDate',
        value: value,
      ));
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterFilterCondition>
      completedDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'completedDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterFilterCondition>
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

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterFilterCondition>
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

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterFilterCondition>
      isCompletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isCompleted',
        value: value,
      ));
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterFilterCondition>
      startedDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'startedDate',
      ));
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterFilterCondition>
      startedDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'startedDate',
      ));
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterFilterCondition>
      startedDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startedDate',
        value: value,
      ));
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterFilterCondition>
      startedDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startedDate',
        value: value,
      ));
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterFilterCondition>
      startedDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startedDate',
        value: value,
      ));
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterFilterCondition>
      startedDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startedDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterFilterCondition>
      totalHoursEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalHours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterFilterCondition>
      totalHoursGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalHours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterFilterCondition>
      totalHoursLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalHours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterFilterCondition>
      totalHoursBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalHours',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterFilterCondition>
      totalSecondsListenedEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalSecondsListened',
        value: value,
      ));
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterFilterCondition>
      totalSecondsListenedGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalSecondsListened',
        value: value,
      ));
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterFilterCondition>
      totalSecondsListenedLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalSecondsListened',
        value: value,
      ));
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterFilterCondition>
      totalSecondsListenedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalSecondsListened',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension BookCompletionStatsQueryObject on QueryBuilder<BookCompletionStats,
    BookCompletionStats, QFilterCondition> {}

extension BookCompletionStatsQueryLinks on QueryBuilder<BookCompletionStats,
    BookCompletionStats, QFilterCondition> {}

extension BookCompletionStatsQuerySortBy
    on QueryBuilder<BookCompletionStats, BookCompletionStats, QSortBy> {
  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterSortBy>
      sortByAuthor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'author', Sort.asc);
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterSortBy>
      sortByAuthorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'author', Sort.desc);
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterSortBy>
      sortByBookPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookPath', Sort.asc);
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterSortBy>
      sortByBookPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookPath', Sort.desc);
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterSortBy>
      sortByBookTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookTitle', Sort.asc);
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterSortBy>
      sortByBookTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookTitle', Sort.desc);
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterSortBy>
      sortByCompletedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedDate', Sort.asc);
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterSortBy>
      sortByCompletedDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedDate', Sort.desc);
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterSortBy>
      sortByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.asc);
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterSortBy>
      sortByIsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.desc);
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterSortBy>
      sortByStartedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedDate', Sort.asc);
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterSortBy>
      sortByStartedDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedDate', Sort.desc);
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterSortBy>
      sortByTotalHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalHours', Sort.asc);
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterSortBy>
      sortByTotalHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalHours', Sort.desc);
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterSortBy>
      sortByTotalSecondsListened() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSecondsListened', Sort.asc);
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterSortBy>
      sortByTotalSecondsListenedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSecondsListened', Sort.desc);
    });
  }
}

extension BookCompletionStatsQuerySortThenBy
    on QueryBuilder<BookCompletionStats, BookCompletionStats, QSortThenBy> {
  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterSortBy>
      thenByAuthor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'author', Sort.asc);
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterSortBy>
      thenByAuthorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'author', Sort.desc);
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterSortBy>
      thenByBookPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookPath', Sort.asc);
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterSortBy>
      thenByBookPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookPath', Sort.desc);
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterSortBy>
      thenByBookTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookTitle', Sort.asc);
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterSortBy>
      thenByBookTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookTitle', Sort.desc);
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterSortBy>
      thenByCompletedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedDate', Sort.asc);
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterSortBy>
      thenByCompletedDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedDate', Sort.desc);
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterSortBy>
      thenByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.asc);
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterSortBy>
      thenByIsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.desc);
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterSortBy>
      thenByStartedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedDate', Sort.asc);
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterSortBy>
      thenByStartedDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedDate', Sort.desc);
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterSortBy>
      thenByTotalHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalHours', Sort.asc);
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterSortBy>
      thenByTotalHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalHours', Sort.desc);
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterSortBy>
      thenByTotalSecondsListened() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSecondsListened', Sort.asc);
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QAfterSortBy>
      thenByTotalSecondsListenedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSecondsListened', Sort.desc);
    });
  }
}

extension BookCompletionStatsQueryWhereDistinct
    on QueryBuilder<BookCompletionStats, BookCompletionStats, QDistinct> {
  QueryBuilder<BookCompletionStats, BookCompletionStats, QDistinct>
      distinctByAuthor({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'author', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QDistinct>
      distinctByBookPath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bookPath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QDistinct>
      distinctByBookTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bookTitle', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QDistinct>
      distinctByCompletedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completedDate');
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QDistinct>
      distinctByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isCompleted');
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QDistinct>
      distinctByStartedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startedDate');
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QDistinct>
      distinctByTotalHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalHours');
    });
  }

  QueryBuilder<BookCompletionStats, BookCompletionStats, QDistinct>
      distinctByTotalSecondsListened() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalSecondsListened');
    });
  }
}

extension BookCompletionStatsQueryProperty
    on QueryBuilder<BookCompletionStats, BookCompletionStats, QQueryProperty> {
  QueryBuilder<BookCompletionStats, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<BookCompletionStats, String?, QQueryOperations>
      authorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'author');
    });
  }

  QueryBuilder<BookCompletionStats, String, QQueryOperations>
      bookPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bookPath');
    });
  }

  QueryBuilder<BookCompletionStats, String, QQueryOperations>
      bookTitleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bookTitle');
    });
  }

  QueryBuilder<BookCompletionStats, DateTime?, QQueryOperations>
      completedDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completedDate');
    });
  }

  QueryBuilder<BookCompletionStats, bool, QQueryOperations>
      isCompletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isCompleted');
    });
  }

  QueryBuilder<BookCompletionStats, DateTime?, QQueryOperations>
      startedDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startedDate');
    });
  }

  QueryBuilder<BookCompletionStats, double, QQueryOperations>
      totalHoursProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalHours');
    });
  }

  QueryBuilder<BookCompletionStats, int, QQueryOperations>
      totalSecondsListenedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalSecondsListened');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetListeningSpeedPreferenceCollection on Isar {
  IsarCollection<ListeningSpeedPreference> get listeningSpeedPreferences =>
      this.collection();
}

const ListeningSpeedPreferenceSchema = CollectionSchema(
  name: r'ListeningSpeedPreference',
  id: 6869481994549383175,
  properties: {
    r'averageSpeed': PropertySchema(
      id: 0,
      name: r'averageSpeed',
      type: IsarType.double,
    ),
    r'speedUsageCountJson': PropertySchema(
      id: 1,
      name: r'speedUsageCountJson',
      type: IsarType.string,
    ),
    r'totalSessionsAtSpeed': PropertySchema(
      id: 2,
      name: r'totalSessionsAtSpeed',
      type: IsarType.long,
    )
  },
  estimateSize: _listeningSpeedPreferenceEstimateSize,
  serialize: _listeningSpeedPreferenceSerialize,
  deserialize: _listeningSpeedPreferenceDeserialize,
  deserializeProp: _listeningSpeedPreferenceDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _listeningSpeedPreferenceGetId,
  getLinks: _listeningSpeedPreferenceGetLinks,
  attach: _listeningSpeedPreferenceAttach,
  version: '3.1.0+1',
);

int _listeningSpeedPreferenceEstimateSize(
  ListeningSpeedPreference object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.speedUsageCountJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _listeningSpeedPreferenceSerialize(
  ListeningSpeedPreference object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.averageSpeed);
  writer.writeString(offsets[1], object.speedUsageCountJson);
  writer.writeLong(offsets[2], object.totalSessionsAtSpeed);
}

ListeningSpeedPreference _listeningSpeedPreferenceDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ListeningSpeedPreference(
    averageSpeed: reader.readDoubleOrNull(offsets[0]) ?? 1.0,
    speedUsageCountJson: reader.readStringOrNull(offsets[1]),
    totalSessionsAtSpeed: reader.readLongOrNull(offsets[2]) ?? 0,
  );
  object.id = id;
  return object;
}

P _listeningSpeedPreferenceDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDoubleOrNull(offset) ?? 1.0) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _listeningSpeedPreferenceGetId(ListeningSpeedPreference object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _listeningSpeedPreferenceGetLinks(
    ListeningSpeedPreference object) {
  return [];
}

void _listeningSpeedPreferenceAttach(
    IsarCollection<dynamic> col, Id id, ListeningSpeedPreference object) {
  object.id = id;
}

extension ListeningSpeedPreferenceQueryWhereSort on QueryBuilder<
    ListeningSpeedPreference, ListeningSpeedPreference, QWhere> {
  QueryBuilder<ListeningSpeedPreference, ListeningSpeedPreference, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ListeningSpeedPreferenceQueryWhere on QueryBuilder<
    ListeningSpeedPreference, ListeningSpeedPreference, QWhereClause> {
  QueryBuilder<ListeningSpeedPreference, ListeningSpeedPreference,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ListeningSpeedPreference, ListeningSpeedPreference,
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

  QueryBuilder<ListeningSpeedPreference, ListeningSpeedPreference,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ListeningSpeedPreference, ListeningSpeedPreference,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ListeningSpeedPreference, ListeningSpeedPreference,
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

extension ListeningSpeedPreferenceQueryFilter on QueryBuilder<
    ListeningSpeedPreference, ListeningSpeedPreference, QFilterCondition> {
  QueryBuilder<ListeningSpeedPreference, ListeningSpeedPreference,
      QAfterFilterCondition> averageSpeedEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'averageSpeed',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ListeningSpeedPreference, ListeningSpeedPreference,
      QAfterFilterCondition> averageSpeedGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'averageSpeed',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ListeningSpeedPreference, ListeningSpeedPreference,
      QAfterFilterCondition> averageSpeedLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'averageSpeed',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ListeningSpeedPreference, ListeningSpeedPreference,
      QAfterFilterCondition> averageSpeedBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'averageSpeed',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ListeningSpeedPreference, ListeningSpeedPreference,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ListeningSpeedPreference, ListeningSpeedPreference,
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

  QueryBuilder<ListeningSpeedPreference, ListeningSpeedPreference,
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

  QueryBuilder<ListeningSpeedPreference, ListeningSpeedPreference,
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

  QueryBuilder<ListeningSpeedPreference, ListeningSpeedPreference,
      QAfterFilterCondition> speedUsageCountJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'speedUsageCountJson',
      ));
    });
  }

  QueryBuilder<ListeningSpeedPreference, ListeningSpeedPreference,
      QAfterFilterCondition> speedUsageCountJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'speedUsageCountJson',
      ));
    });
  }

  QueryBuilder<ListeningSpeedPreference, ListeningSpeedPreference,
      QAfterFilterCondition> speedUsageCountJsonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'speedUsageCountJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ListeningSpeedPreference, ListeningSpeedPreference,
      QAfterFilterCondition> speedUsageCountJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'speedUsageCountJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ListeningSpeedPreference, ListeningSpeedPreference,
      QAfterFilterCondition> speedUsageCountJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'speedUsageCountJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ListeningSpeedPreference, ListeningSpeedPreference,
      QAfterFilterCondition> speedUsageCountJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'speedUsageCountJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ListeningSpeedPreference, ListeningSpeedPreference,
      QAfterFilterCondition> speedUsageCountJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'speedUsageCountJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ListeningSpeedPreference, ListeningSpeedPreference,
      QAfterFilterCondition> speedUsageCountJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'speedUsageCountJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ListeningSpeedPreference, ListeningSpeedPreference,
          QAfterFilterCondition>
      speedUsageCountJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'speedUsageCountJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ListeningSpeedPreference, ListeningSpeedPreference,
          QAfterFilterCondition>
      speedUsageCountJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'speedUsageCountJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ListeningSpeedPreference, ListeningSpeedPreference,
      QAfterFilterCondition> speedUsageCountJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'speedUsageCountJson',
        value: '',
      ));
    });
  }

  QueryBuilder<ListeningSpeedPreference, ListeningSpeedPreference,
      QAfterFilterCondition> speedUsageCountJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'speedUsageCountJson',
        value: '',
      ));
    });
  }

  QueryBuilder<ListeningSpeedPreference, ListeningSpeedPreference,
      QAfterFilterCondition> totalSessionsAtSpeedEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalSessionsAtSpeed',
        value: value,
      ));
    });
  }

  QueryBuilder<ListeningSpeedPreference, ListeningSpeedPreference,
      QAfterFilterCondition> totalSessionsAtSpeedGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalSessionsAtSpeed',
        value: value,
      ));
    });
  }

  QueryBuilder<ListeningSpeedPreference, ListeningSpeedPreference,
      QAfterFilterCondition> totalSessionsAtSpeedLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalSessionsAtSpeed',
        value: value,
      ));
    });
  }

  QueryBuilder<ListeningSpeedPreference, ListeningSpeedPreference,
      QAfterFilterCondition> totalSessionsAtSpeedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalSessionsAtSpeed',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ListeningSpeedPreferenceQueryObject on QueryBuilder<
    ListeningSpeedPreference, ListeningSpeedPreference, QFilterCondition> {}

extension ListeningSpeedPreferenceQueryLinks on QueryBuilder<
    ListeningSpeedPreference, ListeningSpeedPreference, QFilterCondition> {}

extension ListeningSpeedPreferenceQuerySortBy on QueryBuilder<
    ListeningSpeedPreference, ListeningSpeedPreference, QSortBy> {
  QueryBuilder<ListeningSpeedPreference, ListeningSpeedPreference, QAfterSortBy>
      sortByAverageSpeed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'averageSpeed', Sort.asc);
    });
  }

  QueryBuilder<ListeningSpeedPreference, ListeningSpeedPreference, QAfterSortBy>
      sortByAverageSpeedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'averageSpeed', Sort.desc);
    });
  }

  QueryBuilder<ListeningSpeedPreference, ListeningSpeedPreference, QAfterSortBy>
      sortBySpeedUsageCountJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speedUsageCountJson', Sort.asc);
    });
  }

  QueryBuilder<ListeningSpeedPreference, ListeningSpeedPreference, QAfterSortBy>
      sortBySpeedUsageCountJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speedUsageCountJson', Sort.desc);
    });
  }

  QueryBuilder<ListeningSpeedPreference, ListeningSpeedPreference, QAfterSortBy>
      sortByTotalSessionsAtSpeed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSessionsAtSpeed', Sort.asc);
    });
  }

  QueryBuilder<ListeningSpeedPreference, ListeningSpeedPreference, QAfterSortBy>
      sortByTotalSessionsAtSpeedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSessionsAtSpeed', Sort.desc);
    });
  }
}

extension ListeningSpeedPreferenceQuerySortThenBy on QueryBuilder<
    ListeningSpeedPreference, ListeningSpeedPreference, QSortThenBy> {
  QueryBuilder<ListeningSpeedPreference, ListeningSpeedPreference, QAfterSortBy>
      thenByAverageSpeed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'averageSpeed', Sort.asc);
    });
  }

  QueryBuilder<ListeningSpeedPreference, ListeningSpeedPreference, QAfterSortBy>
      thenByAverageSpeedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'averageSpeed', Sort.desc);
    });
  }

  QueryBuilder<ListeningSpeedPreference, ListeningSpeedPreference, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ListeningSpeedPreference, ListeningSpeedPreference, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ListeningSpeedPreference, ListeningSpeedPreference, QAfterSortBy>
      thenBySpeedUsageCountJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speedUsageCountJson', Sort.asc);
    });
  }

  QueryBuilder<ListeningSpeedPreference, ListeningSpeedPreference, QAfterSortBy>
      thenBySpeedUsageCountJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speedUsageCountJson', Sort.desc);
    });
  }

  QueryBuilder<ListeningSpeedPreference, ListeningSpeedPreference, QAfterSortBy>
      thenByTotalSessionsAtSpeed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSessionsAtSpeed', Sort.asc);
    });
  }

  QueryBuilder<ListeningSpeedPreference, ListeningSpeedPreference, QAfterSortBy>
      thenByTotalSessionsAtSpeedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSessionsAtSpeed', Sort.desc);
    });
  }
}

extension ListeningSpeedPreferenceQueryWhereDistinct on QueryBuilder<
    ListeningSpeedPreference, ListeningSpeedPreference, QDistinct> {
  QueryBuilder<ListeningSpeedPreference, ListeningSpeedPreference, QDistinct>
      distinctByAverageSpeed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'averageSpeed');
    });
  }

  QueryBuilder<ListeningSpeedPreference, ListeningSpeedPreference, QDistinct>
      distinctBySpeedUsageCountJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'speedUsageCountJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ListeningSpeedPreference, ListeningSpeedPreference, QDistinct>
      distinctByTotalSessionsAtSpeed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalSessionsAtSpeed');
    });
  }
}

extension ListeningSpeedPreferenceQueryProperty on QueryBuilder<
    ListeningSpeedPreference, ListeningSpeedPreference, QQueryProperty> {
  QueryBuilder<ListeningSpeedPreference, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ListeningSpeedPreference, double, QQueryOperations>
      averageSpeedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'averageSpeed');
    });
  }

  QueryBuilder<ListeningSpeedPreference, String?, QQueryOperations>
      speedUsageCountJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'speedUsageCountJson');
    });
  }

  QueryBuilder<ListeningSpeedPreference, int, QQueryOperations>
      totalSessionsAtSpeedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalSessionsAtSpeed');
    });
  }
}
