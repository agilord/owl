# Changelog

# 0.1.2

- Added support for Postgresql schema prefixes (both for CRUD and for DDL).
- Better support for foreign key names, deterministically generating one if absent
  (may be a **breaking change** if you relied on the default behavior previously).
