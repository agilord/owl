// Copyright (c) 2016, Agilord. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:html';

/// Returns the request headers to set on the request.
typedef Map<String, String> HeaderCallback(String function);

/// Calls the HTTP server and handles common patterns.
Future<HttpRequest> callHttpServer(String method, String path,
    {dynamic body, Map<String, String> headers}) {
  final Completer<HttpRequest> c = new Completer<HttpRequest>();
  final HttpRequest request = new HttpRequest();
  request.open(method, path);
  if (headers != null) {
    headers.forEach((String name, String value) {
      request.setRequestHeader(name, value);
    });
  }
  request.onLoad.first.then((ProgressEvent event) {
    if (!c.isCompleted) c.complete(request);
  });
  request.onError.first.then((event) {
    if (!c.isCompleted) c.completeError(event);
  });
  if (body != null) {
    request.send(body);
  }
  return c.future;
}
