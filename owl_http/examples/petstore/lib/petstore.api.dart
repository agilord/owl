// ignore_for_file: unused_import
// ignore_for_file: unused_element

import 'petstore.messages.dart';
export 'petstore.messages.dart';

abstract class PetstoreApi {
  Future<DownloadImageRs> downloadImage(DownloadImageRq rq);
  Future<ListPetsRs> listPets(ListPetsRq rq);
  Future<CreatePetsRs> createPets(CreatePetsRq rq);
  Future<GetPetRs> getPet(GetPetRq rq);
  Future<UploadImageRs> uploadImage(UploadImageRq rq);
}

class DownloadImageRq {
  final String petId;

  DownloadImageRq({
    this.petId,
  });
}

class DownloadImageRs {
  final DownloadImageRs$ok ok;
  final DownloadImageRs$notFound notFound;
  DownloadImageRs.ok({Stream<List<int>> body})
      : ok = DownloadImageRs$ok(body: body),
        notFound = null;
  DownloadImageRs.notFound({Error body})
      : notFound = DownloadImageRs$notFound(body: body),
        ok = null;
}

class DownloadImageRs$ok {
  final Stream<List<int>> body;

  DownloadImageRs$ok({
    this.body,
  });
}

class DownloadImageRs$notFound {
  final Error body;

  DownloadImageRs$notFound({
    this.body,
  });
}

class ListPetsRq {
  /// How many items to return at one time (max 100)
  final int limit;

  ListPetsRq({
    this.limit,
  });
}

class ListPetsRs {
  final ListPetsRs$ok ok;
  ListPetsRs.ok({String xNext, Pets body})
      : ok = ListPetsRs$ok(xNext: xNext, body: body);
}

class ListPetsRs$ok {
  /// A link to the next page of responses
  final String xNext;

  final Pets body;

  ListPetsRs$ok({
    this.xNext,
    this.body,
  });
}

class CreatePetsRq {
  final Pet body;

  CreatePetsRq({
    this.body,
  });
}

class CreatePetsRs {
  final CreatePetsRs$created created;
  final CreatePetsRs$conflict conflict;
  CreatePetsRs.created()
      : created = CreatePetsRs$created(),
        conflict = null;
  CreatePetsRs.conflict({Error body})
      : conflict = CreatePetsRs$conflict(body: body),
        created = null;
}

class CreatePetsRs$created {
  CreatePetsRs$created();
}

class CreatePetsRs$conflict {
  final Error body;

  CreatePetsRs$conflict({
    this.body,
  });
}

class GetPetRq {
  final String petId;

  GetPetRq({
    this.petId,
  });
}

class GetPetRs {
  final GetPetRs$ok ok;
  final GetPetRs$notFound notFound;
  GetPetRs.ok({Pet body})
      : ok = GetPetRs$ok(body: body),
        notFound = null;
  GetPetRs.notFound({Error body})
      : notFound = GetPetRs$notFound(body: body),
        ok = null;
}

class GetPetRs$ok {
  final Pet body;

  GetPetRs$ok({
    this.body,
  });
}

class GetPetRs$notFound {
  final Error body;

  GetPetRs$notFound({
    this.body,
  });
}

class UploadImageRq {
  final String contentType;

  final String petId;

  final Stream<List<int>> body;

  UploadImageRq({
    this.contentType,
    this.petId,
    this.body,
  });
}

class UploadImageRs {
  final UploadImageRs$created created;
  final UploadImageRs$notFound notFound;
  UploadImageRs.created({UploadImageRs$created$Body body})
      : created = UploadImageRs$created(body: body),
        notFound = null;
  UploadImageRs.notFound({Error body})
      : notFound = UploadImageRs$notFound(body: body),
        created = null;
}

class UploadImageRs$created {
  final UploadImageRs$created$Body body;

  UploadImageRs$created({
    this.body,
  });
}

class UploadImageRs$notFound {
  final Error body;

  UploadImageRs$notFound({
    this.body,
  });
}
