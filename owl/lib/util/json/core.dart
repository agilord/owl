// Copyright (c) 2016, Agilord. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:collection' show LinkedHashMap;

/// Builds a map where null values are omitted.
class MapBuilder {
  Map<String, dynamic> _map;

  /// When [ordered] is set, the map will keep the order of the keys.
  MapBuilder({bool ordered: false}) {
    _map = ordered ? new LinkedHashMap() : new Map();
  }

  /// Put a new [key] - [value] pair into the map. Null [value]s are omitted.
  void put(String key, dynamic value) {
    if (value == null) return;
    _map[key] = value;
  }

  // TODO: clear the map or handle subsequent calls.
  /// Returns the map.
  Map<String, dynamic> toMap() => _map;
}

/// Mapping utility for DateTime
abstract class DateTimeMapper {
  /// Maps a [DateTime] to String.
  static String map(DateTime date) => date?.toUtc()?.toIso8601String();

  /// Parses a DateTime object.
  static DateTime parse(dynamic value) {
    if (value is String) return DateTime.parse(value).toUtc();
    if (value is DateTime) return value.toUtc();
    return null;
  }
}

/// Mapping utility for UUIDs
abstract class UuidMapper {
  /// Maps a [uuid] object (noop).
  static String map(String uuid) => uuid;

  /// Parses a UUID object. Database usually returns it with dashes, removing
  /// them creates a normalized version that is comparable with values from
  /// other sources.
  static String parse(dynamic value) {
    if (value is String) return value.replaceAll('-', '');
    return null;
  }
}
