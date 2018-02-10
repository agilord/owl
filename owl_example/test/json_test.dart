// Copyright (c) 2016, Agilord. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';

import 'package:owl_example/json_example.dart';
import 'package:owl_example/json_example.json.g.dart';

void main() {
  group('Map tests', () {
    final String exampleJson = '{"intList":[4,5,6],'
        '"dateTimeList":["2011-10-09T08:07:00.000Z"],'
        '"children":[{"id":"2", "virtualNativeField":{"key":"value"}}]}';

    test('From object to JSON.', () {
      final Entity entity = new Entity()
        ..intList = <int>[4, 5, 6]
        ..dateTimeList = <DateTime>[new DateTime.utc(2011, 10, 9, 8, 7)]
        ..children = <ChildClass>[
          new ChildClass()
            ..transientField = 3
            ..id = '2'
            ..virtualNativeField = {'key': 'value'}
        ];
      final String json = EntityMapper.toJson(entity);
      expect(json, exampleJson);
    });

    test('From JSON to object.', () {
      final Entity entity = EntityMapper.fromJson(exampleJson);
      expect(entity.intList, <int>[4, 5, 6]);
      expect(entity.dateTimeList, isNotNull);
      expect(entity.dateTimeList, isNotEmpty);
      expect(entity.dateTimeList.first.year, 2011);
      expect(entity.dateTimeList.first.month, 10);
      expect(entity.dateTimeList.first.day, 9);
      expect(entity.dateTimeList.first.hour, 8);
      expect(entity.dateTimeList.first.minute, 7);
      expect(entity.children.first.id, '2');
      expect(entity.children.virtualNativeField['key'], 'value');
    });
  });
}
