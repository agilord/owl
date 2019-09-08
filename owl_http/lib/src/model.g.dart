// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HttpApi _$HttpApiFromJson(Map<String, dynamic> json) {
  return HttpApi(
    endpoints: (json['endpoints'] as List)
        ?.map((e) =>
            e == null ? null : Endpoint.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    messages: (json['messages'] as List)
        ?.map((e) =>
            e == null ? null : Message.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$HttpApiToJson(HttpApi instance) => <String, dynamic>{
      'endpoints': instance.endpoints,
      'messages': instance.messages,
    };

Message _$MessageFromJson(Map<String, dynamic> json) {
  return Message(
    name: json['name'] as String,
    fields: (json['fields'] as List)
        ?.map(
            (e) => e == null ? null : Field.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    description: json['description'] as String,
  );
}

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'name': instance.name,
      'fields': instance.fields,
      'description': instance.description,
    };

Field _$FieldFromJson(Map<String, dynamic> json) {
  return Field(
    name: json['name'] as String,
    type: json['type'] as String,
    description: json['description'] as String,
    isRequired: json['required'] as bool,
  );
}

Map<String, dynamic> _$FieldToJson(Field instance) => <String, dynamic>{
      'name': instance.name,
      'type': instance.type,
      'description': instance.description,
      'required': instance.isRequired,
    };

Endpoint _$EndpointFromJson(Map<String, dynamic> json) {
  return Endpoint(
    method: json['method'] as String,
    path: json['path'] as String,
    action: json['action'] as String,
    description: json['description'] as String,
    query: (json['query'] as List)
        ?.map((e) =>
            e == null ? null : Parameter.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    headers: (json['headers'] as List)
        ?.map((e) =>
            e == null ? null : Parameter.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    body: json['body'] == null
        ? null
        : Body.fromJson(json['body'] as Map<String, dynamic>),
    responses: (json['responses'] as List)
        ?.map((e) =>
            e == null ? null : Response.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$EndpointToJson(Endpoint instance) => <String, dynamic>{
      'method': instance.method,
      'path': instance.path,
      'action': instance.action,
      'description': instance.description,
      'query': instance.query,
      'headers': instance.headers,
      'body': instance.body,
      'responses': instance.responses,
    };

Body _$BodyFromJson(Map<String, dynamic> json) {
  return Body(
    ref: json['ref'] as String,
    inline: json['inline'] == null
        ? null
        : Message.fromJson(json['inline'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$BodyToJson(Body instance) => <String, dynamic>{
      'ref': instance.ref,
      'inline': instance.inline,
    };

Response _$ResponseFromJson(Map<String, dynamic> json) {
  return Response(
    status: json['status'] as int,
    description: json['description'] as String,
    name: json['name'] as String,
    headers: (json['headers'] as List)
        ?.map((e) =>
            e == null ? null : Parameter.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    body: json['body'] == null
        ? null
        : Body.fromJson(json['body'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$ResponseToJson(Response instance) => <String, dynamic>{
      'status': instance.status,
      'description': instance.description,
      'name': instance.name,
      'headers': instance.headers,
      'body': instance.body,
    };

Parameter _$ParameterFromJson(Map<String, dynamic> json) {
  return Parameter(
    name: json['name'] as String,
    type: json['type'] as String,
    description: json['description'] as String,
  );
}

Map<String, dynamic> _$ParameterToJson(Parameter instance) => <String, dynamic>{
      'name': instance.name,
      'type': instance.type,
      'description': instance.description,
    };
