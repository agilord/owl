import 'dart:async';

import 'package:owl_sql/runtime.dart';
import 'package:postgres/postgres.dart';
import 'package:test/test.dart';

import 'docker.dart';
import 'golden/pg_sample.g.dart';

Future main() async {
  withPostgresServer('pg_sample', (server) {
    late Connection conn;
    final table = SampleRelation(Name('stbl', schema: 'test_sample'));

    setUpAll(() async {
      conn = await server.newConnection();
      await conn.execute('CREATE SCHEMA IF NOT EXISTS test_sample;');
      await table.init(conn);
    });

    tearDownAll(() async {
      await conn.execute('DROP SCHEMA test_sample CASCADE;');
    });

    test('populate data', () async {
      await table.insert(
          conn,
          SampleRow(
            textCol: 'id-value',
            bigintCol: 1 << 62,
            smallintCol: -135,
            booleanCol: true,
            byteaCol: <int>[1, 6, 9, 10],
            doubleCol: 4.5,
            jsonbCol: {
              'a': 'a1',
              'b': [1, 2, 3]
            },
            timestampCol: DateTime(2000, 01, 02, 03, 04, 05).toUtc(),
            uuidCol: '00112233-4455-6677-8899-aabbccddeeff',
          ));

      final list =
          await conn.execute('SELECT COUNT(*) FROM ${table.name.fqn};');
      expect(list[0][0], 1);
    });

    test('read data', () async {
      final row = await table.read(conn, ['id-value']);
      expect(row!.textCol, 'id-value');
      expect(row.bigintCol, 4611686018427387904);
      expect(row.smallintCol, -135);
      expect(row.booleanCol, true);
      expect(row.byteaCol, [1, 6, 9, 10]);
      expect(row.doubleCol, 4.5);
      expect(row.jsonbCol, {
        'a': 'a1',
        'b': [1, 2, 3]
      });
      expect(row.timestampCol, DateTime(2000, 01, 02, 03, 04, 05).toUtc());
      expect(row.uuidCol, '00112233-4455-6677-8899-aabbccddeeff');
    });

    test('query data', () async {
      Future run(Expr<bool> Function(SampleColumns c) fn) async {
        final rows = await table.query(conn, where: fn);
        expect(rows, hasLength(1));
      }

      await run((c) => c.bigintCol.equalsTo(4611686018427387904));
      await run((c) => c.bigintCol.greaterThan(4611686018427387903));
      await run((c) => c.smallintCol.equalsTo(-135));
      await run((c) => c.smallintCol.lessThan(-134));
      await run((c) => c.booleanCol.equalsTo(true));
      await run((c) => c.byteaCol.greaterThan([1, 1]));
      await run((c) => c.doubleCol.greaterThan(4.4));
      await run((c) => c.jsonbCol.matches({'a': 'a1'}));
      await run((c) => c.timestampCol.greaterThan(DateTime(1999, 01, 01)));
      await run(
          (c) => c.uuidCol.greaterThan('00112233-0000-6677-8899-aabbccddeeff'));
    });

    test('update data', () async {
      final updated = await table.update(
        conn,
        ['id-value'],
        (c) => [
          c.smallintCol.set(135),
          c.byteaCol.set([2, 3]),
          c.jsonbCol.set({'x': 1}),
          c.timestampCol.set(DateTime(2002, 02, 03, 04, 05, 06).toUtc()),
          c.uuidCol.set('22110033-4455-6677-8899-aabbccddeeff'),
        ],
      );
      expect(updated, 1);
    });

    test('read updated data', () async {
      final row = await table.read(conn, ['id-value']);
      expect(row!.textCol, 'id-value');
      expect(row.bigintCol, 4611686018427387904);
      expect(row.smallintCol, 135);
      expect(row.booleanCol, true);
      expect(row.byteaCol, [2, 3]);
      expect(row.doubleCol, 4.5);
      expect(row.jsonbCol, {'x': 1});
      expect(row.timestampCol, DateTime(2002, 02, 03, 04, 05, 06).toUtc());
      expect(row.uuidCol, '22110033-4455-6677-8899-aabbccddeeff');
    });

    test('delete data', () async {
      expect(await table.delete(conn, SampleKey(textCol: 'id-value2')), 0);
      expect(await table.delete(conn, SampleKey(textCol: 'id-value')), 1);
    });
  });
}
