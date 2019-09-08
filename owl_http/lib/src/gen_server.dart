import '_common.dart';
import 'model.dart';

String generateServer(HttpApi httpApi, String baseName) {
  final sb = StringBuffer();
  ignoresForFile(sb);
  sb.writeln("import 'dart:convert';");
  sb.writeln("import 'package:shelf/shelf.dart' as shelf;");
  sb.writeln("import 'package:shelf_router/shelf_router.dart';");
  sb.writeln("\nimport '$baseName.api.dart';");
  sb.writeln("\npart '$baseName.server.g.dart';");

  sb.writeln('class ${ucFirst(baseName)}HttpService {');
  sb.writeln('  final ${ucFirst(baseName)}Api _api;');
  sb.writeln('  ${ucFirst(baseName)}HttpService(this._api);');
  sb.writeln(
      '\n Router get router => _\$${ucFirst(baseName)}HttpServiceRouter(this);');

  for (final endpoint in httpApi.endpoints) {
    final pathParams = pathParameters(endpoint.path);
    final methodPathParams = pathParams.map((p) => ', String $p').join();
    sb.writeln(
        "@Route('${endpoint.method.toUpperCase()}', '${endpoint.path}')");
    sb.writeln(
        'Future<shelf.Response> ${endpoint.action}(shelf.Request request $methodPathParams) async {');
    sb.writeln('final rq = ${ucFirst(endpoint.action)}Rq(');

    for (final param in endpoint.headers ?? <Parameter>[]) {
      final v = wrapTypeTransform(
          "request.headers['${param.name.toLowerCase()}']", param.type);
      sb.writeln('${dartFieldName(param.name)}: $v,');
    }
    for (final p in pathParams) {
      sb.writeln('$p: $p,');
    }
    for (final param in endpoint.query ?? <Parameter>[]) {
      final v = wrapTypeTransform(
          "request.requestedUri.queryParameters['${param.name.toLowerCase()}']",
          param.type);
      sb.writeln('${dartFieldName(param.name)}: $v,');
    }
    if (endpoint.body?.ref?.toLowerCase() == 'string') {
      sb.writeln('body: await request.readAsString(),');
    } else if (endpoint.body?.ref == 'stream') {
      sb.writeln('body: request.read(),');
    } else if (endpoint.body?.ref != null) {
      final jd =
          'json.decode(await request.readAsString()) as Map<String, dynamic>';
      sb.writeln('body: ${endpoint.body.ref}.fromJson($jd),');
    } else if (endpoint.body?.inline != null) {
      final jd =
          'json.decode(await request.readAsString()) as Map<String, dynamic>';
      sb.writeln('body: ${ucFirst(endpoint.action)}RqBody.fromJson($jd),');
    }

    sb.writeln(');');
    sb.writeln('final rs = await _api.${endpoint.action}(rq);');

    for (final response in endpoint.responses) {
      final postfix = responsePostfix(response.name, response.status);
      sb.writeln('if (rs.$postfix != null) {');
      sb.writeln('  return shelf.Response(');
      sb.writeln('  ${response.status}');
      if (response.headers != null && response.headers.isNotEmpty) {
        sb.writeln(',headers: {');
        for (final hp in response.headers) {
          sb.writeln(
              "'${hp.name.toLowerCase()}': rs.$postfix.${dartFieldName(hp.name)},");
        }
        sb.writeln('}');
      }
      if (response.body?.ref?.toLowerCase() == 'string') {
        sb.writeln(',body: rs.$postfix.body,');
      } else if (response.body?.ref == 'stream') {
        sb.writeln(',body: rs.$postfix.body,');
      } else if (response.body?.ref != null) {
        sb.writeln(',body: json.encode(rs.$postfix.body.toJson()),');
      } else if (response.body?.inline != null) {
        sb.writeln(',body: json.encode(rs.$postfix.body.toJson()),');
      }
      sb.writeln('  );');
      sb.writeln('}');
    }

    sb.writeln('return shelf.Response.internalServerError();');
    sb.writeln('}');
  }

  sb.writeln('}');

  return sb.toString();
}
