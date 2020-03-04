import 'src/text.dart';

/// SQL table
class Table {
  final String type;
  final List<Column> columns;
  final List<Field> fields;
  final List<Index> indexes;

  Table(this.type, this.columns, {this.fields, this.indexes});
}

/// Column of a [Table].
class Column {
  final String name;
  final String type;
  final String defaultsTo;
  final bool isKey;
  final bool isUnique;
  final String family;
  final bool isDescending;

  Column(
    this.name,
    this.type, {
    this.defaultsTo,
    bool isKey,
    bool isUnique,
    this.family,
    bool isDescending,
  })  : isKey = isKey ?? false,
        isUnique = isUnique ?? false,
        isDescending = isDescending ?? false;

  String get fieldName => snakeToFieldName(name);
  bool get hasFamily => family != null && family.isNotEmpty;
}

abstract class SqlType {
  static const String boolean = 'BOOLEAN';
  static const String bigint = 'BIGINT';
  static const String smallint = 'SMALLINT';
  // static const String numeric = 'NUMERIC';
  static const String double = 'DOUBLE';
  static const String text = 'TEXT';
  static const String timestamp = 'TIMESTAMP';
  static const String uuid = 'UUID';
  static const String jsonb = 'JSONB';
  static const String bytea = 'BYTEA';
  static const String tsvector = 'TSVECTOR';
}

/// Non-persisted field added to the `Row` object.
class Field {
  final String name;
  final String type;

  Field(this.name, this.type);
}

/// Index of a [Table].
class Index {
  final String nameSuffix;
  final List<String> columns;
  final bool isInverted;

  /// CockroachDB-only field which stores the listed column values alongside the index.
  final List<String> storing;

  Index(this.nameSuffix, this.columns, {this.isInverted = false, this.storing});
}
