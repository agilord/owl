// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'petstore.server.dart';

// **************************************************************************
// ShelfRouterGenerator
// **************************************************************************

Router _$PetstoreHttpServiceRouter(PetstoreHttpService service) {
  final router = Router();
  router.add('GET', r'/download/<petId>', service.downloadImage);
  router.add('GET', r'/pets', service.listPets);
  router.add('POST', r'/pets', service.createPets);
  router.add('GET', r'/pets/<petId>', service.getPet);
  router.add('POST', r'/upload/<petId>', service.uploadImage);
  return router;
}
