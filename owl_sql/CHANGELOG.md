# Changelog

# 0.7.2

- Supports column-level `UNIQUE` constraints.

# 0.7.1

- Updated code to latest Dart SDK and pedantic lints.
- More support for CockroachDB (e.g. column families, ordered keys).

# 0.7.0

**Breaking changes**:

- Dart 2.2 compatible code (incl. using the optional `new` initialization).
- `${table.type}ConnectionFn` removed
- `Table.paginate` uses `PostgreSQLExecutionContext` (e.g. `Connection` or a pooling proxy).

**Updates**:
- Import package with prefixes.
- Additional mutable (non-database) fields for `Row` objects. 

# 0.6.3

- Support `limit` with `*Table.updateAll`.

# 0.6.2

- Support `limit` with `*Table.deleteAll`.

# 0.6.1

- Support for `SMALLINT` column.

# 0.6.0

- Complete rewrite of the SQL parts from `owl`/`owl_codegen` (`0.4`)
