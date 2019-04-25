import 'dart:io';

import 'package:test/test.dart';

import 'package:owl_sql/postgres.dart';

final _updateGoldenFiles = false;

void main() {
  group('golden', () {
    Future validateGolden(List<Table> tables, String targetFile,
        {Map<String, String> imports, bool targetCockroachDB = false}) async {
      final name = targetFile.hashCode.toString() +
          '-' +
          DateTime.now().microsecondsSinceEpoch.toString() +
          '.dart';
      final tempFile =
          File(Directory.systemTemp.path + Platform.pathSeparator + name);
      try {
        await writeInto(
          tables,
          tempFile.path,
          imports: imports,
          targetCockroachDB: targetCockroachDB,
          format: true,
        );
        final content = await tempFile.readAsString();
        if (_updateGoldenFiles) {
          await File(targetFile).writeAsString(content);
          throw Exception('Golden file was updated.');
        }
        final expected = await File(targetFile).readAsString();
        expect(content, expected);
      } finally {
        try {
          await tempFile.delete();
        } catch (_) {}
      }
    }

    test('pg_scan', () async {
      await validateGolden([
        Table('Scan', [
          Column('id1', SqlType.text, isKey: true),
          Column('id2', SqlType.bytea, isKey: true),
          Column('id3', SqlType.text, isKey: true),
          Column('payload', SqlType.bytea),
        ]),
      ], 'test/golden/pg_scan.g.dart');
    });

    test('pg_sample', () async {
      await validateGolden([
        Table('Sample', [
          Column('text_col', SqlType.text, isKey: true),
          Column('bytea_col', SqlType.bytea),
          Column('boolean_col', SqlType.boolean),
          Column('double_col', SqlType.double),
          Column('bigint_col', SqlType.bigint),
          Column('smallint_col', SqlType.smallint),
          Column('uuid_col', SqlType.uuid),
          Column('timestamp_col', SqlType.timestamp),
          Column('jsonb_col', SqlType.jsonb),
        ]),
      ], 'test/golden/pg_sample.g.dart');
    });

    test('pg_text', () async {
      await validateGolden(
        [
          Table(
            'Text',
            [
              Column('id', SqlType.text, isKey: true),
              Column('snippet', SqlType.text),
              Column('vector', SqlType.tsvector),
            ],
            fields: [
              Field('scanRow', 'a.ScanRow'),
            ],
            indexes: [
              Index('vector_text', ['vector'], isInverted: true),
            ],
          ),
        ],
        'test/golden/pg_text.g.dart',
        imports: {'pg_scan.g.dart': 'a'},
      );
    });
  });
}
