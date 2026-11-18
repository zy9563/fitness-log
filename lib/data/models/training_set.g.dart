// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_set.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

extension GetTrainingSetCollection on Isar {
  IsarCollection<TrainingSet> get trainingSets => this.collection();
}

const TrainingSetSchema = CollectionSchema(
  name: r'TrainingSet',
  id: -9053156302263607305,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'date': PropertySchema(id: 1, name: r'date', type: IsarType.dateTime),
    r'entryId': PropertySchema(id: 2, name: r'entryId', type: IsarType.long),
    r'groupCount': PropertySchema(
      id: 3,
      name: r'groupCount',
      type: IsarType.long,
    ),
    r'groupIndex': PropertySchema(
      id: 4,
      name: r'groupIndex',
      type: IsarType.long,
    ),
    r'gymId': PropertySchema(id: 5, name: r'gymId', type: IsarType.long),
    r'note': PropertySchema(id: 6, name: r'note', type: IsarType.string),
    r'reps': PropertySchema(id: 7, name: r'reps', type: IsarType.long),
    r'updatedAt': PropertySchema(
      id: 8,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'weightRaw': PropertySchema(
      id: 9,
      name: r'weightRaw',
      type: IsarType.string,
    ),
    r'weightUnitIndex': PropertySchema(
      id: 10,
      name: r'weightUnitIndex',
      type: IsarType.long,
    ),
    r'weightValue': PropertySchema(
      id: 11,
      name: r'weightValue',
      type: IsarType.double,
    ),
  },

  estimateSize: _trainingSetEstimateSize,
  serialize: _trainingSetSerialize,
  deserialize: _trainingSetDeserialize,
  deserializeProp: _trainingSetDeserializeProp,
  idName: r'id',
  indexes: {
    r'entryId': IndexSchema(
      id: 3733379884318738402,
      name: r'entryId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'entryId',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'gymId': IndexSchema(
      id: 7901962257235038427,
      name: r'gymId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'gymId',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'date': IndexSchema(
      id: -7552997827385218417,
      name: r'date',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'date',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _trainingSetGetId,
  getLinks: _trainingSetGetLinks,
  attach: _trainingSetAttach,
  version: '3.4.1',
);

int _trainingSetEstimateSize(
  TrainingSet object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.note.length * 3;
  bytesCount += 3 + object.weightRaw.length * 3;
  return bytesCount;
}

void _trainingSetSerialize(
  TrainingSet object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeDateTime(offsets[1], object.date);
  writer.writeLong(offsets[2], object.entryId);
  writer.writeLong(offsets[3], object.groupCount);
  writer.writeLong(offsets[4], object.groupIndex);
  writer.writeLong(offsets[5], object.gymId);
  writer.writeString(offsets[6], object.note);
  writer.writeLong(offsets[7], object.reps);
  writer.writeDateTime(offsets[8], object.updatedAt);
  writer.writeString(offsets[9], object.weightRaw);
  writer.writeLong(offsets[10], object.weightUnitIndex);
  writer.writeDouble(offsets[11], object.weightValue);
}

TrainingSet _trainingSetDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TrainingSet();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.date = reader.readDateTime(offsets[1]);
  object.entryId = reader.readLong(offsets[2]);
  object.groupCount = reader.readLong(offsets[3]);
  object.groupIndex = reader.readLong(offsets[4]);
  object.gymId = reader.readLong(offsets[5]);
  object.id = id;
  object.note = reader.readString(offsets[6]);
  object.reps = reader.readLong(offsets[7]);
  object.updatedAt = reader.readDateTime(offsets[8]);
  object.weightRaw = reader.readString(offsets[9]);
  object.weightUnitIndex = reader.readLongOrNull(offsets[10]);
  object.weightValue = reader.readDoubleOrNull(offsets[11]);
  return object;
}

P _trainingSetDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readLongOrNull(offset)) as P;
    case 11:
      return (reader.readDoubleOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _trainingSetGetId(TrainingSet object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _trainingSetGetLinks(TrainingSet object) {
  return [];
}

void _trainingSetAttach(
  IsarCollection<dynamic> col,
  Id id,
  TrainingSet object,
) {
  object.id = id;
}

extension TrainingSetQueryWhereSort
    on QueryBuilder<TrainingSet, TrainingSet, QWhere> {
  QueryBuilder<TrainingSet, TrainingSet, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterWhere> anyEntryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'entryId'),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterWhere> anyGymId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'gymId'),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterWhere> anyDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'date'),
      );
    });
  }
}

extension TrainingSetQueryWhere
    on QueryBuilder<TrainingSet, TrainingSet, QWhereClause> {
  QueryBuilder<TrainingSet, TrainingSet, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<TrainingSet, TrainingSet, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterWhereClause> idBetween(
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

  QueryBuilder<TrainingSet, TrainingSet, QAfterWhereClause> entryIdEqualTo(
    int entryId,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'entryId', value: [entryId]),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterWhereClause> entryIdNotEqualTo(
    int entryId,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'entryId',
                lower: [],
                upper: [entryId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'entryId',
                lower: [entryId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'entryId',
                lower: [entryId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'entryId',
                lower: [],
                upper: [entryId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterWhereClause> entryIdGreaterThan(
    int entryId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'entryId',
          lower: [entryId],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterWhereClause> entryIdLessThan(
    int entryId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'entryId',
          lower: [],
          upper: [entryId],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterWhereClause> entryIdBetween(
    int lowerEntryId,
    int upperEntryId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'entryId',
          lower: [lowerEntryId],
          includeLower: includeLower,
          upper: [upperEntryId],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterWhereClause> gymIdEqualTo(
    int gymId,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'gymId', value: [gymId]),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterWhereClause> gymIdNotEqualTo(
    int gymId,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'gymId',
                lower: [],
                upper: [gymId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'gymId',
                lower: [gymId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'gymId',
                lower: [gymId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'gymId',
                lower: [],
                upper: [gymId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterWhereClause> gymIdGreaterThan(
    int gymId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'gymId',
          lower: [gymId],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterWhereClause> gymIdLessThan(
    int gymId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'gymId',
          lower: [],
          upper: [gymId],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterWhereClause> gymIdBetween(
    int lowerGymId,
    int upperGymId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'gymId',
          lower: [lowerGymId],
          includeLower: includeLower,
          upper: [upperGymId],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterWhereClause> dateEqualTo(
    DateTime date,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'date', value: [date]),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterWhereClause> dateNotEqualTo(
    DateTime date,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'date',
                lower: [],
                upper: [date],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'date',
                lower: [date],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'date',
                lower: [date],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'date',
                lower: [],
                upper: [date],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterWhereClause> dateGreaterThan(
    DateTime date, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'date',
          lower: [date],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterWhereClause> dateLessThan(
    DateTime date, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'date',
          lower: [],
          upper: [date],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterWhereClause> dateBetween(
    DateTime lowerDate,
    DateTime upperDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'date',
          lower: [lowerDate],
          includeLower: includeLower,
          upper: [upperDate],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension TrainingSetQueryFilter
    on QueryBuilder<TrainingSet, TrainingSet, QFilterCondition> {
  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition>
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition>
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

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition>
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

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition>
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

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition> dateEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'date', value: value),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition> dateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'date',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition> dateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'date',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition> dateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'date',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition> entryIdEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'entryId', value: value),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition>
  entryIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'entryId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition> entryIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'entryId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition> entryIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'entryId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition>
  groupCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'groupCount', value: value),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition>
  groupCountGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'groupCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition>
  groupCountLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'groupCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition>
  groupCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'groupCount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition>
  groupIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'groupIndex', value: value),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition>
  groupIndexGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'groupIndex',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition>
  groupIndexLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'groupIndex',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition>
  groupIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'groupIndex',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition> gymIdEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'gymId', value: value),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition>
  gymIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'gymId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition> gymIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'gymId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition> gymIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'gymId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
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

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition> idBetween(
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

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition> noteEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition> noteGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition> noteLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition> noteBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'note',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition> noteStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition> noteEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition> noteContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition> noteMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'note',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition> noteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'note', value: ''),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition>
  noteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'note', value: ''),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition> repsEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'reps', value: value),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition> repsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'reps',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition> repsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'reps',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition> repsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'reps',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition>
  updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition>
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

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition>
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

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition>
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

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition>
  weightRawEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'weightRaw',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition>
  weightRawGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'weightRaw',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition>
  weightRawLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'weightRaw',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition>
  weightRawBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'weightRaw',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition>
  weightRawStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'weightRaw',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition>
  weightRawEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'weightRaw',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition>
  weightRawContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'weightRaw',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition>
  weightRawMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'weightRaw',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition>
  weightRawIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'weightRaw', value: ''),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition>
  weightRawIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'weightRaw', value: ''),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition>
  weightUnitIndexIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'weightUnitIndex'),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition>
  weightUnitIndexIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'weightUnitIndex'),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition>
  weightUnitIndexEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'weightUnitIndex', value: value),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition>
  weightUnitIndexGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'weightUnitIndex',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition>
  weightUnitIndexLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'weightUnitIndex',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition>
  weightUnitIndexBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'weightUnitIndex',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition>
  weightValueIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'weightValue'),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition>
  weightValueIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'weightValue'),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition>
  weightValueEqualTo(double? value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'weightValue',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition>
  weightValueGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'weightValue',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition>
  weightValueLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'weightValue',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterFilterCondition>
  weightValueBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'weightValue',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }
}

extension TrainingSetQueryObject
    on QueryBuilder<TrainingSet, TrainingSet, QFilterCondition> {}

extension TrainingSetQueryLinks
    on QueryBuilder<TrainingSet, TrainingSet, QFilterCondition> {}

extension TrainingSetQuerySortBy
    on QueryBuilder<TrainingSet, TrainingSet, QSortBy> {
  QueryBuilder<TrainingSet, TrainingSet, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterSortBy> sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterSortBy> sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterSortBy> sortByEntryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entryId', Sort.asc);
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterSortBy> sortByEntryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entryId', Sort.desc);
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterSortBy> sortByGroupCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupCount', Sort.asc);
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterSortBy> sortByGroupCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupCount', Sort.desc);
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterSortBy> sortByGroupIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupIndex', Sort.asc);
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterSortBy> sortByGroupIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupIndex', Sort.desc);
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterSortBy> sortByGymId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gymId', Sort.asc);
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterSortBy> sortByGymIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gymId', Sort.desc);
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterSortBy> sortByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterSortBy> sortByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterSortBy> sortByReps() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reps', Sort.asc);
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterSortBy> sortByRepsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reps', Sort.desc);
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterSortBy> sortByWeightRaw() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightRaw', Sort.asc);
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterSortBy> sortByWeightRawDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightRaw', Sort.desc);
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterSortBy> sortByWeightUnitIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightUnitIndex', Sort.asc);
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterSortBy>
  sortByWeightUnitIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightUnitIndex', Sort.desc);
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterSortBy> sortByWeightValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightValue', Sort.asc);
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterSortBy> sortByWeightValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightValue', Sort.desc);
    });
  }
}

extension TrainingSetQuerySortThenBy
    on QueryBuilder<TrainingSet, TrainingSet, QSortThenBy> {
  QueryBuilder<TrainingSet, TrainingSet, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterSortBy> thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterSortBy> thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterSortBy> thenByEntryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entryId', Sort.asc);
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterSortBy> thenByEntryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entryId', Sort.desc);
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterSortBy> thenByGroupCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupCount', Sort.asc);
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterSortBy> thenByGroupCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupCount', Sort.desc);
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterSortBy> thenByGroupIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupIndex', Sort.asc);
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterSortBy> thenByGroupIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupIndex', Sort.desc);
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterSortBy> thenByGymId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gymId', Sort.asc);
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterSortBy> thenByGymIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gymId', Sort.desc);
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterSortBy> thenByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterSortBy> thenByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterSortBy> thenByReps() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reps', Sort.asc);
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterSortBy> thenByRepsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reps', Sort.desc);
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterSortBy> thenByWeightRaw() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightRaw', Sort.asc);
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterSortBy> thenByWeightRawDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightRaw', Sort.desc);
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterSortBy> thenByWeightUnitIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightUnitIndex', Sort.asc);
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterSortBy>
  thenByWeightUnitIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightUnitIndex', Sort.desc);
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterSortBy> thenByWeightValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightValue', Sort.asc);
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QAfterSortBy> thenByWeightValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightValue', Sort.desc);
    });
  }
}

extension TrainingSetQueryWhereDistinct
    on QueryBuilder<TrainingSet, TrainingSet, QDistinct> {
  QueryBuilder<TrainingSet, TrainingSet, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QDistinct> distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QDistinct> distinctByEntryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'entryId');
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QDistinct> distinctByGroupCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'groupCount');
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QDistinct> distinctByGroupIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'groupIndex');
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QDistinct> distinctByGymId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gymId');
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QDistinct> distinctByNote({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'note', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QDistinct> distinctByReps() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reps');
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QDistinct> distinctByWeightRaw({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weightRaw', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QDistinct>
  distinctByWeightUnitIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weightUnitIndex');
    });
  }

  QueryBuilder<TrainingSet, TrainingSet, QDistinct> distinctByWeightValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weightValue');
    });
  }
}

extension TrainingSetQueryProperty
    on QueryBuilder<TrainingSet, TrainingSet, QQueryProperty> {
  QueryBuilder<TrainingSet, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TrainingSet, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<TrainingSet, DateTime, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<TrainingSet, int, QQueryOperations> entryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entryId');
    });
  }

  QueryBuilder<TrainingSet, int, QQueryOperations> groupCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'groupCount');
    });
  }

  QueryBuilder<TrainingSet, int, QQueryOperations> groupIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'groupIndex');
    });
  }

  QueryBuilder<TrainingSet, int, QQueryOperations> gymIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gymId');
    });
  }

  QueryBuilder<TrainingSet, String, QQueryOperations> noteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'note');
    });
  }

  QueryBuilder<TrainingSet, int, QQueryOperations> repsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reps');
    });
  }

  QueryBuilder<TrainingSet, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<TrainingSet, String, QQueryOperations> weightRawProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weightRaw');
    });
  }

  QueryBuilder<TrainingSet, int?, QQueryOperations> weightUnitIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weightUnitIndex');
    });
  }

  QueryBuilder<TrainingSet, double?, QQueryOperations> weightValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weightValue');
    });
  }
}
