import 'dart:async';
import 'dart:io';

import 'package:docker_process/containers/postgres.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:postgres/postgres.dart';
import 'package:test/test.dart';

class PostgresServer {
  final _port = Completer<int>();
  final _containerName = Completer<String>();

  Future<int> get port => _port.future;
  final String? _pgUser;
  final String? _pgPassword;

  PostgresServer({
    String? pgUser,
    String? pgPassword,
  })  : _pgUser = pgUser,
        _pgPassword = pgPassword;

  Future<Endpoint> endpoint() async => Endpoint(
        host: 'localhost',
        database: 'postgres',
        username: _pgUser ?? 'postgres',
        password: _pgPassword ?? 'postgres',
        port: await port,
      );

  Future<Connection> newConnection({
    ReplicationMode replicationMode = ReplicationMode.none,
    SslMode? sslMode,
  }) async {
    return Connection.open(
      await endpoint(),
      settings: ConnectionSettings(
        connectTimeout: Duration(seconds: 3),
        queryTimeout: Duration(seconds: 3),
        replicationMode: replicationMode,
        sslMode: sslMode,
      ),
    );
  }

  Future<void> kill() async {
    await Process.run('docker', ['kill', await _containerName.future]);
  }
}

@isTestGroup
void withPostgresServer(
  String name,
  void Function(PostgresServer server) fn, {
  Iterable<String>? initSqls,
  String? pgUser,
  String? pgPassword,
  String? pgHbaConfContent,
}) {
  group(name, () {
    final server = PostgresServer(
      pgUser: pgUser,
      pgPassword: pgPassword,
    );
    Directory? tempDir;

    setUpAll(() async {
      try {
        final port = await selectFreePort();
        String? pgHbaConfPath;
        if (pgHbaConfContent != null) {
          tempDir =
              await Directory.systemTemp.createTemp('postgres-dart-test-$port');
          pgHbaConfPath = p.join(tempDir!.path, 'pg_hba.conf');
          await File(pgHbaConfPath).writeAsString(pgHbaConfContent);
        }

        final containerName = 'postgres-dart-test-$port';
        await _startPostgresContainer(
          port: port,
          containerName: containerName,
          initSqls: initSqls ?? const <String>[],
          pgUser: pgUser,
          pgPassword: pgPassword,
          pgHbaConfPath: pgHbaConfPath,
        );

        server._containerName.complete(containerName);
        server._port.complete(port);
      } catch (e, st) {
        server._containerName.completeError(e, st);
        server._port.completeError(e, st);
        rethrow;
      }
    });

    tearDownAll(() async {
      final containerName = await server._containerName.future;
      await Process.run('docker', ['stop', containerName]);
      await Process.run('docker', ['kill', containerName]);
      await tempDir?.delete(recursive: true);
    });

    fn(server);
  });
}

Future<int> selectFreePort() async {
  final socket = await ServerSocket.bind(InternetAddress.anyIPv4, 0);
  final port = socket.port;
  await socket.close();
  return port;
}

Future<void> _startPostgresContainer({
  required int port,
  required String containerName,
  required Iterable<String> initSqls,
  String? pgUser,
  String? pgPassword,
  String? pgHbaConfPath,
}) async {
  final isRunning = await _isPostgresContainerRunning(containerName);
  if (isRunning) {
    return;
  }

  final configPath = p.join(Directory.current.path, 'test', 'pg_configs');

  final dp = await startPostgres(
    name: containerName,
    version: 'latest',
    pgPort: port,
    pgDatabase: 'postgres',
    pgUser: pgUser ?? 'postgres',
    pgPassword: pgPassword ?? 'postgres',
    cleanup: true,
    configurations: [
      // SSL settings
      'ssl=on',
      // The debian image includes a self-signed SSL cert that can be used:
      'ssl_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem',
      'ssl_key_file=/etc/ssl/private/ssl-cert-snakeoil.key',
    ],
    pgHbaConfPath: pgHbaConfPath ?? p.join(configPath, 'pg_hba.conf'),
    postgresqlConfPath: p.join(configPath, 'postgresql.conf'),
  );

  // Setup the database to support all kind of tests
  for (final stmt in initSqls) {
    final args = [
      'psql',
      '-c',
      stmt,
      '-U',
      'postgres',
    ];
    final res = await dp.exec(args);
    if (res.exitCode != 0) {
      final message =
          'Failed to setup PostgreSQL database due to the following error:\n'
          '${res.stderr}';
      throw ProcessException(
        'docker exec $containerName',
        args,
        message,
        res.exitCode,
      );
    }
  }
}

Future<bool> _isPostgresContainerRunning(String containerName) async {
  final pr = await Process.run(
    'docker',
    ['ps', '--format', '{{.Names}}'],
  );
  return pr.stdout
      .toString()
      .split('\n')
      .map((s) => s.trim())
      .contains(containerName);
}
