import '_common.dart';
import 'model.dart';

String generateMessages(HttpApi httpApi, String baseName) {
  final messages = httpApi.messages ?? <Message>[];
  final sb = StringBuffer();
  ignoresForFile(sb);
  sb.writeln("import 'package:json_annotation/json_annotation.dart';");
  sb.writeln("import 'package:meta/meta.dart';");
  sb.writeln("\npart '$baseName.messages.g.dart';");

  for (final message in messages) {
    final className = message.name;
    _write(sb, message, className);
  }

  for (final endpoint in httpApi.endpoints) {
    if (endpoint.body?.inline != null) {
      _write(sb, endpoint.body.inline, '${ucFirst(endpoint.action)}RqBody');
    }
    for (final response in endpoint.responses) {
      final prefix = responsePostfix(response.name, response.status);
      if (response.body?.inline != null) {
        _write(sb, response.body.inline,
            '${ucFirst(endpoint.action)}Rs\$$prefix\$Body');
      }
    }
  }

  return sb.toString();
}

void _write(StringBuffer sb, Message message, String className) {
  writeDocumentation(sb, message.description);
  sb.writeln('@JsonSerializable()');
  sb.writeln('class $className {');

  final constructorLines = <String>[];

  for (final field in message.fields) {
    final dartType = field.type ?? 'String';
    final fieldName = field.name; // the dart field name
    writeDocumentation(sb, field.description);
    sb.writeln('  final $dartType $fieldName;');
    final annotation = (field.isRequired ?? false) ? '@required ' : '';
    constructorLines.add('${annotation}this.$fieldName,');
  }
  sb.writeln('\n$className({${constructorLines.join(' ')}});');

  sb.writeln(
      '\nfactory $className.fromJson(Map<String, dynamic> json) => _\$${className}FromJson(json);');
  sb.writeln('\nMap<String, dynamic> toJson() => _\$${className}ToJson(this);');

  sb.writeln('}');
}
