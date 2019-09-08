import 'package:yaml/yaml.dart';

dynamic deyaml(v) {
  if (v is YamlMap) return deyamlMap(v);
  if (v is YamlList) return deyamlList(v);
  return v;
}

Map<String, dynamic> deyamlMap(YamlMap map) {
  return Map.fromEntries(map.entries.map(
      (e) => MapEntry<String, dynamic>(e.key.toString(), deyaml(e.value))));
}

List deyamlList(YamlList list) {
  return list.map(deyaml).toList();
}
