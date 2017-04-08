# Changelog

- Added missing SQL type mapping.

# 0.2.0

- Added support for Postgresql schema prefixes (both for CRUD and for DDL).
- Better support for foreign key names, deterministically generating one if absent
  (it is a **breaking change** if you relied on the default behavior previously).
- DDL supports adding new columns incrementally.
  (Deleting columns should be the role of the database operator.)
