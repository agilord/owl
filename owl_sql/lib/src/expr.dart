import 'package:owl_sql/runtime.dart';

abstract class Expr<E> {
  static Expr<bool> and(Iterable<Expr<bool>> items) => AndExpr(items);
  static Expr<bool> or(Iterable<Expr<bool>> items) => OrExpr(items);

  T visit<T>(ExprVisitor<T> visitor) => visitor.visitExpr(this);
}

abstract class ExprVisitor<T> {
  T visitExpr(Expr value) =>
      throw UnimplementedError('${value.runtimeType} is not implemented');

  T visitAnd(AndExpr value) => visitExpr(value);
  T visitOr(OrExpr value) => visitExpr(value);
  T visitRaw(RawExpr value) => visitExpr(value);
  T visitColumnConditional(ColumnConditionalExpr value) => visitExpr(value);
  T visitColumnSet(ColumnSetExpr value) => visitExpr(value);
}

extension BoolExprExt on Expr<bool> {
  Expr<bool> operator &(Expr<bool> other) => AndExpr([this, other]);
  Expr<bool> operator |(Expr<bool> other) => OrExpr([this, other]);
}

class AndExpr extends Expr<bool> {
  final List<Expr<bool>> items;

  AndExpr(Iterable<Expr<bool>> items)
      : items = List.unmodifiable(items.fold<List<Expr<bool>>>([], (p, e) {
          if (e is AndExpr) {
            p.addAll(e.items);
          } else {
            p.add(e);
          }
          return p;
        }));

  @override
  T visit<T>(ExprVisitor<T> visitor) => visitor.visitAnd(this);
}

class OrExpr extends Expr<bool> {
  final List<Expr<bool>> items;

  OrExpr(Iterable<Expr<bool>> items)
      : items = List.unmodifiable(items.fold<List<Expr<bool>>>([], (p, e) {
          if (e is OrExpr) {
            p.addAll(e.items);
          } else {
            p.add(e);
          }
          return p;
        }));

  @override
  T visit<T>(ExprVisitor<T> visitor) => visitor.visitOr(this);
}

class RawExpr<E> extends Expr<E> {
  final String sql;
  final List? parameters;

  RawExpr(this.sql, [this.parameters]);

  @override
  T visit<T>(ExprVisitor<T> visitor) => visitor.visitRaw(this);
}

class ColumnConditionalExpr extends Expr<bool> {
  final Column column;
  final String operatorSql;
  final List? parameters;

  ColumnConditionalExpr(this.column, this.operatorSql, [this.parameters]);

  @override
  T visit<T>(ExprVisitor<T> visitor) => visitor.visitColumnConditional(this);
}

class ColumnSetExpr extends Expr<bool> {
  final Column column;
  final List? parameters;

  ColumnSetExpr(this.column, this.parameters);

  @override
  T visit<T>(ExprVisitor<T> visitor) => visitor.visitColumnSet(this);
}
