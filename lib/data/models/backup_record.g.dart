// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_record.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

extension GetBackupRecordCollection on Isar {
  IsarCollection<BackupRecord> get backupRecords => this.collection();
}

const BackupRecordSchema = CollectionSchema(
  name: r'BackupRecord',
  id: -4075346009198954164,
  properties: {
    r'downloadPath': PropertySchema(
      id: 0,
      name: r'downloadPath',
      type: IsarType.string,
    ),
    r'entryCount': PropertySchema(
      id: 1,
      name: r'entryCount',
      type: IsarType.long,
    ),
    r'exportedAt': PropertySchema(
      id: 2,
      name: r'exportedAt',
      type: IsarType.dateTime,
    ),
    r'fileName': PropertySchema(
      id: 3,
      name: r'fileName',
      type: IsarType.string,
    ),
    r'filePath': PropertySchema(
      id: 4,
      name: r'filePath',
      type: IsarType.string,
    ),
    r'fileSize': PropertySchema(id: 5, name: r'fileSize', type: IsarType.long),
    r'gymCount': PropertySchema(id: 6, name: r'gymCount', type: IsarType.long),
    r'presetCount': PropertySchema(
      id: 7,
      name: r'presetCount',
      type: IsarType.long,
    ),
    r'setCount': PropertySchema(id: 8, name: r'setCount', type: IsarType.long),
  },

  estimateSize: _backupRecordEstimateSize,
  serialize: _backupRecordSerialize,
  deserialize: _backupRecordDeserialize,
  deserializeProp: _backupRecordDeserializeProp,
  idName: r'id',
  indexes: {
    r'exportedAt': IndexSchema(
      id: 6645963217403187961,
      name: r'exportedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'exportedAt',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _backupRecordGetId,
  getLinks: _backupRecordGetLinks,
  attach: _backupRecordAttach,
  version: '3.4.1',
);

int _backupRecordEstimateSize(
  BackupRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.downloadPath.length * 3;
  bytesCount += 3 + object.fileName.length * 3;
  bytesCount += 3 + object.filePath.length * 3;
  return bytesCount;
}

void _backupRecordSerialize(
  BackupRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.downloadPath);
  writer.writeLong(offsets[1], object.entryCount);
  writer.writeDateTime(offsets[2], object.exportedAt);
  writer.writeString(offsets[3], object.fileName);
  writer.writeString(offsets[4], object.filePath);
  writer.writeLong(offsets[5], object.fileSize);
  writer.writeLong(offsets[6], object.gymCount);
  writer.writeLong(offsets[7], object.presetCount);
  writer.writeLong(offsets[8], object.setCount);
}

BackupRecord _backupRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BackupRecord();
  object.downloadPath = reader.readString(offsets[0]);
  object.entryCount = reader.readLong(offsets[1]);
  object.exportedAt = reader.readDateTime(offsets[2]);
  object.fileName = reader.readString(offsets[3]);
  object.filePath = reader.readString(offsets[4]);
  object.fileSize = reader.readLong(offsets[5]);
  object.gymCount = reader.readLong(offsets[6]);
  object.id = id;
  object.presetCount = reader.readLong(offsets[7]);
  object.setCount = reader.readLong(offsets[8]);
  return object;
}

P _backupRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _backupRecordGetId(BackupRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _backupRecordGetLinks(BackupRecord object) {
  return [];
}

void _backupRecordAttach(
  IsarCollection<dynamic> col,
  Id id,
  BackupRecord object,
) {
  object.id = id;
}

extension BackupRecordQueryWhereSort
    on QueryBuilder<BackupRecord, BackupRecord, QWhere> {
  QueryBuilder<BackupRecord, BackupRecord, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterWhere> anyExportedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'exportedAt'),
      );
    });
  }
}

extension BackupRecordQueryWhere
    on QueryBuilder<BackupRecord, BackupRecord, QWhereClause> {
  QueryBuilder<BackupRecord, BackupRecord, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<BackupRecord, BackupRecord, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterWhereClause> idBetween(
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

  QueryBuilder<BackupRecord, BackupRecord, QAfterWhereClause> exportedAtEqualTo(
    DateTime exportedAt,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'exportedAt', value: [exportedAt]),
      );
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterWhereClause>
  exportedAtNotEqualTo(DateTime exportedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'exportedAt',
                lower: [],
                upper: [exportedAt],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'exportedAt',
                lower: [exportedAt],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'exportedAt',
                lower: [exportedAt],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'exportedAt',
                lower: [],
                upper: [exportedAt],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterWhereClause>
  exportedAtGreaterThan(DateTime exportedAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'exportedAt',
          lower: [exportedAt],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterWhereClause>
  exportedAtLessThan(DateTime exportedAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'exportedAt',
          lower: [],
          upper: [exportedAt],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterWhereClause> exportedAtBetween(
    DateTime lowerExportedAt,
    DateTime upperExportedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'exportedAt',
          lower: [lowerExportedAt],
          includeLower: includeLower,
          upper: [upperExportedAt],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension BackupRecordQueryFilter
    on QueryBuilder<BackupRecord, BackupRecord, QFilterCondition> {
  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
  downloadPathEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'downloadPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
  downloadPathGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'downloadPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
  downloadPathLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'downloadPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
  downloadPathBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'downloadPath',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
  downloadPathStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'downloadPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
  downloadPathEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'downloadPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
  downloadPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'downloadPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
  downloadPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'downloadPath',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
  downloadPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'downloadPath', value: ''),
      );
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
  downloadPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'downloadPath', value: ''),
      );
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
  entryCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'entryCount', value: value),
      );
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
  entryCountGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'entryCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
  entryCountLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'entryCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
  entryCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'entryCount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
  exportedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'exportedAt', value: value),
      );
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
  exportedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'exportedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
  exportedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'exportedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
  exportedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'exportedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
  fileNameEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'fileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
  fileNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'fileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
  fileNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'fileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
  fileNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'fileName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
  fileNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'fileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
  fileNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'fileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
  fileNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'fileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
  fileNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'fileName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
  fileNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'fileName', value: ''),
      );
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
  fileNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'fileName', value: ''),
      );
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
  filePathEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'filePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
  filePathGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'filePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
  filePathLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'filePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
  filePathBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'filePath',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
  filePathStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'filePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
  filePathEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'filePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
  filePathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'filePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
  filePathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'filePath',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
  filePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'filePath', value: ''),
      );
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
  filePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'filePath', value: ''),
      );
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
  fileSizeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'fileSize', value: value),
      );
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
  fileSizeGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'fileSize',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
  fileSizeLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'fileSize',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
  fileSizeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'fileSize',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
  gymCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'gymCount', value: value),
      );
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
  gymCountGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'gymCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
  gymCountLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'gymCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
  gymCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'gymCount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition> idBetween(
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

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
  presetCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'presetCount', value: value),
      );
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
  presetCountGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'presetCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
  presetCountLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'presetCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
  presetCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'presetCount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
  setCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'setCount', value: value),
      );
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
  setCountGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'setCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
  setCountLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'setCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterFilterCondition>
  setCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'setCount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension BackupRecordQueryObject
    on QueryBuilder<BackupRecord, BackupRecord, QFilterCondition> {}

extension BackupRecordQueryLinks
    on QueryBuilder<BackupRecord, BackupRecord, QFilterCondition> {}

extension BackupRecordQuerySortBy
    on QueryBuilder<BackupRecord, BackupRecord, QSortBy> {
  QueryBuilder<BackupRecord, BackupRecord, QAfterSortBy> sortByDownloadPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadPath', Sort.asc);
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterSortBy>
  sortByDownloadPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadPath', Sort.desc);
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterSortBy> sortByEntryCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entryCount', Sort.asc);
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterSortBy>
  sortByEntryCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entryCount', Sort.desc);
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterSortBy> sortByExportedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exportedAt', Sort.asc);
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterSortBy>
  sortByExportedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exportedAt', Sort.desc);
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterSortBy> sortByFileName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.asc);
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterSortBy> sortByFileNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.desc);
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterSortBy> sortByFilePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filePath', Sort.asc);
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterSortBy> sortByFilePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filePath', Sort.desc);
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterSortBy> sortByFileSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileSize', Sort.asc);
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterSortBy> sortByFileSizeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileSize', Sort.desc);
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterSortBy> sortByGymCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gymCount', Sort.asc);
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterSortBy> sortByGymCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gymCount', Sort.desc);
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterSortBy> sortByPresetCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'presetCount', Sort.asc);
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterSortBy>
  sortByPresetCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'presetCount', Sort.desc);
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterSortBy> sortBySetCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'setCount', Sort.asc);
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterSortBy> sortBySetCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'setCount', Sort.desc);
    });
  }
}

extension BackupRecordQuerySortThenBy
    on QueryBuilder<BackupRecord, BackupRecord, QSortThenBy> {
  QueryBuilder<BackupRecord, BackupRecord, QAfterSortBy> thenByDownloadPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadPath', Sort.asc);
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterSortBy>
  thenByDownloadPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadPath', Sort.desc);
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterSortBy> thenByEntryCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entryCount', Sort.asc);
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterSortBy>
  thenByEntryCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entryCount', Sort.desc);
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterSortBy> thenByExportedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exportedAt', Sort.asc);
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterSortBy>
  thenByExportedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exportedAt', Sort.desc);
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterSortBy> thenByFileName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.asc);
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterSortBy> thenByFileNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.desc);
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterSortBy> thenByFilePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filePath', Sort.asc);
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterSortBy> thenByFilePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filePath', Sort.desc);
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterSortBy> thenByFileSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileSize', Sort.asc);
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterSortBy> thenByFileSizeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileSize', Sort.desc);
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterSortBy> thenByGymCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gymCount', Sort.asc);
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterSortBy> thenByGymCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gymCount', Sort.desc);
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterSortBy> thenByPresetCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'presetCount', Sort.asc);
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterSortBy>
  thenByPresetCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'presetCount', Sort.desc);
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterSortBy> thenBySetCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'setCount', Sort.asc);
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QAfterSortBy> thenBySetCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'setCount', Sort.desc);
    });
  }
}

extension BackupRecordQueryWhereDistinct
    on QueryBuilder<BackupRecord, BackupRecord, QDistinct> {
  QueryBuilder<BackupRecord, BackupRecord, QDistinct> distinctByDownloadPath({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'downloadPath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QDistinct> distinctByEntryCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'entryCount');
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QDistinct> distinctByExportedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'exportedAt');
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QDistinct> distinctByFileName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fileName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QDistinct> distinctByFilePath({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'filePath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QDistinct> distinctByFileSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fileSize');
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QDistinct> distinctByGymCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gymCount');
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QDistinct> distinctByPresetCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'presetCount');
    });
  }

  QueryBuilder<BackupRecord, BackupRecord, QDistinct> distinctBySetCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'setCount');
    });
  }
}

extension BackupRecordQueryProperty
    on QueryBuilder<BackupRecord, BackupRecord, QQueryProperty> {
  QueryBuilder<BackupRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<BackupRecord, String, QQueryOperations> downloadPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'downloadPath');
    });
  }

  QueryBuilder<BackupRecord, int, QQueryOperations> entryCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entryCount');
    });
  }

  QueryBuilder<BackupRecord, DateTime, QQueryOperations> exportedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'exportedAt');
    });
  }

  QueryBuilder<BackupRecord, String, QQueryOperations> fileNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fileName');
    });
  }

  QueryBuilder<BackupRecord, String, QQueryOperations> filePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'filePath');
    });
  }

  QueryBuilder<BackupRecord, int, QQueryOperations> fileSizeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fileSize');
    });
  }

  QueryBuilder<BackupRecord, int, QQueryOperations> gymCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gymCount');
    });
  }

  QueryBuilder<BackupRecord, int, QQueryOperations> presetCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'presetCount');
    });
  }

  QueryBuilder<BackupRecord, int, QQueryOperations> setCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'setCount');
    });
  }
}
