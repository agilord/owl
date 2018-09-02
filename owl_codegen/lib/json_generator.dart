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
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) {
    List<AnnotatedElement> elements =
        library.annotatedWith(new TypeChecker.fromRuntime(JsonClass)).toList();
    if (elements.isEmpty) return null;
    List<String> blocks = [];
    blocks.add(generateImportBlock(
      buildStep,
      libraries: [],
      aliasedLibraries: {
        'convert': 'dart:convert',
        _coreAlias: 'package:owl/util/json/core.dart',
      },
    ));

    for (var ae in elements) {
      if (ae.element is ClassElement) {
        blocks.add(_generate(ae.element as ClassElement, buildStep));
      }
    }

    return blocks.join('\n');
  }

  String _generate(ClassElement element, BuildStep buildStep) {
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
        access = 'object.${field.fieldName}?.map(${field.mapperFn})?.toList()';
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
        parse = "(map['${field.keyName}'] as List<dynamic>)"
            "\n// ignore: argument_type_not_assignable\n"
            "?.map((d) => ${field.parserFn}(d))?.cast<${field.baseType}>()?.toList()";
      } else if (field.isList) {
        parse = "(map['${field.keyName}'] as List)"
            "?.cast<${field.baseType}>()"
            "?.toList()";
      } else if (field.parserFn != null) {
        final skipAsMap = field.parserFn.startsWith('_owl_json');
        final asMap = skipAsMap ? '' : ' as Map<String, dynamic>';
        parse = "${field.parserFn}(map['${field.keyName}']$asMap)";
      } else {
        parse = "map['${field.keyName}']";
        if (isNativeJson(field.baseType)) {
          parse += ' as ${field.baseType}';
        } else if (field.baseType.startsWith('Map')) {
          parse += ' as ${field.baseType}';
        }
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
        '  final Map<String, dynamic> map = convert.json.decoder.convert(json);';
    mapper += '  return parse(map);';
    mapper += '}\n';

    mapper += '\n/// Converts an instance of ${element.name} to JSON string.\n';
    mapper += 'static String toJson(${element.name} object) {';
    mapper += '  if (object == null) return null;\n';
    mapper += '  return convert.json.encoder.convert(map(object));';
    mapper += '}\n';

    mapper += '}';
    return mapper;
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
    final jsonField = getJsonFieldAnnotation(elem);

    final String fieldType = elem.type.toString();
    if (fieldType.startsWith('List<') && fieldType.endsWith('>')) {
      baseType = fieldType.substring(5, fieldType.length - 1);
      isList = true;
    } else {
      isList = false;
      baseType = fieldType;
    }

    bool isNative =
        isNativeJson(baseType) || boolValue(jsonField, 'native', false);
    if (!isNative) {
      String mapperClass;
      if (baseType == 'DateTime') {
        mapperClass = '$_coreAlias.DateTimeMapper';
      } else {
        mapperClass = '${baseType}Mapper';
      }
      mapperFn = '$mapperClass.map';
      parserFn = '$mapperClass.parse';
    }

    if (jsonField != null) {
      keyName = stringValue(jsonField, 'key', keyName);
      // TODO: implement overriding mapperFn and parserFn
    }
  }

  static _Field parse(FieldElement elem) {
    if (hasAnnotation(elem, Transient)) return null;
    if (elem.getter == null || elem.setter == null) return null;
    return new _Field.fromElement(elem);
  }
}
