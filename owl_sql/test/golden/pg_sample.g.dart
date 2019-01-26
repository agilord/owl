import 'dart:async';
import 'dart:convert' as convert;

import 'package:meta/meta.dart';
import 'package:page/page.dart';
import 'package:postgres/postgres.dart';

/// Column names of Sample tables.
class SampleColumn {
  static const String textCol = 'text_col';
  static const String byteaCol = 'bytea_col';
  static const String booleanCol = 'boolean_col';
  static const String doubleCol = 'double_col';
  static const String bigintCol = 'bigint_col';
  static const String smallintCol = 'smallint_col';
  static const String uuidCol = 'uuid_col';
  static const String timestampCol = 'timestamp_col';
  static const String jsonbCol = 'jsonb_col';

  static const List<String> $all = const <String>[
    SampleColumn.textCol,
    SampleColumn.byteaCol,
    SampleColumn.booleanCol,
    SampleColumn.doubleCol,
    SampleColumn.bigintCol,
    SampleColumn.smallintCol,
    SampleColumn.uuidCol,
    SampleColumn.timestampCol,
    SampleColumn.jsonbCol,
  ];

  static const List<String> $keys = const <String>[
    SampleColumn.textCol,
  ];

  static const List<String> $nonKeys = const <String>[
    SampleColumn.byteaCol,
    SampleColumn.booleanCol,
    SampleColumn.doubleCol,
    SampleColumn.bigintCol,
    SampleColumn.smallintCol,
    SampleColumn.uuidCol,
    SampleColumn.timestampCol,
    SampleColumn.jsonbCol,
  ];

  static const List<String> $jsonb = const <String>[
    SampleColumn.jsonbCol,
  ];

  static const List<String> $bytea = const <String>[
    SampleColumn.byteaCol,
  ];

  static const List<String> $tsvector = const <String>[];
}

/// Unique continuity position for Sample tables.
class SampleKey implements Comparable<SampleKey> {
  final String textCol;

  SampleKey({
    @required this.textCol,
  });

  @override
  int compareTo(SampleKey $other) {
    int $x = 0;
    $x = textCol.compareTo($other.textCol);
    if ($x != 0) return $x;
    return 0;
  }
}

class SampleRow {
  final String textCol;
  final List<int> byteaCol;
  final bool booleanCol;
  final double doubleCol;
  final int bigintCol;
  final int smallintCol;
  final String uuidCol;
  final DateTime timestampCol;
  final Map<String, dynamic> jsonbCol;

  SampleRow({
    this.textCol,
    this.byteaCol,
    this.booleanCol,
    this.doubleCol,
    this.bigintCol,
    this.smallintCol,
    this.uuidCol,
    this.timestampCol,
    this.jsonbCol,
  });

  factory SampleRow.fromRowList(List row, {List<String> columns}) {
    columns ??= SampleColumn.$all;
    assert(row.length == columns.length);
    if (columns == SampleColumn.$all) {
      return new SampleRow(
        textCol: row[0] as String,
        byteaCol: row[1] as List<int>,
        booleanCol: row[2] as bool,
        doubleCol: row[3] as double,
        bigintCol: row[4] as int,
        smallintCol: row[5] as int,
        uuidCol: row[6] as String,
        timestampCol: row[7] as DateTime,
        jsonbCol: row[8] as Map<String, dynamic>,
      );
    }
    final int $textCol = columns.indexOf(SampleColumn.textCol);
    final int $byteaCol = columns.indexOf(SampleColumn.byteaCol);
    final int $booleanCol = columns.indexOf(SampleColumn.booleanCol);
    final int $doubleCol = columns.indexOf(SampleColumn.doubleCol);
    final int $bigintCol = columns.indexOf(SampleColumn.bigintCol);
    final int $smallintCol = columns.indexOf(SampleColumn.smallintCol);
    final int $uuidCol = columns.indexOf(SampleColumn.uuidCol);
    final int $timestampCol = columns.indexOf(SampleColumn.timestampCol);
    final int $jsonbCol = columns.indexOf(SampleColumn.jsonbCol);
    return new SampleRow(
      textCol: $textCol == -1 ? null : row[$textCol] as String,
      byteaCol: $byteaCol == -1 ? null : row[$byteaCol] as List<int>,
      booleanCol: $booleanCol == -1 ? null : row[$booleanCol] as bool,
      doubleCol: $doubleCol == -1 ? null : row[$doubleCol] as double,
      bigintCol: $bigintCol == -1 ? null : row[$bigintCol] as int,
      smallintCol: $smallintCol == -1 ? null : row[$smallintCol] as int,
      uuidCol: $uuidCol == -1 ? null : row[$uuidCol] as String,
      timestampCol: $timestampCol == -1 ? null : row[$timestampCol] as DateTime,
      jsonbCol: $jsonbCol == -1 ? null : row[$jsonbCol] as Map<String, dynamic>,
    );
  }

  factory SampleRow.fromRowMap(Map<String, Map<String, dynamic>> row,
      {String table}) {
    if (row == null) return null;
    if (table == null) {
      if (row.length == 1) {
        table = row.keys.first;
      } else {
        throw new StateError(
            'Unable to lookup table prefix: $table of ${row.keys}');
      }
    }
    final map = row[table];
    if (map == null) return null;
    return new SampleRow(
      textCol: map[SampleColumn.textCol] as String,
      byteaCol: map[SampleColumn.byteaCol] as List<int>,
      booleanCol: map[SampleColumn.booleanCol] as bool,
      doubleCol: map[SampleColumn.doubleCol] as double,
      bigintCol: map[SampleColumn.bigintCol] as int,
      smallintCol: map[SampleColumn.smallintCol] as int,
      uuidCol: map[SampleColumn.uuidCol] as String,
      timestampCol: map[SampleColumn.timestampCol] as DateTime,
      jsonbCol: map[SampleColumn.jsonbCol] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toFieldMap({bool removeNulls: false}) {
    final $map = {
      'textCol': textCol,
      'byteaCol': byteaCol,
      'booleanCol': booleanCol,
      'doubleCol': doubleCol,
      'bigintCol': bigintCol,
      'smallintCol': smallintCol,
      'uuidCol': uuidCol,
      'timestampCol': timestampCol?.toIso8601String(),
      'jsonbCol': jsonbCol,
    };
    if (removeNulls) {
      $map.removeWhere((k, v) => v == null);
    }
    return $map;
  }

  Map<String, dynamic> toColumnMap({bool removeNulls: false}) {
    final $map = {
      'text_col': textCol,
      'bytea_col': byteaCol,
      'boolean_col': booleanCol,
      'double_col': doubleCol,
      'bigint_col': bigintCol,
      'smallint_col': smallintCol,
      'uuid_col': uuidCol,
      'timestamp_col': timestampCol?.toIso8601String(),
      'jsonb_col': jsonbCol,
    };
    if (removeNulls) {
      $map.removeWhere((k, v) => v == null);
    }
    return $map;
  }

  SampleKey toKey() => new SampleKey(
        textCol: textCol,
      );
}

class SampleFilter {
  final $params = <String, dynamic>{};
  final $expressions = <String>[];
  final String _prefix = 'p';
  int _cnt = 0;

  SampleFilter clone() {
    return new SampleFilter()
      ..$params.addAll($params)
      ..$expressions.addAll($expressions)
      .._cnt = _cnt;
  }

  void primaryKeys(String textCol) {
    this.textCol$equalsTo(textCol);
  }

  String $join(String op) => $expressions.map((s) => '($s)').join(op);

  void addExpression(String expr) {
    $expressions.add(expr);
  }

  String _next() => '$_prefix${_cnt++}';

  void keyAfter(SampleKey key) {
    final key0 = _next();
    $params[key0] = key.textCol;
    $expressions.add('"text_col" > @$key0');
  }

  void textCol$equalsTo(String value) {
    final key = _next();
    $params[key] = value;
    $expressions.add('"text_col" = @$key');
  }

  void textCol$isNull() {
    $expressions.add('"text_col" IS NULL');
  }

  void textCol$isNotNull() {
    $expressions.add('"text_col" IS NOT NULL');
  }

  void textCol$greaterThan(String value) {
    final key = _next();
    $params[key] = value;
    $expressions.add('"text_col" > @$key');
  }

  void textCol$greaterThanOrEqualTo(String value) {
    final key = _next();
    $params[key] = value;
    $expressions.add('"text_col" >= @$key');
  }

  void textCol$lessThan(String value) {
    final key = _next();
    $params[key] = value;
    $expressions.add('"text_col" < @$key');
  }

  void textCol$lessThanOrEqualTo(String value) {
    final key = _next();
    $params[key] = value;
    $expressions.add('"text_col" <= @$key');
  }

  void byteaCol$equalsTo(List<int> value) {
    final key = _next();
    $params[key] = convert.base64.encode(value);
    $expressions.add('"bytea_col" = decode(@$key, \'base64\')');
  }

  void byteaCol$isNull() {
    $expressions.add('"bytea_col" IS NULL');
  }

  void byteaCol$isNotNull() {
    $expressions.add('"bytea_col" IS NOT NULL');
  }

  void byteaCol$greaterThan(List<int> value) {
    final key = _next();
    $params[key] = convert.base64.encode(value);
    $expressions.add('"bytea_col" > decode(@$key, \'base64\')');
  }

  void byteaCol$greaterThanOrEqualTo(List<int> value) {
    final key = _next();
    $params[key] = convert.base64.encode(value);
    $expressions.add('"bytea_col" >= decode(@$key, \'base64\')');
  }

  void byteaCol$lessThan(List<int> value) {
    final key = _next();
    $params[key] = convert.base64.encode(value);
    $expressions.add('"bytea_col" < decode(@$key, \'base64\')');
  }

  void byteaCol$lessThanOrEqualTo(List<int> value) {
    final key = _next();
    $params[key] = convert.base64.encode(value);
    $expressions.add('"bytea_col" <= decode(@$key, \'base64\')');
  }

  void booleanCol$equalsTo(bool value) {
    final key = _next();
    $params[key] = value;
    $expressions.add('"boolean_col" = @$key');
  }

  void booleanCol$isNull() {
    $expressions.add('"boolean_col" IS NULL');
  }

  void booleanCol$isNotNull() {
    $expressions.add('"boolean_col" IS NOT NULL');
  }

  void booleanCol$greaterThan(bool value) {
    final key = _next();
    $params[key] = value;
    $expressions.add('"boolean_col" > @$key');
  }

  void booleanCol$greaterThanOrEqualTo(bool value) {
    final key = _next();
    $params[key] = value;
    $expressions.add('"boolean_col" >= @$key');
  }

  void booleanCol$lessThan(bool value) {
    final key = _next();
    $params[key] = value;
    $expressions.add('"boolean_col" < @$key');
  }

  void booleanCol$lessThanOrEqualTo(bool value) {
    final key = _next();
    $params[key] = value;
    $expressions.add('"boolean_col" <= @$key');
  }

  void doubleCol$equalsTo(double value) {
    final key = _next();
    $params[key] = value;
    $expressions.add('"double_col" = @$key');
  }

  void doubleCol$isNull() {
    $expressions.add('"double_col" IS NULL');
  }

  void doubleCol$isNotNull() {
    $expressions.add('"double_col" IS NOT NULL');
  }

  void doubleCol$greaterThan(double value) {
    final key = _next();
    $params[key] = value;
    $expressions.add('"double_col" > @$key');
  }

  void doubleCol$greaterThanOrEqualTo(double value) {
    final key = _next();
    $params[key] = value;
    $expressions.add('"double_col" >= @$key');
  }

  void doubleCol$lessThan(double value) {
    final key = _next();
    $params[key] = value;
    $expressions.add('"double_col" < @$key');
  }

  void doubleCol$lessThanOrEqualTo(double value) {
    final key = _next();
    $params[key] = value;
    $expressions.add('"double_col" <= @$key');
  }

  void bigintCol$equalsTo(int value) {
    final key = _next();
    $params[key] = value;
    $expressions.add('"bigint_col" = @$key');
  }

  void bigintCol$isNull() {
    $expressions.add('"bigint_col" IS NULL');
  }

  void bigintCol$isNotNull() {
    $expressions.add('"bigint_col" IS NOT NULL');
  }

  void bigintCol$greaterThan(int value) {
    final key = _next();
    $params[key] = value;
    $expressions.add('"bigint_col" > @$key');
  }

  void bigintCol$greaterThanOrEqualTo(int value) {
    final key = _next();
    $params[key] = value;
    $expressions.add('"bigint_col" >= @$key');
  }

  void bigintCol$lessThan(int value) {
    final key = _next();
    $params[key] = value;
    $expressions.add('"bigint_col" < @$key');
  }

  void bigintCol$lessThanOrEqualTo(int value) {
    final key = _next();
    $params[key] = value;
    $expressions.add('"bigint_col" <= @$key');
  }

  void smallintCol$equalsTo(int value) {
    final key = _next();
    $params[key] = value;
    $expressions.add('"smallint_col" = @$key');
  }

  void smallintCol$isNull() {
    $expressions.add('"smallint_col" IS NULL');
  }

  void smallintCol$isNotNull() {
    $expressions.add('"smallint_col" IS NOT NULL');
  }

  void smallintCol$greaterThan(int value) {
    final key = _next();
    $params[key] = value;
    $expressions.add('"smallint_col" > @$key');
  }

  void smallintCol$greaterThanOrEqualTo(int value) {
    final key = _next();
    $params[key] = value;
    $expressions.add('"smallint_col" >= @$key');
  }

  void smallintCol$lessThan(int value) {
    final key = _next();
    $params[key] = value;
    $expressions.add('"smallint_col" < @$key');
  }

  void smallintCol$lessThanOrEqualTo(int value) {
    final key = _next();
    $params[key] = value;
    $expressions.add('"smallint_col" <= @$key');
  }

  void uuidCol$equalsTo(String value) {
    final key = _next();
    $params[key] = value;
    $expressions.add('"uuid_col" = @$key');
  }

  void uuidCol$isNull() {
    $expressions.add('"uuid_col" IS NULL');
  }

  void uuidCol$isNotNull() {
    $expressions.add('"uuid_col" IS NOT NULL');
  }

  void uuidCol$greaterThan(String value) {
    final key = _next();
    $params[key] = value;
    $expressions.add('"uuid_col" > @$key');
  }

  void uuidCol$greaterThanOrEqualTo(String value) {
    final key = _next();
    $params[key] = value;
    $expressions.add('"uuid_col" >= @$key');
  }

  void uuidCol$lessThan(String value) {
    final key = _next();
    $params[key] = value;
    $expressions.add('"uuid_col" < @$key');
  }

  void uuidCol$lessThanOrEqualTo(String value) {
    final key = _next();
    $params[key] = value;
    $expressions.add('"uuid_col" <= @$key');
  }

  void timestampCol$equalsTo(DateTime value) {
    final key = _next();
    $params[key] = value.toUtc().toIso8601String().replaceFirst('Z', '');
    $expressions.add('"timestamp_col" = @$key::TIMESTAMP');
  }

  void timestampCol$isNull() {
    $expressions.add('"timestamp_col" IS NULL');
  }

  void timestampCol$isNotNull() {
    $expressions.add('"timestamp_col" IS NOT NULL');
  }

  void timestampCol$greaterThan(DateTime value) {
    final key = _next();
    $params[key] = value.toUtc().toIso8601String().replaceFirst('Z', '');
    $expressions.add('"timestamp_col" > @$key::TIMESTAMP');
  }

  void timestampCol$greaterThanOrEqualTo(DateTime value) {
    final key = _next();
    $params[key] = value.toUtc().toIso8601String().replaceFirst('Z', '');
    $expressions.add('"timestamp_col" >= @$key::TIMESTAMP');
  }

  void timestampCol$lessThan(DateTime value) {
    final key = _next();
    $params[key] = value.toUtc().toIso8601String().replaceFirst('Z', '');
    $expressions.add('"timestamp_col" < @$key::TIMESTAMP');
  }

  void timestampCol$lessThanOrEqualTo(DateTime value) {
    final key = _next();
    $params[key] = value.toUtc().toIso8601String().replaceFirst('Z', '');
    $expressions.add('"timestamp_col" <= @$key::TIMESTAMP');
  }

  void jsonbCol$matches(Map<String, dynamic> value) {
    final key = _next();
    $params[key] = convert.json.encode(value);
    $expressions.add('"jsonb_col" @> @$key::JSONB');
  }
}

class SampleUpdate {
  final $params = <String, dynamic>{};
  final $expressions = <String>[];
  final String _prefix = 'u';
  int _cnt = 0;

  String join() => $expressions.join(', ');

  String _next() => '$_prefix${_cnt++}';

  void textCol(String value) {
    if (value == null) return;
    final key = _next();
    $params[key] = value;
    $expressions.add('"text_col" = @$key');
  }

  void textCol$null() {
    $expressions.add('"text_col" = NULL');
  }

  void textCol$expr(String expr) {
    $expressions.add('"text_col" = $expr');
  }

  void byteaCol(List<int> value) {
    if (value == null) return;
    final key = _next();
    $params[key] = convert.base64.encode(value);
    $expressions.add('"bytea_col" = decode(@$key, \'base64\')');
  }

  void byteaCol$null() {
    $expressions.add('"bytea_col" = NULL');
  }

  void byteaCol$expr(String expr) {
    $expressions.add('"bytea_col" = $expr');
  }

  void booleanCol(bool value) {
    if (value == null) return;
    final key = _next();
    $params[key] = value;
    $expressions.add('"boolean_col" = @$key');
  }

  void booleanCol$null() {
    $expressions.add('"boolean_col" = NULL');
  }

  void booleanCol$expr(String expr) {
    $expressions.add('"boolean_col" = $expr');
  }

  void doubleCol(double value) {
    if (value == null) return;
    final key = _next();
    $params[key] = value;
    $expressions.add('"double_col" = @$key');
  }

  void doubleCol$null() {
    $expressions.add('"double_col" = NULL');
  }

  void doubleCol$expr(String expr) {
    $expressions.add('"double_col" = $expr');
  }

  void bigintCol(int value) {
    if (value == null) return;
    final key = _next();
    $params[key] = value;
    $expressions.add('"bigint_col" = @$key');
  }

  void bigintCol$null() {
    $expressions.add('"bigint_col" = NULL');
  }

  void bigintCol$expr(String expr) {
    $expressions.add('"bigint_col" = $expr');
  }

  void smallintCol(int value) {
    if (value == null) return;
    final key = _next();
    $params[key] = value;
    $expressions.add('"smallint_col" = @$key');
  }

  void smallintCol$null() {
    $expressions.add('"smallint_col" = NULL');
  }

  void smallintCol$expr(String expr) {
    $expressions.add('"smallint_col" = $expr');
  }

  void uuidCol(String value) {
    if (value == null) return;
    final key = _next();
    $params[key] = value;
    $expressions.add('"uuid_col" = @$key');
  }

  void uuidCol$null() {
    $expressions.add('"uuid_col" = NULL');
  }

  void uuidCol$expr(String expr) {
    $expressions.add('"uuid_col" = $expr');
  }

  void timestampCol(DateTime value) {
    if (value == null) return;
    final key = _next();
    $params[key] = value.toUtc().toIso8601String().replaceFirst('Z', '');
    $expressions.add('"timestamp_col" = @$key::TIMESTAMP');
  }

  void timestampCol$null() {
    $expressions.add('"timestamp_col" = NULL');
  }

  void timestampCol$expr(String expr) {
    $expressions.add('"timestamp_col" = $expr');
  }

  void jsonbCol(Map<String, dynamic> value) {
    if (value == null) return;
    final key = _next();
    $params[key] = convert.json.encode(value);
    $expressions.add('"jsonb_col" = @$key::JSONB');
  }

  void jsonbCol$null() {
    $expressions.add('"jsonb_col" = NULL');
  }

  void jsonbCol$expr(String expr) {
    $expressions.add('"jsonb_col" = $expr');
  }
}

class SampleTable {
  final String schema;
  final String name;
  final String fqn;

  SampleTable(this.name, {this.schema})
      : this.fqn = schema == null ? '"$name"' : '"$schema"."$name"';

  Future init(PostgreSQLExecutionContext conn) async {
    await conn.execute(
        """CREATE TABLE IF NOT EXISTS $fqn ("text_col" TEXT, "bytea_col" BYTEA, "boolean_col" BOOLEAN, "double_col" DOUBLE PRECISION, "bigint_col" BIGINT, "smallint_col" SMALLINT, "uuid_col" UUID, "timestamp_col" TIMESTAMP, "jsonb_col" JSONB, PRIMARY KEY ("text_col"));""");
    await conn.execute(
        """ALTER TABLE $fqn ADD COLUMN IF NOT EXISTS "bytea_col" BYTEA;""");
    await conn.execute(
        """ALTER TABLE $fqn ADD COLUMN IF NOT EXISTS "boolean_col" BOOLEAN;""");
    await conn.execute(
        """ALTER TABLE $fqn ADD COLUMN IF NOT EXISTS "double_col" DOUBLE PRECISION;""");
    await conn.execute(
        """ALTER TABLE $fqn ADD COLUMN IF NOT EXISTS "bigint_col" BIGINT;""");
    await conn.execute(
        """ALTER TABLE $fqn ADD COLUMN IF NOT EXISTS "smallint_col" SMALLINT;""");
    await conn.execute(
        """ALTER TABLE $fqn ADD COLUMN IF NOT EXISTS "uuid_col" UUID;""");
    await conn.execute(
        """ALTER TABLE $fqn ADD COLUMN IF NOT EXISTS "timestamp_col" TIMESTAMP;""");
    await conn.execute(
        """ALTER TABLE $fqn ADD COLUMN IF NOT EXISTS "jsonb_col" JSONB;""");
  }

  Future<SampleRow> read(PostgreSQLExecutionContext conn, String textCol,
      {List<String> columns}) async {
    columns ??= SampleColumn.$all;
    final filter = new SampleFilter()..primaryKeys(textCol);
    final list = await query(conn, columns: columns, limit: 2, filter: filter);
    if (list.isEmpty) return null;
    return list.single;
  }

  Future<List<SampleRow>> query(
    PostgreSQLExecutionContext conn, {
    List<String> columns,
    List<String> orderBy,
    int limit,
    int offset,
    SampleFilter filter,
  }) async {
    columns ??= SampleColumn.$all;
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
    return list.map((row) => new SampleRow.fromRowMap(row)).toList();
  }

  Future<Page<SampleRow>> paginate(
    SampleConnectionFn fn, {
    int pageSize: 100,
    List<String> columns,
    SampleFilter filter,
    SampleKey startAfter,
  }) async {
    final List<String> fixedColumns =
        columns == null ? null : new List<String>.from(columns);
    if (fixedColumns != null) {
      if (!fixedColumns.contains(SampleColumn.textCol)) {
        fixedColumns.add(SampleColumn.textCol);
      }
    }
    final page = new SamplePage._(null, false, fn, this, pageSize, fixedColumns,
        filter?.clone(), startAfter);
    return await page.next();
  }

  Future<int> insert(
    PostgreSQLExecutionContext conn,
    /* SampleRow | List<SampleRow> */
    items, {
    List<String> columns,
    bool upsert,
  }) async {
    final List<SampleRow> rows =
        items is SampleRow ? [items] : items as List<SampleRow>;
    columns ??= SampleColumn.$all;
    final params = <String, dynamic>{};
    final list = <String>[];
    for (int i = 0; i < rows.length; i++) {
      final row = rows[i].toColumnMap();
      final exprs = <String>[];
      for (String col in columns) {
        final key = 'p${i}x$col';
        dynamic value = row[col];
        String expr = '@$key';
        if (value is Map && SampleColumn.$jsonb.contains(col)) {
          expr = '@$key::JSONB';
          value = convert.json.encode(value);
        }
        if (value is List<int> && SampleColumn.$bytea.contains(col)) {
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

  Future<int> update(
      PostgreSQLExecutionContext conn, String textCol, SampleUpdate update) {
    return updateAll(conn, update,
        filter: new SampleFilter()..primaryKeys(textCol));
  }

  Future<int> updateAll(
    PostgreSQLExecutionContext conn,
    SampleUpdate update, {
    SampleFilter filter,
  }) async {
    final whereQ = (filter == null || filter.$expressions.isEmpty)
        ? ''
        : 'WHERE ${filter.$join(' AND ')}';
    final params = new Map<String, dynamic>.from(filter?.$params ?? {})
      ..addAll(update.$params);
    return conn.execute('UPDATE $fqn SET ${update.join()} $whereQ',
        substitutionValues: params);
  }

  Future<int> delete(PostgreSQLExecutionContext conn, String textCol) {
    return deleteAll(conn, new SampleFilter()..primaryKeys(textCol));
  }

  Future<int> deleteAll(PostgreSQLExecutionContext conn, SampleFilter filter,
      {int limit}) async {
    final whereQ = (filter == null || filter.$expressions.isEmpty)
        ? ''
        : 'WHERE ${filter.$join(' AND ')}';
    final limitQ = (limit == null || limit == 0) ? '' : ' LIMIT $limit';
    return conn.execute('DELETE FROM $fqn $whereQ$limitQ',
        substitutionValues: filter?.$params);
  }
}

typedef Future<R> SampleConnectionFn<R>(
    Future<R> fn(PostgreSQLExecutionContext c));

class SamplePage extends Object with PageMixin<SampleRow> {
  @override
  final bool isLast;
  @override
  final List<SampleRow> items;
  final SampleConnectionFn _fn;
  final SampleTable _table;
  final int _limit;
  final List<String> _columns;
  final SampleFilter _filter;
  final SampleKey _startAfter;

  SamplePage._(this.items, this.isLast, this._fn, this._table, this._limit,
      this._columns, this._filter, this._startAfter);

  @override
  Future<Page<SampleRow>> next() async {
    if (isLast) return null;
    final filter = _filter?.clone() ?? new SampleFilter();
    if (items != null) {
      filter.keyAfter(items.last.toKey());
    } else if (_startAfter != null) {
      filter.keyAfter(_startAfter);
    }
    final rs = await _fn((c) async {
      final rows = await _table.query(c,
          columns: _columns,
          filter: filter,
          limit: _limit + 1,
          orderBy: [
            SampleColumn.textCol,
          ]);
      final nextLast = rows.length <= _limit;
      final nextRows = nextLast ? rows : rows.sublist(0, _limit);
      return new SamplePage._(
          nextRows, nextLast, _fn, _table, _limit, _columns, _filter, null);
    });
    return rs as Page<SampleRow>;
  }

  @override
  Future close() async {}
}
