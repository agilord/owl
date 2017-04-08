// Copyright (c) 2016, Agilord. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:id/id.dart';
import 'package:source_gen/source_gen.dart';

import 'package:owl/annotation/sql.dart';

import 'utils.dart';

final String _coreAlias = '_owl_json';
final String _crudPgAlias = '_owl_sql_pg';

/// Generator class for mapping (JSON-ish serialization).
class PostgresSqlGenerator extends Generator {
  @override
  Future<String> generate(Element element, BuildStep buildStep) async {
    final String libBlock =
        handleIfLibrary(buildStep, element, SqlTable, libraries: [
      'dart:async'
    ], aliasedLibraries: {
      _coreAlias: 'package:owl/util/json/core.dart',
      _crudPgAlias: 'package:owl/util/sql/postgresql.dart',
      'pg': 'package:postgresql/postgresql.dart'
    });
    if (libBlock != null) {
      final List<_Table> tables = listClasses(element, SqlTable)
          .map(_parseClass)
          .toList()..sort((t1, t2) => t1.tableName.compareTo(t2.tableName));
      final sqlVarName =
          new Id(buildStep.inputId.path.split('/').last.split('.').first).camel;
      final sqlPackageName =
          new Id(buildStep.inputId.path.split('/').last.split('.').first)
              .capCamel;

      final sqlVarBlock = '\n/// DDL statements for the default schema.\n'
          '@Deprecated(\'Use ${sqlPackageName}Ddl.getDdls() instead.\')'
          'final List<String> ${sqlVarName}Ddl = ${sqlPackageName}Ddl.getDdls();\n';

      final sqlFnBlock = '\n/// DDL statements for a given schema.\n'
          '@Deprecated(\'Use ${sqlPackageName}Ddl.getDdls() instead.\')'
          'List<String> get${sqlPackageName}Ddl({String schema}) =>\n'
          '${sqlPackageName}Ddl.getDdls(schema: schema);';

      final String tableAddAll = tables
          .map((t) => t.className)
          .map((cn) => 'results.addAll(get${cn}Ddls(schema: schema));\n')
          .join();

      final String tableDdlFns = tables.map((t) {
        final List<String> sqls = [];
        sqls.add(_createTable(t));
        for (_Column column in t.columns) {
          sqls.add(_addColumn(t, column));
        }
        return '\n/// DDL statements for a ${t.tableName}.\n'
            'static List<String> get${t.className}Ddls({String schema, String table}) {\n'
            '  final String schemaPrefix = schema == null ? \'\': schema + \'.\';\n'
            '  final String tableName = table ?? \'${t.tableName}\';\n'
            '  final String fqtn = \'\$schemaPrefix\$tableName\';\n'
            '  return <String>[${sqls.map((sql) => '"""$sql"""').join(', ')}];\n'
            '}';
      }).join('\n');

      final ddlBlock = '\n/// DDL statements.\n'
          'abstract class ${sqlPackageName}Ddl {\n'
          '  /// DDL statements for a given schema.\n'
          '  static List<String> getDdls({String schema}) {'
          '    final List<String> results = <String>[];\n'
          '    $tableAddAll'
          '    return results;\n'
          '  }'
          '  $tableDdlFns\n'
          '}\n';

      return '$libBlock\n$sqlVarBlock\n$sqlFnBlock\n$ddlBlock\n';
    }
    if (element is ClassElement && hasAnnotation(element, SqlTable)) {
      final _Table table = _parseClass(element);
      String code = '/// CRUD methods for table: ${table.tableName}\n';
      code += 'abstract class ${table.className} {';
      // basic names
      code += '/// table: ${table.tableName}\n';
      code += '/// ignore: constant_identifier_names\n';
      code +=
          'static const String ${table.tableName.toUpperCase()} = \'${table.tableName}\';\n';
      for (var column in table.columns) {
        code += '/// column: ${column.columnName}\n';
        code +=
            'static const String ${column.field} = \'${column.columnName}\';\n';
      }

      // parseRow
      code += '/// Convert database row to object.\n';
      code += 'static ${element.name} parseRow(pg.Row row) {\n';
      code += '  if (row == null) return null;\n';
      code += '  // ignore: always_specify_types\n';
      code += '  final Map map = row.toMap();\n';
      code += '  final ${element.name} object = new ${element.name}();\n';
      for (var column in table.columns) {
        String parse;
        if (column.parserFn != null) {
          parse = "${column.parserFn}(map['${column.columnName}'])";
        } else {
          parse = 'map[\'${column.columnName}\']';
        }
        code += 'object.${column.field} = $parse;\n';
      }
      code += '  return object;\n';
      code += '}\n';

      // map
      code += '/// Convert object to Map.\n';
      code += 'static Map<String, dynamic> map(${element.name} object) {\n';
      code += '  if (object == null) return null;';
      code += '  return <String, dynamic>{';
      for (var column in table.columns) {
        String mapper;
        if (column.mapperFn != null) {
          mapper = '${column.mapperFn}(object.${column.field})';
        } else {
          mapper = 'object.${column.field}';
        }
        code += '\'${column.columnName}\': $mapper,';
      }
      code += '  };';
      code += '}\n';

      final varName = new Id.fromCamels(element.name).camel;
      final pks = table.primaryKeys;
      final vks = table.versionKeys;
      final String pkFnParams =
          pks.map((c) => '${c.dartType} ${c.field}').join(', ');
      final String vkFnParams =
          vks.map((c) => '${c.dartType} ${c.field}, ').join();
      final String pkWhere =
          pks.map((c) => '\'${c.columnName}\': ${c.field}').join(', ');
      final String allWhere = table.allKeys
          .map((c) => '\'${c.columnName}\': ${c.field}')
          .join(', ');
      final bool autoVersion = (vks.length == 1) && vks.first.dartType == 'int';
      final String autoVersionFnParam =
          autoVersion ? 'bool autoVersion: false, ' : '';

      // create
      code += '/// Insert a row into ${table.tableName}.\n';
      code += 'static Future<int> create(pg.Connection connection, '
          '${element.name} $varName, '
          '{String schema, String table, List<String> clear, '
          'bool strict: true, bool ifNotExists: false,}) async {';
      code += 'if (ifNotExists) {\n';

      code += '  final ${element.name} _x = await read(connection, '
          '${pks.map((c) => '$varName.${c.field}, ').join()}'
          ' strict: false);';
      code += '  if (_x != null) return 0;';
      code += '}\n';
      code += 'return await new $_crudPgAlias.SimpleCreate(schema: schema, '
          'table: table ?? \'${table.tableName}\', '
          'set: map($varName), clear: clear)'
          '.execute(connection, strict: strict);';
      code += '}\n';

      // read
      code += '/// Read a row from ${table.tableName}.\n';
      code += 'static Future<${element.name}> read('
          'pg.Connection connection, '
          '$pkFnParams, '
          '{String schema, String table, List<String> columns, '
          'bool forUpdate: false, bool strict: true,}) async {\n';
      for (_Column c in pks) {
        code += 'assert(${c.field} != null);\n';
      }
      code += 'final pg.Row _row = await new $_crudPgAlias.SimpleSelect('
          'schema: schema, table: table ?? \'${table.tableName}\', columns: columns,';
      code += 'where: <String, dynamic>{$pkWhere},';
      code += 'limit: (strict ? 2:1), '
          'forUpdate: forUpdate).get(connection, strict: strict);';
      code += 'return parseRow(_row);';
      code += '}';

      // update
      code += '/// Update a row in ${table.tableName}.\n';
      code += 'static Future<int> update('
          'pg.Connection connection, '
          '${element.name} $varName, {String schema, String table, ';
      code +=
          '$vkFnParams $autoVersionFnParam List<String> clear, bool strict: true,}) async {';
      if (autoVersion) {
        code += 'if (autoVersion) {';
        code += 'assert(${vks.first.field} == null);\n';
        code += '  // ignore: parameter_assignments\n';
        code += '  ${vks.first.field} = $varName.${vks.first.field}++;';
        code += '}\n';
      }
      code += 'final Map<String, dynamic> _set = map($varName);';
      code += 'final Map<String, dynamic> _where = <String, dynamic>{';
      for (_Column c in pks) {
        code += '\'${c.columnName}\': _set.remove(\'${c.columnName}\'),';
      }
      for (_Column c in vks) {
        code += '\'${c.columnName}\': ${c.field},';
      }
      code += '};';
      code += 'return await new $_crudPgAlias.SimpleUpdate('
          'schema: schema, table: table ?? \'${table.tableName}\', '
          'set: _set, clear: clear, where: _where)'
          '.execute(connection, strict: strict);';
      code += '}\n';

      // delete
      code += '/// Delete a row from ${table.tableName}.\n';
      code += 'static Future<int> delete('
          'pg.Connection connection, '
          '$pkFnParams, '
          '{String schema, String table, ${vkFnParams}bool strict: true,}) async {';
      for (_Column c in pks) {
        code += 'assert(${c.field} != null);\n';
      }
      code += 'return await new $_crudPgAlias.SimpleDelete('
          'schema: schema, table: table ?? \'${table.tableName}\', '
          'where: <String, dynamic>{$allWhere}).execute(connection, strict: strict);';
      code += '}\n';

      code += '}';
      return code;
    }
    return null;
  }
}

_Table _parseClass(ClassElement element, {bool skipReferences: false}) {
  final _Table table = new _Table();
  final sqlTable = getAnnotation(element, SqlTable);
  final name = stringValue(sqlTable, 'name');
  Id tableName;
  if (name == null) {
    tableName = new Id.fromCamels(element.name);
  } else {
    tableName = new Id(name);
  }
  table.tableName = tableName.snake;
  table.className = '${tableName.capCamel}Table';
  element.fields.forEach((field) {
    final column = _parseField(field);
    if (column != null) {
      table.columns.add(column);
      if (!skipReferences) {
        getAnnotations(field, SqlForeignKey).forEach((obj) {
          table.foreignKeys
              .add(_parseForeignKey(table.tableName, field, column, obj));
        });
      }
    }
  });
  return table;
}

_Column _parseField(FieldElement field) {
  if (hasAnnotation(field, Transient)) return null;
  final sqlColumn = getAnnotation(field, SqlColumn);
  final column = new _Column()..field = field.name;

  Id columnName = new Id.fromCamels(field.name);
  if (sqlColumn == null) {
    //
  } else {
    final String name = stringValue(sqlColumn, 'name');
    columnName = name == null ? new Id.fromCamels(field.name) : new Id(name);
    final sqlType = sqlColumn.getField('sqlType');
    if (!sqlType.isNull) {
      column.sqlType = SqlType.values[sqlType.getField('index').toIntValue()];
    }
    column.customType = stringValue(sqlColumn, 'customType');
  }
  column.columnName = columnName.snake;
  column.isPrimaryKey = boolValue(sqlColumn, 'primaryKey', false);
  column.isVersionKey = boolValue(sqlColumn, 'versionKey', false);
  column.dartType = field.type.toString();
  String mapperClass;
  if (column.dartType == 'DateTime') {
    mapperClass = '$_coreAlias.DateTimeMapper';
  } else if (column.dartType == 'String' && column.sqlType == SqlType.uuid) {
    mapperClass = '$_coreAlias.UuidMapper';
    column.parserFn = '$mapperClass.parse';
  }
  if (mapperClass != null) {
    column.mapperFn = '$mapperClass.map';
    column.parserFn = '$mapperClass.parse';
  }
  column.resolvedType = column.customType;
  if (column.resolvedType == null && column.sqlType != null) {
    column.resolvedType = _resolvedSqlTypes[column.sqlType];
  }
  if (column.resolvedType == null) {
    column.resolvedType = _resolvedDartTypes[column.dartType];
  }
  if (column.resolvedType == null) {
    throw new Exception(
        'Unable to resolve database type: ${column.columnName}.');
  }
  return column;
}

Map<SqlType, String> _resolvedSqlTypes = {
  SqlType.bool: 'BOOLEAN',
  SqlType.date: 'DATE',
  SqlType.int16: 'SMALLINT',
  SqlType.int32: 'INTEGER',
  SqlType.int64: 'BIGINT',
  SqlType.float32: 'REAL',
  SqlType.float64: 'DOUBLE PRECISION',
  SqlType.json: 'JSON',
  SqlType.jsonb: 'JSONB',
  SqlType.serial32: 'SERIAL',
  SqlType.serial64: 'BIGSERIAL',
  SqlType.text: 'TEXT',
  SqlType.timestamp: 'TIMESTAMP WITH TIME ZONE',
  SqlType.uuid: 'UUID',
};

Map<String, String> _resolvedDartTypes = {
  'int': 'INTEGER',
  'bool': 'BOOLEAN',
  'double': 'DOUBLE PRECISION',
  'String': 'TEXT',
  'DateTime': 'TIMESTAMP WITH TIME ZONE',
  'Map': 'JSONB',
};

_ForeignKey _parseForeignKey(String tableName, FieldElement field,
    _Column column, DartObject foreignKey) {
  final _ForeignKey fk = new _ForeignKey();
  final reference = foreignKey.getField('reference');
  if (reference == null || reference.isNull) {
    fk.table = stringValue(foreignKey, 'table');
    fk.targetColumns = [stringValue(foreignKey, 'column', column.columnName)];
  } else {
    final ClassElement classRef = getClassRef(field.library, reference);
    if (classRef == null) {
      throw new Exception('Class reference not found: $reference.');
    }
    final _Table tableRef = _parseClass(classRef, skipReferences: true);
    fk.table = tableRef.tableName;
    fk.targetColumns = [tableRef.primaryKeys.single.columnName];
  }
  fk.sourceColumns = [column.columnName];
  if (fk.name == null) {
    fk.name = 'fk__${tableName}__${field.name}__${fk.table}';
  }
  return fk;
}

class _Table {
  String tableName;
  String className;
  List<_Column> columns = [];
  List<_ForeignKey> foreignKeys = [];
  List<_Column> get primaryKeys =>
      columns.where((c) => c.isPrimaryKey).toList();
  List<_Column> get versionKeys =>
      columns.where((c) => c.isVersionKey).toList();
  List<_Column> get allKeys =>
      columns.where((c) => c.isPrimaryKey || c.isVersionKey).toList();
}

class _Column {
  String field;
  String dartType;
  String columnName;
  SqlType sqlType;
  String customType;
  bool isPrimaryKey;
  bool isVersionKey;
  String mapperFn;
  String parserFn;
  String resolvedType;
}

class _ForeignKey {
  String name;
  String table;
  List<String> sourceColumns;
  List<String> targetColumns;
  FKConstraint onUpdate;
  FKConstraint onDelete;
}

String _createTable(_Table table) {
  final String columns =
      table.columns.map((c) => '${c.columnName} ${c.resolvedType}').join(', ');
  final String pks = table.primaryKeys.map((c) => c.columnName).join(', ');
  return 'CREATE TABLE IF NOT EXISTS \$fqtn($columns, PRIMARY KEY($pks));';
}

String _addColumn(_Table table, _Column column) {
  List<String> constraints = [];
  // TODO: review how this could be done
//  if (column.isPrimaryKey) {
//    constraints.add('PRIMARY KEY');
//  }
  return 'ALTER TABLE \$fqtn '
      'ADD COLUMN IF NOT EXISTS ${column.columnName} ${column.resolvedType} ${constraints.join(' ')};';
}

List<String> _createReferences(_Table table) {
  final List<String> result = [];
  for (_ForeignKey fk in table.foreignKeys) {
    result.add('ALTER TABLE \$fqtn '
        'ADD CONSTRAINT ${fk.name} '
        'FOREIGN KEY (${fk.sourceColumns.join(', ')}) '
        'REFERENCES ${fk.table} (${fk.targetColumns.join(', ')})'
        '${_constraint('ON UPDATE', fk.onUpdate)}'
        '${_constraint('ON DELETE', fk.onDelete)};');
  }
  return result;
}

String _constraint(String kind, FKConstraint value) {
  if (value == null) return '';
  switch (value) {
    case FKConstraint.cascade:
      return '$kind CASCADE';
    case FKConstraint.noAction:
      return '$kind NO ACTION';
    case FKConstraint.restrict:
      return '$kind RESTRICT';
    case FKConstraint.setNull:
      return '$kind SET NULL';
  }
  throw new Exception('No resolution: $kind, $value.');
}
