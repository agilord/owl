import 'dart:async';
import 'dart:convert' as convert;

import 'package:meta/meta.dart';
import 'package:page/page.dart';
import 'package:postgres/postgres.dart';

/// Column names of Scan tables.
class ScanColumn {
  static const String id1 = 'id1';
  static const String id2 = 'id2';
  static const String id3 = 'id3';
  static const String payload = 'payload';

  static const List<String> $all = <String>[
    ScanColumn.id1,
    ScanColumn.id2,
    ScanColumn.id3,
    ScanColumn.payload,
  ];

  static const List<String> $keys = <String>[
    ScanColumn.id1,
    ScanColumn.id2,
    ScanColumn.id3,
  ];

  static const List<String> $nonKeys = <String>[
    ScanColumn.payload,
  ];

  static const List<String> $jsonb = <String>[];

  static const List<String> $bytea = <String>[
    ScanColumn.id2,
    ScanColumn.payload,
  ];

  static const List<String> $tsvector = <String>[];
}

/// Unique continuity position for Scan tables.
class ScanKey implements Comparable<ScanKey> {
  final String id1;
  final List<int> id2;
  final String id3;

  ScanKey({
    @required this.id1,
    @required this.id2,
    @required this.id3,
  });

  @override
  int compareTo(ScanKey $other) {
    int $x = 0;
    $x = id1.compareTo($other.id1);
    if ($x != 0) return $x;
    for (int i = 0; i < id2.length && i < $other.id2.length; i++) {
      $x = id2[i].compareTo($other.id2[i]);
      if ($x != 0) return $x;
    }
    $x = id2.length.compareTo($other.id2.length);
    if ($x != 0) return $x;
    $x = id3.compareTo($other.id3);
    if ($x != 0) return $x;
    return 0;
  }
}

class ScanRow {
  final String id1;
  final List<int> id2;
  final String id3;
  final List<int> payload;

  ScanRow({
    this.id1,
    this.id2,
    this.id3,
    this.payload,
  });

  factory ScanRow.fromRowList(List row, {List<String> columns}) {
    columns ??= ScanColumn.$all;
    assert(row.length == columns.length);
    if (columns == ScanColumn.$all) {
      return ScanRow(
        id1: row[0] as String,
        id2: row[1] as List<int>,
        id3: row[2] as String,
        payload: row[3] as List<int>,
      );
    }
    final int $id1 = columns.indexOf(ScanColumn.id1);
    final int $id2 = columns.indexOf(ScanColumn.id2);
    final int $id3 = columns.indexOf(ScanColumn.id3);
    final int $payload = columns.indexOf(ScanColumn.payload);
    return ScanRow(
      id1: $id1 == -1 ? null : row[$id1] as String,
      id2: $id2 == -1 ? null : row[$id2] as List<int>,
      id3: $id3 == -1 ? null : row[$id3] as String,
      payload: $payload == -1 ? null : row[$payload] as List<int>,
    );
  }

  factory ScanRow.fromRowMap(Map<String, Map<String, dynamic>> row,
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
    return ScanRow(
      id1: map[ScanColumn.id1] as String,
      id2: map[ScanColumn.id2] as List<int>,
      id3: map[ScanColumn.id3] as String,
      payload: map[ScanColumn.payload] as List<int>,
    );
  }

  Map<String, dynamic> toFieldMap({bool removeNulls = false}) {
    final $map = {
      'id1': id1,
      'id2': id2,
      'id3': id3,
      'payload': payload,
    };
    if (removeNulls) {
      $map.removeWhere((k, v) => v == null);
    }
    return $map;
  }

  Map<String, dynamic> toColumnMap({bool removeNulls = false}) {
    final $map = {
      'id1': id1,
      'id2': id2,
      'id3': id3,
      'payload': payload,
    };
    if (removeNulls) {
      $map.removeWhere((k, v) => v == null);
    }
    return $map;
  }

  ScanKey toKey() => ScanKey(
        id1: id1,
        id2: id2,
        id3: id3,
      );
}

class ScanFilter {
  final $params = <String, dynamic>{};
  final $expressions = <String>[];
  final String _prefix = 'p';
  int _cnt = 0;

  ScanFilter clone() {
    return ScanFilter()
      ..$params.addAll($params)
      ..$expressions.addAll($expressions)
      .._cnt = _cnt;
  }

  void primaryKeys(String id1, List<int> id2, String id3) {
    id1$equalsTo(id1);
    id2$equalsTo(id2);
    id3$equalsTo(id3);
  }

  String $join(String op) => $expressions.map((s) => '($s)').join(op);

  void addExpression(String expr) {
    $expressions.add(expr);
  }

  String _next() => '$_prefix${_cnt++}';

  void keyAfter(ScanKey key) {
    final key2 = _next();
    $params[key2] = key.id3;
    final key1 = _next();
    $params[key1] = convert.base64.encode(key.id2);
    final key0 = _next();
    $params[key0] = key.id1;
    $expressions.add(
        '"id1" > @$key0 OR ("id1" = @$key0 AND ("id2" > decode(@$key1, \'base64\') OR ("id2" = decode(@$key1, \'base64\') AND ("id3" > @$key2))))');
  }

  void id1$equalsTo(String value) {
    final key = _next();
    $params[key] = value;
    $expressions.add('"id1" = @$key');
  }

  void id1$isNull() {
    $expressions.add('"id1" IS NULL');
  }

  void id1$isNotNull() {
    $expressions.add('"id1" IS NOT NULL');
  }

  void id1$greaterThan(String value) {
    final key = _next();
    $params[key] = value;
    $expressions.add('"id1" > @$key');
  }

  void id1$greaterThanOrEqualTo(String value) {
    final key = _next();
    $params[key] = value;
    $expressions.add('"id1" >= @$key');
  }

  void id1$lessThan(String value) {
    final key = _next();
    $params[key] = value;
    $expressions.add('"id1" < @$key');
  }

  void id1$lessThanOrEqualTo(String value) {
    final key = _next();
    $params[key] = value;
    $expressions.add('"id1" <= @$key');
  }

  void id2$equalsTo(List<int> value) {
    final key = _next();
    $params[key] = convert.base64.encode(value);
    $expressions.add('"id2" = decode(@$key, \'base64\')');
  }

  void id2$isNull() {
    $expressions.add('"id2" IS NULL');
  }

  void id2$isNotNull() {
    $expressions.add('"id2" IS NOT NULL');
  }

  void id2$greaterThan(List<int> value) {
    final key = _next();
    $params[key] = convert.base64.encode(value);
    $expressions.add('"id2" > decode(@$key, \'base64\')');
  }

  void id2$greaterThanOrEqualTo(List<int> value) {
    final key = _next();
    $params[key] = convert.base64.encode(value);
    $expressions.add('"id2" >= decode(@$key, \'base64\')');
  }

  void id2$lessThan(List<int> value) {
    final key = _next();
    $params[key] = convert.base64.encode(value);
    $expressions.add('"id2" < decode(@$key, \'base64\')');
  }

  void id2$lessThanOrEqualTo(List<int> value) {
    final key = _next();
    $params[key] = convert.base64.encode(value);
    $expressions.add('"id2" <= decode(@$key, \'base64\')');
  }

  void id3$equalsTo(String value) {
    final key = _next();
    $params[key] = value;
    $expressions.add('"id3" = @$key');
  }

  void id3$isNull() {
    $expressions.add('"id3" IS NULL');
  }

  void id3$isNotNull() {
    $expressions.add('"id3" IS NOT NULL');
  }

  void id3$greaterThan(String value) {
    final key = _next();
    $params[key] = value;
    $expressions.add('"id3" > @$key');
  }

  void id3$greaterThanOrEqualTo(String value) {
    final key = _next();
    $params[key] = value;
    $expressions.add('"id3" >= @$key');
  }

  void id3$lessThan(String value) {
    final key = _next();
    $params[key] = value;
    $expressions.add('"id3" < @$key');
  }

  void id3$lessThanOrEqualTo(String value) {
    final key = _next();
    $params[key] = value;
    $expressions.add('"id3" <= @$key');
  }

  void payload$equalsTo(List<int> value) {
    final key = _next();
    $params[key] = convert.base64.encode(value);
    $expressions.add('"payload" = decode(@$key, \'base64\')');
  }

  void payload$isNull() {
    $expressions.add('"payload" IS NULL');
  }

  void payload$isNotNull() {
    $expressions.add('"payload" IS NOT NULL');
  }

  void payload$greaterThan(List<int> value) {
    final key = _next();
    $params[key] = convert.base64.encode(value);
    $expressions.add('"payload" > decode(@$key, \'base64\')');
  }

  void payload$greaterThanOrEqualTo(List<int> value) {
    final key = _next();
    $params[key] = convert.base64.encode(value);
    $expressions.add('"payload" >= decode(@$key, \'base64\')');
  }

  void payload$lessThan(List<int> value) {
    final key = _next();
    $params[key] = convert.base64.encode(value);
    $expressions.add('"payload" < decode(@$key, \'base64\')');
  }

  void payload$lessThanOrEqualTo(List<int> value) {
    final key = _next();
    $params[key] = convert.base64.encode(value);
    $expressions.add('"payload" <= decode(@$key, \'base64\')');
  }
}

class ScanUpdate {
  final $params = <String, dynamic>{};
  final $expressions = <String>[];
  final String _prefix = 'u';
  int _cnt = 0;

  String join() => $expressions.join(', ');

  String _next() => '$_prefix${_cnt++}';

  void id1(String value) {
    if (value == null) return;
    final key = _next();
    $params[key] = value;
    $expressions.add('"id1" = @$key');
  }

  void id1$null() {
    $expressions.add('"id1" = NULL');
  }

  void id1$expr(String expr) {
    $expressions.add('"id1" = $expr');
  }

  void id2(List<int> value) {
    if (value == null) return;
    final key = _next();
    $params[key] = convert.base64.encode(value);
    $expressions.add('"id2" = decode(@$key, \'base64\')');
  }

  void id2$null() {
    $expressions.add('"id2" = NULL');
  }

  void id2$expr(String expr) {
    $expressions.add('"id2" = $expr');
  }

  void id3(String value) {
    if (value == null) return;
    final key = _next();
    $params[key] = value;
    $expressions.add('"id3" = @$key');
  }

  void id3$null() {
    $expressions.add('"id3" = NULL');
  }

  void id3$expr(String expr) {
    $expressions.add('"id3" = $expr');
  }

  void payload(List<int> value) {
    if (value == null) return;
    final key = _next();
    $params[key] = convert.base64.encode(value);
    $expressions.add('"payload" = decode(@$key, \'base64\')');
  }

  void payload$null() {
    $expressions.add('"payload" = NULL');
  }

  void payload$expr(String expr) {
    $expressions.add('"payload" = $expr');
  }
}

class ScanTable {
  final String schema;
  final String name;
  final String fqn;

  ScanTable(this.name, {this.schema})
      : fqn = schema == null ? '"$name"' : '"$schema"."$name"';

  Future init(PostgreSQLExecutionContext conn) async {
    await conn.execute(
        """CREATE TABLE IF NOT EXISTS $fqn ("id1" TEXT, "id2" BYTEA, "id3" TEXT, "payload" BYTEA, PRIMARY KEY ("id1", "id2", "id3"));""");
    await conn.execute(
        """ALTER TABLE $fqn ADD COLUMN IF NOT EXISTS "payload" BYTEA;""");
  }

  Future<ScanRow> read(
      PostgreSQLExecutionContext conn, String id1, List<int> id2, String id3,
      {List<String> columns}) async {
    columns ??= ScanColumn.$all;
    final filter = ScanFilter()..primaryKeys(id1, id2, id3);
    final list = await query(conn, columns: columns, limit: 2, filter: filter);
    if (list.isEmpty) return null;
    return list.single;
  }

  Future<List<ScanRow>> query(
    PostgreSQLExecutionContext conn, {
    List<String> columns,
    List<String> orderBy,
    int limit,
    int offset,
    ScanFilter filter,
  }) async {
    columns ??= ScanColumn.$all;
    final whereQ = (filter == null || filter.$expressions.isEmpty)
        ? null
        : 'WHERE ${filter.$join(' AND ')}';
    final orderByQ = (orderBy == null || orderBy.isEmpty)
        ? null
        : 'ORDER BY ${orderBy.join(', ')}';
    final offsetQ = (offset == null || offset == 0) ? null : 'OFFSET $offset';
    final limitQ = (limit == null || limit == 0) ? null : 'LIMIT $limit';
    final qexpr = ['$fqn', whereQ, orderByQ, offsetQ, limitQ]
        .where((s) => s != null)
        .join(' ');
    final list = await conn.mappedResultsQuery(
        'SELECT ${columns.map((c) => '"$c"').join(', ')} FROM $qexpr',
        substitutionValues: filter?.$params);
    return list.map((row) => ScanRow.fromRowMap(row)).toList();
  }

  Future<Page<ScanRow>> paginate(
    PostgreSQLExecutionContext c, {
    int pageSize = 100,
    List<String> columns,
    ScanFilter filter,
    ScanKey startAfter,
  }) async {
    final List<String> fixedColumns =
        columns == null ? null : List<String>.from(columns);
    if (fixedColumns != null) {
      if (!fixedColumns.contains(ScanColumn.id1)) {
        fixedColumns.add(ScanColumn.id1);
      }
      if (!fixedColumns.contains(ScanColumn.id2)) {
        fixedColumns.add(ScanColumn.id2);
      }
      if (!fixedColumns.contains(ScanColumn.id3)) {
        fixedColumns.add(ScanColumn.id3);
      }
    }
    final page = ScanPage._(null, false, c, this, pageSize, fixedColumns,
        filter?.clone(), startAfter);
    return await page.next();
  }

  Future<int> insert(
    PostgreSQLExecutionContext conn,
    /* ScanRow | List<ScanRow> */
    items, {
    List<String> columns,
    bool upsert,
  }) async {
    final List<ScanRow> rows =
        items is ScanRow ? [items] : items as List<ScanRow>;
    columns ??= ScanColumn.$all;
    final params = <String, dynamic>{};
    final list = <String>[];
    for (int i = 0; i < rows.length; i++) {
      final row = rows[i].toColumnMap();
      final exprs = <String>[];
      for (String col in columns) {
        final key = 'p${i}x$col';
        dynamic value = row[col];
        String expr = '@$key';
        if (value is List<int> && ScanColumn.$bytea.contains(col)) {
          expr = 'decode(@$key, \'base64\')';
          value = convert.base64.encode(value as List<int>);
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
    return conn.execute(
        '$verb INTO $fqn (${columns.map((c) => '"$c"').join(', ')}) VALUES ${list.join(', ')}',
        substitutionValues: params);
  }

  Future<int> update(PostgreSQLExecutionContext conn, String id1, List<int> id2,
      String id3, ScanUpdate update) {
    return updateAll(conn, update,
        filter: ScanFilter()..primaryKeys(id1, id2, id3));
  }

  Future<int> updateAll(PostgreSQLExecutionContext conn, ScanUpdate update,
      {ScanFilter filter, int limit}) async {
    final whereQ = (filter == null || filter.$expressions.isEmpty)
        ? ''
        : 'WHERE ${filter.$join(' AND ')}';
    final params = Map<String, dynamic>.from(filter?.$params ?? {})
      ..addAll(update.$params);
    final limitQ = (limit == null || limit == 0) ? '' : ' LIMIT $limit';
    return conn.execute('UPDATE $fqn SET ${update.join()} $whereQ$limitQ',
        substitutionValues: params);
  }

  Future<int> delete(
      PostgreSQLExecutionContext conn, String id1, List<int> id2, String id3) {
    return deleteAll(conn, ScanFilter()..primaryKeys(id1, id2, id3));
  }

  Future<int> deleteAll(PostgreSQLExecutionContext conn, ScanFilter filter,
      {int limit}) async {
    final whereQ = (filter == null || filter.$expressions.isEmpty)
        ? ''
        : 'WHERE ${filter.$join(' AND ')}';
    final limitQ = (limit == null || limit == 0) ? '' : ' LIMIT $limit';
    return conn.execute('DELETE FROM $fqn $whereQ$limitQ',
        substitutionValues: filter?.$params);
  }
}

class ScanPage extends Object with PageMixin<ScanRow> {
  @override
  final bool isLast;
  @override
  final List<ScanRow> items;
  final PostgreSQLExecutionContext _c;
  final ScanTable _table;
  final int _limit;
  final List<String> _columns;
  final ScanFilter _filter;
  final ScanKey _startAfter;

  ScanPage._(this.items, this.isLast, this._c, this._table, this._limit,
      this._columns, this._filter, this._startAfter);

  @override
  Future<Page<ScanRow>> next() async {
    if (isLast) return null;
    final filter = _filter?.clone() ?? ScanFilter();
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
          ScanColumn.id1,
          ScanColumn.id2,
          ScanColumn.id3,
        ]);
    final nextLast = rows.length <= _limit;
    final nextRows = nextLast ? rows : rows.sublist(0, _limit);
    return ScanPage._(
        nextRows, nextLast, _c, _table, _limit, _columns, _filter, null);
  }

  @override
  Future close() async {}
}
