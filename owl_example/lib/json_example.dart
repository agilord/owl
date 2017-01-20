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

  @JsonField(native: true)
  Map map;
}
