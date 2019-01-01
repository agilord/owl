String snakeToFieldName(String name) {
  final parts = name.split('_').where((s) => s.isNotEmpty).toList();
  for (int i = 1; i < parts.length; i++) {
    final p = parts[i];
    parts[i] = '${p.substring(0, 1).toUpperCase()}${p.substring(1)}';
  }
  return parts.join();
}
