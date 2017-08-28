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
  final List<BuildAction> buildActions = [];
  if (config.type == 'json' || config.type == 'all') {
    buildActions.add(
      new BuildAction(
          new LibraryBuilder(new JsonGenerator(),
              generatedExtension: '.json.g.dart'),
          config.package,
          inputs: config.globs),
    );
  }
  if (config.type == 'pg_sql' || config.type == 'sql' || config.type == 'all') {
    buildActions.add(
      new BuildAction(
          new LibraryBuilder(new PostgresSqlGenerator(),
              generatedExtension: '.pg_sql.g.dart'),
          config.package,
          inputs: config.globs),
    );
  }
  if (config.type == 'http' || config.type == 'all') {
    buildActions.add(
      new BuildAction(
          new LibraryBuilder(new HttpWebappClientGenerator(),
              generatedExtension: '.http_webapp.g.dart'),
          config.package,
          inputs: config.globs),
    );
    buildActions.add(
      new BuildAction(
          new LibraryBuilder(new HttpServerGenerator(),
              generatedExtension: '.http_server.g.dart'),
          config.package,
          inputs: config.globs),
    );
  }
  await build(buildActions, deleteFilesByDefault: true);
}
