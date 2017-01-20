// Copyright (c) 2016, Agilord. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

/// The annotated class will have mapper and parser methods generated.
/// By default all of the fields will be included.
class JsonClass {
  /// Whether the key order in the output map is important. If set, the
  /// generator will follow the order of the fields as defined in the class.
  final bool ordered;

  /// Generate mapper methods for the class.
  const JsonClass({this.ordered: false});
}

/// Override default mapper properties for the given field.
class JsonField {
  /// The key for the mapping. By default it is the field's name.
  final String key;

  /// Indicates that they field (especially if it is `List` or `Map`) accepts
  /// the native JSON values without additional mapping.
  final bool native;

  /// Override mapper methods for the field.
  const JsonField({this.key, this.native: false});
}

/// Marks a field transient, not part of the mapping.
class Transient {
  /// Field should not be part of the mapping / serialization.
  const Transient();
}
