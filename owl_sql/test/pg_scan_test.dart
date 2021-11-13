import 'dart:async';

import 'package:postgres/postgres.dart';
import 'package:test/test.dart';

import 'golden/pg_scan.g.dart';

Future main() async {
  group('pg_scan', () {
    late PostgreSQLConnection conn;
    final table = ScanTable('stbl', schema: 'test_scan');

    setUpAll(() async {
      // docker run --rm -it -p 5432:5432 postgres:11.1
      conn = PostgreSQLConnection('localhost', 5432, 'postgres',
          username: 'postgres', password: 'postgres');
      await conn.open();
      await conn.execute('CREATE SCHEMA IF NOT EXISTS test_scan;');
      await table.init(conn);
    });

    tearDownAll(() async {
      await conn.execute('DROP SCHEMA test_scan CASCADE;');
    });

    test('populate data', () async {
      final rows = <ScanRow>[];
      for (var i = 0; i < 20; i++) {
        final id1 = i.toString().padLeft(2, '0');
        for (var j = 0; j < 20; j++) {
          final id2 = <int>[j ~/ 10, j % 10];
          for (var k = 0; k < 20; k++) {
            rows.add(ScanRow(
              id1: id1,
              id2: id2,
              id3: k.toString().padLeft(2, '0'),
              payload: [i, j, k],
            ));
          }
        }
      }

      rows.shuffle();
      for (var i = 0; i < rows.length; i += 100) {
        await table.insert(conn, rows.sublist(i, i + 100).toList());
      }

      final list = await conn.query('SELECT COUNT(*) FROM ${table.fqn};');
      expect(list[0][0], 8000);
    });

    test('paginate without filter', () async {
      final page = await table.paginate(conn, pageSize: 71);
      final list = await page.asStream().toList();
      expect(list, hasLength(8000));
      final row = list.firstWhere((r) =>
          r.id1 == '03' &&
          r.id2 != null &&
          r.id2![0] == 0 &&
          r.id2![1] == 4 &&
          r.id3 == '05');
      expect(row.payload, [3, 4, 5]);
    });

    test('paginate without all columns', () async {
      final page = await table.paginate(conn, pageSize: 71, columns: []);
      final list = await page.asStream().toList();
      expect(list, hasLength(8000));
      final row = list.firstWhere((r) =>
          r.id1 == '03' &&
          r.id2 != null &&
          r.id2![0] == 0 &&
          r.id2![1] == 4 &&
          r.id3 == '05');
      expect(row.payload, isNull);
    });

    test('paginate with filter', () async {
      final page = await table.paginate(conn,
          pageSize: 11, filter: ScanFilter()..id2$equalsTo([0, 4]));
      final list = await page.asStream().toList();
      expect(list, hasLength(400));
      final row = list.firstWhere((r) =>
          r.id1 == '03' &&
          r.id2 != null &&
          r.id2![0] == 0 &&
          r.id2![1] == 4 &&
          r.id3 == '05');
      expect(row.payload, [3, 4, 5]);
    });
  });
}
