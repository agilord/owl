// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'petstore.messages.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Error _$ErrorFromJson(Map<String, dynamic> json) {
  return Error(
    code: json['code'] as int,
    message: json['message'] as String,
  );
}

Map<String, dynamic> _$ErrorToJson(Error instance) => <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
    };

Pet _$PetFromJson(Map<String, dynamic> json) {
  return Pet(
    id: json['id'] as String,
    name: json['name'] as String,
  );
}

Map<String, dynamic> _$PetToJson(Pet instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };

Pets _$PetsFromJson(Map<String, dynamic> json) {
  return Pets(
    pets: (json['pets'] as List)
        ?.map((e) => e == null ? null : Pet.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$PetsToJson(Pets instance) => <String, dynamic>{
      'pets': instance.pets,
    };

UploadImageRs$created$Body _$UploadImageRs$created$BodyFromJson(
    Map<String, dynamic> json) {
  return UploadImageRs$created$Body(
    imageId: json['imageId'] as String,
  );
}

Map<String, dynamic> _$UploadImageRs$created$BodyToJson(
        UploadImageRs$created$Body instance) =>
    <String, dynamic>{
      'imageId': instance.imageId,
    };
