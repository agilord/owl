import 'package:open_api/v3.dart';

String schemaObjectAsDartType(APISchemaObject obj) {
  switch (obj.type) {
    case APIType.number:
      return 'num';
    case APIType.string:
      return 'String';
    case APIType.integer:
      return 'int';
    case APIType.boolean:
      return 'bool';
    case APIType.array:
      final typeName = obj.items.referenceURI.pathSegments.last;
      return 'List<$typeName>';
    default:
      throw Exception('${obj.type} is not (yet) supported as primitive type.');
  }
}

String ucFirst(String text) =>
    text.substring(0, 1).toUpperCase() + text.substring(1);

String responseName(String key) {
  switch (key) {
    case '200':
      return 'ok';
    case '404':
      return 'notFound';
  }
  return 'rs${ucFirst(key)}';
}

void writeDocumentation(StringBuffer sb, String documentation) {
  if (documentation == null || documentation.isEmpty) return;
  // TODO: split long lines
  sb.writeln('/// $documentation');
}

final _pathParam = RegExp(r'\<(.*?)>');
List<String> pathParameters(String path) {
  return _pathParam
      .allMatches(path)
      .map((m) => m.group(1))
      .map((s) => s.split('|').first)
      .toList();
}

const statusNames = <int, String>{
  102: 'processing',
  200: 'ok',
  201: 'created',
  202: 'accepted',
  204: 'noContent',
  301: 'moved',
  302: 'found',
  304: 'notModified',
  400: 'badRequest',
  401: 'unauthorized',
  403: 'forbidden',
  404: 'notFound',
  409: 'conflict',
  503: 'unavailable',
};

String dartFieldName(String name) {
  final nameParts = name.split('-');
  return nameParts.first + nameParts.skip(1).map(ucFirst).join();
}

String wrapTypeTransform(String expr, String type) {
  if (type == null || type.isEmpty || type.toLowerCase() == 'string') {
    return expr;
  }
  if (type == 'int') {
    return "int.tryParse($expr ?? '')";
  }
  if (type == 'bool') {
    return "($expr == 'true')";
  }
  throw Exception('Unknown wrapper for type: $type ($expr)');
}

String responsePostfix(String name, int status) {
  return name ?? statusNames[status] ?? 'rs$status';
}

void ignoresForFile(StringBuffer sb) {
  sb.writeln('// ignore_for_file: unused_import');
  sb.writeln('// ignore_for_file: unused_element');
  sb.writeln();
}
