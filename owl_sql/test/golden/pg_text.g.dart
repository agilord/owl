// ignore_for_file: omit_local_variable_types, prefer_final_locals, prefer_single_quotes

import 'package:owl_sql/runtime.dart';
import 'package:postgres/postgres.dart';

import 'pg_scan.g.dart' as a;

class TextColumns extends Columns {
  final String? _ref;
  TextColumns({String? ref}) : _ref = ref;

  late final id = TextColumn('id', isKey: true, ref: _ref);
  late final snippet = TextColumn('snippet', ref: _ref);
  late final vector = TsvectorColumn('vector', ref: _ref);

  @override
  late final $all = List.unmodifiable([
    id,
    snippet,
    vector,
  ]);
}

class TextRelation extends Relation<TextColumns, TextKey, TextRow> {
  TextRelation(super.name, {super.ref});

  @override
  late final columns = TextColumns(ref: ref);

  @override
  Expr<bool> whereFromKeyFn(TextColumns c, TextKey key) =>
      c.id.equalsTo(key.id);

  @override
  TextRow rowFn(ResultRow row) => TextRow.fromColumnMap(row.toColumnMap());
}

/// Unique continuity position for Text tables.
class TextKey extends Key implements Comparable<TextKey> {
  final String id;

  TextKey({
    required this.id,
  });

  factory TextKey.fromList(List list) {
    return TextKey(
      id: list[0] as String,
    );
  }

  factory TextKey.fromFieldMap(Map<String, Object?> map) {
    return TextKey(
      id: map['id'] as String,
    );
  }

  @override
  Map<String, Object?> toFieldMap() {
    return {
      'id': id,
    };
  }

  @override
  List toList() => [id];

  @override
  int compareTo(TextKey $other) {
    int $x = 0;
    $x = id.compareTo($other.id);
    if ($x != 0) return $x;
    return 0;
  }
}

class TextRow implements Row {
  final String? id;
  final String? snippet;
  final TsVector? vector;
  a.ScanRow? scanRow;

  TextRow({
    this.id,
    this.snippet,
    this.vector,
    this.scanRow,
  });

  factory TextRow.fromRowList(List row) {
    return TextRow(
      id: row[0] as String?,
      snippet: row[1] as String?,
      vector: row[2] as TsVector?,
    );
  }

  factory TextRow.fromColumnMap(Map<String, Object?> map) {
    return TextRow(
      id: map['id'] as String?,
      snippet: map['snippet'] as String?,
      vector: map['vector'] as TsVector?,
    );
  }

  factory TextRow.fromFieldMap(Map<String, Object?> map) {
    return TextRow(
      id: map['id'] as String?,
      snippet: map['snippet'] as String?,
      vector: map['vector'] as TsVector?,
    );
  }

  Map<String, dynamic> toFieldMap() {
    return {
      if (id != null) 'id': id,
      if (snippet != null) 'snippet': snippet,
      if (vector != null) 'vector': vector,
    };
  }

  @override
  Map<String, dynamic> toColumnMap() {
    return {
      if (id != null) 'id': id,
      if (snippet != null) 'snippet': snippet,
      if (vector != null) 'vector': vector,
    };
  }

  @override
  TextKey toKey() => TextKey(
        id: id!,
      );
}
