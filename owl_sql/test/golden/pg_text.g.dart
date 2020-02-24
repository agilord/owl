// ignore_for_file: omit_local_variable_types, prefer_single_quotes
import 'dart:async';

import 'package:meta/meta.dart';
import 'package:page/page.dart';
import 'package:postgres/postgres.dart';

import 'pg_scan.g.dart' as a;

/// Column names of Text tables.
class TextColumn {
  static const String id = 'id';
  static const String snippet = 'snippet';
  static const String vector = 'vector';

  static const List<String> $all = <String>[
    TextColumn.id,
    TextColumn.snippet,
    TextColumn.vector,
  ];

  static const List<String> $keys = <String>[
    TextColumn.id,
  ];

  static const List<String> $nonKeys = <String>[
    TextColumn.snippet,
    TextColumn.vector,
  ];

  static const List<String> $jsonb = <String>[];

  static const List<String> $bytea = <String>[];

  static const List<String> $tsvector = <String>[
    TextColumn.vector,
  ];
}

/// Unique continuity position for Text tables.
class TextKey implements Comparable<TextKey> {
  final String id;

  TextKey({
    @required this.id,
  });

  @override
  int compareTo(TextKey $other) {
    int $x = 0;
    $x = id.compareTo($other.id);
    if ($x != 0) return $x;
    return 0;
  }

  bool isAfter(TextKey other) => compareTo(other) > 0;

  bool isBefore(TextKey other) => compareTo(other) < 0;
}

class TextRow {
  final String id;
  final String snippet;
  final Map<String, String> vector;
  a.ScanRow scanRow;

  TextRow({
    this.id,
    this.snippet,
    this.vector,
    this.scanRow,
  });

  factory TextRow.fromRowList(List row, {List<String> columns}) {
    columns ??= TextColumn.$all;
    assert(row.length == columns.length);
    if (columns == TextColumn.$all) {
      return TextRow(
        id: row[0] as String,
        snippet: row[1] as String,
        vector: _parseTsvector(row[2] as String),
      );
    }
    final int $id = columns.indexOf(TextColumn.id);
    final int $snippet = columns.indexOf(TextColumn.snippet);
    final int $vector = columns.indexOf(TextColumn.vector);
    return TextRow(
      id: $id == -1 ? null : row[$id] as String,
      snippet: $snippet == -1 ? null : row[$snippet] as String,
      vector: $vector == -1 ? null : _parseTsvector(row[$vector] as String),
    );
  }

  factory TextRow.fromRowMap(Map<String, Map<String, dynamic>> row,
      {String table}) {
    if (row == null) return null;
    if (table == null) {
      if (row.length == 1) {
        table = row.keys.first;
      } else {
        throw StateError(
            'Unable to lookup table prefix: $table of ${row.keys}');
      }
    }
    final map = row[table];
    if (map == null) return null;
    return TextRow(
      id: map[TextColumn.id] as String,
      snippet: map[TextColumn.snippet] as String,
      vector: _parseTsvector(map[TextColumn.vector] as String),
    );
  }

  Map<String, dynamic> toFieldMap({bool removeNulls = false}) {
    final $map = {
      'id': id,
      'snippet': snippet,
      'vector': vector,
    };
    if (removeNulls) {
      $map.removeWhere((k, v) => v == null);
    }
    return $map;
  }

  Map<String, dynamic> toColumnMap({bool removeNulls = false}) {
    final $map = {
      'id': id,
      'snippet': snippet,
      'vector': vector,
    };
    if (removeNulls) {
      $map.removeWhere((k, v) => v == null);
    }
    return $map;
  }

  TextKey toKey() => TextKey(
        id: id,
      );
}

class TextFilter {
  final $params = <String, dynamic>{};
  final $expressions = <String>[];
  final String _prefix = 'p';
  int _cnt = 0;

  TextFilter clone() {
    return TextFilter()
      ..$params.addAll($params)
      ..$expressions.addAll($expressions)
      .._cnt = _cnt;
  }

  void primaryKeys(String id) {
    id$equalsTo(id);
  }

  String $join(String op) => $expressions.map((s) => '($s)').join(op);

  void addExpression(String expr) {
    $expressions.add(expr);
  }

  String _next() => '$_prefix${_cnt++}';

  void keyAfter(TextKey key) {
    final key0 = _next();
    $params[key0] = key.id;
    $expressions.add('"id" > @$key0');
  }

  void id$equalsTo(String value) {
    final key = _next();
    $params[key] = value;
    $expressions.add('"id" = @$key');
  }

  void id$isNull() {
    $expressions.add('"id" IS NULL');
  }

  void id$isNotNull() {
    $expressions.add('"id" IS NOT NULL');
  }

  void id$greaterThan(String value) {
    final key = _next();
    $params[key] = value;
    $expressions.add('"id" > @$key');
  }

  void id$greaterThanOrEqualTo(String value) {
    final key = _next();
    $params[key] = value;
    $expressions.add('"id" >= @$key');
  }

  void id$lessThan(String value) {
    final key = _next();
    $params[key] = value;
    $expressions.add('"id" < @$key');
  }

  void id$lessThanOrEqualTo(String value) {
    final key = _next();
    $params[key] = value;
    $expressions.add('"id" <= @$key');
  }

  void snippet$equalsTo(String value) {
    final key = _next();
    $params[key] = value;
    $expressions.add('"snippet" = @$key');
  }

  void snippet$isNull() {
    $expressions.add('"snippet" IS NULL');
  }

  void snippet$isNotNull() {
    $expressions.add('"snippet" IS NOT NULL');
  }

  void snippet$greaterThan(String value) {
    final key = _next();
    $params[key] = value;
    $expressions.add('"snippet" > @$key');
  }

  void snippet$greaterThanOrEqualTo(String value) {
    final key = _next();
    $params[key] = value;
    $expressions.add('"snippet" >= @$key');
  }

  void snippet$lessThan(String value) {
    final key = _next();
    $params[key] = value;
    $expressions.add('"snippet" < @$key');
  }

  void snippet$lessThanOrEqualTo(String value) {
    final key = _next();
    $params[key] = value;
    $expressions.add('"snippet" <= @$key');
  }

  void vector$tsquery(String query) {
    final key = _next();
    $params[key] = query;
    $expressions.add('"vector" @@ @$key::TSQUERY');
  }
}

class TextUpdate {
  final $params = <String, dynamic>{};
  final $expressions = <String>[];
  final String _prefix = 'u';
  int _cnt = 0;

  String join() => $expressions.join(', ');

  String _next() => '$_prefix${_cnt++}';

  void id(String value) {
    if (value == null) return;
    final key = _next();
    $params[key] = value;
    $expressions.add('"id" = @$key');
  }

  void id$null() {
    $expressions.add('"id" = NULL');
  }

  void id$expr(String expr) {
    $expressions.add('"id" = $expr');
  }

  void snippet(String value) {
    if (value == null) return;
    final key = _next();
    $params[key] = value;
    $expressions.add('"snippet" = @$key');
  }

  void snippet$null() {
    $expressions.add('"snippet" = NULL');
  }

  void snippet$expr(String expr) {
    $expressions.add('"snippet" = $expr');
  }

  void vector(Map<String, String> value) {
    if (value == null) return;
    final key = _next();
    $params[key] = _tsvectorToString(value);
    $expressions.add('"vector" = @$key');
  }

  void vector$null() {
    $expressions.add('"vector" = NULL');
  }

  void vector$expr(String expr) {
    $expressions.add('"vector" = $expr');
  }
}

class TextTable {
  final String schema;
  final String name;
  final String fqn;

  TextTable(this.name, {this.schema})
      : fqn = schema == null ? '"$name"' : '"$schema"."$name"';

  Future init(PostgreSQLExecutionContext conn) async {
    await conn.execute(
        """CREATE TABLE IF NOT EXISTS $fqn ("id" TEXT, "snippet" TEXT, "vector" TSVECTOR, PRIMARY KEY ("id"));""");
    await conn.execute(
        """ALTER TABLE $fqn ADD COLUMN IF NOT EXISTS "snippet" TEXT;""");
    await conn.execute(
        """ALTER TABLE $fqn ADD COLUMN IF NOT EXISTS "vector" TSVECTOR;""");
    await conn.execute(
        """CREATE INDEX IF NOT EXISTS "${name}__nx_vector_text" ON $fqn USING GIN("vector");""");
  }

  Future<TextRow> read(PostgreSQLExecutionContext conn, String id,
      {List<String> columns}) async {
    columns ??= TextColumn.$all;
    final filter = TextFilter()..primaryKeys(id);
    final list = await query(conn, columns: columns, limit: 2, filter: filter);
    if (list.isEmpty) return null;
    return list.single;
  }

  Future<List<TextRow>> query(
    PostgreSQLExecutionContext conn, {
    List<String> columns,
    List<String> orderBy,
    int limit,
    int offset,
    TextFilter filter,
  }) async {
    columns ??= TextColumn.$all;
    final whereQ = (filter == null || filter.$expressions.isEmpty)
        ? null
        : 'WHERE ${filter.$join(' AND ')}';
    final orderByQ = (orderBy == null || orderBy.isEmpty)
        ? null
        : 'ORDER BY ${orderBy.map((s) => '"$s"').join(', ')}';
    final offsetQ = (offset == null || offset == 0) ? null : 'OFFSET $offset';
    final limitQ = (limit == null || limit == 0) ? null : 'LIMIT $limit';
    final qexpr = ['$fqn', whereQ, orderByQ, offsetQ, limitQ]
        .where((s) => s != null)
        .join(' ');
    final list = await conn.mappedResultsQuery(
        'SELECT ${columns.map((c) => '"$c"').join(', ')} FROM $qexpr',
        substitutionValues: filter?.$params);
    return list.map((row) => TextRow.fromRowMap(row)).toList();
  }

  Future<Page<TextRow>> paginate(
    PostgreSQLExecutionContext c, {
    int pageSize = 100,
    List<String> columns,
    TextFilter filter,
    TextKey startAfter,
  }) async {
    final List<String> fixedColumns =
        columns == null ? null : List<String>.from(columns);
    if (fixedColumns != null) {
      if (!fixedColumns.contains(TextColumn.id)) {
        fixedColumns.add(TextColumn.id);
      }
    }
    final page = TextPage._(null, false, c, this, pageSize, fixedColumns,
        filter?.clone(), startAfter);
    return await page.next();
  }

  Future<int> insert(
    PostgreSQLExecutionContext conn,
    /* TextRow | List<TextRow> */
    items, {
    List<String> columns,
    bool upsert,
    bool onConflictDoNothing,
  }) async {
    final List<TextRow> rows =
        items is TextRow ? [items] : items as List<TextRow>;
    columns ??= TextColumn.$all;
    final params = <String, dynamic>{};
    final list = <String>[];
    for (int i = 0; i < rows.length; i++) {
      final row = rows[i].toColumnMap();
      final exprs = <String>[];
      for (String col in columns) {
        final key = 'p${i}x$col';
        dynamic value = row[col];
        String expr = '@$key';
        if (value is Map<String, String> &&
            TextColumn.$tsvector.contains(col)) {
          expr = '@$key::TSVECTOR';
          value = _tsvectorToString(value as Map<String, String>);
        }
        exprs.add(expr);
        params[key] = value;
      }
      list.add('(${exprs.join(', ')})');
    }
    if (list.isEmpty) {
      return 0;
    }
    final verb = upsert == true ? 'UPSERT' : 'INSERT';
    var onConflict = '';
    if (onConflictDoNothing ?? false) {
      onConflict = ' ON CONFLICT DO NOTHING';
    }
    return conn.execute(
        '$verb INTO $fqn (${columns.map((c) => '"$c"').join(', ')}) VALUES ${list.join(', ')}$onConflict',
        substitutionValues: params);
  }

  Future<int> update(
      PostgreSQLExecutionContext conn, String id, TextUpdate update) {
    return updateAll(conn, update, filter: TextFilter()..primaryKeys(id));
  }

  Future<int> updateAll(PostgreSQLExecutionContext conn, TextUpdate update,
      {TextFilter filter, int limit}) async {
    final whereQ = (filter == null || filter.$expressions.isEmpty)
        ? ''
        : 'WHERE ${filter.$join(' AND ')}';
    final params = Map<String, dynamic>.from(filter?.$params ?? {})
      ..addAll(update.$params);
    final limitQ = (limit == null || limit == 0) ? '' : ' LIMIT $limit';
    return conn.execute('UPDATE $fqn SET ${update.join()} $whereQ$limitQ',
        substitutionValues: params);
  }

  Future<int> delete(PostgreSQLExecutionContext conn, String id) {
    return deleteAll(conn, TextFilter()..primaryKeys(id));
  }

  Future<int> deleteAll(PostgreSQLExecutionContext conn, TextFilter filter,
      {int limit}) async {
    final whereQ = (filter == null || filter.$expressions.isEmpty)
        ? ''
        : 'WHERE ${filter.$join(' AND ')}';
    final limitQ = (limit == null || limit == 0) ? '' : ' LIMIT $limit';
    return conn.execute('DELETE FROM $fqn $whereQ$limitQ',
        substitutionValues: filter?.$params);
  }
}

class TextPage extends Object with PageMixin<TextRow> {
  @override
  final bool isLast;
  @override
  final List<TextRow> items;
  final PostgreSQLExecutionContext _c;
  final TextTable _table;
  final int _limit;
  final List<String> _columns;
  final TextFilter _filter;
  final TextKey _startAfter;

  TextPage._(this.items, this.isLast, this._c, this._table, this._limit,
      this._columns, this._filter, this._startAfter);

  @override
  Future<Page<TextRow>> next() async {
    if (isLast) return null;
    final filter = _filter?.clone() ?? TextFilter();
    if (items != null) {
      filter.keyAfter(items.last.toKey());
    } else if (_startAfter != null) {
      filter.keyAfter(_startAfter);
    }
    final rows = await _table.query(_c,
        columns: _columns,
        filter: filter,
        limit: _limit + 1,
        orderBy: [
          TextColumn.id,
        ]);
    final nextLast = rows.length <= _limit;
    final nextRows = nextLast ? rows : rows.sublist(0, _limit);
    return TextPage._(
        nextRows, nextLast, _c, _table, _limit, _columns, _filter, null);
  }

  @override
  Future close() async {}
}

String _tsvectorToString(Map<String, String> vector) {
  if (vector == null) return null;
  return vector.keys.map((k) {
    final v = vector[k];
    return v == null ? k : '$k:$v';
  }).join(' ');
}

Map<String, String> _parseTsvector(String vector) {
  if (vector == null) return null;
  final result = <String, String>{};
  vector.split(' ').forEach((part) {
    final ps = part.split(':');
    if (ps.length == 1) {
      result[part] = null;
    } else if (ps.length == 2) {
      result[ps[0]] = ps[1];
    }
  });
  return result;
}
