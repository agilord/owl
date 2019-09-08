// ignore_for_file: unused_import
// ignore_for_file: unused_element

import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'petstore.messages.g.dart';

@JsonSerializable()
class Error {
  final int code;
  final String message;

  Error({
    @required this.code,
    @required this.message,
  });

  factory Error.fromJson(Map<String, dynamic> json) => _$ErrorFromJson(json);

  Map<String, dynamic> toJson() => _$ErrorToJson(this);
}

@JsonSerializable()
class Pet {
  final String id;

  /// The nickname of the pet.
  final String name;

  Pet({
    @required this.id,
    @required this.name,
  });

  factory Pet.fromJson(Map<String, dynamic> json) => _$PetFromJson(json);

  Map<String, dynamic> toJson() => _$PetToJson(this);
}

/// List of pets.
@JsonSerializable()
class Pets {
  final List<Pet> pets;

  Pets({
    @required this.pets,
  });

  factory Pets.fromJson(Map<String, dynamic> json) => _$PetsFromJson(json);

  Map<String, dynamic> toJson() => _$PetsToJson(this);
}

@JsonSerializable()
class UploadImageRs$created$Body {
  final String imageId;

  UploadImageRs$created$Body({
    this.imageId,
  });

  factory UploadImageRs$created$Body.fromJson(Map<String, dynamic> json) =>
      _$UploadImageRs$created$BodyFromJson(json);

  Map<String, dynamic> toJson() => _$UploadImageRs$created$BodyToJson(this);
}
