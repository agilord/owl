// Copyright (c) 2016, Agilord. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library sql_crud_example;

import 'package:owl/annotation/sql.dart';

///
@SqlTable(name: 'my_custom_entity')
class EntityMain {
  ///
  @SqlColumn(primaryKey: true)
  int entityId;

  ///
  DateTime ts;

  ///
  @SqlColumn(name: 'some_other_column')
  String field;

  ///
  @SqlColumn(sqlType: SqlType.uuid)
  String externalId;

  ///
  @Transient()
  String transientField;

  ///
  @SqlColumn(versionKey: true)
  int version;
}

///
@SqlTable()
class EntityDetail {
  ///
  @SqlColumn(primaryKey: true)
  @SqlForeignKey(reference: EntityMain, onDelete: FKConstraint.cascade)
  int entityId;

  ///
  @SqlColumn(primaryKey: true)
  int detailId;

  ///
  bool isActive;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EntityDetail &&
          runtimeType == other.runtimeType &&
          entityId == other.entityId &&
          detailId == other.detailId &&
          isActive == other.isActive;

  @override
  int get hashCode => entityId.hashCode ^ detailId.hashCode ^ isActive.hashCode;
}
