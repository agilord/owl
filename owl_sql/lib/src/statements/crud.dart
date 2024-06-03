import 'package:owl_sql/runtime.dart';
import 'package:postgres/postgres.dart' show Type;

import '../query_builder.dart';

Query doSelect({
  Object? columns,
  Object? from,
  Object? where,
  Object? orderBy,
  int? offset,
  int? limit,
  bool? forUpdate,
}) {
  final builder = QueryBuilder();
  builder.write('SELECT ');
  if (columns == null) {
    builder.write('*');
  } else {
    final list = columns is Iterable ? columns.toList() : [columns];
    for (var i = 0; i < list.length; i++) {
      if (i > 0) {
        builder.write(', ');
      }
      final e = list[i];
      if (e is String) {
        builder.write(e);
      } else if (e is Column) {
        builder.write(e.fqn);
      } else {
        throw ArgumentError('Unknown $e');
      }
    }
  }

  if (from != null) {
    _writeFrom(builder, from);
  }

  if (where != null) {
    _writeWhere(builder, where);
  }

  if (orderBy != null) {
    final list = orderBy is Iterable ? orderBy.toList() : [orderBy];
    builder.write(' ORDER BY ');
    for (var i = 0; i < list.length; i++) {
      if (i > 0) {
        builder.write(', ');
      }
      final e = list[i];
      if (e is String) {
        builder.write(e);
      } else if (e is Column) {
        final orderSql = e.order == Order.desc ? '${e.fqn} DESC' : e.fqn;
        builder.write(orderSql);
      } else {
        throw ArgumentError('Unknown $e');
      }
    }
  }

  if (offset != null && offset > 0) {
    builder.write(' OFFSET $limit');
  }
  if (limit != null && limit > 0) {
    builder.write(' LIMIT $limit');
  }
  if (forUpdate ?? false) {
    builder.write(' FOR UPDATE');
  }
  return builder.toQuery();
}

void _writeFrom(QueryBuilder builder, Object from) {
  if (from is Relation) {
    builder.write(' FROM ${from.name.fqn}');
  } else if (from is String) {
    builder.write(' FROM $from');
  } else {
    throw ArgumentError('Unknown `from`: $from');
  }
}

void _writeWhere(QueryBuilder builder, Object where) {
  builder.write(' WHERE ');
  var w = where;
  if (where is Iterable) {
    w = AndExpr(where.cast<Expr<bool>>().toList());
  }
  if (w is String) {
    builder.write(w);
  } else if (w is Expr) {
    builder.writeExpr(w);
  } else {
    throw ArgumentError('Unknown $where');
  }
}

Query doInsert({
  required Object table,
  Iterable<Object>? columns,
  required Iterable rows,
  bool? onConflictDoNothing,
  Iterable? keyColumns,
  bool? upsert,
}) {
  final builder = QueryBuilder();
  builder.write('INSERT INTO ');
  _writeTable(builder, table);

  List<String>? columnNames;
  Set<String>? keyColumnNames;
  List<Type?>? columnTypes;
  if (keyColumns != null && keyColumns.isNotEmpty) {
    keyColumnNames = keyColumns.map((e) {
      if (e is String) {
        return e;
      } else if (e is Column) {
        return e.name;
      } else {
        throw ArgumentError('Unknown `keyColumn`: $e');
      }
    }).toSet();
  }
  if (columns != null && columns.isNotEmpty) {
    columnNames = columns.map((c) {
      if (c is Column) {
        return c.name;
      } else if (c is String) {
        return c;
      } else {
        throw ArgumentError('Unknown column: $c');
      }
    }).toList();
    columnTypes = columns.map((e) {
      if (e is Column) {
        return e.type;
      } else {
        return null;
      }
    }).toList();
    builder.write(' (${columnNames.join(', ')})');
  }

  builder.write(' VALUES ');
  var firstRow = true;
  for (final row in rows) {
    if (firstRow) {
      firstRow = false;
    } else {
      builder.write(', ');
    }
    _writeInsertValue(builder, columnNames, columnTypes, row);
  }

  if (onConflictDoNothing ?? false) {
    builder.write(' ON CONFLICT DO NOTHING');
  } else if (upsert ?? false) {
    if (columnNames == null || columnNames.isEmpty) {
      throw ArgumentError('Missing column names.');
    }
    if (keyColumnNames == null || keyColumnNames.isEmpty) {
      throw ArgumentError('Missing key column names.');
    }
    final setExpr = columnNames
        .where((c) => !keyColumnNames!.contains(c))
        .map((e) => '$e = EXCLUDED.$e')
        .join(', ');
    builder.write(
        'ON CONFLICT (${keyColumnNames.join(', ')}) DO UPDATE SET $setExpr');
  }

  return builder.toQuery();
}

void _writeTable(QueryBuilder builder, Object table) {
  if (table is Relation) {
    builder.write(table.name.fqn);
  } else if (table is String) {
    builder.write(table);
  } else {
    throw ArgumentError('Unknown `table`: $table');
  }
}

void _writeInsertValue(
  QueryBuilder builder,
  List<String>? columnNames,
  List<Type?>? columnTypes,
  Object values,
) {
  final expectedCount = columnNames?.length;
  if (values is List) {
    if (expectedCount != null && expectedCount != values.length) {
      throw ArgumentError(
          'Inserted value length (${values.length}) does not match expected count ($expectedCount).');
    }
    final marks = List.filled(values.length, '?');
    final parameters = [];
    for (var i = 0; i < values.length; i++) {
      final type = columnTypes == null ? null : columnTypes[i];
      final value = values[i];
      parameters.add(type?.value(value) ?? value);
    }
    builder.write('(${marks.join(', ')})', parameters);
  } else if (values is Map) {
    final marks = List.filled(expectedCount ?? values.length, '?');
    final parameters = [];
    final list = columnNames == null
        ? values.values.toList()
        : columnNames.map((e) => values[e]).toList();
    for (var i = 0; i < values.length; i++) {
      final type = columnTypes == null ? null : columnTypes[i];
      final value = list[i];
      parameters.add(type?.value(value) ?? value);
    }
    builder.write('(${marks.join(', ')})', parameters);
  } else {
    throw ArgumentError('Unknown insert value: $values');
  }
}

Query doUpdate({
  required Object table,
  required Object set,
  Object? where,
  int? limit,
}) {
  final builder = QueryBuilder();
  builder.write('UPDATE ');
  _writeTable(builder, table);

  builder.write(' SET ');

  final list = set is Iterable ? set.toList() : [set];
  for (var i = 0; i < list.length; i++) {
    if (i > 0) {
      builder.write(', ');
    }
    final e = list[i];
    if (e is String) {
      builder.write(e);
    } else if (e is Expr) {
      builder.writeExpr(e);
    } else {
      throw ArgumentError('Unknown set item: $e');
    }
  }

  if (where != null) {
    _writeWhere(builder, where);
  }
  if (limit != null && limit > 0) {
    builder.write(' LIMIT $limit');
  }
  return builder.toQuery();
}

Query doDelete({
  required Object from,
  Object? where,
  int? limit,
}) {
  final builder = QueryBuilder();
  builder.write('DELETE');
  _writeFrom(builder, from);

  if (where != null) {
    _writeWhere(builder, where);
  }
  if (limit != null && limit > 0) {
    builder.write(' LIMIT $limit');
  }
  return builder.toQuery();
}
