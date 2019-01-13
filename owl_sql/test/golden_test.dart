import 'dart:io';

import 'package:test/test.dart';

import 'package:owl_sql/postgres.dart';

final _updateGoldenFiles = false;

void main() {
  group('golden', () {
    Future validateGolden(List<Table> tables, String targetFile,
        {bool targetCockroachDB: false}) async {
      final name = targetFile.hashCode.toString() +
          '-' +
          new DateTime.now().microsecondsSinceEpoch.toString() +
          '.dart';
      final tempFile =
          new File(Directory.systemTemp.path + Platform.pathSeparator + name);
      try {
        await writeInto(tables, tempFile.path,
            targetCockroachDB: targetCockroachDB, format: true);
        final content = await tempFile.readAsString();
        if (_updateGoldenFiles) {
          await new File(targetFile).writeAsString(content);
          throw new Exception('Golden file was updated.');
        }
        final expected = await new File(targetFile).readAsString();
        expect(content, expected);
      } finally {
        try {
          await tempFile.delete();
        } catch (_) {}
      }
    }

    test('pg_scan', () async {
      await validateGolden([
        new Table('Scan', [
          new Column('id1', SqlType.text, isKey: true),
          new Column('id2', SqlType.bytea, isKey: true),
          new Column('id3', SqlType.text, isKey: true),
          new Column('payload', SqlType.bytea),
        ]),
      ], 'test/golden/pg_scan.g.dart');
    });

    test('pg_sample', () async {
      await validateGolden([
        new Table('Sample', [
          new Column('text_col', SqlType.text, isKey: true),
          new Column('bytea_col', SqlType.bytea),
          new Column('boolean_col', SqlType.boolean),
          new Column('double_col', SqlType.double),
          new Column('bigint_col', SqlType.bigint),
          new Column('smallint_col', SqlType.smallint),
          new Column('uuid_col', SqlType.uuid),
          new Column('timestamp_col', SqlType.timestamp),
          new Column('jsonb_col', SqlType.jsonb),
        ]),
      ], 'test/golden/pg_sample.g.dart');
    });

    test('pg_text', () async {
      await validateGolden([
        new Table('Text', [
          new Column('id', SqlType.text, isKey: true),
          new Column('snippet', SqlType.text),
          new Column('vector', SqlType.tsvector),
        ], indexes: [
          new Index('vector_text', ['vector'], isInverted: true),
        ]),
      ], 'test/golden/pg_text.g.dart');
    });
  });
}
