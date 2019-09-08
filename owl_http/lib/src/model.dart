import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'model.g.dart';

@JsonSerializable()
class HttpApi {
  final List<Endpoint> endpoints;
  final List<Message> messages;

  HttpApi({
    @required this.endpoints,
    @required this.messages,
  });

  factory HttpApi.fromJson(Map<String, dynamic> json) =>
      _$HttpApiFromJson(json);

  Map<String, dynamic> toJson() => _$HttpApiToJson(this);
}

@JsonSerializable()
class Message {
  final String name;
  final List<Field> fields;
  final String description;

  Message({
    @required this.name,
    @required this.fields,
    this.description,
  });

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);
}

@JsonSerializable()
class Field {
  final String name;
  final String type;
  final String description;

  @JsonKey(name: 'required')
  final bool isRequired;

  Field({
    @required this.name,
    this.type,
    this.description,
    this.isRequired,
  });

  factory Field.fromJson(Map<String, dynamic> json) => _$FieldFromJson(json);

  Map<String, dynamic> toJson() => _$FieldToJson(this);
}

@JsonSerializable()
class Endpoint {
  final String method;
  final String path;
  final String action;
  final String description;
  final List<Parameter> query;
  final List<Parameter> headers;
  final Body body;
  final List<Response> responses;

  Endpoint({
    @required this.method,
    @required this.path,
    @required this.action,
    this.description,
    this.query,
    this.headers,
    this.body,
    @required this.responses,
  });

  factory Endpoint.fromJson(Map<String, dynamic> json) =>
      _$EndpointFromJson(json);

  Map<String, dynamic> toJson() => _$EndpointToJson(this);
}

@JsonSerializable()
class Body {
  final String ref;
  final Message inline;

  Body({
    this.ref,
    this.inline,
  });

  factory Body.fromJson(Map<String, dynamic> json) => _$BodyFromJson(json);

  Map<String, dynamic> toJson() => _$BodyToJson(this);
}

@JsonSerializable()
class Response {
  final int status;
  final String description;
  final String name;
  final List<Parameter> headers;
  final Body body;

  Response({
    @required this.status,
    this.description,
    this.name,
    this.headers,
    this.body,
  });

  factory Response.fromJson(Map<String, dynamic> json) =>
      _$ResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ResponseToJson(this);
}

@JsonSerializable()
class Parameter {
  final String name;
  final String type;
  final String description;

  Parameter({
    @required this.name,
    this.type,
    this.description,
  });

  factory Parameter.fromJson(Map<String, dynamic> json) =>
      _$ParameterFromJson(json);

  Map<String, dynamic> toJson() => _$ParameterToJson(this);
}
