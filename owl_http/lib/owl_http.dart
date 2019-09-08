import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

import 'src/deyaml.dart';
import 'src/gen_api.dart';
import 'src/gen_client.dart';
import 'src/gen_messages.dart';
import 'src/gen_server.dart';
import 'src/model.dart';
import 'src/model_shortcuts.dart';

export 'src/model.dart';

Future generateHttpApi({
  String baseName,
  String inputFile,
  HttpApi httpApi,
  String outputDir,
}) async {
  if (inputFile != null) {
    assert(httpApi == null);
    final content = await File(inputFile).readAsString();
    Map<String, dynamic> map;
    if (inputFile.endsWith('.json')) {
      map = json.decode(content) as Map<String, dynamic>;
    } else {
      map = json.decode(json.encode(deyaml(loadYaml(content))))
          as Map<String, dynamic>;
    }
    normalizeModel(map);
    httpApi = HttpApi.fromJson(map);

    final methodOrder = ['GET', 'POST', 'PUT', 'DELETE'];
    httpApi.messages.sort((a, b) => a.name.compareTo(b.name));
    httpApi.endpoints.sort((a, b) {
      final px = a.path.compareTo(b.path);
      if (px != 0) return px;
      final moa = methodOrder.indexOf(a.method.toUpperCase());
      final mob = methodOrder.indexOf(b.method.toUpperCase());
      if (moa != mob) {
        if (mob == -1) return -1;
        if (moa == -1) return 1;
        return moa.compareTo(mob);
      }
      final mx = a.method.compareTo(b.method);
      if (mx != 0) return mx;
      return a.action.compareTo(b.action);
    });
    httpApi.endpoints.forEach((e) {
      e.responses.sort((a, b) => a.status.compareTo(b.status));
    });

    baseName ??= path.basename(inputFile).split('.').first;
    outputDir ??= path.dirname(inputFile);
  } else {
    ArgumentError.checkNotNull(baseName);
    ArgumentError.checkNotNull(httpApi);
    ArgumentError.checkNotNull(outputDir);
  }

  await File(path.join(outputDir, '$baseName.api.dart'))
      .writeAsString(generateApi(httpApi, baseName));

  await File(path.join(outputDir, '$baseName.client.dart'))
      .writeAsString(generateClient(httpApi, baseName));

  await File(path.join(outputDir, '$baseName.messages.dart'))
      .writeAsString(generateMessages(httpApi, baseName));

  await File(path.join(outputDir, '$baseName.server.dart'))
      .writeAsString(generateServer(httpApi, baseName));

  await Process.run('dartfmt', ['-w', outputDir]);
}
