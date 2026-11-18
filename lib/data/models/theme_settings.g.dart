// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_settings.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

extension GetThemeSettingsCollection on Isar {
  IsarCollection<ThemeSettings> get themeSettings => this.collection();
}

const ThemeSettingsSchema = CollectionSchema(
  name: r'ThemeSettings',
  id: 815540309993789807,
  properties: {
    r'backgroundColorValue': PropertySchema(
      id: 0,
      name: r'backgroundColorValue',
      type: IsarType.long,
    ),
    r'backgroundImageBlur': PropertySchema(
      id: 1,
      name: r'backgroundImageBlur',
      type: IsarType.double,
    ),
    r'backgroundImageOpacity': PropertySchema(
      id: 2,
      name: r'backgroundImageOpacity',
      type: IsarType.double,
    ),
    r'backgroundImagePath': PropertySchema(
      id: 3,
      name: r'backgroundImagePath',
      type: IsarType.string,
    ),
    r'cardColorValue': PropertySchema(
      id: 4,
      name: r'cardColorValue',
      type: IsarType.long,
    ),
    r'themeModeIndex': PropertySchema(
      id: 5,
      name: r'themeModeIndex',
      type: IsarType.long,
    ),
    r'updatedAt': PropertySchema(
      id: 6,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'useBackgroundImage': PropertySchema(
      id: 7,
      name: r'useBackgroundImage',
      type: IsarType.bool,
    ),
  },

  estimateSize: _themeSettingsEstimateSize,
  serialize: _themeSettingsSerialize,
  deserialize: _themeSettingsDeserialize,
  deserializeProp: _themeSettingsDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _themeSettingsGetId,
  getLinks: _themeSettingsGetLinks,
  attach: _themeSettingsAttach,
  version: '3.4.1',
);

int _themeSettingsEstimateSize(
  ThemeSettings object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.backgroundImagePath.length * 3;
  return bytesCount;
}

void _themeSettingsSerialize(
  ThemeSettings object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.backgroundColorValue);
  writer.writeDouble(offsets[1], object.backgroundImageBlur);
  writer.writeDouble(offsets[2], object.backgroundImageOpacity);
  writer.writeString(offsets[3], object.backgroundImagePath);
  writer.writeLong(offsets[4], object.cardColorValue);
  writer.writeLong(offsets[5], object.themeModeIndex);
  writer.writeDateTime(offsets[6], object.updatedAt);
  writer.writeBool(offsets[7], object.useBackgroundImage);
}

ThemeSettings _themeSettingsDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ThemeSettings();
  object.backgroundColorValue = reader.readLong(offsets[0]);
  object.backgroundImageBlur = reader.readDouble(offsets[1]);
  object.backgroundImageOpacity = reader.readDouble(offsets[2]);
  object.backgroundImagePath = reader.readString(offsets[3]);
  object.cardColorValue = reader.readLong(offsets[4]);
  object.id = id;
  object.themeModeIndex = reader.readLong(offsets[5]);
  object.updatedAt = reader.readDateTime(offsets[6]);
  object.useBackgroundImage = reader.readBool(offsets[7]);
  return object;
}

P _themeSettingsDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readDateTime(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _themeSettingsGetId(ThemeSettings object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _themeSettingsGetLinks(ThemeSettings object) {
  return [];
}

void _themeSettingsAttach(
  IsarCollection<dynamic> col,
  Id id,
  ThemeSettings object,
) {
  object.id = id;
}

extension ThemeSettingsQueryWhereSort
    on QueryBuilder<ThemeSettings, ThemeSettings, QWhere> {
  QueryBuilder<ThemeSettings, ThemeSettings, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ThemeSettingsQueryWhere
    on QueryBuilder<ThemeSettings, ThemeSettings, QWhereClause> {
  QueryBuilder<ThemeSettings, ThemeSettings, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
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

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterWhereClause> idBetween(
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

extension ThemeSettingsQueryFilter
    on QueryBuilder<ThemeSettings, ThemeSettings, QFilterCondition> {
  QueryBuilder<ThemeSettings, ThemeSettings, QAfterFilterCondition>
  backgroundColorValueEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'backgroundColorValue',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterFilterCondition>
  backgroundColorValueGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'backgroundColorValue',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterFilterCondition>
  backgroundColorValueLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'backgroundColorValue',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterFilterCondition>
  backgroundColorValueBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'backgroundColorValue',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterFilterCondition>
  backgroundImageBlurEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'backgroundImageBlur',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterFilterCondition>
  backgroundImageBlurGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'backgroundImageBlur',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterFilterCondition>
  backgroundImageBlurLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'backgroundImageBlur',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterFilterCondition>
  backgroundImageBlurBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'backgroundImageBlur',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterFilterCondition>
  backgroundImageOpacityEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'backgroundImageOpacity',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterFilterCondition>
  backgroundImageOpacityGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'backgroundImageOpacity',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterFilterCondition>
  backgroundImageOpacityLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'backgroundImageOpacity',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterFilterCondition>
  backgroundImageOpacityBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'backgroundImageOpacity',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterFilterCondition>
  backgroundImagePathEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'backgroundImagePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterFilterCondition>
  backgroundImagePathGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'backgroundImagePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterFilterCondition>
  backgroundImagePathLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'backgroundImagePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterFilterCondition>
  backgroundImagePathBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'backgroundImagePath',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterFilterCondition>
  backgroundImagePathStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'backgroundImagePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterFilterCondition>
  backgroundImagePathEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'backgroundImagePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterFilterCondition>
  backgroundImagePathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'backgroundImagePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterFilterCondition>
  backgroundImagePathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'backgroundImagePath',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterFilterCondition>
  backgroundImagePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'backgroundImagePath', value: ''),
      );
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterFilterCondition>
  backgroundImagePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'backgroundImagePath',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterFilterCondition>
  cardColorValueEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'cardColorValue', value: value),
      );
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterFilterCondition>
  cardColorValueGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'cardColorValue',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterFilterCondition>
  cardColorValueLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'cardColorValue',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterFilterCondition>
  cardColorValueBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'cardColorValue',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterFilterCondition>
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

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
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

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterFilterCondition> idBetween(
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

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterFilterCondition>
  themeModeIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'themeModeIndex', value: value),
      );
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterFilterCondition>
  themeModeIndexGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'themeModeIndex',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterFilterCondition>
  themeModeIndexLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'themeModeIndex',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterFilterCondition>
  themeModeIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'themeModeIndex',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterFilterCondition>
  updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterFilterCondition>
  updatedAtGreaterThan(DateTime value, {bool include = false}) {
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

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterFilterCondition>
  updatedAtLessThan(DateTime value, {bool include = false}) {
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

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterFilterCondition>
  updatedAtBetween(
    DateTime lower,
    DateTime upper, {
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

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterFilterCondition>
  useBackgroundImageEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'useBackgroundImage', value: value),
      );
    });
  }
}

extension ThemeSettingsQueryObject
    on QueryBuilder<ThemeSettings, ThemeSettings, QFilterCondition> {}

extension ThemeSettingsQueryLinks
    on QueryBuilder<ThemeSettings, ThemeSettings, QFilterCondition> {}

extension ThemeSettingsQuerySortBy
    on QueryBuilder<ThemeSettings, ThemeSettings, QSortBy> {
  QueryBuilder<ThemeSettings, ThemeSettings, QAfterSortBy>
  sortByBackgroundColorValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backgroundColorValue', Sort.asc);
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterSortBy>
  sortByBackgroundColorValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backgroundColorValue', Sort.desc);
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterSortBy>
  sortByBackgroundImageBlur() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backgroundImageBlur', Sort.asc);
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterSortBy>
  sortByBackgroundImageBlurDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backgroundImageBlur', Sort.desc);
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterSortBy>
  sortByBackgroundImageOpacity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backgroundImageOpacity', Sort.asc);
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterSortBy>
  sortByBackgroundImageOpacityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backgroundImageOpacity', Sort.desc);
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterSortBy>
  sortByBackgroundImagePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backgroundImagePath', Sort.asc);
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterSortBy>
  sortByBackgroundImagePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backgroundImagePath', Sort.desc);
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterSortBy>
  sortByCardColorValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardColorValue', Sort.asc);
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterSortBy>
  sortByCardColorValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardColorValue', Sort.desc);
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterSortBy>
  sortByThemeModeIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeModeIndex', Sort.asc);
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterSortBy>
  sortByThemeModeIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeModeIndex', Sort.desc);
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterSortBy>
  sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterSortBy>
  sortByUseBackgroundImage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'useBackgroundImage', Sort.asc);
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterSortBy>
  sortByUseBackgroundImageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'useBackgroundImage', Sort.desc);
    });
  }
}

extension ThemeSettingsQuerySortThenBy
    on QueryBuilder<ThemeSettings, ThemeSettings, QSortThenBy> {
  QueryBuilder<ThemeSettings, ThemeSettings, QAfterSortBy>
  thenByBackgroundColorValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backgroundColorValue', Sort.asc);
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterSortBy>
  thenByBackgroundColorValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backgroundColorValue', Sort.desc);
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterSortBy>
  thenByBackgroundImageBlur() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backgroundImageBlur', Sort.asc);
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterSortBy>
  thenByBackgroundImageBlurDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backgroundImageBlur', Sort.desc);
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterSortBy>
  thenByBackgroundImageOpacity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backgroundImageOpacity', Sort.asc);
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterSortBy>
  thenByBackgroundImageOpacityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backgroundImageOpacity', Sort.desc);
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterSortBy>
  thenByBackgroundImagePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backgroundImagePath', Sort.asc);
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterSortBy>
  thenByBackgroundImagePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backgroundImagePath', Sort.desc);
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterSortBy>
  thenByCardColorValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardColorValue', Sort.asc);
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterSortBy>
  thenByCardColorValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardColorValue', Sort.desc);
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterSortBy>
  thenByThemeModeIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeModeIndex', Sort.asc);
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterSortBy>
  thenByThemeModeIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeModeIndex', Sort.desc);
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterSortBy>
  thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterSortBy>
  thenByUseBackgroundImage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'useBackgroundImage', Sort.asc);
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QAfterSortBy>
  thenByUseBackgroundImageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'useBackgroundImage', Sort.desc);
    });
  }
}

extension ThemeSettingsQueryWhereDistinct
    on QueryBuilder<ThemeSettings, ThemeSettings, QDistinct> {
  QueryBuilder<ThemeSettings, ThemeSettings, QDistinct>
  distinctByBackgroundColorValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'backgroundColorValue');
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QDistinct>
  distinctByBackgroundImageBlur() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'backgroundImageBlur');
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QDistinct>
  distinctByBackgroundImageOpacity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'backgroundImageOpacity');
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QDistinct>
  distinctByBackgroundImagePath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'backgroundImagePath',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QDistinct>
  distinctByCardColorValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cardColorValue');
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QDistinct>
  distinctByThemeModeIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'themeModeIndex');
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<ThemeSettings, ThemeSettings, QDistinct>
  distinctByUseBackgroundImage() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'useBackgroundImage');
    });
  }
}

extension ThemeSettingsQueryProperty
    on QueryBuilder<ThemeSettings, ThemeSettings, QQueryProperty> {
  QueryBuilder<ThemeSettings, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ThemeSettings, int, QQueryOperations>
  backgroundColorValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'backgroundColorValue');
    });
  }

  QueryBuilder<ThemeSettings, double, QQueryOperations>
  backgroundImageBlurProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'backgroundImageBlur');
    });
  }

  QueryBuilder<ThemeSettings, double, QQueryOperations>
  backgroundImageOpacityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'backgroundImageOpacity');
    });
  }

  QueryBuilder<ThemeSettings, String, QQueryOperations>
  backgroundImagePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'backgroundImagePath');
    });
  }

  QueryBuilder<ThemeSettings, int, QQueryOperations> cardColorValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cardColorValue');
    });
  }

  QueryBuilder<ThemeSettings, int, QQueryOperations> themeModeIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'themeModeIndex');
    });
  }

  QueryBuilder<ThemeSettings, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<ThemeSettings, bool, QQueryOperations>
  useBackgroundImageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'useBackgroundImage');
    });
  }
}
