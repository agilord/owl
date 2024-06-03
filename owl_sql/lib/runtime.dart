// ignore_for_file: one_member_abstracts

import 'package:collection/collection.dart';
import 'package:owl_sql/src/query_builder.dart';
import 'package:owl_sql/src/statements/init_table.dart';
import 'package:owl_sql/src/statements/crud.dart';
import 'package:page/page.dart' as page;
import 'package:postgres/postgres.dart';

import 'src/expr.dart';

export 'src/expr.dart';

int compareBytes(List<int> a, List<int> b, bool asc) {
  for (int i = 0; i < a.length && i < b.length; i++) {
    final x = a[i].compareTo(b[i]);
    if (x != 0) return asc ? x : -x;
  }
  final x = a.length.compareTo(b.length);
  return asc ? x : -x;
}

class Name {
  final String? schema;
  final String name;

  Name(this.name, {this.schema});

  static Name castFrom(Object value) {
    if (value is Name) {
      return value;
    }
    if (value is String) {
      return Name(value);
    }
    throw ArgumentError('Unknown Name value: $value');
  }

  late final fqn =
      [if (schema != null) schema, name].map((e) => '"$e"').join('.');
}

abstract class Columns {
  List<Column> get $all;
  late final $pks = List<Column>.unmodifiable($all.where((c) => c.isKey));
}

abstract class Relation<C extends Columns, K extends Key, R extends Row> {
  final Name name;
  final String? ref;

  Relation(/* String | Name */ name, {this.ref}) : name = Name.castFrom(name);

  C get columns;
  Expr<bool> whereFromKeyFn(C columns, K key);
  R rowFn(ResultRow row);

  List<Query> createInitQueries() {
    return doCreateInitQueries(this);
  }

  Future<void> init(Session session) async {
    for (final query in createInitQueries()) {
      await session.executeQuery(query);
    }
  }

  Future<R?> read(
    Session session,
    /* K | List  */ Object key, {
    List<Object>? Function(C columns)? columns,
  }) async {
    final list = await query(
      session,
      columns: columns,
      limit: 2,
      where: (c) => _whereFromKey(c, key),
    );
    return list.isEmpty ? null : list.single;
  }

  Expr<bool> _whereFromKey(C c, key) {
    if (key is K) {
      return whereFromKeyFn(c, key);
    }
    if (key is List) {
      return key
          .mapIndexed((index, e) => c.$pks[index].equalsTo(e))
          .reduce((value, element) => value & element);
    }
    throw ArgumentError('Unknown key: $key');
  }

  Future<List<R>> query(
    Session session, {
    List<Object>? Function(C columns)? columns,
    Expr<bool>? Function(C columns)? where,
    List<Object>? Function(C columns)? orderBy,
    int? limit,
  }) async {
    final query = doSelect(
      from: this,
      columns: columns == null ? null : columns(this.columns),
      where: where == null ? null : where(this.columns),
      orderBy: orderBy == null ? null : orderBy(this.columns),
      limit: limit,
    );
    final rs = await session.executeQuery(query);
    return rs.map(rowFn).toList();
  }

  Future<page.Page<R>> paginate(
    Session session, {
    List<Object>? Function(C columns)? columns,
    Expr<bool>? Function(C columns)? where,
    int pageSize = 100,
    K? startAfter,
  }) async {
    final page = _Page2<C, K, R>._(
        [], false, session, this, columns, where, pageSize, startAfter);
    return await page.next();
  }

  Future<int> insert(
    Session session,
    /* R | List<R> */ items, {
    List<Object>? Function(C columns)? columns,
    bool? upsert,
    bool? onConflictDoNothing,
  }) async {
    final query = doInsert(
      table: this,
      rows: (items is Iterable ? items : [items])
          .map((e) => e is R ? e.toColumnMap() : e),
      columns:
          (columns == null ? null : columns(this.columns)) ?? this.columns.$all,
      keyColumns: this.columns.$pks,
      upsert: upsert,
      onConflictDoNothing: onConflictDoNothing,
    );
    final rs = await session.executeQuery(query);
    return rs.affectedRows;
  }

  Future<int> update(
    Session session,
    /* K | List  */ Object key,
    List<Expr<void>> Function(C columns) set,
  ) async {
    return await updateAll(
      session,
      set: set,
      where: (c) => _whereFromKey(c, key),
      // limit: 1, - postgresql does not recognize limit
    );
  }

  Future<int> updateAll(
    Session session, {
    required List<Expr<void>> Function(C columns) set,
    Expr<bool>? Function(C columns)? where,
    int? limit,
  }) async {
    final query = doUpdate(
      table: this,
      set: set(columns),
      where: where == null ? null : where(this.columns),
      limit: limit,
    );
    final rs = await session.executeQuery(query);
    return rs.affectedRows;
  }

  Future<int> delete(
    Session session,
    /* K | List  */ Object key,
  ) async {
    return await deleteAll(
      session,
      where: (c) => _whereFromKey(c, key),
      // limit: 1, - postgresql does not recognize limit
    );
  }

  Future<int> deleteAll(
    Session session, {
    Expr<bool>? Function(C columns)? where,
    int? limit,
  }) async {
    final query = doDelete(
      from: this,
      where: where == null ? null : where(this.columns),
      limit: limit,
    );
    final rs = await session.executeQuery(query);
    return rs.affectedRows;
  }
}

class _Page2<C extends Columns, K extends Key, R extends Row> extends Object
    with page.PageMixin<R> {
  @override
  final bool isLast;
  @override
  final List<R> items;
  final Session _session;
  final Relation<C, K, R> _table;
  final List<Object>? Function(C columns)? _select;
  final Expr<bool>? Function(C columns)? _where;
  final int _limit;
  final K? _startAfter;

  _Page2._(
    this.items,
    this.isLast,
    this._session,
    this._table,
    this._select,
    this._where,
    this._limit,
    this._startAfter,
  );

  @override
  Future<page.Page<R>> next() async {
    if (isLast) {
      throw StateError('`next` called on last page.');
    }
    final rows = await _table.query(
      _session,
      limit: _limit + 1,
      columns: _expandedColumns,
      where: (t) {
        final keyAfter =
            _startAfter ?? (items.isEmpty ? null : items.last.toKey());
        final w = _where == null ? null : _where!(_table.columns);
        final values = <Expr<bool>>[
          if (keyAfter != null) _exprAfterKey(t, keyAfter.toList()),
          if (w != null) w,
        ];
        if (values.isEmpty) return null;
        if (values.length == 1) return values.single;
        return AndExpr(values);
      },
      orderBy: (t) => t.$pks,
    );
    final nextLast = rows.length <= _limit;
    final nextRows = nextLast ? rows : rows.sublist(0, _limit);
    return _Page2._(
      nextRows,
      nextLast,
      _session,
      _table,
      _select,
      _where,
      _limit,
      null as K?,
    );
  }

  List<Object>? _expandedColumns(C c) {
    if (_select == null) return null;
    final list = _select!(c);
    if (list == null) return null;
    return [
      ...c.$pks.where((c) => !list.contains(c) && !list.contains(c.name)),
      ...list,
    ];
  }

  Expr<bool> _exprAfterKey(Columns columns, List values) {
    final pks = columns.$pks;
    final exprs = <Expr<bool>>[];
    for (var i = 0; i < pks.length; i++) {
      final items = <Expr<bool>>[];
      for (var j = 0; j < i; j++) {
        items.add(pks[j].equalsTo(values[j]));
      }
      items.add(pks[i].greaterThan(values[i]));
      if (items.length > 1) {
        exprs.add(AndExpr(items));
      } else {
        exprs.add(items.single);
      }
    }
    return OrExpr(exprs);
  }

  @override
  Future close() async {}
}

abstract class Key {
  Map<String, Object?> toFieldMap();
  List toList();
}

abstract class Row {
  Map<String, Object?> toColumnMap();
  Key toKey();
}

extension SessionExt on Session {
  Future<Result> executeQuery(Query query) async {
    return await execute(
      Sql.indexed(query.sql, substitution: '?'),
      parameters: query.parameters,
    );
  }
}

enum Order {
  asc,
  desc,
}

abstract class Column<T extends Object> {
  final String? ref;
  final String name;
  final Type<T>? type;
  final bool isKey;
  final Order order;
  final String ddl;
  final String? family;

  Column(
    this.name, {
    this.ref,
    this.type,
    this.isKey = false,
    this.order = Order.asc,
    this.family,
    required String ddl,
    bool isUnique = false,
    String? defaultsTo,
  }) : ddl = [
          ddl,
          if (isUnique) 'UNIQUE',
          if (defaultsTo != null) 'DEFAULT $defaultsTo',
        ].join(' ');

  @override
  String toString() => name;

  late final fqn = [
    if (ref != null && ref!.isNotEmpty) ref!,
    '"$name"',
  ].join('.');

  Expr<bool> isNull() => ColumnConditionalExpr(this, 'IS NULL');
  Expr<bool> isNotNull() => ColumnConditionalExpr(this, 'IS NOT NULL');

  Object _value(T value) {
    return type == null ? value : type!.value(value);
  }

  Expr<bool> equalsTo(T value) =>
      ColumnConditionalExpr(this, '= ?', [_value(value)]);

  Expr<bool> greaterThan(T value) =>
      ColumnConditionalExpr(this, '> ?', [_value(value)]);

  Expr<bool> lessThan(T value) =>
      ColumnConditionalExpr(this, '< ?', [_value(value)]);

  Expr<void> set(T value) => ColumnSetExpr(this, [_value(value)]);
}

class BoolColumn extends Column<bool> {
  BoolColumn(
    super.name, {
    super.ref,
    super.isKey,
  }) : super(
          ddl: 'BOOL',
          type: Type.boolean,
        );
}

class BigintColumn extends Column<int> {
  BigintColumn(
    super.name, {
    super.ref,
    super.isKey,
  }) : super(
          ddl: 'BIGINT',
          type: Type.bigInteger,
        );
}

class ByteaColumn extends Column<List<int>> {
  ByteaColumn(
    super.name, {
    super.ref,
    super.isKey,
  }) : super(
          ddl: 'BYTEA',
          type: Type.byteArray,
        );
}

class DoubleColumn extends Column<double> {
  DoubleColumn(super.name, {super.ref})
      : super(
          ddl: 'DOUBLE PRECISION',
          type: Type.double,
        );
}

class JsonbColumn extends Column<Object> {
  JsonbColumn(super.name, {super.ref})
      : super(
          ddl: 'JSONB',
          type: Type.jsonb,
        );

  Expr<bool> matches(Object value) =>
      ColumnConditionalExpr(this, '@> ?', [_value(value)]);
}

class SmallintColumn extends Column<int> {
  SmallintColumn(
    super.name, {
    super.ref,
    super.isKey,
  }) : super(
          ddl: 'SMALLINT',
          type: Type.smallInteger,
        );
}

class TextColumn extends Column<String> {
  TextColumn(
    super.name, {
    super.ref,
    super.isKey,
  }) : super(
          ddl: 'TEXT',
          type: Type.text,
        );
}

class TimestampColumn extends Column<DateTime> {
  TimestampColumn(super.name, {super.ref})
      : super(
          ddl: 'TIMESTAMP',
          type: Type.timestamp,
        );
}

class UuidColumn extends Column<String> {
  UuidColumn(super.name, {super.ref, super.isKey})
      : super(
          ddl: 'UUID',
          type: Type.uuid,
        );
}

class TsvectorColumn extends Column<TsVector> {
  TsvectorColumn(super.name, {super.ref})
      : super(
          ddl: 'TSVECTOR',
          type: Type.tsvector,
        );

  Expr<bool> tsquery(TsQuery value) =>
      ColumnConditionalExpr(this, '@@ ?', [Type.tsquery.value(value)]);
}
