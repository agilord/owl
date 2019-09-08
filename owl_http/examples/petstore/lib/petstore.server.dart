// ignore_for_file: unused_import
// ignore_for_file: unused_element

import 'dart:convert';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_router/shelf_router.dart';

import 'petstore.api.dart';

part 'petstore.server.g.dart';

class PetstoreHttpService {
  final PetstoreApi _api;
  PetstoreHttpService(this._api);

  Router get router => _$PetstoreHttpServiceRouter(this);
  @Route('GET', '/download/<petId>')
  Future<shelf.Response> downloadImage(
      shelf.Request request, String petId) async {
    final rq = DownloadImageRq(
      petId: petId,
    );
    final rs = await _api.downloadImage(rq);
    if (rs.ok != null) {
      return shelf.Response(
        200,
        body: rs.ok.body,
      );
    }
    if (rs.notFound != null) {
      return shelf.Response(
        404,
        body: json.encode(rs.notFound.body.toJson()),
      );
    }
    return shelf.Response.internalServerError();
  }

  @Route('GET', '/pets')
  Future<shelf.Response> listPets(shelf.Request request) async {
    final rq = ListPetsRq(
      limit: int.tryParse(request.requestedUri.queryParameters['limit'] ?? ''),
    );
    final rs = await _api.listPets(rq);
    if (rs.ok != null) {
      return shelf.Response(
        200,
        headers: {
          'x-next': rs.ok.xNext,
        },
        body: json.encode(rs.ok.body.toJson()),
      );
    }
    return shelf.Response.internalServerError();
  }

  @Route('POST', '/pets')
  Future<shelf.Response> createPets(shelf.Request request) async {
    final rq = CreatePetsRq(
      body: Pet.fromJson(
          json.decode(await request.readAsString()) as Map<String, dynamic>),
    );
    final rs = await _api.createPets(rq);
    if (rs.created != null) {
      return shelf.Response(201);
    }
    if (rs.conflict != null) {
      return shelf.Response(
        409,
        body: json.encode(rs.conflict.body.toJson()),
      );
    }
    return shelf.Response.internalServerError();
  }

  @Route('GET', '/pets/<petId>')
  Future<shelf.Response> getPet(shelf.Request request, String petId) async {
    final rq = GetPetRq(
      petId: petId,
    );
    final rs = await _api.getPet(rq);
    if (rs.ok != null) {
      return shelf.Response(
        200,
        body: json.encode(rs.ok.body.toJson()),
      );
    }
    if (rs.notFound != null) {
      return shelf.Response(
        404,
        body: json.encode(rs.notFound.body.toJson()),
      );
    }
    return shelf.Response.internalServerError();
  }

  @Route('POST', '/upload/<petId>')
  Future<shelf.Response> uploadImage(
      shelf.Request request, String petId) async {
    final rq = UploadImageRq(
      contentType: request.headers['content-type'],
      petId: petId,
      body: request.read(),
    );
    final rs = await _api.uploadImage(rq);
    if (rs.created != null) {
      return shelf.Response(
        201,
        body: json.encode(rs.created.body.toJson()),
      );
    }
    if (rs.notFound != null) {
      return shelf.Response(
        404,
        body: json.encode(rs.notFound.body.toJson()),
      );
    }
    return shelf.Response.internalServerError();
  }
}
