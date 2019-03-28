import 'dart:async';
import 'dart:io';

import 'src/io_utils.dart';
import 'owl_sql.dart';

export 'owl_sql.dart';

Future<bool> writeInto(
  List<Table> tables,
  String targetFile, {
  bool targetCockroachDB: false,
  bool format: true,
}) async {
  return await writeIntoFile(
      tables,
      new File(targetFile),
      (List<Table> items) =>
          generateSource(items, targetCockroachDB: targetCockroachDB),
      format);
}

String generateSource(List<Table> tables, {bool targetCockroachDB: false}) {
  return new _Codegen(tables, targetCockroachDB).generate();
}

class _Codegen {
  final _sb = new StringBuffer();
  final List<Table> _tables;
  final bool _targetCockroachDB;
  final bool _hasJsonb;
  final bool _hasBytea;
  final bool _hasTsvector;

  _Codegen(List<Table> tables, this._targetCockroachDB)
      : _tables = tables,
        _hasJsonb = tables
            .any((table) => table.columns.any((c) => c.type == SqlType.jsonb)),
        _hasBytea = tables
            .any((table) => table.columns.any((c) => c.type == SqlType.bytea)),
        _hasTsvector = tables.any(
            (table) => table.columns.any((c) => c.type == SqlType.tsvector));

  String generate() {
    _sb.writeln('import \'dart:async\';');
    if (_hasJsonb || _hasBytea) {
      _sb.writeln('import \'dart:convert\' as convert;');
    }
    _sb.writeln();
    _sb.writeln('import \'package:meta/meta.dart\';');
    _sb.writeln('import \'package:page/page.dart\';');
    _sb.writeln('import \'package:postgres/postgres.dart\';');

    for (Table table in _tables) {
      _writeSchema(table);
      _writeKey(table);
      _writeRow(table);
      _writeFilter(table);
      _writeUpdate(table);
      _writeTable(table);
      _writePage(table);
    }
    _writeParse();
    return _sb.toString();
  }

  void _writeSchema(Table table) {
    _sb.writeln('\n/// Column names of ${table.type} tables.');
    _sb.writeln('class ${table.type}Column {');
    for (Column col in table.columns) {
      _sb.writeln('static const String ${col.fieldName} = \'${col.name}\';');
    }
    final cols =
        table.columns.map((c) => '${table.type}Column.${c.fieldName},').join();
    final pkCols = table.columns
        .where((c) => c.isKey == true)
        .map((c) => '${table.type}Column.${c.fieldName},')
        .join();
    final otherCols = table.columns
        .where((c) => c.isKey != true)
        .map((c) => '${table.type}Column.${c.fieldName},')
        .join();
    final jsonbColumns = table.columns
        .where((c) => c.type == SqlType.jsonb)
        .map((c) => '${table.type}Column.${c.fieldName},')
        .join();
    final bytesColumns = table.columns
        .where((c) => c.type == SqlType.bytea)
        .map((c) => '${table.type}Column.${c.fieldName},')
        .join();
    final tsvectorColumns = table.columns
        .where((c) => c.type == SqlType.tsvector)
        .map((c) => '${table.type}Column.${c.fieldName},')
        .join();
    _sb.writeln('\nstatic const List<String> \$all = const <String>[$cols];');
    _sb.writeln(
        '\nstatic const List<String> \$keys = const <String>[$pkCols];');
    _sb.writeln(
        '\nstatic const List<String> \$nonKeys = const <String>[$otherCols];');
    _sb.writeln(
        '\nstatic const List<String> \$jsonb = const <String>[$jsonbColumns];');
    _sb.writeln(
        '\nstatic const List<String> \$bytea = const <String>[$bytesColumns];');
    _sb.writeln(
        '\nstatic const List<String> \$tsvector = const <String>[$tsvectorColumns];');
    _sb.write('}\n');
  }

  void _writeKey(Table table) {
    _sb.writeln('\n/// Unique continuity position for ${table.type} tables.');
    _sb.writeln(
        'class ${table.type}Key implements Comparable<${table.type}Key>{');
    for (Column col in table.columns.where((c) => c.isKey == true)) {
      _sb.write('final ${_toDartType(col.type)} ${col.fieldName};\n');
    }
    _sb.write('\n  ${table.type}Key({\n');
    for (Column col in table.columns.where((c) => c.isKey == true)) {
      _sb.write('  @required this.${col.fieldName},\n');
    }
    _sb.writeln('  });');
    _sb.writeln('\n  @override int compareTo(${table.type}Key \$other) {');
    _sb.writeln('  int \$x = 0;');
    for (Column col in table.columns.where((c) => c.isKey == true)) {
      if (col.type == SqlType.bytea) {
        _sb.writeln(
            '  for (int i = 0; i < ${col.fieldName}.length && i < \$other.${col.fieldName}.length; i++) {');
        _sb.writeln(
            '    \$x = ${col.fieldName}[i].compareTo(\$other.${col.fieldName}[i]);');
        _sb.writeln('    if (\$x != 0) return \$x;');
        _sb.writeln('  }');
        _sb.writeln(
            '  \$x = ${col.fieldName}.length.compareTo(\$other.${col.fieldName}.length);');
        _sb.writeln('  if (\$x != 0) return \$x;');
      } else {
        _sb.writeln(
            '  \$x = ${col.fieldName}.compareTo(\$other.${col.fieldName});');
        _sb.writeln('  if (\$x != 0) return \$x;');
      }
    }
    _sb.writeln('  return 0;');
    _sb.writeln('  }');
    _sb.write('}\n');
  }

  void _writeRow(Table table) {
    final pks = table.columns.where((c) => c.isKey == true).toList();
    _sb.write('class ${table.type}Row {\n');
    for (Column col in table.columns) {
      _sb.write('final ${_toDartType(col.type)} ${col.fieldName};\n');
    }
    _sb.write('\n  ${table.type}Row({\n');
    for (Column col in table.columns) {
      _sb.write('  this.${col.fieldName},\n');
    }
    _sb.writeln('  });');

    _sb.writeln(
        '\n  factory ${table.type}Row.fromRowList(List row, {List<String> columns}) {');
    _sb.writeln('    columns ??= ${table.type}Column.\$all;');
    _sb.writeln('    assert(row.length == columns.length);');
    _sb.writeln('    if (columns ==${table.type}Column.\$all) {');
    int colIdx = 0;
    final colX = table.columns.map((c) {
      final rowExp = _transformToDart(c.type, 'row[${colIdx++}]');
      return '${c.fieldName}: $rowExp,';
    }).join('');
    _sb.writeln('      return new ${table.type}Row($colX);');
    _sb.writeln('    }');
    for (Column col in table.columns) {
      _sb.writeln(
          '    final int \$${col.fieldName} = columns.indexOf(${table.type}Column.${col.fieldName});');
    }
    final cols = table.columns.map((c) {
      final rowExp = _transformToDart(c.type, 'row[\$${c.fieldName}]');
      return '${c.fieldName}: \$${c.fieldName} == -1 ? null : $rowExp,';
    }).join('');
    _sb.writeln('    return new ${table.type}Row($cols);');
    _sb.writeln('  }\n');

    _sb.writeln(
        '\n  factory ${table.type}Row.fromRowMap(Map<String, Map<String, dynamic>> row, {String table}) {');
    _sb.writeln('    if (row == null) return null;');
    _sb.writeln(
        '    if (table == null) {if (row.length == 1) {table = row.keys.first;} else {');
    _sb.writeln(
        '    throw new StateError(\'Unable to lookup table prefix: \$table of \${row.keys}\');}}');
    _sb.writeln('    final map = row[table];');
    _sb.writeln('    if (map == null) return null;');
    final colM = table.columns.map((c) {
      final colExpr =
          _transformToDart(c.type, 'map[${table.type}Column.${c.fieldName}]');
      return '${c.fieldName}: $colExpr,';
    }).join('');
    _sb.writeln('    return new ${table.type}Row($colM);');
    _sb.writeln('  }\n');

    _sb.writeln(
        '\n  Map<String, dynamic> toFieldMap({bool removeNulls: false}) {');
    _sb.writeln('    final \$map = {');
    for (Column col in table.columns) {
      String expr = col.fieldName;
      if (col.type == SqlType.timestamp) {
        expr = '$expr?.toIso8601String()';
      }
      _sb.write('  \'${col.fieldName}\': $expr,\n');
    }
    _sb.writeln('    };');
    _sb.writeln('    if (removeNulls) {');
    _sb.writeln('      \$map.removeWhere((k, v) => v == null);');
    _sb.writeln('    }');
    _sb.writeln('    return \$map;');
    _sb.writeln('  }');
    _sb.writeln(
        '\n  Map<String, dynamic> toColumnMap({bool removeNulls: false}) {');
    _sb.writeln('    final \$map = {');
    for (Column col in table.columns) {
      String expr = col.fieldName;
      if (col.type == SqlType.timestamp) {
        expr = '$expr?.toIso8601String()';
      }
      _sb.write('  \'${col.name}\': $expr,\n');
    }
    _sb.writeln('    };');
    _sb.writeln('    if (removeNulls) {');
    _sb.writeln('      \$map.removeWhere((k, v) => v == null);');
    _sb.writeln('    }');
    _sb.writeln('    return \$map;');
    _sb.writeln('  }');
    _sb.writeln('\n  ${table.type}Key toKey() =>');
    _sb.writeln(
        '    new ${table.type}Key(${pks.map((c) => '${c.fieldName}: ${c.fieldName},').join()});');
    _sb.write('}\n');
  }

  void _writeFilter(Table table) {
    final pks = table.columns.where((c) => c.isKey == true).toList();
    _sb.writeln('\nclass ${table.type}Filter {');
    _sb.writeln('  final \$params = <String, dynamic>{};');
    _sb.writeln('  final \$expressions = <String>[];');
    _sb.writeln('  final String _prefix = \'p\';');
    _sb.writeln('  int _cnt = 0;');
//    _sb.writeln('\n  ${table.type}Filter();');
    _sb.writeln('\n  ${table.type}Filter clone() {');
    _sb.writeln('    return new ${table.type}Filter()');
    _sb.writeln('    ..\$params.addAll(\$params)');
    _sb.writeln('    ..\$expressions.addAll(\$expressions)');
    _sb.writeln('    .._cnt = _cnt;');
    _sb.writeln('  }');
    final pksParams = table.columns
        .where((c) => c.isKey == true)
        .map((c) => '${_toDartType(c.type)} ${c.fieldName}')
        .join(', ');
    final pksInit = table.columns
        .where((c) => c.isKey == true)
        .map((c) => 'this.${c.fieldName}\$equalsTo(${c.fieldName});')
        .join();
    _sb.writeln('\n  void primaryKeys($pksParams) {$pksInit}');
    _sb.writeln(
        '\n  String \$join(String op) => \$expressions.map((s) => \'(\$s)\').join(op);');
    _sb.writeln(
        '\n void addExpression(String expr) {\$expressions.add(expr);}');
    _sb.writeln('\n  String _next() => \'\$_prefix\${_cnt++}\';');
    _sb.write('\n  void keyAfter(${table.type}Key key) {');

    String expr;
    for (int i = pks.length - 1; i >= 0; i--) {
      _sb.writeln('    final key$i = _next();');
      final kv = _keyValue('key$i', 'key.${pks[i].fieldName}', pks[i].type);
      _sb.writeln('    \$params[key$i] = ${kv.convert};');
      final x = '"${pks[i].name}" > ${kv.key}';
      if (i == pks.length - 1) {
        expr = x;
      } else {
        expr = '$x OR ("${pks[i].name}" = ${kv.key} AND ($expr))';
      }
    }
    _sb.writeln('    \$expressions.add(\'$expr\');');
    _sb.write('  }\n');
    for (Column col in table.columns) {
      if (col.type == SqlType.jsonb) {
        _sb.writeln(
            '\n void ${col.fieldName}\$matches(${_toDartType(col.type)} value) {'
            'final key = _next();'
            '\$params[key] = convert.json.encode(value);'
            '\$expressions.add(\'"${col.name}" @> @\$key::JSONB\');'
            '}\n');
      } else if (col.type == SqlType.tsvector) {
        _sb.writeln('\n  void ${col.fieldName}\$tsquery(String query) {');
        _sb.writeln('    final key = _next();');
        _sb.writeln('    \$params[key] = query;');
        _sb.writeln(
            '    \$expressions.add(\'"${col.name}" @@ @\$key::TSQUERY\');');
        _sb.writeln('  }');
      } else {
        final kv = _keyValue('key', 'value', col.type);
        _sb.writeln(
            '\n void ${col.fieldName}\$equalsTo(${_toDartType(col.type)} value) {'
            'final key = _next();'
            '\$params[key] = ${kv.convert};'
            '\$expressions.add(\'"${col.name}" = ${kv.key}\');'
            '}\n');

        _sb.writeln('\n void ${col.fieldName}\$isNull() {'
            '\$expressions.add(\'"${col.name}" IS NULL\');'
            '}\n');

        _sb.writeln('\n void ${col.fieldName}\$isNotNull() {'
            '\$expressions.add(\'"${col.name}" IS NOT NULL\');'
            '}\n');

        _sb.writeln(
            '\n void ${col.fieldName}\$greaterThan(${_toDartType(col.type)} value) {'
            'final key = _next();'
            '\$params[key] = ${kv.convert};'
            '\$expressions.add(\'"${col.name}" > ${kv.key}\');'
            '}\n');

        _sb.writeln(
            '\n void ${col.fieldName}\$greaterThanOrEqualTo(${_toDartType(col.type)} value) {'
            'final key = _next();'
            '\$params[key] = ${kv.convert};'
            '\$expressions.add(\'"${col.name}" >= ${kv.key}\');'
            '}\n');

        _sb.writeln(
            '\n void ${col.fieldName}\$lessThan(${_toDartType(col.type)} value) {'
            'final key = _next();'
            '\$params[key] = ${kv.convert};'
            '\$expressions.add(\'"${col.name}" < ${kv.key}\');'
            '}\n');

        _sb.writeln(
            '\n void ${col.fieldName}\$lessThanOrEqualTo(${_toDartType(col.type)} value) {'
            'final key = _next();'
            '\$params[key] = ${kv.convert};'
            '\$expressions.add(\'"${col.name}" <= ${kv.key}\');'
            '}\n');
      }
    }
    _sb.write('}\n');
  }

  String _toPgType(String type) {
    switch (type) {
      case SqlType.double:
        return 'DOUBLE PRECISION';
      default:
        return type.toUpperCase();
    }
  }

  String _toDartType(String type) {
    switch (type) {
      case SqlType.boolean:
        return 'bool';
      case SqlType.bigint:
      case SqlType.smallint:
        return 'int';
      case SqlType.double:
        return 'double';
      case SqlType.text:
      case SqlType.uuid:
        return 'String';
      case SqlType.timestamp:
        return 'DateTime';
      case SqlType.jsonb:
        return 'Map<String, dynamic>';
      case SqlType.bytea:
        return 'List<int>';
      case SqlType.tsvector:
        return 'Map<String, String>';
    }
    throw new StateError('Unmapped column type: $type');
  }

  String _transformToDart(String type, String expr) {
    switch (type) {
      case SqlType.tsvector:
        return '_parseTsvector($expr as String)';
      default:
        return '$expr as ${_toDartType(type)}';
    }
  }

  String _ddlCreate(Column c) {
    return '"${c.name}" ${_toPgType(c.type)}' +
        (c.defaultsTo == null ? '' : ' DEFAULT ${c.defaultsTo}');
  }

  String _guard(String name) {
    if (name == 'conn' ||
        name == 'columns' ||
        name == 'filter' ||
        name == 'list' ||
        name == 'update') {
      return '$name\$';
    }
    return name;
  }

  void _writeUpdate(Table table) {
    _sb.writeln('\nclass ${table.type}Update {');
    _sb.writeln('  final \$params = <String, dynamic>{};');
    _sb.writeln('  final \$expressions = <String>[];');
    _sb.writeln('  final String _prefix = \'u\';');
    _sb.writeln('  int _cnt = 0;');
    _sb.writeln('\n  String join() => \$expressions.join(\', \');');
    _sb.writeln('\n  String _next() => \'\$_prefix\${_cnt++}\';');
    for (Column col in table.columns) {
      final kv = _keyValue('key', 'value', col.type);
      String value = kv.convert;
      if (col.type == SqlType.tsvector) {
        value = '_tsvectorToString(value)';
      }
      _sb.writeln('\n void ${col.fieldName}(${_toDartType(col.type)} value) {'
          'if (value == null) return;'
          'final key = _next();'
          '\$params[key] = $value;'
          '\$expressions.add(\'"${col.name}" = ${kv.key}\');'
          '}\n');

      _sb.writeln('\n void ${col.fieldName}\$null() {'
          '\$expressions.add(\'"${col.name}" = NULL\');'
          '}\n');

      _sb.writeln('\n void ${col.fieldName}\$expr(String expr) {'
          '\$expressions.add(\'"${col.name}" = \$expr\');'
          '}\n');
    }
    _sb.write('}\n');
  }

  void _writeTable(Table table) {
    _sb.writeln('class ${table.type}Table {');
    _sb.writeln('  final String schema;');
    _sb.writeln('  final String name;');
    _sb.writeln('  final String fqn;');
    _sb.writeln('\n  ${table.type}Table(this.name, {this.schema}) :'
        'this.fqn = schema == null ? \'"\$name"\' : \'"\$schema"."\$name"\';');

    _writeTableInit(table);
    _writeTableRead(table);
    _writeTableQuery(table);
    _writeTablePaginate(table);
    _writeTableInsert(table);
    _writeTableUpdate(table);
    _writeTableUpdateAll(table);
    _writeTableDelete(table);
    _writeTableDeleteAll(table);

    _sb.write('}\n');
  }

  void _writeTableInit(Table table) {
    _sb.write('\n  Future init(PostgreSQLExecutionContext conn) async {\n');
    final allColumnsCreateDdl =
        table.columns.map((c) => _ddlCreate(c)).join(', ');
    final pkColNames = table.columns
        .where((c) => c.isKey == true)
        .map((c) => '"${c.name}"')
        .join(', ');
    _sb.writeln(
        '    await conn.execute("""CREATE TABLE IF NOT EXISTS \$fqn ($allColumnsCreateDdl, PRIMARY KEY ($pkColNames));""");');
    for (Column col in table.columns) {
      if (col.isKey == true) continue;
      _sb.writeln(
          '  await conn.execute("""ALTER TABLE \$fqn ADD COLUMN IF NOT EXISTS ${_ddlCreate(col)};""");');
    }
    for (Index index in table.indexes ?? []) {
      final cols = index.columns.map((s) {
        if (s.startsWith('-')) {
          return '"${s.substring(1)}" DESC';
        }
        return '"$s"';
      }).join(', ');
      String storing = '';
      if (index.storing != null &&
          index.storing.isNotEmpty &&
          _targetCockroachDB) {
        final storedCols = index.storing.map((s) => '"$s"').join(', ');
        storing = ' STORING ($storedCols)';
      }
      final inverted =
          (_targetCockroachDB && index.isInverted == true) ? ' INVERTED' : '';
      final using =
          (!_targetCockroachDB && index.isInverted == true) ? 'USING GIN' : '';
      _sb.writeln(
          '  await conn.execute("""CREATE$inverted INDEX IF NOT EXISTS "\${name}__nx_${index.nameSuffix}" ON \$fqn $using($cols)$storing;""");');
    }
    _sb.write('\n  }\n');
  }

  void _writeTableRead(Table table) {
    final pks = table.columns
        .where((c) => c.isKey == true)
        .map((c) => '${_toDartType(c.type)} ${_guard(c.fieldName)}')
        .join(', ');
    final pksParams = table.columns
        .where((c) => c.isKey == true)
        .map((c) => _guard(c.fieldName))
        .join(', ');
    _sb.writeln(
        '\n  Future<${table.type}Row> read(PostgreSQLExecutionContext conn, $pks, {List<String> columns}) async {');
    _sb.writeln('    columns ??= ${table.type}Column.\$all;');
    _sb.writeln(
        '    final filter = new ${table.type}Filter()..primaryKeys($pksParams);');
    _sb.writeln(
        '    final list = await query(conn, columns: columns, limit: 2, filter: filter);');
    _sb.writeln('    if (list.isEmpty) return null;');
    _sb.writeln('    return list.single;');
    _sb.writeln('  }');
  }

  void _writeTableQuery(Table table) {
    _sb.writeln(
        '\n  Future<List<${table.type}Row>> query(PostgreSQLExecutionContext conn, {List<String> columns, List<String> orderBy, int limit, int offset, ${table.type}Filter filter,}) async {');
    _sb.writeln('    columns ??= ${table.type}Column.\$all;');
    _sb.writeln(
        '    final whereQ = (filter == null || filter.\$expressions.isEmpty) ? null : \'WHERE \${filter.\$join(\' AND \')}\';');
    _sb.writeln(
        '    final orderByQ = (orderBy == null || orderBy.isEmpty) ? null : \'ORDER BY \${orderBy.join(\', \')}\';');
    _sb.writeln(
        '    final offsetQ = (offset == null || offset == 0) ? null : \'OFFSET \$offset\';');
    _sb.writeln(
        '    final limitQ = (limit == null || limit == 0) ? null : \'LIMIT \$limit\';');
    _sb.writeln(
        '  final qexpr = [\'\$fqn\', whereQ, orderByQ, offsetQ, limitQ].where((s) => s != null).join(\' \');');
    _sb.writeln('    final list = await conn.mappedResultsQuery('
        '\'SELECT \${columns.map((c) => \'"\$c"\').join(\', \')} '
        'FROM \$qexpr\', substitutionValues: filter?.\$params);');
    _sb.writeln(
        '    return list.map((row) => new ${table.type}Row.fromRowMap(row)).toList();');
    _sb.writeln('  }');
  }

  void _writeTablePaginate(Table table) {
    _sb.writeln(
        '\n Future<Page<${table.type}Row>> paginate(${table.type}ConnectionFn fn, '
        '{int pageSize: 100, List<String> columns, ${table.type}Filter filter, ${table.type}Key startAfter,}) async {');
    _sb.writeln(
        '  final List<String> fixedColumns = columns == null ? null : new List<String>.from(columns);');
    _sb.writeln('  if (fixedColumns != null) {');
    for (Column c in table.columns.where((c) => c.isKey == true)) {
      _sb.writeln(
          '    if (!fixedColumns.contains(${table.type}Column.${c.fieldName})) {fixedColumns.add(${table.type}Column.${c.fieldName});}');
    }
    _sb.writeln('  }');
    _sb.writeln(
        '    final page = new ${table.type}Page._(null, false, fn, this, pageSize, fixedColumns, filter?.clone(), startAfter);');
    _sb.writeln('    return await page.next();');
    _sb.writeln('  }');
  }

  void _writeTableInsert(Table table) {
    final ff = (_hasJsonb || _hasBytea || _hasTsvector) ? ' ' : ' final';
    _sb.writeln(
        '\n  Future<int> insert(PostgreSQLExecutionContext conn, /* ${table.type}Row | List<${table.type}Row> */ items, {List<String> columns, bool upsert,}) async {');
    _sb.writeln(
        '    final List<${table.type}Row> rows = items is ${table.type}Row ? [items] : items as List<${table.type}Row>;');
    _sb.writeln('    columns ??= ${table.type}Column.\$all;');
    _sb.writeln('    final params = <String, dynamic>{};');
    _sb.writeln('    final list = <String>[];');
    _sb.writeln('    for (int i = 0; i < rows.length; i++) {');
    _sb.writeln('      final row = rows[i].toColumnMap();');
    _sb.writeln('      final exprs = <String>[];');
    _sb.writeln('      for (String col in columns) {');
    _sb.writeln('        final key = \'p\${i}x\$col\';');
    _sb.writeln('       $ff dynamic value = row[col];');
    _sb.writeln('       $ff String expr = \'@\$key\';');
    if (_hasJsonb) {
      _sb.writeln(
          '        if (value is Map && ${table.type}Column.\$jsonb.contains(col)) {');
      _sb.writeln('          expr = \'@\$key::JSONB\';');
      _sb.writeln('          value = convert.json.encode(value);');
      _sb.writeln('        }');
    }
    if (_hasBytea) {
      _sb.writeln(
          '        if (value is List<int> && ${table.type}Column.\$bytea.contains(col)) {');
      _sb.writeln('          expr = \'decode(@\$key, \\\'base64\\\')\';');
      _sb.writeln(
          '          value = convert.base64.encode(value as List<int>);');
      _sb.writeln('        }');
    }
    if (_hasTsvector) {
      _sb.writeln(
          '        if (value is Map<String, String> && ${table.type}Column.\$tsvector.contains(col)) {');
      _sb.writeln('          expr = \'@\$key::TSVECTOR\';');
      _sb.writeln(
          '          value = _tsvectorToString(value as Map<String, String>);');
      _sb.writeln('        }');
    }
    _sb.writeln('        exprs.add(expr);');
    _sb.writeln('        params[key] = value;');
    _sb.writeln('      }');
    _sb.writeln('      list.add(\'(\${exprs.join(\', \')})\');');
    _sb.writeln('    }');
    _sb.writeln('    if (list.isEmpty) {return 0;}');
    _sb.writeln('    final verb = upsert == true ? \'UPSERT\' : \'INSERT\';');
    _sb.writeln(
        '    return conn.execute(\'\$verb INTO \$fqn (\${columns.map((c) => \'"\$c"\').join(\', \')}) VALUES \${list.join(\', \')}\', substitutionValues: params);');
    _sb.writeln('  }');
  }

  void _writeTableUpdate(Table table) {
    final pks = table.columns
        .where((c) => c.isKey == true)
        .map((c) => '${_toDartType(c.type)} ${_guard(c.fieldName)}')
        .join(', ');
    final pksParams = table.columns
        .where((c) => c.isKey == true)
        .map((c) => _guard(c.fieldName))
        .join(', ');
    _sb.writeln(
        '\n  Future<int> update(PostgreSQLExecutionContext conn, $pks, ${table.type}Update update) {');
    _sb.writeln(
        '    return updateAll(conn, update, filter: new ${table.type}Filter()..primaryKeys($pksParams));');
    _sb.writeln('  }');
  }

  void _writeTableUpdateAll(Table table) {
    _sb.writeln(
        '\n  Future<int> updateAll(PostgreSQLExecutionContext conn, ${table.type}Update update, {${table.type}Filter filter, int limit}) async {');
    _sb.writeln(
        '    final whereQ = (filter == null || filter.\$expressions.isEmpty) ? \'\' : \'WHERE \${filter.\$join(\' AND \')}\';');
    _sb.writeln(
        '    final params = new Map<String, dynamic>.from(filter?.\$params ?? {})..addAll(update.\$params);');
    _sb.writeln(
        '    final limitQ = (limit == null || limit == 0) ? \'\' : \' LIMIT \$limit\';');
    _sb.writeln(
        '    return conn.execute(\'UPDATE \$fqn SET \${update.join()} \$whereQ\$limitQ\', substitutionValues: params);');
    _sb.writeln('  }');
  }

  void _writeTableDelete(Table table) {
    final pks = table.columns
        .where((c) => c.isKey == true)
        .map((c) => '${_toDartType(c.type)} ${_guard(c.fieldName)}')
        .join(', ');
    final pksParams = table.columns
        .where((c) => c.isKey == true)
        .map((c) => _guard(c.fieldName))
        .join(', ');
    _sb.writeln(
        '\n  Future<int> delete(PostgreSQLExecutionContext conn, $pks) {');
    _sb.writeln(
        '    return deleteAll(conn, new ${table.type}Filter()..primaryKeys($pksParams));');
    _sb.writeln('  }');
  }

  void _writeTableDeleteAll(Table table) {
    _sb.writeln(
        '\n  Future<int> deleteAll(PostgreSQLExecutionContext conn, ${table.type}Filter filter, {int limit}) async {');
    _sb.writeln(
        '    final whereQ = (filter == null || filter.\$expressions.isEmpty) ? \'\' : \'WHERE \${filter.\$join(\' AND \')}\';');
    _sb.writeln(
        '    final limitQ = (limit == null || limit == 0) ? \'\' : \' LIMIT \$limit\';');
    _sb.writeln(
        '    return conn.execute(\'DELETE FROM \$fqn \$whereQ\$limitQ\', substitutionValues: filter?.\$params);');
    _sb.writeln('  }');
  }

  void _writePage(Table table) {
    _sb.writeln(
        '\ntypedef Future<R> ${table.type}ConnectionFn<R>(Future<R> fn(PostgreSQLExecutionContext c));');
    _sb.writeln(
        '\nclass ${table.type}Page extends Object with PageMixin<${table.type}Row> {');
    _sb.writeln('  @override final bool isLast;');
    _sb.writeln('  @override final List<${table.type}Row> items;');
    _sb.writeln('  final ${table.type}ConnectionFn _fn;');
    _sb.writeln('   final ${table.type}Table _table;');
    _sb.writeln('  final int _limit;');
    _sb.writeln('  final List<String> _columns;');
    _sb.writeln('  final ${table.type}Filter _filter;');
    _sb.writeln('  final ${table.type}Key _startAfter;');
    _sb.writeln(
        '\n  ${table.type}Page._(this.items, this.isLast, this._fn, this._table, this._limit, this._columns, this._filter, this._startAfter);');

    _sb.writeln('\n  @override  Future<Page<${table.type}Row>> next() async {');
    _sb.writeln('    if (isLast) return null;');
    _sb.writeln(
        '    final filter = _filter?.clone() ?? new ${table.type}Filter();');
    _sb.writeln(
        '    if (items != null) {filter.keyAfter(items.last.toKey());} else if (_startAfter != null) {filter.keyAfter(_startAfter);}');
    _sb.writeln('    final rs = await _fn((c) async {');
    final pks = table.columns
        .where((c) => c.isKey == true)
        .map((c) => '${table.type}Column.${c.fieldName},')
        .join();
    _sb.writeln(
        '      final rows = await _table.query(c, columns: _columns, filter: filter, limit: _limit + 1, orderBy: [$pks]);');
    _sb.writeln('      final nextLast = rows.length <= _limit;');
    _sb.writeln(
        '      final nextRows = nextLast ? rows : rows.sublist(0, _limit);');
    _sb.writeln(
        '      return new ${table.type}Page._(nextRows, nextLast, _fn, _table, _limit, _columns, _filter, null);');
    _sb.writeln('    });');
    _sb.writeln('    return rs as Page<${table.type}Row>;');
    _sb.writeln('  }');

    _sb.writeln('\n  @override\n  Future close() async{}');
    _sb.writeln('}');
  }

  void _writeParse() {
    if (_hasTsvector) {
      _sb.writeln('\n  String _tsvectorToString(Map<String, String> vector) {');
      _sb.writeln('    if (vector == null) return null;');
      _sb.writeln(
          '    return vector.keys.map((k) {final v = vector[k]; return v == null ? k : \'\$k:\$v\';}).join(\' \');');
      _sb.writeln('  }');
      _sb.writeln('\n  Map<String, String> _parseTsvector(String vector) {');
      _sb.writeln('    if (vector == null) return null;');
      _sb.writeln('    final result = <String, String>{};');
      _sb.writeln('    vector.split(\' \').forEach((part) {'
          'final ps = part.split(\':\'); '
          'if (ps.length == 1) {result[part] = null;} '
          'else if (ps.length == 2) {result[ps[0]] = ps[1];}});');
      _sb.writeln('    return result;');
      _sb.writeln('  }');
    }
  }
}

_KV _keyValue(String name, String value, String type) {
  String key = '@\$$name';
  String convert = value;
  if (type == SqlType.timestamp) {
    key = '@\$$name::TIMESTAMP';
    convert = '$value.toUtc().toIso8601String().replaceFirst(\'Z\', \'\')';
  } else if (type == SqlType.bytea) {
    key = 'decode(@\$$name, \\\'base64\\\')';
    convert = 'convert.base64.encode($value)';
  } else if (type == SqlType.jsonb) {
    key = '@\$$name::JSONB';
    convert = 'convert.json.encode($value)';
  }
  return new _KV(key, convert);
}

class _KV {
  final String key;
  final String convert;

  _KV(this.key, this.convert);
}
