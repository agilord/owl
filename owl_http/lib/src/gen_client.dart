import '_common.dart';
import 'model.dart';

String generateClient(HttpApi httpApi, String baseName) {
  final sb = StringBuffer();
  ignoresForFile(sb);

  sb.writeln("import 'dart:convert';");
  sb.writeln("import 'package:http/http.dart' as http;");
  sb.writeln("\nimport '$baseName.api.dart';");

  sb.writeln(
      'class ${ucFirst(baseName)}HttpClient implements ${ucFirst(baseName)}Api {');
  sb.writeln('  final http.Client _client;');
  sb.writeln('  final Uri _baseUri;');
  sb.writeln('  String _baseUriPath;');
  sb.writeln('\n${ucFirst(baseName)}HttpClient(this._client, url) :');
  sb.writeln('_baseUri = url is Uri ? url : Uri.parse(url as String);');

  sb.writeln('\n  String _path(String path) {');
  sb.writeln('    if (_baseUriPath == null) {');
  sb.writeln('      final bup = _baseUri.path;');
  sb.writeln(
      '      _baseUriPath = bup.endsWith(\'/\') ? bup.substring(0, bup.length - 1) : bup;');
  sb.writeln('    }');
  sb.writeln("    return '\$_baseUriPath\$path';");
  sb.writeln('  }');

  for (final endpoint in httpApi.endpoints) {
    final ucId = ucFirst(endpoint.action);
    String path = endpoint.path;
    for (String pp in pathParameters(path)) {
      path = path.replaceFirst('<$pp>', '\${rq.${dartFieldName(pp)}}');
    }
    sb.writeln('\n  @override');
    sb.writeln('  Future<${ucId}Rs> ${endpoint.action}(${ucId}Rq rq) async {');
    sb.writeln('  final hrq = http.StreamedRequest(');
    sb.writeln("'${endpoint.method.toUpperCase()}', _baseUri.replace(");
    sb.writeln("path: _path('$path'),");
    if (endpoint.query != null && endpoint.query.isNotEmpty) {
      sb.writeln('queryParameters: _queryParameters({');
      for (final p in endpoint.query) {
        final dfn = dartFieldName(p.name);
        sb.writeln("if (rq.$dfn != null) '${p.name}': rq.$dfn.toString(),");
      }
      sb.writeln('}),');
    }
    sb.writeln('  )');
    sb.writeln('  );');

    for (final p in endpoint.headers ?? <Parameter>[]) {
      sb.writeln(
          "hrq.headers['${p.name}'] = rq.${dartFieldName(p.name)}?.toString();");
    }

    sb.writeln('final f = _client.send(hrq);');
    if (endpoint.body?.ref?.toLowerCase() == 'string') {
      sb.writeln('if (rq.body != null) {');
      sb.writeln('hrq.sink.add(utf8.encode(rq.body));');
      sb.writeln('}');
    } else if (endpoint.body?.ref == 'stream') {
      sb.writeln('if (rq.body != null) {');
      sb.writeln('await for (final bytes in rq.body) {');
      sb.writeln('  hrq.sink.add(bytes);');
      sb.writeln('}');
      sb.writeln('}');
    } else if (endpoint.body?.ref != null) {
      sb.writeln('if (rq.body != null) {');
      sb.writeln('hrq.sink.add(utf8.encode(json.encode(rq.body.toJson())));');
      sb.writeln('}');
    } else if (endpoint.body?.inline != null) {
      sb.writeln('if (rq.body != null) {');
      sb.writeln('hrq.sink.add(utf8.encode(json.encode(rq.body.toJson())));');
      sb.writeln('}');
    }
    sb.writeln('hrq.sink.close();');
    sb.writeln('final rs = await f;');

    for (final response in endpoint.responses) {
      final postfix = responsePostfix(response.name, response.status);
      sb.writeln('if (rs.statusCode == ${response.status}) {');
      sb.writeln('  return ${ucId}Rs.$postfix(');
      for (final p in response.headers ?? <Parameter>[]) {
        final v = wrapTypeTransform("rs.headers['${p.name}']", p.type);
        sb.writeln('${dartFieldName(p.name)}: $v,');
      }
      if (response.body?.ref?.toLowerCase() == 'string') {
        sb.writeln('body: await rs.stream.bytesToString(),');
      } else if (response.body?.ref == 'stream') {
        sb.writeln('body: rs.stream,');
      } else if (response.body?.ref != null) {
        sb.writeln(
            'body: ${response.body?.ref}.fromJson(json.decode(await rs.stream.bytesToString()) as Map<String, dynamic>),');
      } else if (response.body?.inline != null) {
        sb.writeln(
            'body: ${ucId}Rs\$$postfix\$Body.fromJson(json.decode(await rs.stream.bytesToString()) as Map<String, dynamic>),');
      }
      sb.writeln(');');
      sb.writeln('}');
    }
    sb.writeln(
        "throw Exception('Unknown server response: \${rs.statusCode}}');");

    sb.writeln('  }');
  }
  sb.writeln('}');

  sb.writeln(
      '\nMap<String, String> _queryParameters(Map<String, String> map) {');
  sb.writeln('  return map.isEmpty ? null : map;');
  sb.writeln('}');

  return sb.toString();
}
