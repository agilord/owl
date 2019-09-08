import 'package:meta/meta.dart';

import '_common.dart';
import 'model.dart';

String generateApi(HttpApi httpApi, String baseName) {
  final sb = StringBuffer();
  ignoresForFile(sb);
  sb.writeln("import '$baseName.messages.dart';");
  sb.writeln("export '$baseName.messages.dart';");

  sb.writeln('\nabstract class ${ucFirst(baseName)}Api {');
  for (final endpoint in httpApi.endpoints) {
    final ucId = ucFirst(endpoint.action);
    sb.writeln('  Future<${ucId}Rs> ${endpoint.action}(${ucId}Rq rq);');
  }
  sb.writeln('}');

  for (final endpoint in httpApi.endpoints) {
    final ucId = ucFirst(endpoint.action);
    final rqBuilder = ApiClassBuilder();
    endpoint.headers?.forEach(rqBuilder.addParameter);
    for (String name in pathParameters(endpoint.path)) {
      rqBuilder.add(name: name);
    }
    endpoint.query?.forEach(rqBuilder.addParameter);
    if (endpoint.body?.ref != null) {
      rqBuilder.addBodyRef(endpoint.body.ref);
    } else if (endpoint.body?.inline != null) {
      rqBuilder.add(name: 'body', dartType: '${ucId}RqBody');
    }

    sb.writeln('\n${rqBuilder.toClassDeclaration('${ucId}Rq', null)}');

    ApiClassBuilder buildResponseClass(Response response) {
      final postfix = responsePostfix(response.name, response.status);
      final builder = ApiClassBuilder();
      response.headers?.forEach(builder.addParameter);
      if (response.body?.ref != null) {
        builder.addBodyRef(response.body.ref);
      } else if (response.body?.inline != null) {
        builder.add(name: 'body', dartType: '${ucId}Rs\$$postfix\$Body');
      }
      return builder;
    }

    sb.writeln('\nclass ${ucId}Rs {');
    for (final response in endpoint.responses) {
      final postfix = responsePostfix(response.name, response.status);
      sb.writeln('final ${ucId}Rs\$$postfix $postfix;');
    }
    for (final response in endpoint.responses) {
      final postfix = responsePostfix(response.name, response.status);
      final remaining = endpoint.responses
          .where((r) => r != response)
          .map((r) => responsePostfix(r.name, r.status))
          .toList();
      final builder = buildResponseClass(response);
      sb.write(builder.toDelegateConstructor('${ucId}Rs', postfix, remaining));
//      sb.write('${ucId}Rs.$postfix(this.$postfix)');
//      if (remaining.isNotEmpty) {
//        sb.write(':');
//        sb.write(remaining.map((r) => '$r = null').join(', '));
//      }
//      sb.writeln(';');
    }
    sb.writeln('}');

    for (final response in endpoint.responses) {
      final postfix = responsePostfix(response.name, response.status);
      final builder = buildResponseClass(response);
      sb.writeln(
          '\n${builder.toClassDeclaration('${ucId}Rs\$$postfix', null)}');
    }
  }

  return sb.toString();
}

class ApiClassBuilder {
  final _fieldDeclarations = <String>[];
  final _constructorParams = <String>[];
  final _delegateDeclarations = <String>[];
  final _delegateParams = <String>[];

  void add({@required String name, String dartType, String description}) {
    dartType ??= 'String';
    final sb = StringBuffer();
    writeDocumentation(sb, description);
    sb.writeln('final $dartType $name;');
    _fieldDeclarations.add(sb.toString());
    _constructorParams.add('this.$name,');
    _delegateDeclarations.add('$dartType $name');
    _delegateParams.add('$name: $name');
  }

  void addParameter(Parameter param) {
    add(
      name: dartFieldName(param.name),
      dartType: param.type,
      description: param.description,
    );
  }

  void addBodyRef(String ref) {
    if (ref == null) {
      return;
    } else if (ref == 'stream') {
      add(name: 'body', dartType: 'Stream<List<int>>');
    } else if (ref.toLowerCase() == 'string') {
      add(name: 'body', dartType: 'String');
    } else {
      add(name: 'body', dartType: ref);
    }
  }

  String toClassDeclaration(String name, String description) {
    final sb = StringBuffer();
    writeDocumentation(sb, description);
    sb.writeln('class $name {');
    _fieldDeclarations.forEach(sb.writeln);
    sb.write('$name(');
    if (_constructorParams.isNotEmpty) {
      sb.write('{');
      _constructorParams.forEach(sb.writeln);
      sb.write('}');
    }
    sb.writeln(');');
    sb.writeln('}');
    return sb.toString();
  }

  String toDelegateConstructor(
      String className, String postfix, List<String> remaining) {
    final sb = StringBuffer();
    sb.writeln('$className.$postfix(');
    if (_delegateDeclarations.isNotEmpty) {
      sb.write('{');
      sb.write(_delegateDeclarations.join(', '));
      sb.write('}');
    }
    sb.write(') : ');
    sb.write('$postfix = $className\$$postfix(${_delegateParams.join(', ')})');
    if (remaining.isNotEmpty) {
      sb.write(',');
      sb.write(remaining.map((r) => '$r = null').join(', '));
    }
    sb.writeln(';');
    return sb.toString();
  }
}
