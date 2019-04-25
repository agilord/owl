import 'dart:async';

import 'package:postgres/postgres.dart';
import 'package:test/test.dart';

import 'golden/pg_text.g.dart';

Future main() async {
  group('pg_text', () {
    PostgreSQLConnection conn;
    final table = TextTable('ttbl', schema: 'test_text');

    setUpAll(() async {
      // docker run --rm -it -p 5432:5432 postgres:11.1
      conn = PostgreSQLConnection('localhost', 5432, 'postgres',
          username: 'postgres', password: 'postgres');
      await conn.open();
      await conn.execute('CREATE SCHEMA IF NOT EXISTS test_text;');
      await table.init(conn);
    });

    tearDownAll(() async {
      await conn.execute('DROP SCHEMA test_text CASCADE;');
    });

    test('populate data', () async {
      await table.insert(
          conn,
          TextRow(
            id: 'tr1',
            snippet: 'snippet-1',
            vector: <String, String>{'abc': null, 'bcd': '1,2', 'cde': '3C,8'},
          ));
      final list = await conn.query('SELECT COUNT(*) FROM ${table.fqn};');
      expect(list[0][0], 1);
    });

    test('read back data', () async {
      final row = await table.read(conn, 'tr1');
      expect(row.snippet, 'snippet-1');
      expect(row.vector, isNotEmpty);
      expect(row.scanRow, isEmpty);
    });

    test('search data', () async {
      final rows =
          await table.query(conn, filter: TextFilter()..vector$tsquery('abc'));
      expect(rows, hasLength(1));
      expect(rows.first.id, 'tr1');
    });

    test('update data', () async {
      await table.update(conn, 'tr1', TextUpdate()..vector({'xx': null}));
    });

    test('search updated data', () async {
      final emptyRows =
          await table.query(conn, filter: TextFilter()..vector$tsquery('abc'));
      expect(emptyRows, hasLength(0));
      final rows =
          await table.query(conn, filter: TextFilter()..vector$tsquery('xx'));
      expect(rows, hasLength(1));
      expect(rows.first.id, 'tr1');
    });
  });
}
