// ignore_for_file: omit_local_variable_types, prefer_single_quotes
import 'dart:async';
import 'dart:convert' as convert;

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

  static const List<String> $all = <String>[
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

  static const List<String> $keys = <String>[
    SampleColumn.textCol,
  ];

  static const List<String> $nonKeys = <String>[
    SampleColumn.byteaCol,
    SampleColumn.booleanCol,
    SampleColumn.doubleCol,
    SampleColumn.bigintCol,
    SampleColumn.smallintCol,
    SampleColumn.uuidCol,
    SampleColumn.timestampCol,
    SampleColumn.jsonbCol,
  ];

  static const List<String> $jsonb = <String>[
    SampleColumn.jsonbCol,
  ];

  static const List<String> $bytea = <String>[
    SampleColumn.byteaCol,
  ];

  static const List<String> $tsvector = <String>[];
}

/// Unique continuity position for Sample tables.
class SampleKey implements Comparable<SampleKey> {
  final String textCol;

  SampleKey({
    required this.textCol,
  });

  @override
  int compareTo(SampleKey $other) {
    int $x = 0;
    $x = textCol.compareTo($other.textCol);
    if ($x != 0) return $x;
    return 0;
  }

  bool isAfter(SampleKey other) => compareTo(other) > 0;

  bool isBefore(SampleKey other) => compareTo(other) < 0;
}

class SampleRow {
  final String? textCol;
  final List<int>? byteaCol;
  final bool? booleanCol;
  final double? doubleCol;
  final int? bigintCol;
  final int? smallintCol;
  final String? uuidCol;
  final DateTime? timestampCol;
  final Map<String, dynamic>? jsonbCol;

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

  factory SampleRow.fromRowList(List row, {List<String>? columns}) {
    columns ??= SampleColumn.$all;
    assert(row.length == columns.length);
    if (columns == SampleColumn.$all) {
      return SampleRow(
        textCol: row[0] as String?,
        byteaCol: row[1] as List<int>?,
        booleanCol: row[2] as bool?,
        doubleCol: row[3] as double?,
        bigintCol: row[4] as int?,
        smallintCol: row[5] as int?,
        uuidCol: row[6] as String?,
        timestampCol: row[7] as DateTime?,
        jsonbCol: row[8] as Map<String, dynamic>?,
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
    return SampleRow(
      textCol: $textCol == -1 ? null : row[$textCol] as String?,
      byteaCol: $byteaCol == -1 ? null : row[$byteaCol] as List<int>?,
      booleanCol: $booleanCol == -1 ? null : row[$booleanCol] as bool?,
      doubleCol: $doubleCol == -1 ? null : row[$doubleCol] as double?,
      bigintCol: $bigintCol == -1 ? null : row[$bigintCol] as int?,
      smallintCol: $smallintCol == -1 ? null : row[$smallintCol] as int?,
      uuidCol: $uuidCol == -1 ? null : row[$uuidCol] as String?,
      timestampCol:
          $timestampCol == -1 ? null : row[$timestampCol] as DateTime?,
      jsonbCol:
          $jsonbCol == -1 ? null : row[$jsonbCol] as Map<String, dynamic>?,
    );
  }

  factory SampleRow.fromRowMap(Map<String, dynamic> map) {
    return SampleRow(
      textCol: map[SampleColumn.textCol] as String?,
      byteaCol: map[SampleColumn.byteaCol] as List<int>?,
      booleanCol: map[SampleColumn.booleanCol] as bool?,
      doubleCol: map[SampleColumn.doubleCol] as double?,
      bigintCol: map[SampleColumn.bigintCol] as int?,
      smallintCol: map[SampleColumn.smallintCol] as int?,
      uuidCol: map[SampleColumn.uuidCol] as String?,
      timestampCol: map[SampleColumn.timestampCol] as DateTime?,
      jsonbCol: map[SampleColumn.jsonbCol] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toFieldMap({bool removeNulls = false}) {
    final $map = {
      'textCol': textCol,
      'byteaCol': byteaCol,
      'booleanCol': booleanCol,
      'doubleCol': doubleCol,
      'bigintCol': bigintCol,
      'smallintCol': smallintCol,
      'uuidCol': uuidCol,
      'timestampCol':
          timestampCol?.toUtc().toIso8601String().replaceFirst('Z', ''),
      'jsonbCol': jsonbCol,
    };
    if (removeNulls) {
      $map.removeWhere((k, v) => v == null);
    }
    return $map;
  }

  Map<String, dynamic> toColumnMap({bool removeNulls = false}) {
    final $map = {
      'text_col': textCol,
      'bytea_col': byteaCol,
      'boolean_col': booleanCol,
      'double_col': doubleCol,
      'bigint_col': bigintCol,
      'smallint_col': smallintCol,
      'uuid_col': uuidCol,
      'timestamp_col':
          timestampCol?.toUtc().toIso8601String().replaceFirst('Z', ''),
      'jsonb_col': jsonbCol,
    };
    if (removeNulls) {
      $map.removeWhere((k, v) => v == null);
    }
    return $map;
  }

  SampleKey toKey() => SampleKey(
        textCol: textCol!,
      );
}

class SampleFilter {
  final $params = <String, dynamic>{};
  final $expressions = <String>[];
  final String _prefix = 'p';
  int _cnt = 0;

  SampleFilter clone() {
    return SampleFilter()
      ..$params.addAll($params)
      ..$expressions.addAll($expressions)
      .._cnt = _cnt;
  }

  void primaryKeys(String textCol) {
    textCol$equalsTo(textCol);
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

  void textCol(String? value, {bool setIfNull = false}) {
    if (value == null && setIfNull) {
      textCol$null();
      return;
    }
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

  void byteaCol(List<int>? value, {bool setIfNull = false}) {
    if (value == null && setIfNull) {
      byteaCol$null();
      return;
    }
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

  void booleanCol(bool? value, {bool setIfNull = false}) {
    if (value == null && setIfNull) {
      booleanCol$null();
      return;
    }
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

  void doubleCol(double? value, {bool setIfNull = false}) {
    if (value == null && setIfNull) {
      doubleCol$null();
      return;
    }
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

  void bigintCol(int? value, {bool setIfNull = false}) {
    if (value == null && setIfNull) {
      bigintCol$null();
      return;
    }
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

  void bigintCol$increment([int amount = 1]) {
    if (amount == 0) return;
    final sign = amount > 0 ? '+' : '-';
    $expressions.add('"bigint_col" = "bigint_col" $sign ${amount.abs()}');
  }

  void smallintCol(int? value, {bool setIfNull = false}) {
    if (value == null && setIfNull) {
      smallintCol$null();
      return;
    }
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

  void smallintCol$increment([int amount = 1]) {
    if (amount == 0) return;
    final sign = amount > 0 ? '+' : '-';
    $expressions.add('"smallint_col" = "smallint_col" $sign ${amount.abs()}');
  }

  void uuidCol(String? value, {bool setIfNull = false}) {
    if (value == null && setIfNull) {
      uuidCol$null();
      return;
    }
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

  void timestampCol(DateTime? value, {bool setIfNull = false}) {
    if (value == null && setIfNull) {
      timestampCol$null();
      return;
    }
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

  void jsonbCol(Map<String, dynamic>? value, {bool setIfNull = false}) {
    if (value == null && setIfNull) {
      jsonbCol$null();
      return;
    }
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
  final String? schema;
  final String name;
  final String fqn;

  SampleTable(this.name, {this.schema})
      : fqn = schema == null ? '"$name"' : '"$schema"."$name"';

  Future init(Session conn) async {
    await conn.execute([
      """CREATE TABLE IF NOT EXISTS $fqn ("text_col" TEXT, "bytea_col" BYTEA, "boolean_col" BOOLEAN, "double_col" DOUBLE PRECISION, "bigint_col" BIGINT, "smallint_col" SMALLINT, "uuid_col" UUID, "timestamp_col" TIMESTAMP, "jsonb_col" JSONB, PRIMARY KEY ("text_col")""",
      ');',
    ].join());
    await conn.execute([
      """ALTER TABLE $fqn ADD COLUMN IF NOT EXISTS "bytea_col" BYTEA""",
      ';',
    ].join());
    await conn.execute([
      """ALTER TABLE $fqn ADD COLUMN IF NOT EXISTS "boolean_col" BOOLEAN""",
      ';',
    ].join());
    await conn.execute([
      """ALTER TABLE $fqn ADD COLUMN IF NOT EXISTS "double_col" DOUBLE PRECISION""",
      ';',
    ].join());
    await conn.execute([
      """ALTER TABLE $fqn ADD COLUMN IF NOT EXISTS "bigint_col" BIGINT""",
      ';',
    ].join());
    await conn.execute([
      """ALTER TABLE $fqn ADD COLUMN IF NOT EXISTS "smallint_col" SMALLINT""",
      ';',
    ].join());
    await conn.execute([
      """ALTER TABLE $fqn ADD COLUMN IF NOT EXISTS "uuid_col" UUID""",
      ';',
    ].join());
    await conn.execute([
      """ALTER TABLE $fqn ADD COLUMN IF NOT EXISTS "timestamp_col" TIMESTAMP""",
      ';',
    ].join());
    await conn.execute([
      """ALTER TABLE $fqn ADD COLUMN IF NOT EXISTS "jsonb_col" JSONB""",
      ';',
    ].join());
  }

  Future<SampleRow?> read(Session conn, String textCol,
      {List<String>? columns}) async {
    columns ??= SampleColumn.$all;
    final filter = SampleFilter()..primaryKeys(textCol);
    final list = await query(conn, columns: columns, limit: 2, filter: filter);
    if (list.isEmpty) return null;
    return list.single;
  }

  Future<List<SampleRow>> query(
    Session conn, {
    List<String>? columns,
    List<String>? orderBy,
    int? limit,
    int? offset,
    SampleFilter? filter,
  }) async {
    columns ??= SampleColumn.$all;
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
    final list = await conn.execute(
        Sql.named(
            'SELECT ${columns.map((c) => '"$c"').join(', ')} FROM $qexpr'),
        parameters: filter?.$params);
    return list.map((row) => SampleRow.fromRowMap(row.toColumnMap())).toList();
  }

  Future<Page<SampleRow>> paginate(
    Session c, {
    int pageSize = 100,
    List<String>? columns,
    SampleFilter? filter,
    SampleKey? startAfter,
  }) async {
    final fixedColumns = columns == null ? null : List<String>.from(columns);
    if (fixedColumns != null) {
      if (!fixedColumns.contains(SampleColumn.textCol)) {
        fixedColumns.add(SampleColumn.textCol);
      }
    }
    final page = SamplePage._([], false, c, this, pageSize, fixedColumns,
        filter?.clone(), startAfter);
    return await page.next();
  }

  Future<int> insert(
    Session conn,
    /* SampleRow | List<SampleRow> */ items, {
    List<String>? columns,
    bool? upsert,
    bool? onConflictDoNothing,
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
          value = convert.base64.encode(value);
        }
        exprs.add(expr);
        params[key] = value;
      }
      list.add('(${exprs.join(', ')})');
    }
    if (list.isEmpty) {
      return 0;
    }
    final verb = 'INSERT';
    var onConflict = '';
    if (onConflictDoNothing ?? false) {
      onConflict = ' ON CONFLICT DO NOTHING';
    } else if (upsert ?? false) {
      final colExprs = columns
          .where(SampleColumn.$nonKeys.contains)
          .map((c) => '"$c" = EXCLUDED."$c"')
          .join(', ');
      onConflict = ' ON CONFLICT ("text_col") DO UPDATE SET $colExprs';
    }
    final rs = await conn.execute(
        Sql.named(
            '$verb INTO $fqn (${columns.map((c) => '"$c"').join(', ')}) VALUES ${list.join(', ')}$onConflict'),
        parameters: params);
    return rs.affectedRows;
  }

  Future<int> update(Session conn, String textCol, SampleUpdate update) {
    return updateAll(conn, update,
        filter: SampleFilter()..primaryKeys(textCol));
  }

  Future<int> updateAll(Session conn, SampleUpdate update,
      {SampleFilter? filter, int? limit}) async {
    final whereQ = (filter == null || filter.$expressions.isEmpty)
        ? ''
        : 'WHERE ${filter.$join(' AND ')}';
    final params = Map<String, dynamic>.from(filter?.$params ?? {})
      ..addAll(update.$params);
    final limitQ = (limit == null || limit == 0) ? '' : ' LIMIT $limit';
    final rs = await conn.execute(
        Sql.named('UPDATE $fqn SET ${update.join()} $whereQ$limitQ'),
        parameters: params);
    return rs.affectedRows;
  }

  Future<int> delete(Session conn, String textCol) {
    return deleteAll(conn, SampleFilter()..primaryKeys(textCol));
  }

  Future<int> deleteAll(Session conn, SampleFilter? filter,
      {int? limit}) async {
    final whereQ = (filter == null || filter.$expressions.isEmpty)
        ? ''
        : 'WHERE ${filter.$join(' AND ')}';
    final limitQ = (limit == null || limit == 0) ? '' : ' LIMIT $limit';
    final rs = await conn.execute(Sql.named('DELETE FROM $fqn $whereQ$limitQ'),
        parameters: filter?.$params);
    return rs.affectedRows;
  }
}

class SamplePage extends Object with PageMixin<SampleRow> {
  @override
  final bool isLast;
  @override
  final List<SampleRow> items;
  final Session _c;
  final SampleTable _table;
  final int _limit;
  final List<String>? _columns;
  final SampleFilter? _filter;
  final SampleKey? _startAfter;

  SamplePage._(this.items, this.isLast, this._c, this._table, this._limit,
      this._columns, this._filter, this._startAfter);

  @override
  Future<Page<SampleRow>> next() async {
    if (isLast) {
      throw StateError('`next` called on last page.');
    }
    final filter = _filter?.clone() ?? SampleFilter();
    if (items.isNotEmpty) {
      filter.keyAfter(items.last.toKey());
    } else if (_startAfter != null) {
      filter.keyAfter(_startAfter!);
    }
    final rows = await _table.query(_c,
        columns: _columns,
        filter: filter,
        limit: _limit + 1,
        orderBy: [
          SampleColumn.textCol,
        ]);
    final nextLast = rows.length <= _limit;
    final nextRows = nextLast ? rows : rows.sublist(0, _limit);
    return SamplePage._(
        nextRows, nextLast, _c, _table, _limit, _columns, _filter, null);
  }

  @override
  Future close() async {}
}
