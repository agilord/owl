// Copyright (c) 2016, Agilord. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'package:owl/annotation/json.dart';

import 'utils.dart';

final String _coreAlias = '_owl_json';

/// Generator class for JSON mapping.
class JsonGenerator extends Generator {
  @override
  Future<String> generate(Element element, BuildStep buildStep) async {
    final String libBlock = handleIfLibrary(buildStep, element, JsonClass,
        libraries: ['dart:convert'],
        aliasedLibraries: {_coreAlias: 'package:owl/util/json/core.dart'});
    if (libBlock != null) return libBlock;
    if (element is ClassElement && hasAnnotation(element, JsonClass)) {
      final List<_Field> fields =
          element.fields.map(_Field.parse).where((f) => f != null).toList();
      String mapper = '/// Mapper for ${element.name}\n';
      mapper += 'abstract class ${element.name}Mapper {';
      mapper += '\n/// Converts an instance of ${element.name} to Map.\n';
      mapper += '  static Map<String, dynamic> map(${element.name} object) {';
      mapper += '    if (object == null) return null;';
      final bool ordered =
          boolValue(getAnnotation(element, JsonClass), 'ordered', false);
      mapper += '    return (new $_coreAlias.MapBuilder(ordered: $ordered)\n';
      // mapper += '    return {';
      for (_Field field in fields) {
        // ignore: prefer_final_locals
        String access;
        if (field.isList && field.mapperFn != null) {
          access =
              'object.${field.fieldName}?.map(${field.mapperFn})?.toList()';
        } else if (field.isList) {
          access = 'object.${field.fieldName}?.toList()';
        } else if (field.mapperFn != null) {
          access = '${field.mapperFn}(object.${field.fieldName})';
        } else {
          access = 'object.${field.fieldName}';
        }
        mapper += '..put(\'${field.keyName}\', $access)';
        // mapper += "'${field.keyName}': $access,\n";
      }
      //mapper += '    };';
      mapper += ').toMap();';
      mapper += '  }';

      mapper += '\n/// Converts a Map to an instance of ${element.name}.\n';
      mapper += '  static ${element.name} parse(Map<String, dynamic> map) {';
      mapper += '    if (map == null) return null;';
      mapper += '    final ${element.name} object = new ${element.name}();';
      for (_Field field in fields) {
        // ignore: prefer_final_locals
        String parse;
        if (field.isList && field.parserFn != null) {
          parse =
              "(map['${field.keyName}'] as List<dynamic>)?.map(${field.parserFn})?.toList()";
        } else if (field.isList) {
          parse =
              "(map['${field.keyName}'] as List<${field.baseType}>)?.toList()";
        } else if (field.parserFn != null) {
          parse = "${field.parserFn}(map['${field.keyName}'])";
        } else {
          parse = "map['${field.keyName}']";
        }
        if (field.isList) {
          mapper += '\n    // ignore: avoid_as\n';
        }
        mapper += "object.${field.fieldName} = $parse;\n";
      }
      mapper += '    return object;';
      mapper += '  }';

      // JSON
      mapper +=
          '\n/// Converts a JSON string to an instance of ${element.name}.\n';
      mapper += 'static ${element.name} fromJson(String json) {';
      mapper += '  if (json == null || json.isEmpty) return null;\n';
      mapper +=
          '  final Map<String, dynamic> map = JSON.decoder.convert(json);';
      mapper += '  return parse(map);';
      mapper += '}\n';

      mapper +=
          '\n/// Converts an instance of ${element.name} to JSON string.\n';
      mapper += 'static String toJson(${element.name} object) {';
      mapper += '  if (object == null) return null;\n';
      mapper += '  return JSON.encoder.convert(map(object));';
      mapper += '}\n';

      mapper += '}';
      return mapper;
    }
    return null;
  }
}

class _Field {
  String fieldName;
  String keyName;
  String baseType;
  bool isList;
  String mapperFn;
  String parserFn;

  _Field.fromElement(FieldElement elem) {
    fieldName = elem.name;
    keyName = elem.name;

    final String fieldType = elem.type.toString();
    if (fieldType.startsWith('List<') && fieldType.endsWith('>')) {
      baseType = fieldType.substring(5, fieldType.length - 1);
      isList = true;
    } else {
      isList = false;
      baseType = fieldType;
    }

    if (!isNativeJson(baseType)) {
      String mapperClass;
      if (baseType == 'DateTime') {
        mapperClass = '$_coreAlias.DateTimeMapper';
      } else {
        mapperClass = '${baseType}Mapper';
      }
      mapperFn = '$mapperClass.map';
      parserFn = '$mapperClass.parse';
    }

    final mapField = getAnnotation(elem, JsonField);
    if (mapField != null) {
      keyName = stringValue(mapField, 'key', keyName);
      // TODO: implement overriding mapperFn and parserFn
    }
  }

  static _Field parse(FieldElement elem) {
    if (hasAnnotation(elem, Transient)) return null;
    return new _Field.fromElement(elem);
  }
}
