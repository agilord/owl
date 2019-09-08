import 'dart:io';

import 'package:test/test.dart';

import 'package:owl_http/owl_http.dart';

final _generateGolden = false;

main() {
  group('petstore', () {
    Directory dir;

    setUpAll(() async {
      dir = await Directory.systemTemp.createTemp();
    });

    tearDownAll(() async {
      await dir.delete(recursive: true);
    });

    test('generate', () async {
      await generateHttpApi(
        inputFile: 'test/petstore/spec.yaml',
        outputDir: dir.path,
        baseName: 'petstore',
      );
    });

    test('match files', () async {
      final golderDir = Directory('examples/petstore/lib');
      final files =
          await dir.list().where((f) => f is File).cast<File>().toList();
      if (_generateGolden) {
        await golderDir.create(recursive: true);
        for (File f in files) {
          await f.copy('${golderDir.path}/${f.path.split('/').last}');
        }
        throw Exception('_generateGolden is set to true');
      } else {
        for (File f in files) {
          final goldenFile = File('${golderDir.path}/${f.path.split('/').last}');
          final expected = await goldenFile.readAsString();
          final actual = await f.readAsString();
          expect(expected, actual);
        }
      }
    });
  });
}
