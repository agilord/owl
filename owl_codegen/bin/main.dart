// Copyright (c) 2016, Agilord. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:build_runner/build_runner.dart';
import 'package:source_gen/source_gen.dart';

import 'package:owl_codegen/config.dart';
import 'package:owl_codegen/http_generator.dart';
import 'package:owl_codegen/json_generator.dart';
import 'package:owl_codegen/sql_generator.dart';

Future main(List<String> args) async {
  final Config config = await parseArgs(args);
  final phases = new PhaseGroup();
  if (config.type == 'json' || config.type == 'all') {
    phases.newPhase().addAction(
        new GeneratorBuilder([new JsonGenerator()],
            generatedExtension: '.json.g.dart', isStandalone: true),
        new InputSet(config.package, config.globs));
  }
  if (config.type == 'pg_sql' || config.type == 'sql' || config.type == 'all') {
    phases.newPhase().addAction(
        new GeneratorBuilder([new PostgresSqlGenerator()],
            generatedExtension: '.pg_sql.g.dart', isStandalone: true),
        new InputSet(config.package, config.globs));
  }
  if (config.type == 'http' || config.type == 'all') {
    phases.newPhase().addAction(
        new GeneratorBuilder([new HttpWebappClientGenerator()],
            generatedExtension: '.http_webapp.g.dart', isStandalone: true),
        new InputSet(config.package, config.globs));
    phases.newPhase().addAction(
        new GeneratorBuilder([new HttpServerGenerator()],
            generatedExtension: '.http_server.g.dart', isStandalone: true),
        new InputSet(config.package, config.globs));
  }
  await build(phases);
}
