import 'package:owl_sql/src/expr.dart';

class Query {
  final String sql;
  final List parameters;

  Query(this.sql, [this.parameters = const []]);
}

class QueryBuilder {
  final _sql = StringBuffer();
  final _parameters = [];

  void write(String text, [Iterable? parameters]) {
    _sql.write(text);
    if (parameters != null) {
      _parameters.addAll(parameters);
    }
  }

  void writeExpr(Expr expr) {
    expr.visit(_QueryExprVisitor(this));
  }

  Query toQuery() => Query(_sql.toString(), _parameters);
}

class _QueryExprVisitor extends ExprVisitor<void> {
  final QueryBuilder _builder;

  _QueryExprVisitor(this._builder);

  @override
  void visitAnd(AndExpr value) {
    for (var i = 0; i < value.items.length; i++) {
      if (i > 0) {
        _builder.write(' AND ');
      }
      _builder.write('(');
      value.items[i].visit(this);
      _builder.write(')');
    }
  }

  @override
  void visitOr(OrExpr value) {
    for (var i = 0; i < value.items.length; i++) {
      if (i > 0) {
        _builder.write(' OR ');
      }
      _builder.write('(');
      value.items[i].visit(this);
      _builder.write(')');
    }
  }

  @override
  void visitRaw(RawExpr value) {
    _builder.write(value.sql, value.parameters);
  }

  @override
  void visitColumnConditional(ColumnConditionalExpr value) {
    _builder.write(
        '"${value.column.name}" ${value.operatorSql}', value.parameters);
  }

  @override
  void visitColumnSet(ColumnSetExpr value) {
    _builder.write('"${value.column.name}" = ?', value.parameters);
  }
}
