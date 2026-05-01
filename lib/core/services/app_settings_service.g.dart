// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings_service.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIsarAppSettingsCollection on Isar {
  IsarCollection<IsarAppSettings> get isarAppSettings => this.collection();
}

const IsarAppSettingsSchema = CollectionSchema(
  name: r'IsarAppSettings',
  id: -9223260734181630302,
  properties: {
    r'audioPreset': PropertySchema(
      id: 0,
      name: r'audioPreset',
      type: IsarType.byte,
      enumMap: _IsarAppSettingsaudioPresetEnumValueMap,
    ),
    r'libraryPaths': PropertySchema(
      id: 1,
      name: r'libraryPaths',
      type: IsarType.stringList,
    ),
    r'loudnessNormalization': PropertySchema(
      id: 2,
      name: r'loudnessNormalization',
      type: IsarType.bool,
    ),
    r'playerThemeMode': PropertySchema(
      id: 3,
      name: r'playerThemeMode',
      type: IsarType.byte,
      enumMap: _IsarAppSettingsplayerThemeModeEnumValueMap,
    ),
    r'showCoverReflection': PropertySchema(
      id: 4,
      name: r'showCoverReflection',
      type: IsarType.bool,
    ),
    r'showWaveform': PropertySchema(
      id: 5,
      name: r'showWaveform',
      type: IsarType.bool,
    ),
    r'skipSilence': PropertySchema(
      id: 6,
      name: r'skipSilence',
      type: IsarType.bool,
    ),
    r'themeMode': PropertySchema(
      id: 7,
      name: r'themeMode',
      type: IsarType.byte,
      enumMap: _IsarAppSettingsthemeModeEnumValueMap,
    ),
  },

  estimateSize: _isarAppSettingsEstimateSize,
  serialize: _isarAppSettingsSerialize,
  deserialize: _isarAppSettingsDeserialize,
  deserializeProp: _isarAppSettingsDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _isarAppSettingsGetId,
  getLinks: _isarAppSettingsGetLinks,
  attach: _isarAppSettingsAttach,
  version: '3.3.2',
);

int _isarAppSettingsEstimateSize(
  IsarAppSettings object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.libraryPaths.length * 3;
  {
    for (var i = 0; i < object.libraryPaths.length; i++) {
      final value = object.libraryPaths[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _isarAppSettingsSerialize(
  IsarAppSettings object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeByte(offsets[0], object.audioPreset.index);
  writer.writeStringList(offsets[1], object.libraryPaths);
  writer.writeBool(offsets[2], object.loudnessNormalization);
  writer.writeByte(offsets[3], object.playerThemeMode.index);
  writer.writeBool(offsets[4], object.showCoverReflection);
  writer.writeBool(offsets[5], object.showWaveform);
  writer.writeBool(offsets[6], object.skipSilence);
  writer.writeByte(offsets[7], object.themeMode.index);
}

IsarAppSettings _isarAppSettingsDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarAppSettings();
  object.audioPreset =
      _IsarAppSettingsaudioPresetValueEnumMap[reader.readByteOrNull(
        offsets[0],
      )] ??
      AudioPreset.flat;
  object.id = id;
  object.libraryPaths = reader.readStringList(offsets[1]) ?? [];
  object.loudnessNormalization = reader.readBool(offsets[2]);
  object.playerThemeMode =
      _IsarAppSettingsplayerThemeModeValueEnumMap[reader.readByteOrNull(
        offsets[3],
      )] ??
      PlayerThemeMode.standard;
  object.showCoverReflection = reader.readBool(offsets[4]);
  object.showWaveform = reader.readBool(offsets[5]);
  object.skipSilence = reader.readBool(offsets[6]);
  object.themeMode =
      _IsarAppSettingsthemeModeValueEnumMap[reader.readByteOrNull(
        offsets[7],
      )] ??
      ThemeMode.system;
  return object;
}

P _isarAppSettingsDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (_IsarAppSettingsaudioPresetValueEnumMap[reader.readByteOrNull(
                offset,
              )] ??
              AudioPreset.flat)
          as P;
    case 1:
      return (reader.readStringList(offset) ?? []) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (_IsarAppSettingsplayerThemeModeValueEnumMap[reader.readByteOrNull(
                offset,
              )] ??
              PlayerThemeMode.standard)
          as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (_IsarAppSettingsthemeModeValueEnumMap[reader.readByteOrNull(
                offset,
              )] ??
              ThemeMode.system)
          as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _IsarAppSettingsaudioPresetEnumValueMap = {
  'flat': 0,
  'voiceEnhance': 1,
  'bassBoost': 2,
};
const _IsarAppSettingsaudioPresetValueEnumMap = {
  0: AudioPreset.flat,
  1: AudioPreset.voiceEnhance,
  2: AudioPreset.bassBoost,
};
const _IsarAppSettingsplayerThemeModeEnumValueMap = {
  'standard': 0,
  'trueBlack': 1,
  'adaptive': 2,
};
const _IsarAppSettingsplayerThemeModeValueEnumMap = {
  0: PlayerThemeMode.standard,
  1: PlayerThemeMode.trueBlack,
  2: PlayerThemeMode.adaptive,
};
const _IsarAppSettingsthemeModeEnumValueMap = {
  'system': 0,
  'light': 1,
  'dark': 2,
};
const _IsarAppSettingsthemeModeValueEnumMap = {
  0: ThemeMode.system,
  1: ThemeMode.light,
  2: ThemeMode.dark,
};

Id _isarAppSettingsGetId(IsarAppSettings object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _isarAppSettingsGetLinks(IsarAppSettings object) {
  return [];
}

void _isarAppSettingsAttach(
  IsarCollection<dynamic> col,
  Id id,
  IsarAppSettings object,
) {
  object.id = id;
}

extension IsarAppSettingsQueryWhereSort
    on QueryBuilder<IsarAppSettings, IsarAppSettings, QWhere> {
  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension IsarAppSettingsQueryWhere
    on QueryBuilder<IsarAppSettings, IsarAppSettings, QWhereClause> {
  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterWhereClause>
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

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension IsarAppSettingsQueryFilter
    on QueryBuilder<IsarAppSettings, IsarAppSettings, QFilterCondition> {
  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterFilterCondition>
  audioPresetEqualTo(AudioPreset value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'audioPreset', value: value),
      );
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterFilterCondition>
  audioPresetGreaterThan(AudioPreset value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'audioPreset',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterFilterCondition>
  audioPresetLessThan(AudioPreset value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'audioPreset',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterFilterCondition>
  audioPresetBetween(
    AudioPreset lower,
    AudioPreset upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'audioPreset',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterFilterCondition>
  idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterFilterCondition>
  idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterFilterCondition>
  libraryPathsElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'libraryPaths',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterFilterCondition>
  libraryPathsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'libraryPaths',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterFilterCondition>
  libraryPathsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'libraryPaths',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterFilterCondition>
  libraryPathsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'libraryPaths',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterFilterCondition>
  libraryPathsElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'libraryPaths',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterFilterCondition>
  libraryPathsElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'libraryPaths',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterFilterCondition>
  libraryPathsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'libraryPaths',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterFilterCondition>
  libraryPathsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'libraryPaths',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterFilterCondition>
  libraryPathsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'libraryPaths', value: ''),
      );
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterFilterCondition>
  libraryPathsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'libraryPaths', value: ''),
      );
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterFilterCondition>
  libraryPathsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'libraryPaths', length, true, length, true);
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterFilterCondition>
  libraryPathsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'libraryPaths', 0, true, 0, true);
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterFilterCondition>
  libraryPathsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'libraryPaths', 0, false, 999999, true);
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterFilterCondition>
  libraryPathsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'libraryPaths', 0, true, length, include);
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterFilterCondition>
  libraryPathsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'libraryPaths', length, include, 999999, true);
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterFilterCondition>
  libraryPathsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'libraryPaths',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterFilterCondition>
  loudnessNormalizationEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'loudnessNormalization',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterFilterCondition>
  playerThemeModeEqualTo(PlayerThemeMode value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'playerThemeMode', value: value),
      );
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterFilterCondition>
  playerThemeModeGreaterThan(PlayerThemeMode value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'playerThemeMode',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterFilterCondition>
  playerThemeModeLessThan(PlayerThemeMode value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'playerThemeMode',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterFilterCondition>
  playerThemeModeBetween(
    PlayerThemeMode lower,
    PlayerThemeMode upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'playerThemeMode',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterFilterCondition>
  showCoverReflectionEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'showCoverReflection', value: value),
      );
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterFilterCondition>
  showWaveformEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'showWaveform', value: value),
      );
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterFilterCondition>
  skipSilenceEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'skipSilence', value: value),
      );
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterFilterCondition>
  themeModeEqualTo(ThemeMode value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'themeMode', value: value),
      );
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterFilterCondition>
  themeModeGreaterThan(ThemeMode value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'themeMode',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterFilterCondition>
  themeModeLessThan(ThemeMode value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'themeMode',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterFilterCondition>
  themeModeBetween(
    ThemeMode lower,
    ThemeMode upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'themeMode',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension IsarAppSettingsQueryObject
    on QueryBuilder<IsarAppSettings, IsarAppSettings, QFilterCondition> {}

extension IsarAppSettingsQueryLinks
    on QueryBuilder<IsarAppSettings, IsarAppSettings, QFilterCondition> {}

extension IsarAppSettingsQuerySortBy
    on QueryBuilder<IsarAppSettings, IsarAppSettings, QSortBy> {
  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterSortBy>
  sortByAudioPreset() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioPreset', Sort.asc);
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterSortBy>
  sortByAudioPresetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioPreset', Sort.desc);
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterSortBy>
  sortByLoudnessNormalization() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loudnessNormalization', Sort.asc);
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterSortBy>
  sortByLoudnessNormalizationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loudnessNormalization', Sort.desc);
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterSortBy>
  sortByPlayerThemeMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playerThemeMode', Sort.asc);
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterSortBy>
  sortByPlayerThemeModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playerThemeMode', Sort.desc);
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterSortBy>
  sortByShowCoverReflection() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showCoverReflection', Sort.asc);
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterSortBy>
  sortByShowCoverReflectionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showCoverReflection', Sort.desc);
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterSortBy>
  sortByShowWaveform() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showWaveform', Sort.asc);
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterSortBy>
  sortByShowWaveformDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showWaveform', Sort.desc);
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterSortBy>
  sortBySkipSilence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skipSilence', Sort.asc);
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterSortBy>
  sortBySkipSilenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skipSilence', Sort.desc);
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterSortBy>
  sortByThemeMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeMode', Sort.asc);
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterSortBy>
  sortByThemeModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeMode', Sort.desc);
    });
  }
}

extension IsarAppSettingsQuerySortThenBy
    on QueryBuilder<IsarAppSettings, IsarAppSettings, QSortThenBy> {
  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterSortBy>
  thenByAudioPreset() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioPreset', Sort.asc);
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterSortBy>
  thenByAudioPresetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioPreset', Sort.desc);
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterSortBy>
  thenByLoudnessNormalization() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loudnessNormalization', Sort.asc);
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterSortBy>
  thenByLoudnessNormalizationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loudnessNormalization', Sort.desc);
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterSortBy>
  thenByPlayerThemeMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playerThemeMode', Sort.asc);
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterSortBy>
  thenByPlayerThemeModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playerThemeMode', Sort.desc);
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterSortBy>
  thenByShowCoverReflection() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showCoverReflection', Sort.asc);
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterSortBy>
  thenByShowCoverReflectionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showCoverReflection', Sort.desc);
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterSortBy>
  thenByShowWaveform() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showWaveform', Sort.asc);
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterSortBy>
  thenByShowWaveformDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showWaveform', Sort.desc);
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterSortBy>
  thenBySkipSilence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skipSilence', Sort.asc);
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterSortBy>
  thenBySkipSilenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skipSilence', Sort.desc);
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterSortBy>
  thenByThemeMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeMode', Sort.asc);
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QAfterSortBy>
  thenByThemeModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeMode', Sort.desc);
    });
  }
}

extension IsarAppSettingsQueryWhereDistinct
    on QueryBuilder<IsarAppSettings, IsarAppSettings, QDistinct> {
  QueryBuilder<IsarAppSettings, IsarAppSettings, QDistinct>
  distinctByAudioPreset() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'audioPreset');
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QDistinct>
  distinctByLibraryPaths() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'libraryPaths');
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QDistinct>
  distinctByLoudnessNormalization() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'loudnessNormalization');
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QDistinct>
  distinctByPlayerThemeMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'playerThemeMode');
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QDistinct>
  distinctByShowCoverReflection() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'showCoverReflection');
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QDistinct>
  distinctByShowWaveform() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'showWaveform');
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QDistinct>
  distinctBySkipSilence() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'skipSilence');
    });
  }

  QueryBuilder<IsarAppSettings, IsarAppSettings, QDistinct>
  distinctByThemeMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'themeMode');
    });
  }
}

extension IsarAppSettingsQueryProperty
    on QueryBuilder<IsarAppSettings, IsarAppSettings, QQueryProperty> {
  QueryBuilder<IsarAppSettings, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IsarAppSettings, AudioPreset, QQueryOperations>
  audioPresetProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'audioPreset');
    });
  }

  QueryBuilder<IsarAppSettings, List<String>, QQueryOperations>
  libraryPathsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'libraryPaths');
    });
  }

  QueryBuilder<IsarAppSettings, bool, QQueryOperations>
  loudnessNormalizationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'loudnessNormalization');
    });
  }

  QueryBuilder<IsarAppSettings, PlayerThemeMode, QQueryOperations>
  playerThemeModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'playerThemeMode');
    });
  }

  QueryBuilder<IsarAppSettings, bool, QQueryOperations>
  showCoverReflectionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'showCoverReflection');
    });
  }

  QueryBuilder<IsarAppSettings, bool, QQueryOperations> showWaveformProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'showWaveform');
    });
  }

  QueryBuilder<IsarAppSettings, bool, QQueryOperations> skipSilenceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'skipSilence');
    });
  }

  QueryBuilder<IsarAppSettings, ThemeMode, QQueryOperations>
  themeModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'themeMode');
    });
  }
}

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AppSettingsNotifier)
final appSettingsProvider = AppSettingsNotifierProvider._();

final class AppSettingsNotifierProvider
    extends $NotifierProvider<AppSettingsNotifier, AppSettings> {
  AppSettingsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appSettingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appSettingsNotifierHash();

  @$internal
  @override
  AppSettingsNotifier create() => AppSettingsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppSettings>(value),
    );
  }
}

String _$appSettingsNotifierHash() =>
    r'cd5b28cdf28a1335eb2009851059c6274b1b99f3';

abstract class _$AppSettingsNotifier extends $Notifier<AppSettings> {
  AppSettings build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AppSettings, AppSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppSettings, AppSettings>,
              AppSettings,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
