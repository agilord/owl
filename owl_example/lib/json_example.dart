// Copyright (c) 2016, Agilord. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library json_mapping_example;

import 'package:owl/annotation/json.dart';

/// Example entity class.
@JsonClass(ordered: true)
class Entity {
  ///
  String stringProperty;

  ///
  int intProperty;

  ///
  List<int> intList;

  ///
  DateTime dateTimeProperty;

  ///
  List<DateTime> dateTimeList;

  ///
  @JsonField(key: 'alt_name')
  String alternativeName;

  ///
  List<ChildClass> children;

  ///
  int get virtualField => null;

  ///
  set virtualField(int value) {}
}

///
@JsonClass()
class ChildClass {
  ///
  String id;

  ///
  ChildClass left;

  ///
  ChildClass right;

  ///
  @Transient()
  int transientField;

  ///
  @JsonField(native: true)
  Map<dynamic, dynamic> map;

  @Transient()
  Map<dynamic, dynamic> _virtualField;

  ///
  @JsonField(native: true)
  // ignore: unnecessary_getters_setters
  Map<dynamic, dynamic> get virtualNativeField => _virtualField;

  ///
  // It is enough to annotate either the getter or setter.
  // ignore: unnecessary_getters_setters
  set virtualNativeField(Map<dynamic, dynamic> value) => _virtualField = value;
}

///
@JsonClass()
class WithEqualsAndHash {
  ///
  int id;

  ///
  String text;

  ///
  WithEqualsAndHash({this.id, this.text});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WithEqualsAndHash &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          text == other.text;

  @override
  int get hashCode => id.hashCode ^ text.hashCode;
}
