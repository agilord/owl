// ignore_for_file: omit_local_variable_types, prefer_final_locals, prefer_single_quotes

import 'package:owl_sql/runtime.dart';
import 'package:postgres/postgres.dart';

class SampleColumns extends Columns {
  final String? _ref;
  SampleColumns({String? ref}) : _ref = ref;

  late final textCol = TextColumn('text_col', isKey: true, ref: _ref);
  late final byteaCol = ByteaColumn('bytea_col', ref: _ref);
  late final booleanCol = BoolColumn('boolean_col', ref: _ref);
  late final doubleCol = DoubleColumn('double_col', ref: _ref);
  late final bigintCol = BigintColumn('bigint_col', ref: _ref);
  late final smallintCol = SmallintColumn('smallint_col', ref: _ref);
  late final uuidCol = UuidColumn('uuid_col', ref: _ref);
  late final timestampCol = TimestampColumn('timestamp_col', ref: _ref);
  late final jsonbCol = JsonbColumn('jsonb_col', ref: _ref);

  @override
  late final $all = List.unmodifiable([
    textCol,
    byteaCol,
    booleanCol,
    doubleCol,
    bigintCol,
    smallintCol,
    uuidCol,
    timestampCol,
    jsonbCol,
  ]);
}

class SampleRelation extends Relation<SampleColumns, SampleKey, SampleRow> {
  SampleRelation(super.name, {super.ref});

  @override
  late final columns = SampleColumns(ref: ref);

  @override
  Expr<bool> whereFromKeyFn(SampleColumns c, SampleKey key) =>
      c.textCol.equalsTo(key.textCol);

  @override
  SampleRow rowFn(ResultRow row) => SampleRow.fromColumnMap(row.toColumnMap());
}

/// Unique continuity position for Sample tables.
class SampleKey extends Key implements Comparable<SampleKey> {
  final String textCol;

  SampleKey({
    required this.textCol,
  });

  factory SampleKey.fromList(List list) {
    return SampleKey(
      textCol: list[0] as String,
    );
  }

  factory SampleKey.fromFieldMap(Map<String, Object?> map) {
    return SampleKey(
      textCol: map['textCol'] as String,
    );
  }

  @override
  Map<String, Object?> toFieldMap() {
    return {
      'textCol': textCol,
    };
  }

  @override
  List toList() => [textCol];

  @override
  int compareTo(SampleKey $other) {
    int $x = 0;
    $x = textCol.compareTo($other.textCol);
    if ($x != 0) return $x;
    return 0;
  }
}

class SampleRow implements Row {
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

  factory SampleRow.fromRowList(List row) {
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

  factory SampleRow.fromColumnMap(Map<String, Object?> map) {
    return SampleRow(
      textCol: map['text_col'] as String?,
      byteaCol: map['bytea_col'] as List<int>?,
      booleanCol: map['boolean_col'] as bool?,
      doubleCol: map['double_col'] as double?,
      bigintCol: map['bigint_col'] as int?,
      smallintCol: map['smallint_col'] as int?,
      uuidCol: map['uuid_col'] as String?,
      timestampCol: map['timestamp_col'] as DateTime?,
      jsonbCol: map['jsonb_col'] as Map<String, dynamic>?,
    );
  }

  factory SampleRow.fromFieldMap(Map<String, Object?> map) {
    return SampleRow(
      textCol: map['textCol'] as String?,
      byteaCol: map['byteaCol'] as List<int>?,
      booleanCol: map['booleanCol'] as bool?,
      doubleCol: map['doubleCol'] as double?,
      bigintCol: map['bigintCol'] as int?,
      smallintCol: map['smallintCol'] as int?,
      uuidCol: map['uuidCol'] as String?,
      timestampCol: map['timestampCol'] as DateTime?,
      jsonbCol: map['jsonbCol'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toFieldMap() {
    return {
      if (textCol != null) 'textCol': textCol,
      if (byteaCol != null) 'byteaCol': byteaCol,
      if (booleanCol != null) 'booleanCol': booleanCol,
      if (doubleCol != null) 'doubleCol': doubleCol,
      if (bigintCol != null) 'bigintCol': bigintCol,
      if (smallintCol != null) 'smallintCol': smallintCol,
      if (uuidCol != null) 'uuidCol': uuidCol,
      if (timestampCol != null) 'timestampCol': timestampCol,
      if (jsonbCol != null) 'jsonbCol': jsonbCol,
    };
  }

  @override
  Map<String, dynamic> toColumnMap() {
    return {
      if (textCol != null) 'text_col': textCol,
      if (byteaCol != null) 'bytea_col': byteaCol,
      if (booleanCol != null) 'boolean_col': booleanCol,
      if (doubleCol != null) 'double_col': doubleCol,
      if (bigintCol != null) 'bigint_col': bigintCol,
      if (smallintCol != null) 'smallint_col': smallintCol,
      if (uuidCol != null) 'uuid_col': uuidCol,
      if (timestampCol != null) 'timestamp_col': timestampCol,
      if (jsonbCol != null) 'jsonb_col': jsonbCol,
    };
  }

  @override
  SampleKey toKey() => SampleKey(
        textCol: textCol!,
      );
}
