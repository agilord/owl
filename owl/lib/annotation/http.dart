// Copyright (c) 2016, Agilord. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

export 'json.dart';

/// Root of the API definition.
class HttpApi {
  /// The root path of the API.
  final String rootPath;

  /// HTTP functions in the API.
  final List<HttpFn> functions;

  /// Root of the API definition.
  const HttpApi({this.rootPath, this.functions});
}

/// HTTP function.
class HttpFn {
  /// The URL path.
  final String path;

  /// The HTTP method.
  final String method;

  /// The function name.
  final String name;

  /// The request object type.
  final Type request;

  /// The response object type.
  final Type response;

  /// HTTP function.
  const HttpFn(this.path,
      {this.method, this.name, this.request, this.response});
}

/// HTTP-related constants.
abstract class HttpMethod {
  /// HTTP GET.
  // ignore: constant_identifier_names
  static const String GET = 'GET';

  /// HTTP POST.
  // ignore: constant_identifier_names
  static const String POST = 'POST';

  /// HTTP DELETE.
  // ignore: constant_identifier_names
  static const String DELETE = 'DELETE';
}
