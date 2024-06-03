import 'package:owl_sql/runtime.dart';
import 'package:owl_sql/src/query_builder.dart';

List<Query> doCreateInitQueries(
  Relation relation, {
  bool isCockroachDB = false,
}) {
  // final hasFamily = table.columns.any((c) => c.hasFamily);
  // final pksWithFamily = table.columns.where((c) => c.isKey && c.hasFamily);
  // final firstPkFamily =
  //     pksWithFamily.isEmpty ? null : pksWithFamily.first.family;
  // final firstFamily = firstPkFamily ?? 'primary';
  // final familyColumns = <String, List<Column>>{};
  // for (final col in table.columns) {
  //   familyColumns
  //       .putIfAbsent(col.family ?? firstFamily, () => <Column>[])
  //       .add(col);
  // }
  // final families = StringBuffer();
  // if (_targetCockroachDB && hasFamily) {
  //   families.write(
  //       ', FAMILY "$firstFamily" (${familyColumns[firstFamily]!.map((c) => '"${c.name}"').join(', ')})');
  //   for (final f in familyColumns.keys) {
  //     if (f == firstFamily) continue;
  //     families.write(
  //         ', FAMILY "$f" (${familyColumns[f]!.map((c) => '"${c.name}"').join(', ')})');
  //   }
  // }

  // final familiesBlock = _targetCockroachDB && families.isNotEmpty
  //     ? '      if (_isCockroachDB) """$families""",\n'
  //     : '';

  final columns = relation.columns;
  final allCols = columns.$all.map((e) => '"${e.name}" ${e.ddl}').join(', ');
  final pks = columns.$pks.isEmpty
      ? ''
      : ', PRIMARY KEY (${columns.$pks.map((e) => [
            '"${e.name}"',
            if (isCockroachDB && e.order == Order.desc) 'DESC',
          ].join(' ')).join(', ')})';
  final table = relation.name.fqn;

  return [
    Query('CREATE TABLE IF NOT EXISTS $table ($allCols$pks);'),
    // TODO: CockroachDB family (column groups)
    // final emitFamily =
    //     _targetCockroachDB && ((col.family ?? firstFamily) != firstFamily);
    // final family = emitFamily
    //     ? 'if (_isCockroachDB) \' CREATE IF NOT EXISTS FAMILY "${col.family}"\',\n'
    //     : '';

    ...columns.$all.where((e) => !e.isKey).map((e) => Query(
        'ALTER TABLE $table ADD COLUMN IF NOT EXISTS "${e.name}" ${e.ddl};')),
  ];
}
