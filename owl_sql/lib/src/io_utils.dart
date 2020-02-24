import 'dart:async';
import 'dart:io';

/// Returns the changed status.
Future<bool> writeIntoFile<T>(
    /*T | List<T>*/ items,
    File file,
    String Function(List<T> items) generate,
    bool format) async {
  final tables = items is List ? items as List<T> : [items].cast<T>();
  String oldContent;
  if (await file.exists()) {
    oldContent = await file.readAsString();
  } else {
    await file.parent.create(recursive: true);
  }
  final content = generate(tables);
  await file.writeAsString(content);
  if (format) {
    var executable = Platform.isWindows ? 'dartfmt.bat' : 'dartfmt';
    final p = Platform.executable.split(Platform.pathSeparator);
    if (p.last == 'dart' || p.last == 'dart.exe') {
      p.removeLast();
      p.add(executable);
      executable = p.join(Platform.pathSeparator);
    }
    final pr = await Process.run(executable, ['-w', file.path]);
    if (pr.exitCode != 0) {
      print('dartfmt exited with code $exitCode');
    }
  }
  final newContent = await file.readAsString();
  return oldContent != newContent;
}
