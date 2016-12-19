// Copyright (c) 2016, Agilord. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:yaml/yaml.dart' as yaml;

/// Common configuration object for code generators.
class Config {
  /// The codegen type.
  String type;

  /// The name of the target package.
  String package;

  /// The list of globs to identify target files.
  List<String> globs;
}

/// Parses the command line arguments and creates a config object.
Future<Config> parseArgs(List<String> args) async {
  String packageName;
  final List<String> globs = [];

  final ArgResults argv = (new ArgParser()
        ..addOption('type', abbr: 't')
        ..addOption('package', abbr: 'p')
        ..addOption('glob', abbr: 'g', allowMultiple: true, splitCommas: true))
      .parse(args);

  packageName = argv['package'];
  if (packageName == null) {
    packageName =
        yaml.loadYaml(new File('pubspec.yaml').readAsStringSync())['name'];
  }

  if (argv['glob'] != null) {
    globs.addAll(argv['glob']);
  }
  globs.addAll(argv.rest);
  if (globs.isEmpty) {
    globs.add('**/*.dart');
//    globs.addAll(new Directory('lib')
//        .listSync(recursive: true)
//        .where((fse) =>
//            fse is File &&
//            fse.path.endsWith('.dart') &&
//            !fse.path.endsWith('.g.dart'))
//        .map((fse) => fse.path));
  }

  return new Config()
    ..type = argv['type'] ?? 'all'
    ..package = packageName
    ..globs = globs;
}
