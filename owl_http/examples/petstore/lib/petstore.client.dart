// ignore_for_file: unused_import
// ignore_for_file: unused_element

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'petstore.api.dart';

class PetstoreHttpClient implements PetstoreApi {
  final http.Client _client;
  final Uri _baseUri;
  String _baseUriPath;

  PetstoreHttpClient(this._client, url)
      : _baseUri = url is Uri ? url : Uri.parse(url as String);

  String _path(String path) {
    if (_baseUriPath == null) {
      final bup = _baseUri.path;
      _baseUriPath = bup.endsWith('/') ? bup.substring(0, bup.length - 1) : bup;
    }
    return '$_baseUriPath$path';
  }

  @override
  Future<DownloadImageRs> downloadImage(DownloadImageRq rq) async {
    final hrq = http.StreamedRequest(
        'GET',
        _baseUri.replace(
          path: _path('/download/${rq.petId}'),
        ));
    final f = _client.send(hrq);
    hrq.sink.close();
    final rs = await f;
    if (rs.statusCode == 200) {
      return DownloadImageRs.ok(
        body: rs.stream,
      );
    }
    if (rs.statusCode == 404) {
      return DownloadImageRs.notFound(
        body: Error.fromJson(json.decode(await rs.stream.bytesToString())
            as Map<String, dynamic>),
      );
    }
    throw Exception('Unknown server response: ${rs.statusCode}}');
  }

  @override
  Future<ListPetsRs> listPets(ListPetsRq rq) async {
    final hrq = http.StreamedRequest(
        'GET',
        _baseUri.replace(
          path: _path('/pets'),
          queryParameters: _queryParameters({
            if (rq.limit != null) 'limit': rq.limit.toString(),
          }),
        ));
    final f = _client.send(hrq);
    hrq.sink.close();
    final rs = await f;
    if (rs.statusCode == 200) {
      return ListPetsRs.ok(
        xNext: rs.headers['x-next'],
        body: Pets.fromJson(json.decode(await rs.stream.bytesToString())
            as Map<String, dynamic>),
      );
    }
    throw Exception('Unknown server response: ${rs.statusCode}}');
  }

  @override
  Future<CreatePetsRs> createPets(CreatePetsRq rq) async {
    final hrq = http.StreamedRequest(
        'POST',
        _baseUri.replace(
          path: _path('/pets'),
        ));
    final f = _client.send(hrq);
    if (rq.body != null) {
      hrq.sink.add(utf8.encode(json.encode(rq.body.toJson())));
    }
    hrq.sink.close();
    final rs = await f;
    if (rs.statusCode == 201) {
      return CreatePetsRs.created();
    }
    if (rs.statusCode == 409) {
      return CreatePetsRs.conflict(
        body: Error.fromJson(json.decode(await rs.stream.bytesToString())
            as Map<String, dynamic>),
      );
    }
    throw Exception('Unknown server response: ${rs.statusCode}}');
  }

  @override
  Future<GetPetRs> getPet(GetPetRq rq) async {
    final hrq = http.StreamedRequest(
        'GET',
        _baseUri.replace(
          path: _path('/pets/${rq.petId}'),
        ));
    final f = _client.send(hrq);
    hrq.sink.close();
    final rs = await f;
    if (rs.statusCode == 200) {
      return GetPetRs.ok(
        body: Pet.fromJson(json.decode(await rs.stream.bytesToString())
            as Map<String, dynamic>),
      );
    }
    if (rs.statusCode == 404) {
      return GetPetRs.notFound(
        body: Error.fromJson(json.decode(await rs.stream.bytesToString())
            as Map<String, dynamic>),
      );
    }
    throw Exception('Unknown server response: ${rs.statusCode}}');
  }

  @override
  Future<UploadImageRs> uploadImage(UploadImageRq rq) async {
    final hrq = http.StreamedRequest(
        'POST',
        _baseUri.replace(
          path: _path('/upload/${rq.petId}'),
        ));
    hrq.headers['content-type'] = rq.contentType?.toString();
    final f = _client.send(hrq);
    if (rq.body != null) {
      await for (final bytes in rq.body) {
        hrq.sink.add(bytes);
      }
    }
    hrq.sink.close();
    final rs = await f;
    if (rs.statusCode == 201) {
      return UploadImageRs.created(
        body: UploadImageRs$created$Body.fromJson(json
            .decode(await rs.stream.bytesToString()) as Map<String, dynamic>),
      );
    }
    if (rs.statusCode == 404) {
      return UploadImageRs.notFound(
        body: Error.fromJson(json.decode(await rs.stream.bytesToString())
            as Map<String, dynamic>),
      );
    }
    throw Exception('Unknown server response: ${rs.statusCode}}');
  }
}

Map<String, String> _queryParameters(Map<String, String> map) {
  return map.isEmpty ? null : map;
}
