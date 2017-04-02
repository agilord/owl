// Copyright (c) 2016, Agilord. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

export 'package:owl/annotation/json.dart' show Transient;

/// The annotated class describes a table in the database.
/// Unless @Transient is used, fields will be used as columns in the table.
class SqlTable {
  /// The name of the table. If not specified, the snake_case version of the
  /// annotated class will be used as name.
  final String name;

  /// The annotated class describes a table in the database.
  const SqlTable({this.name});
}

/// Overrides of the column's inferred details.
class SqlColumn {
  /// The name of the column.
  final String name;

  /// The specific SQL type of the column.
  final SqlType sqlType;

  /// The SQL type, in case [SqlType] does not support it yet.
  final String customType;

  /// Whether the column is part of the primary key.
  final bool primaryKey;

  /// Whether the column is part of the optimistic locking pattern.
  final bool versionKey;

  /// Overrides of the column's inferred details.
  const SqlColumn(
      {this.name,
      this.sqlType,
      this.customType,
      this.primaryKey: false,
      this.versionKey: false});
}

/// Describes a foreign key constraint on a single column.
class SqlForeignKey {
  /// The foreign key's name.
  final String name;

  /// The target table's name.
  final String table;

  /// The target column's name.
  final String column;

  /// The dart type that also has [SqlTable] annotation.
  /// [table] and [column] are inferred from that table.
  final Type reference;

  /// The ON UPDATE constraint.
  final FKConstraint onUpdate;

  /// The ON DELETE constraint.
  final FKConstraint onDelete;

  /// Describes a foreign key constraint on a single column.
  const SqlForeignKey(
      {this.name,
      this.table,
      this.column,
      this.reference,
      this.onUpdate,
      this.onDelete});
}

/// Standard SQL type.
enum SqlType {
  /// Boolean.
  bool,

  /// 16-bit (2-byte) integer.
  int16,

  /// 32-bit (4-byte) integer.
  int32,

  /// 64-bit (8-byte) integer.
  int64,

  /// 32-bit (4-byte) floating point value.
  float32,

  /// 64-bit (8-byte) floating point value.
  float64,

  /// Autoincrementing 32-bit (4-byte) integer.
  serial32,

  /// Autoincrementing 64-bit (8-byte) integer.
  serial64,

  /// String with any length.
  text,

  /// Timestamp with time zone.
  timestamp,

  /// A 128-bit UUID value.
  uuid,
}

/// Foreign key constraint.
enum FKConstraint {
  /// Don't allow constraint violation.
  restrict,

  /// No action on constraint violation.
  noAction,

  /// Change effect is cascading.
  cascade,

  /// Set reference to null.
  setNull
}
