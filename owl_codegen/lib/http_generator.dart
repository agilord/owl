// Copyright (c) 2016, Agilord. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'ext/id.dart';

import 'package:owl/annotation/http.dart';

import 'utils.dart';

final String _webappAlias = '_owl';

/// HTTP webapp client generator.
class HttpWebappClientGenerator extends Generator {
  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) {
    List<AnnotatedElement> elements =
        library.annotatedWith(new TypeChecker.fromRuntime(HttpApi)).toList();
    if (elements.isEmpty) return null;
    List<String> blocks = [];
    blocks.add(generateImportBlock(
      buildStep,
      libraries: ['dart:async', _jsonMapping(buildStep)],
      aliasedLibraries: {_webappAlias: 'package:owl/util/http/webapp.dart'},
    ));
    blocks.add('import \'dart:html\' show HttpRequest;');

    for (var ae in elements) {
      if (ae.element is ClassElement) {
        blocks.add(_generate(ae.element as ClassElement, buildStep));
      }
    }

    return blocks.join('\n');
  }

  String _generate(ClassElement element, BuildStep buildStep) {
    final _Api api = _parse(element);
    // interface
    String code = '/// API client interface of ${api.service}.\n';
    code += 'abstract class ${api.service}Client {';
    for (_Function fn in api.functions) {
      code += '/// ${fn.method} ${fn.path.path}\n';
      code += 'Future<${fn.response}> ${fn.name}(${fn.fnParams.join(', ')});\n';
    }
    code += '}';

    // implementation
    code += '/// API client implementation of ${api.service}.\n';
    code += 'class ${api.service}ClientImpl implements ${api.service}Client {';
    code += '/// Returns the request headers to set on the request.\n';
    code +=
        '/// Signature: Map<String, String> headerCallback(String functionName)\n';
    code += '$_webappAlias.HeaderCallback headerCallback;';
    for (_Function fn in api.functions) {
      code += '/// ${fn.method} ${fn.path.path}\n';
      code += '@override\n';
      code +=
          'Future<${fn.response}> ${fn.name}(${fn.fnParams.join(', ')}) async {\n';
      code +=
          '  final Map<String, String> _headers = headerCallback == null ? null : headerCallback(\'${fn.name}\');\n';
      if (fn.request != null) {}
      code += '  final HttpRequest _r = await $_webappAlias.callHttpServer(\n';
      String path = fn.path.simplePath;
      for (String fnParam in fn.path.paramNames) {
        path = path.replaceFirst('{}', '\${$fnParam}');
      }
      code += '    \'${fn.method}\', ';
      code += '    // ignore: unnecessary_brace_in_string_interp\n';
      code += '\'$path\', headers: _headers';
      if (fn.request != null) {
        switch (fn.request) {
          case 'String':
            code += ', body: ${fn.requestVar}';
            break;
          case 'int':
            code += ', body: \'\$${fn.requestVar}\'';
            break;
          default:
            code += ', body: ${fn.request}Mapper.toJson(${fn.requestVar})';
            break;
        }
      }
      code += ');\n';

      switch (fn.response) {
        case 'String':
          code += 'return _r.responseText;\n';
          break;
        default:
          code += 'return ${fn.response}Mapper.fromJson(_r.responseText);\n';
          break;
      }

      code += '}\n';
    }
    code += '}';
    return code;
  }
}

/// HTTP server handler generator.
class HttpServerGenerator extends Generator {
  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) {
    List<AnnotatedElement> elements =
        library.annotatedWith(new TypeChecker.fromRuntime(HttpApi)).toList();
    if (elements.isEmpty) return null;
    List<String> blocks = [];
    blocks.add(generateImportBlock(
      buildStep,
      libraries: ['dart:async', _jsonMapping(buildStep)],
    ));
    blocks.add('import \'dart:io\' show HttpRequest, HttpResponse;');
    blocks.add('import \'dart:convert\' as convert show utf8;');

    for (var ae in elements) {
      if (ae.element is ClassElement) {
        blocks.add(_generate(ae.element as ClassElement, buildStep));
      }
    }

    return blocks.join('\n');
  }

  String _generate(ClassElement element, BuildStep buildStep) {
    final _Api api = _parse(element);
    // interface
    String code = '/// Server interface of ${api.service}.\n';
    code += 'abstract class ${api.service}Server {';
    for (_Function fn in api.functions) {
      code += '/// ${fn.method} ${fn.path.path}\n';
      final List<String> fnParams = new List()
        ..add('HttpRequest httpRequest')
        ..addAll(fn.fnParams);
      code += 'Future<${fn.response}> ${fn.name}(${fnParams.join(', ')});\n';
    }
    code += '}\n';

    // handler
    code += '/// HTTP handler of ${api.service}.\n';
    code += 'class ${api.service}HttpHandler {\n';
    code += '  final ${api.service}Server _server;\n';
    for (_Function fn in api.functions) {
      if (fn.path.paramNames.isNotEmpty) {
        String regexp = fn.path.simplePath;
        for (int i = 0; i < fn.path.paramNames.length; i++) {
          String pattern;
          switch (fn.path.paramTypes[i]) {
            case 'int':
              pattern = '(\d+)';
              break;
            default:
              pattern = '(\w+)';
              break;
          }
          regexp = regexp.replaceFirst('{}', pattern);
        }
        code +=
            '  final RegExp _regexp${fn.casedName} = new RegExp(r\'^$regexp\$\');\n';
      }
    }
    code += '\n\n /// HTTP handler of ${api.service}.\n';
    code += '  ${api.service}HttpHandler(this._server);\n';
    code += '  /// Tries to handle the request, returns a Future if the\n';
    code += '  /// path matches any of the configured patterns.\n';
    code += '  Future<Null> handle(HttpRequest httpRequest) {\n';
    code += '    final String _path = httpRequest.uri.path;\n';
    for (_Function fn in api.functions) {
      code += '  if (httpRequest.method == \'${fn.method.toUpperCase()}\'';
      final List<String> parts = fn.path.simplePath.split('{}');
      if (parts.length == 1) {
        code += ' && _path == \'${fn.path.simplePath}\'';
      } else if (parts.first.isNotEmpty) {
        code += ' && _path.startsWith(\'${parts.first}\')';
      }
      code += ') {\n';
      code += '  final Future<Null> f = _handle${fn.casedName}(httpRequest);\n';
      code += '  if (f != null) return f;\n';
      code += '}\n';
    }
    code += '    return null;\n';
    code += '  }\n';
    for (_Function fn in api.functions) {
      code += '/// ${fn.method.toUpperCase()} ${fn.path.path}\n';
      code +=
          'Future<Null> _handle${fn.casedName}(HttpRequest httpRequest) async { ';
      if (fn.path.paramNames.isNotEmpty) {
        code +=
            '  final Match match = _regexp${fn.casedName}.matchAsPrefix(httpRequest.uri.path);';
        code += ' if (match == null) return null;\n';
        for (int i = 0; i < fn.path.paramNames.length; i++) {
          code += '  final ${fn.path.paramTypes[i]} ${fn.path.paramNames[i]} =';
          switch (fn.path.paramTypes[i]) {
            case 'int':
              code += 'int.parse(match[${i+1}]);';
              break;
            default:
              code += 'match[${i+1}];';
              break;
          }
        }
      }
      final List<String> callParams = ['httpRequest']
        ..addAll(fn.path.paramNames);
      if (fn.requestVar != null) {
        code +=
            'final String _body = await convert.utf8.decodeStream(httpRequest);';
        code += 'final ${fn.request} ${fn.requestVar} = ';
        switch (fn.request) {
          case 'String':
            code += '_body;';
            break;
          case 'int':
            code += 'int.parse(_body);';
            break;
          default:
            code += '${fn.request}Mapper.fromJson(_body);';
            break;
        }
        callParams.add(fn.requestVar);
      }
      code +=
          '    final ${fn.response} _result = await _server.${fn.name}(${callParams.join(', ')});';
      code += '  final HttpResponse _response = httpRequest.response;';
      code += '  if (_result != null) {';
      switch (fn.response) {
        case 'String':
        case 'int':
          code += '_response.write(_result);';
          break;
        default:
          code += '_response.write(${fn.response}Mapper.toJson(_result));';
          break;
      }
      code += '}';
      code += 'await _response.flush();';
      code += 'await _response.close();';
      code += '}\n';
    }
    code += '}';

    return code;
  }
}

String _jsonMapping(BuildStep buildStep) =>
    '${buildStep.inputId.path.split('/').last.split('.').first}.json.g.dart';

_Api _parse(ClassElement element) {
  final DartObject apiAnnotation = getAnnotation(element, HttpApi);
  final _Api api = new _Api()
    ..rootPath = stringValue(apiAnnotation, 'rootPath', '')
    ..service = _getServiceBase(element);
  for (DartObject fnAnn in apiAnnotation.getField('functions').toListValue()) {
    final _Function fn = new _Function()
      ..path = new _Path(api.rootPath + stringValue(fnAnn, 'path'))
      ..method = stringValue(fnAnn, 'method')?.toUpperCase()
      ..name = stringValue(fnAnn, 'name')
      ..request = fnAnn.getField('request').toTypeValue()?.displayName
      ..response = fnAnn.getField('response').toTypeValue()?.displayName;

    if (fn.method == null) {
      if (fn.request == null) {
        fn.method = HttpMethod.GET;
      } else {
        throw new Exception(
            'Default HTTP method get is not working for ${fn.path}');
      }
    }

    if (fn.name == null) {
      final List<String> parts = [];
      parts.add(fn.method.toLowerCase());
      parts.addAll(fn.path.simplePath
          .substring(api.rootPath.length)
          .toLowerCase()
          .replaceAll(new RegExp('\\W+'), ' ')
          .trim()
          .split(' '));
      fn.name = new Id(parts.join('_')).camel;
    }
    fn.casedName = new Id.fromCamels(fn.name).capCamel;

    if (fn.response == null && fn.method == HttpMethod.GET) {
      fn.response = 'String';
    }
    fn.response ??= 'Null';

    for (int i = 0; i < fn.path.paramNames.length; i++) {
      fn.fnParams.add('${fn.path.paramTypes[i]} ${fn.path.paramNames[i]}');
    }
    if (fn.request != null) {
      switch (fn.request) {
        case 'int':
        case 'String':
          fn.requestVar = 'request';
          break;
        default:
          fn.requestVar = new Id.fromCamels(fn.request).camel;
          break;
      }
      fn.fnParams.add('${fn.request} ${fn.requestVar}');
    }

    api.functions.add(fn);
  }
  return api;
}

class _Api {
  String service;
  String rootPath;
  List<_Function> functions = [];
}

class _Function {
  _Path path;
  String method;
  String name;
  String casedName;
  String request;
  String response;

  String requestVar;
  List<String> fnParams = [];
}

class _Path {
  String path;
  String simplePath;
  List<String> paramNames = [];
  List<String> paramTypes = [];

  _Path(this.path) {
    simplePath = path;
    for (Match m in new RegExp('\\\{([^\}]*)\\\}').allMatches(path)) {
      final String param = m.group(1);
      final List<String> parts = param.split(':');
      paramNames.add(parts[0]);
      if (parts.length == 1) {
        paramTypes.add('String');
      } else {
        paramTypes.add(parts[1]);
      }
      simplePath = simplePath.replaceFirst('{$param}', '{}');
    }
  }

  @override
  String toString() => path;
}

String _getServiceBase(ClassElement element) {
  String serviceBase = element.name;
  if (serviceBase.endsWith('Api')) {
    serviceBase = serviceBase.substring(0, serviceBase.length - 3);
  }
  return serviceBase;
}
