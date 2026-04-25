// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'keyboard_shortcuts.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetKeyboardShortcutCollection on Isar {
  IsarCollection<KeyboardShortcut> get keyboardShortcuts => this.collection();
}

const KeyboardShortcutSchema = CollectionSchema(
  name: r'KeyboardShortcut',
  id: 4759584051836721976,
  properties: {
    r'action': PropertySchema(
      id: 0,
      name: r'action',
      type: IsarType.string,
    ),
    r'alt': PropertySchema(
      id: 1,
      name: r'alt',
      type: IsarType.bool,
    ),
    r'ctrl': PropertySchema(
      id: 2,
      name: r'ctrl',
      type: IsarType.bool,
    ),
    r'description': PropertySchema(
      id: 3,
      name: r'description',
      type: IsarType.string,
    ),
    r'keyValue': PropertySchema(
      id: 4,
      name: r'keyValue',
      type: IsarType.string,
    ),
    r'shift': PropertySchema(
      id: 5,
      name: r'shift',
      type: IsarType.bool,
    ),
    r'shortcutString': PropertySchema(
      id: 6,
      name: r'shortcutString',
      type: IsarType.string,
    )
  },
  estimateSize: _keyboardShortcutEstimateSize,
  serialize: _keyboardShortcutSerialize,
  deserialize: _keyboardShortcutDeserialize,
  deserializeProp: _keyboardShortcutDeserializeProp,
  idName: r'id',
  indexes: {
    r'action': IndexSchema(
      id: -2948318935682215514,
      name: r'action',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'action',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _keyboardShortcutGetId,
  getLinks: _keyboardShortcutGetLinks,
  attach: _keyboardShortcutAttach,
  version: '3.1.0+1',
);

int _keyboardShortcutEstimateSize(
  KeyboardShortcut object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.action.length * 3;
  bytesCount += 3 + object.description.length * 3;
  bytesCount += 3 + object.keyValue.length * 3;
  bytesCount += 3 + object.shortcutString.length * 3;
  return bytesCount;
}

void _keyboardShortcutSerialize(
  KeyboardShortcut object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.action);
  writer.writeBool(offsets[1], object.alt);
  writer.writeBool(offsets[2], object.ctrl);
  writer.writeString(offsets[3], object.description);
  writer.writeString(offsets[4], object.keyValue);
  writer.writeBool(offsets[5], object.shift);
  writer.writeString(offsets[6], object.shortcutString);
}

KeyboardShortcut _keyboardShortcutDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = KeyboardShortcut(
    action: reader.readString(offsets[0]),
    alt: reader.readBoolOrNull(offsets[1]) ?? false,
    ctrl: reader.readBoolOrNull(offsets[2]) ?? false,
    description: reader.readString(offsets[3]),
    keyValue: reader.readString(offsets[4]),
    shift: reader.readBoolOrNull(offsets[5]) ?? false,
  );
  object.id = id;
  return object;
}

P _keyboardShortcutDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 2:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 6:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _keyboardShortcutGetId(KeyboardShortcut object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _keyboardShortcutGetLinks(KeyboardShortcut object) {
  return [];
}

void _keyboardShortcutAttach(
    IsarCollection<dynamic> col, Id id, KeyboardShortcut object) {
  object.id = id;
}

extension KeyboardShortcutByIndex on IsarCollection<KeyboardShortcut> {
  Future<KeyboardShortcut?> getByAction(String action) {
    return getByIndex(r'action', [action]);
  }

  KeyboardShortcut? getByActionSync(String action) {
    return getByIndexSync(r'action', [action]);
  }

  Future<bool> deleteByAction(String action) {
    return deleteByIndex(r'action', [action]);
  }

  bool deleteByActionSync(String action) {
    return deleteByIndexSync(r'action', [action]);
  }

  Future<List<KeyboardShortcut?>> getAllByAction(List<String> actionValues) {
    final values = actionValues.map((e) => [e]).toList();
    return getAllByIndex(r'action', values);
  }

  List<KeyboardShortcut?> getAllByActionSync(List<String> actionValues) {
    final values = actionValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'action', values);
  }

  Future<int> deleteAllByAction(List<String> actionValues) {
    final values = actionValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'action', values);
  }

  int deleteAllByActionSync(List<String> actionValues) {
    final values = actionValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'action', values);
  }

  Future<Id> putByAction(KeyboardShortcut object) {
    return putByIndex(r'action', object);
  }

  Id putByActionSync(KeyboardShortcut object, {bool saveLinks = true}) {
    return putByIndexSync(r'action', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByAction(List<KeyboardShortcut> objects) {
    return putAllByIndex(r'action', objects);
  }

  List<Id> putAllByActionSync(List<KeyboardShortcut> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'action', objects, saveLinks: saveLinks);
  }
}

extension KeyboardShortcutQueryWhereSort
    on QueryBuilder<KeyboardShortcut, KeyboardShortcut, QWhere> {
  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension KeyboardShortcutQueryWhere
    on QueryBuilder<KeyboardShortcut, KeyboardShortcut, QWhereClause> {
  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterWhereClause>
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

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterWhereClause> idBetween(
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

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterWhereClause>
      actionEqualTo(String action) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'action',
        value: [action],
      ));
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterWhereClause>
      actionNotEqualTo(String action) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'action',
              lower: [],
              upper: [action],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'action',
              lower: [action],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'action',
              lower: [action],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'action',
              lower: [],
              upper: [action],
              includeUpper: false,
            ));
      }
    });
  }
}

extension KeyboardShortcutQueryFilter
    on QueryBuilder<KeyboardShortcut, KeyboardShortcut, QFilterCondition> {
  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterFilterCondition>
      actionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'action',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterFilterCondition>
      actionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'action',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterFilterCondition>
      actionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'action',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterFilterCondition>
      actionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'action',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterFilterCondition>
      actionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'action',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterFilterCondition>
      actionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'action',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterFilterCondition>
      actionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'action',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterFilterCondition>
      actionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'action',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterFilterCondition>
      actionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'action',
        value: '',
      ));
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterFilterCondition>
      actionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'action',
        value: '',
      ));
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterFilterCondition>
      altEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'alt',
        value: value,
      ));
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterFilterCondition>
      ctrlEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ctrl',
        value: value,
      ));
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterFilterCondition>
      descriptionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterFilterCondition>
      descriptionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterFilterCondition>
      descriptionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterFilterCondition>
      descriptionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'description',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterFilterCondition>
      descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterFilterCondition>
      descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterFilterCondition>
      descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterFilterCondition>
      descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterFilterCondition>
      descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterFilterCondition>
      descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterFilterCondition>
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

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterFilterCondition>
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

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterFilterCondition>
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

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterFilterCondition>
      keyValueEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'keyValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterFilterCondition>
      keyValueGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'keyValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterFilterCondition>
      keyValueLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'keyValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterFilterCondition>
      keyValueBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'keyValue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterFilterCondition>
      keyValueStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'keyValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterFilterCondition>
      keyValueEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'keyValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterFilterCondition>
      keyValueContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'keyValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterFilterCondition>
      keyValueMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'keyValue',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterFilterCondition>
      keyValueIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'keyValue',
        value: '',
      ));
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterFilterCondition>
      keyValueIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'keyValue',
        value: '',
      ));
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterFilterCondition>
      shiftEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'shift',
        value: value,
      ));
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterFilterCondition>
      shortcutStringEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'shortcutString',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterFilterCondition>
      shortcutStringGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'shortcutString',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterFilterCondition>
      shortcutStringLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'shortcutString',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterFilterCondition>
      shortcutStringBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'shortcutString',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterFilterCondition>
      shortcutStringStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'shortcutString',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterFilterCondition>
      shortcutStringEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'shortcutString',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterFilterCondition>
      shortcutStringContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'shortcutString',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterFilterCondition>
      shortcutStringMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'shortcutString',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterFilterCondition>
      shortcutStringIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'shortcutString',
        value: '',
      ));
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterFilterCondition>
      shortcutStringIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'shortcutString',
        value: '',
      ));
    });
  }
}

extension KeyboardShortcutQueryObject
    on QueryBuilder<KeyboardShortcut, KeyboardShortcut, QFilterCondition> {}

extension KeyboardShortcutQueryLinks
    on QueryBuilder<KeyboardShortcut, KeyboardShortcut, QFilterCondition> {}

extension KeyboardShortcutQuerySortBy
    on QueryBuilder<KeyboardShortcut, KeyboardShortcut, QSortBy> {
  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterSortBy>
      sortByAction() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'action', Sort.asc);
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterSortBy>
      sortByActionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'action', Sort.desc);
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterSortBy> sortByAlt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alt', Sort.asc);
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterSortBy>
      sortByAltDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alt', Sort.desc);
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterSortBy> sortByCtrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ctrl', Sort.asc);
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterSortBy>
      sortByCtrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ctrl', Sort.desc);
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterSortBy>
      sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterSortBy>
      sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterSortBy>
      sortByKeyValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'keyValue', Sort.asc);
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterSortBy>
      sortByKeyValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'keyValue', Sort.desc);
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterSortBy> sortByShift() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shift', Sort.asc);
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterSortBy>
      sortByShiftDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shift', Sort.desc);
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterSortBy>
      sortByShortcutString() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shortcutString', Sort.asc);
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterSortBy>
      sortByShortcutStringDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shortcutString', Sort.desc);
    });
  }
}

extension KeyboardShortcutQuerySortThenBy
    on QueryBuilder<KeyboardShortcut, KeyboardShortcut, QSortThenBy> {
  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterSortBy>
      thenByAction() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'action', Sort.asc);
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterSortBy>
      thenByActionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'action', Sort.desc);
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterSortBy> thenByAlt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alt', Sort.asc);
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterSortBy>
      thenByAltDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alt', Sort.desc);
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterSortBy> thenByCtrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ctrl', Sort.asc);
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterSortBy>
      thenByCtrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ctrl', Sort.desc);
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterSortBy>
      thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterSortBy>
      thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterSortBy>
      thenByKeyValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'keyValue', Sort.asc);
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterSortBy>
      thenByKeyValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'keyValue', Sort.desc);
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterSortBy> thenByShift() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shift', Sort.asc);
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterSortBy>
      thenByShiftDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shift', Sort.desc);
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterSortBy>
      thenByShortcutString() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shortcutString', Sort.asc);
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QAfterSortBy>
      thenByShortcutStringDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shortcutString', Sort.desc);
    });
  }
}

extension KeyboardShortcutQueryWhereDistinct
    on QueryBuilder<KeyboardShortcut, KeyboardShortcut, QDistinct> {
  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QDistinct> distinctByAction(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'action', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QDistinct> distinctByAlt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'alt');
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QDistinct> distinctByCtrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ctrl');
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QDistinct>
      distinctByDescription({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QDistinct>
      distinctByKeyValue({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'keyValue', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QDistinct>
      distinctByShift() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'shift');
    });
  }

  QueryBuilder<KeyboardShortcut, KeyboardShortcut, QDistinct>
      distinctByShortcutString({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'shortcutString',
          caseSensitive: caseSensitive);
    });
  }
}

extension KeyboardShortcutQueryProperty
    on QueryBuilder<KeyboardShortcut, KeyboardShortcut, QQueryProperty> {
  QueryBuilder<KeyboardShortcut, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<KeyboardShortcut, String, QQueryOperations> actionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'action');
    });
  }

  QueryBuilder<KeyboardShortcut, bool, QQueryOperations> altProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'alt');
    });
  }

  QueryBuilder<KeyboardShortcut, bool, QQueryOperations> ctrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ctrl');
    });
  }

  QueryBuilder<KeyboardShortcut, String, QQueryOperations>
      descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<KeyboardShortcut, String, QQueryOperations> keyValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'keyValue');
    });
  }

  QueryBuilder<KeyboardShortcut, bool, QQueryOperations> shiftProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'shift');
    });
  }

  QueryBuilder<KeyboardShortcut, String, QQueryOperations>
      shortcutStringProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'shortcutString');
    });
  }
}
