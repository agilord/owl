# Changelog

# 0.3.0

- Updated to Dart 2.

# 0.2.4

- Use lowercase JSON and UTF8 from dart:convert.

# 0.2.3

- Support annotated getters and setters for JSON generator.
- Fixed `analysis_options.yaml`.
- Upgrade dependencies.
- Suppress strong-mode warnings in generated code.

# 0.2.2

- Upgrade dependencies (`build`, `build_runner` and `source_gen`).

# 0.2.1+2

- Bugfix: exclude final or setter-only fields (e.g. hashCode).

# 0.2.1+1

- Bugfix in SQL: Table.create's `ifNotExists` should propagate `schema` and `table`.

# 0.2.1

- Added missing SQL type mapping.
- Add support for table name overrides (both for CRUD and for DDL).

# 0.2.0

- Added support for Postgresql schema prefixes (both for CRUD and for DDL).
- Better support for foreign key names, deterministically generating one if absent
  (it is a **breaking change** if you relied on the default behavior previously).
- DDL supports adding new columns incrementally.
  (Deleting columns should be the role of the database operator.)
