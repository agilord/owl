// ignore_for_file: omit_local_variable_types, prefer_final_locals, prefer_single_quotes

import 'package:owl_sql/runtime.dart';
import 'package:postgres/postgres.dart';

class ScanColumns extends Columns {
  final String? _ref;
  ScanColumns({String? ref}) : _ref = ref;

  late final id1 = TextColumn('id1', isKey: true, ref: _ref);
  late final id2 = ByteaColumn('id2', isKey: true, ref: _ref);
  late final id3 = TextColumn('id3', isKey: true, ref: _ref);
  late final payload = ByteaColumn('payload', ref: _ref);

  @override
  late final $all = List.unmodifiable([
    id1,
    id2,
    id3,
    payload,
  ]);
}

class ScanRelation extends Relation<ScanColumns, ScanKey, ScanRow> {
  ScanRelation(super.name, {super.ref});

  @override
  late final columns = ScanColumns(ref: ref);

  @override
  Expr<bool> whereFromKeyFn(ScanColumns c, ScanKey key) =>
      c.id1.equalsTo(key.id1) &
      c.id2.equalsTo(key.id2) &
      c.id3.equalsTo(key.id3);

  @override
  ScanRow rowFn(ResultRow row) => ScanRow.fromColumnMap(row.toColumnMap());
}

/// Unique continuity position for Scan tables.
class ScanKey extends Key implements Comparable<ScanKey> {
  final String id1;
  final List<int> id2;
  final String id3;

  ScanKey({
    required this.id1,
    required this.id2,
    required this.id3,
  });

  factory ScanKey.fromList(List list) {
    return ScanKey(
      id1: list[0] as String,
      id2: list[1] as List<int>,
      id3: list[2] as String,
    );
  }

  factory ScanKey.fromFieldMap(Map<String, Object?> map) {
    return ScanKey(
      id1: map['id1'] as String,
      id2: map['id2'] as List<int>,
      id3: map['id3'] as String,
    );
  }

  @override
  Map<String, Object?> toFieldMap() {
    return {
      'id1': id1,
      'id2': id2,
      'id3': id3,
    };
  }

  @override
  List toList() => [id1, id2, id3];

  @override
  int compareTo(ScanKey $other) {
    int $x = 0;
    $x = id1.compareTo($other.id1);
    if ($x != 0) return $x;
    $x = compareBytes(id2, $other.id2, true);
    if ($x != 0) return $x;
    $x = id3.compareTo($other.id3);
    if ($x != 0) return $x;
    return 0;
  }
}

class ScanRow implements Row {
  final String? id1;
  final List<int>? id2;
  final String? id3;
  final List<int>? payload;

  ScanRow({
    this.id1,
    this.id2,
    this.id3,
    this.payload,
  });

  factory ScanRow.fromRowList(List row) {
    return ScanRow(
      id1: row[0] as String?,
      id2: row[1] as List<int>?,
      id3: row[2] as String?,
      payload: row[3] as List<int>?,
    );
  }

  factory ScanRow.fromColumnMap(Map<String, Object?> map) {
    return ScanRow(
      id1: map['id1'] as String?,
      id2: map['id2'] as List<int>?,
      id3: map['id3'] as String?,
      payload: map['payload'] as List<int>?,
    );
  }

  factory ScanRow.fromFieldMap(Map<String, Object?> map) {
    return ScanRow(
      id1: map['id1'] as String?,
      id2: map['id2'] as List<int>?,
      id3: map['id3'] as String?,
      payload: map['payload'] as List<int>?,
    );
  }

  Map<String, dynamic> toFieldMap() {
    return {
      if (id1 != null) 'id1': id1,
      if (id2 != null) 'id2': id2,
      if (id3 != null) 'id3': id3,
      if (payload != null) 'payload': payload,
    };
  }

  @override
  Map<String, dynamic> toColumnMap() {
    return {
      if (id1 != null) 'id1': id1,
      if (id2 != null) 'id2': id2,
      if (id3 != null) 'id3': id3,
      if (payload != null) 'payload': payload,
    };
  }

  @override
  ScanKey toKey() => ScanKey(
        id1: id1!,
        id2: id2!,
        id3: id3!,
      );
}
