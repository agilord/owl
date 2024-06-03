import 'dart:async';

import 'package:owl_sql/runtime.dart';
import 'package:postgres/postgres.dart';
import 'package:test/test.dart';

import 'docker.dart';
import 'golden/pg_text.g.dart';

Future main() async {
  withPostgresServer('pg_sample', (server) {
    late Connection conn;
    final table = TextRelation(Name('ttbl', schema: 'test_text'));

    setUpAll(() async {
      conn = await server.newConnection();
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
            // <String, String>{'abc': '', 'bcd': '1,2', 'cde': '3C,8'}
            vector: TsVector(words: [
              TsWord('abc'),
              TsWord('bcd', positions: [TsWordPos(1), TsWordPos(2)]),
              TsWord('cde',
                  positions: [TsWordPos(3, weight: TsWeight.c), TsWordPos(8)]),
            ]),
          ));
      final list =
          await conn.execute('SELECT COUNT(*) FROM ${table.name.fqn};');
      expect(list[0][0], 1);
    });

    test('read back data', () async {
      final row = (await table.read(conn, ['tr1']))!;
      expect(row.snippet, 'snippet-1');
      expect(row.vector.toString(), 'abc bcd:1,2 cde:3C,8');
      expect(row.scanRow, isNull);
    });

    test('search data', () async {
      final rows = await table.query(conn,
          where: (c) => c.vector.tsquery(TsQuery.word('abc')));
      expect(rows, hasLength(1));
      expect(rows.first.id, 'tr1');
    });

    test('update data', () async {
      await table.update(
        conn,
        ['tr1'],
        (c) => [
          c.vector.set(TsVector(words: [TsWord('xx')]))
        ],
      );
    });

    test('search updated data', () async {
      final emptyRows = await table.query(conn,
          where: (c) => c.vector.tsquery(TsQuery.word('abc')));
      expect(emptyRows, hasLength(0));
      final rows = await table.query(conn,
          where: (c) => c.vector.tsquery(TsQuery.word('xx')));
      expect(rows, hasLength(1));
      expect(rows.first.id, 'tr1');
    });
  });
}
