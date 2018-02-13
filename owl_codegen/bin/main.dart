// Copyright (c) 2016, Agilord. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:build_config/build_config.dart';
import 'package:build_runner/build_runner.dart';
import 'package:source_gen/source_gen.dart';

import 'package:owl_codegen/config.dart';
import 'package:owl_codegen/http_generator.dart';
import 'package:owl_codegen/json_generator.dart';
import 'package:owl_codegen/sql_generator.dart';

Future main(List<String> args) async {
  final Config config = await parseArgs(args);
  final List<BuilderApplication> buildApplications = [];
  if (config.type == 'json' || config.type == 'all') {
    buildApplications.add(applyToRoot(
      new LibraryBuilder(new JsonGenerator(),
          generatedExtension: '.json.g.dart'),
      generateFor: new InputSet(include: config.globs),
    ));
  }
  if (config.type == 'pg_sql' || config.type == 'sql' || config.type == 'all') {
    buildApplications.add(
      applyToRoot(
          new LibraryBuilder(new PostgresSqlGenerator(),
              generatedExtension: '.pg_sql.g.dart'),
          generateFor: new InputSet(include: config.globs)),
    );
  }
  if (config.type == 'http' || config.type == 'all') {
    buildApplications.add(
      applyToRoot(
          new LibraryBuilder(new HttpWebappClientGenerator(),
              generatedExtension: '.http_webapp.g.dart'),
          generateFor: new InputSet(include: config.globs)),
    );
    buildApplications.add(
      applyToRoot(
          new LibraryBuilder(new HttpServerGenerator(),
              generatedExtension: '.http_server.g.dart'),
          generateFor: new InputSet(include: config.globs)),
    );
  }
  await build(buildApplications, deleteFilesByDefault: true);
}
