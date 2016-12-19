// Copyright (c) 2016, Agilord. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library http_api_example;

import 'package:owl/annotation/http.dart';

/// Article data object.
@JsonClass()
class Article {
  /// title
  String title;

  /// description
  String description;
}

/// Status data object.
@JsonClass()
class Status {
  /// Success indicator.
  bool success;

  /// System message.
  String message;
}

/// API example.
@HttpApi(rootPath: '/api/content/v1', functions: const <HttpFn>[
  const HttpFn('/ping', name: 'ping'),
  const HttpFn('/greet/{greeting}/{name}', name: 'greet'),
  const HttpFn('/article/{id:int}', response: Article),
  const HttpFn('/article/{id:int}',
      method: HttpMethod.POST, request: Article, response: Status),
  const HttpFn('/article/{id:int}',
      method: HttpMethod.DELETE, response: Status),
])
abstract class ContentApi {}
