import 'dart:async';
import 'dart:io';

/// Returns the changed status.
Future<bool> writeIntoFile<T>(/*T | List<T>*/ items, File file,
    String Function(List<T> items) generate, bool format) async {
  final tables = items is List ? items as List<T> : [items].cast<T>();
  String? oldContent;
  if (await file.exists()) {
    oldContent = await file.readAsString();
  } else {
    await file.parent.create(recursive: true);
  }
  final content = generate(tables);
  await file.writeAsString(content);
  if (format) {
    final pr =
        await Process.run(Platform.resolvedExecutable, ['format', file.path]);
    if (pr.exitCode != 0) {
      print('dart format exited with code $exitCode');
    }
  }
  final newContent = await file.readAsString();
  return oldContent != newContent;
}
