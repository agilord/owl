// Copyright (c) 2016, Agilord. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:postgresql/postgresql.dart';

class _BaseQuery {
  String _query;
  List _params = [];

  /// The SQL query.
  String get query => _query;

  /// The parameters for that query.
  List get params => _params;

  Future<int> _execute(Connection connection, {bool strict: true}) async {
    final int count = await connection.execute(query, params);
    if (strict) {
      if (count == 0) throw new Exception('No such record.');
      if (count > 1) throw new Exception('Too many records.');
    }
    return count;
  }

  void _addWhere(StringBuffer sb, Map<String, dynamic> where) {
    if (where != null && where.isNotEmpty) {
      final List<String> conditions = [];
      for (String column in where.keys) {
        final param = where[column];
        if (param != null) {
          conditions.add('($column = @${_params.length})');
          _params.add(param);
        }
      }
      sb.write(' WHERE ${conditions.join(' AND ')}');
    }
  }
}

/// Simple INSERT query builder.
class SimpleCreate extends _BaseQuery {
  /// The database schema.
  final String schema;

  /// The table name.
  final String table;

  /// The columns to set.
  final Map<String, dynamic> set;

  /// The columns to set to NULL.
  final List<String> clear;

  /// Simple INSERT query builder.
  SimpleCreate({this.schema, this.table, this.set, this.clear}) {
    final String schemaPrefix = schema == null ? '' : schema + '.';
    final StringBuffer sb = new StringBuffer('INSERT INTO $schemaPrefix$table');
    final List<String> columns = [];
    final List<String> placeholders = [];
    for (String column in set.keys) {
      if (clear?.contains(column) == true) continue;
      final param = set[column];
      if (param != null) {
        columns.add(column);
        placeholders.add('@${_params.length}');
        _params.add(param);
      }
    }
    clear?.forEach((String column) {
      columns.add(column);
      placeholders.add('@${_params.length}');
      _params.add(null);
    });
    sb.write(' (${columns.join(', ')}) VALUES (${placeholders.join(', ')})');
    _query = sb.toString();
  }

  /// Execute the query.
  Future<int> execute(Connection connection, {bool strict: true}) =>
      _execute(connection, strict: strict);
}

/// Simple SELECT query builder.
class SimpleSelect extends _BaseQuery {
  /// The database schema.
  final String schema;

  /// The table name.
  final String table;

  /// The columns to query (or all of them if not specified).
  final List<String> columns;

  /// The column conditions to restrict the query.
  final Map<String, dynamic> where;

  /// The limit on the number of results.
  final int limit;

  /// Whether to lock rows for subsequent update.
  final bool forUpdate;

  /// Simple SELECT query builder.
  SimpleSelect(
      {this.schema,
      this.table,
      this.columns,
      this.where,
      this.limit: -1,
      this.forUpdate: false}) {
    final String schemaPrefix = schema == null ? '' : schema + '.';
    final StringBuffer sb = new StringBuffer('SELECT ');
    if (columns == null || columns.isEmpty) {
      sb.write('*');
    } else {
      sb.write(columns.join(', '));
    }
    sb.write(' FROM $schemaPrefix$table');
    _addWhere(sb, where);
    if (limit > -1) {
      sb.write(' LIMIT $limit');
    }
    if (forUpdate) {
      sb.write(' FOR UPDATE');
    }
    _query = sb.toString();
  }

  /// Return one row.
  Future<Row> get(Connection connection, {bool strict: true}) async {
    final List<Row> rows = await connection.query(_query, _params).toList();
    if (strict) {
      if (rows.isEmpty) throw new Exception('No such record.');
      if (rows.length > 1) throw new Exception('Too many records.');
    }
    if (rows.isEmpty) return null;
    return rows.first;
  }

  /// Return multiple rows.
  Stream<Row> list(Connection connection) => connection.query(_query, _params);
}

/// Simple UPDATE query builder.
class SimpleUpdate extends _BaseQuery {
  /// The database schema.
  final String schema;

  /// The table name.
  final String table;

  /// The column values to set.
  final Map<String, dynamic> set;

  /// The column values to set to NULL.
  final List<String> clear;

  /// The column conditions to restrict the query.
  final Map<String, dynamic> where;

  /// Simple UPDATE query builder.
  SimpleUpdate({this.schema, this.table, this.set, this.clear, this.where}) {
    final String schemaPrefix = schema == null ? '' : schema + '.';
    final StringBuffer sb = new StringBuffer('UPDATE $schemaPrefix$table');
    final List<String> updates = [];
    for (String column in set.keys) {
      if (clear?.contains(column) == true) continue;
      final param = set[column];
      if (param != null) {
        updates.add('($column = @${_params.length})');
        _params.add(param);
      }
    }
    clear?.forEach((String column) {
      updates.add('($column = @${_params.length})');
      _params.add(null);
    });
    sb.write(' SET ${updates.join(', ')}');
    _addWhere(sb, where);
    _query = sb.toString();
  }

  /// Execute the query.
  Future<int> execute(Connection connection, {bool strict: true}) =>
      _execute(connection, strict: strict);
}

/// Simple DELETE query builder.
class SimpleDelete extends _BaseQuery {
  /// The database schema.
  final String schema;

  /// The table name.
  final String table;

  /// The column conditions to restrict the query.
  final Map<String, dynamic> where;

  /// Simple UPDATE query builder.
  SimpleDelete({this.schema, this.table, this.where}) {
    final String schemaPrefix = schema == null ? '' : schema + '.';
    final StringBuffer sb = new StringBuffer('DELETE FROM $schemaPrefix$table');
    _addWhere(sb, where);
    _query = sb.toString();
  }

  /// Execute the query.
  Future<int> execute(Connection connection, {bool strict: true}) =>
      _execute(connection, strict: strict);
}
