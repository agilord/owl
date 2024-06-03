import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';

import 'src/io_utils.dart';
import 'model.dart';

export 'model.dart';

Future<bool> writeInto(
  List<Table> tables,
  String targetFile, {
  String? header,
  Map<String, String>? imports,
  bool targetCockroachDB = false,
  bool format = true,
}) async {
  return await writeIntoFile(tables, File(targetFile), (List<Table> items) {
    final src = generateSource(
      items,
      imports: imports,
    );
    return '${header ?? ''}$src';
  }, format);
}

String generateSource(
  List<Table> tables, {
  Map<String, String>? imports,
}) {
  return _Codegen(tables, imports).generate();
}

class _Codegen {
  final _sb = StringBuffer();
  final List<Table> _tables;
  final Map<String, String?>? _imports;

  _Codegen(List<Table> tables, this._imports) : _tables = tables;

  String generate() {
    _sb.writeln(
        '// ignore_for_file: omit_local_variable_types, prefer_final_locals, prefer_single_quotes');
    final imports = [
      'import \'package:owl_sql/runtime.dart\';',
      'import \'package:postgres/postgres.dart\';',
    ];
    _imports?.entries.forEach((e) {
      if (e.value == null) {
        imports.add('import \'${e.key}\';');
      } else {
        imports.add('import \'${e.key}\' as ${e.value};');
      }
    });
    imports.sort();
    imports.where((s) => s.contains('\'dart:')).forEach(_sb.writeln);
    _sb.writeln();
    imports.where((s) => s.contains('\'package:')).forEach(_sb.writeln);
    _sb.writeln();
    final relatives = imports
        .where((s) => !s.contains('\'dart:') && !s.contains('\'package:'))
        .toList();
    relatives.forEach(_sb.writeln);
    if (relatives.isNotEmpty) {
      _sb.writeln();
    }

    for (var table in _tables) {
      _writeSchema(table);
      _writeKey(table);
      _writeRow(table);
    }
    return _sb.toString();
  }

  void _writeSchema(Table table) {
    _sb.writeln('\nclass ${table.type}Columns extends Columns {');
    _sb.writeln('  final String? _ref;');
    _sb.writeln('  ${table.type}Columns({String? ref}) : _ref = ref;\n');
    for (var col in table.columns) {
      final parts = [
        "'${col.name}'",
        if (col.isKey) 'isKey: true',
        if (col.isDescending) 'order: Order.desc',
        if (col.hasFamily) 'family: \'${col.family}\'',
        'ref: _ref',
      ];
      _sb.writeln(
          'late final ${col.fieldName} = ${_toColumnType(col.type)}(${parts.join(', ')});');
    }
    _sb.writeln(
        '\n\n  @override\n  late final \$all = List.unmodifiable([${table.columns.map((e) => '${e.fieldName},').join()}]);');

    _sb.writeln('}');

    _sb.writeln(
        '\nclass ${table.type}Relation extends Relation<${table.type}Columns, ${table.type}Key, ${table.type}Row> {');
    _sb.writeln('  ${table.type}Relation(super.name, {super.ref});');
    _sb.writeln(
        '\n\n  @override\n  late final columns = ${table.type}Columns(ref: ref);');

    _sb.writeln(
        '\n @override\n Expr<bool> whereFromKeyFn(${table.type}Columns c, ${table.type}Key key) => ');
    _sb.writeln(table.columns
        .where((c) => c.isKey)
        .map((c) => 'c.${c.fieldName}.equalsTo(key.${c.fieldName})')
        .join(' & '));
    _sb.writeln(';');

    _sb.writeln(
        '\n  @override\n  ${table.type}Row rowFn(ResultRow row) => ${table.type}Row.fromColumnMap(row.toColumnMap());');

    _sb.writeln('}');
  }

  void _writeKey(Table table) {
    _sb.writeln('\n/// Unique continuity position for ${table.type} tables.');
    final keyColumns = table.columns.where((c) => c.isKey).toList();
    _sb.writeln(
        'class ${table.type}Key extends Key implements Comparable<${table.type}Key> {');
    for (var col in keyColumns) {
      _sb.write('final ${_toDartType(col.type)} ${col.fieldName};\n');
    }
    _sb.write('\n  ${table.type}Key({\n');
    for (var col in keyColumns) {
      _sb.write('  required this.${col.fieldName},\n');
    }
    _sb.writeln('  });');

    _sb.writeln('\n  factory ${table.type}Key.fromList(List list) {');
    final listM = table.columns.where((c) => c.isKey).mapIndexed((index, c) {
      final colExpr =
          _transformToDart(c.type, 'list[$index]', isRequired: true);
      return '${c.fieldName}: $colExpr,';
    }).join('');
    _sb.writeln('    return ${table.type}Key($listM);');
    _sb.writeln('  }\n');

    _sb.writeln(
        '\n  factory ${table.type}Key.fromFieldMap(Map<String, Object?> map) {');
    final fieldM = table.columns.where((c) => c.isKey).map((c) {
      final colExpr =
          _transformToDart(c.type, 'map[\'${c.fieldName}\']', isRequired: true);
      return '${c.fieldName}: $colExpr,';
    }).join('');
    _sb.writeln('    return ${table.type}Key($fieldM);');
    _sb.writeln('  }\n');

    _sb.writeln('\n  @override\n  Map<String, Object?> toFieldMap() {');
    _sb.writeln('    return {');
    for (var col in table.columns.where((e) => e.isKey)) {
      final expr = col.fieldName;
      _sb.write('    \'${col.fieldName}\': $expr,\n');
    }
    _sb.writeln('    };');
    _sb.writeln('  }');

    _sb.writeln(
        '\n  @override\n  List toList() => [${keyColumns.map((e) => e.fieldName).join(', ')}];');
    _sb.writeln('\n  @override int compareTo(${table.type}Key \$other) {');
    _sb.writeln('  int \$x = 0;');
    for (var col in keyColumns) {
      final asc = !col.isDescending;
      final sign = col.isDescending ? '-' : '';
      if (col.type == SqlType.bytea) {
        _sb.writeln(
            '  \$x = compareBytes(${col.fieldName}, \$other.${col.fieldName}, $asc);');
        _sb.writeln('  if (\$x != 0) return $sign\$x;');
      } else {
        _sb.writeln(
            '  \$x = ${col.fieldName}.compareTo(\$other.${col.fieldName});');
        _sb.writeln('  if (\$x != 0) return $sign\$x;');
      }
    }
    _sb.writeln('  return 0;');
    _sb.writeln('  }');
    _sb.write('}\n');
  }

  void _writeRow(Table table) {
    final pks = table.columns.where((c) => c.isKey == true).toList();
    _sb.write('class ${table.type}Row implements Row {\n');
    for (var col in table.columns) {
      _sb.write('final ${_toDartType(col.type)}? ${col.fieldName};\n');
    }
    for (var field in table.fields ?? const []) {
      _sb.writeln('${field.type}? ${field.name};');
    }
    _sb.write('\n  ${table.type}Row({\n');
    for (var col in table.columns) {
      _sb.write('  this.${col.fieldName},\n');
    }
    for (var field in table.fields ?? const []) {
      _sb.writeln('  this.${field.name},');
    }
    _sb.writeln('  });');

    _sb.writeln('\n  factory ${table.type}Row.fromRowList(List row) {');
    var colIdx = 0;
    final colX = table.columns.map((c) {
      final rowExp = _transformToDart(c.type, 'row[${colIdx++}]');
      return '${c.fieldName}: $rowExp,';
    }).join('');
    _sb.writeln('      return ${table.type}Row($colX);');
    _sb.writeln('  }\n');

    _sb.writeln(
        '\n  factory ${table.type}Row.fromColumnMap(Map<String, Object?> map) {');
    final colM = table.columns.map((c) {
      final colExpr = _transformToDart(c.type, 'map[\'${c.name}\']');
      return '${c.fieldName}: $colExpr,';
    }).join('');
    _sb.writeln('    return ${table.type}Row($colM);');
    _sb.writeln('  }\n');

    _sb.writeln(
        '\n  factory ${table.type}Row.fromFieldMap(Map<String, Object?> map) {');
    final fieldM = table.columns.map((c) {
      final colExpr = _transformToDart(c.type, 'map[\'${c.fieldName}\']');
      return '${c.fieldName}: $colExpr,';
    }).join('');
    _sb.writeln('    return ${table.type}Row($fieldM);');
    _sb.writeln('  }\n');

    _sb.writeln('\n  Map<String, dynamic> toFieldMap() {');
    _sb.writeln('    return {');
    for (var col in table.columns) {
      final expr = col.fieldName;
      _sb.write('  if ($expr != null) \'${col.fieldName}\': $expr,\n');
    }
    _sb.writeln('    };');
    _sb.writeln('  }');
    _sb.writeln('\n  @override\n  Map<String, dynamic> toColumnMap() {');
    _sb.writeln('    return {');
    for (var col in table.columns) {
      final expr = col.fieldName;
      _sb.write('  if ($expr != null) \'${col.name}\': $expr,\n');
    }
    _sb.writeln('    };');
    _sb.writeln('  }');
    _sb.writeln('\n  @override\n  ${table.type}Key toKey() =>');
    _sb.writeln(
        '    ${table.type}Key(${pks.map((c) => '${c.fieldName}: ${c.fieldName}!,').join()});');
    _sb.write('}\n');
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
        return 'TsVector';
    }
    throw StateError('Unmapped column type: $type');
  }

  String _toColumnType(String type) {
    switch (type) {
      case SqlType.boolean:
        return 'BoolColumn';
      case SqlType.bigint:
        return 'BigintColumn';
      case SqlType.smallint:
        return 'SmallintColumn';
      case SqlType.double:
        return 'DoubleColumn';
      case SqlType.text:
        return 'TextColumn';
      case SqlType.uuid:
        return 'UuidColumn';
      case SqlType.timestamp:
        return 'TimestampColumn';
      case SqlType.jsonb:
        return 'JsonbColumn';
      case SqlType.bytea:
        return 'ByteaColumn';
      case SqlType.tsvector:
        return 'TsvectorColumn';
    }
    throw StateError('Unmapped column type: $type');
  }

  String _transformToDart(
    String type,
    String expr, {
    bool isRequired = false,
  }) {
    final qm = isRequired ? '' : '?';
    switch (type) {
      default:
        return '$expr as ${_toDartType(type)}$qm';
    }
  }
}
