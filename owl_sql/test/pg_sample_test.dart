import 'dart:async';

import 'package:postgres/postgres.dart';
import 'package:test/test.dart';

import 'golden/pg_sample.g.dart';

Future main() async {
  group('pg_scan', () {
    late Connection conn;
    final table = SampleTable('stbl', schema: 'test_sample');

    setUpAll(() async {
      // docker run --rm -it -p 5432:5432 postgres:11.1
      conn = await Connection.open(
        Endpoint(
          host: 'localhost',
          port: 5432,
          database: 'postgres',
          username: 'postgres',
          password: 'postgres',
        ),
        settings: ConnectionSettings(
          sslMode: SslMode.disable,
        ),
      );
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

      final list = await conn.execute('SELECT COUNT(*) FROM ${table.fqn};');
      expect(list[0][0], 1);
    });

    test('read data', () async {
      final row = await table.read(conn, 'id-value');
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
      Future run(SampleFilter filter) async {
        final rows = await table.query(conn, filter: filter);
        expect(rows, hasLength(1));
      }

      await run(SampleFilter()..bigintCol$equalsTo(4611686018427387904));
      await run(SampleFilter()..bigintCol$greaterThan(4611686018427387903));
      await run(SampleFilter()..smallintCol$equalsTo(-135));
      await run(SampleFilter()..smallintCol$lessThan(-134));
      await run(SampleFilter()..booleanCol$equalsTo(true));
      await run(SampleFilter()..byteaCol$greaterThan([1, 1]));
      await run(SampleFilter()..doubleCol$greaterThan(4.4));
      await run(SampleFilter()..jsonbCol$matches({'a': 'a1'}));
      await run(
          SampleFilter()..timestampCol$greaterThan(DateTime(1999, 01, 01)));
      await run(SampleFilter()
        ..uuidCol$greaterThan('00112233-0000-6677-8899-aabbccddeeff'));
    });

    test('update data', () async {
      await table.update(
          conn,
          'id-value',
          SampleUpdate()
            ..smallintCol(135)
            ..byteaCol([2, 3])
            ..jsonbCol({'x': 1})
            ..timestampCol(DateTime(2002, 02, 03, 04, 05, 06).toUtc())
            ..uuidCol('22110033-4455-6677-8899-aabbccddeeff'));
    });

    test('read updated data', () async {
      final row = await table.read(conn, 'id-value');
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
  });
}
