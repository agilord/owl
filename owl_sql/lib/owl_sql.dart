import 'src/text.dart';

/// SQL table
class Table {
  final String type;
  final List<Column> columns;
  final List<Index> indexes;

  Table(this.type, this.columns, {this.indexes});
}

/// Column of a [Table].
class Column {
  final String name;
  final String type;
  final String defaultsTo;
  final bool isKey;

  Column(this.name, this.type, {this.defaultsTo, this.isKey});

  String get fieldName => snakeToFieldName(name);
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

/// Index of a [Table].
class Index {
  final String nameSuffix;
  final List<String> columns;
  final bool isInverted;

  /// CockroachDB-only field which stores the listed column values alongside the index.
  final List<String> storing;

  Index(this.nameSuffix, this.columns, {this.isInverted: false, this.storing});
}
