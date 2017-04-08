// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// Generator: JsonGenerator
// Target: library http_api_example
// **************************************************************************

// Generated by owl 0.2.1
// https://github.com/agilord/owl

// ignore: unused_import, library_prefixes
import 'http_api_example.dart';
// ignore: unused_import, library_prefixes
import 'dart:convert';
// ignore: unused_import, library_prefixes
import 'package:owl/util/json/core.dart' as _owl_json;

// **************************************************************************
// Generator: JsonGenerator
// Target: class Article
// **************************************************************************

/// Mapper for Article
abstract class ArticleMapper {
  /// Converts an instance of Article to Map.
  static Map<String, dynamic> map(Article object) {
    if (object == null) return null;
    return (new _owl_json.MapBuilder(ordered: false)
          ..put('title', object.title)
          ..put('description', object.description))
        .toMap();
  }

  /// Converts a Map to an instance of Article.
  static Article parse(Map<String, dynamic> map) {
    if (map == null) return null;
    final Article object = new Article();
    object.title = map['title'];
    object.description = map['description'];
    return object;
  }

  /// Converts a JSON string to an instance of Article.
  static Article fromJson(String json) {
    if (json == null || json.isEmpty) return null;
    final Map<String, dynamic> map = JSON.decoder.convert(json);
    return parse(map);
  }

  /// Converts an instance of Article to JSON string.
  static String toJson(Article object) {
    if (object == null) return null;
    return JSON.encoder.convert(map(object));
  }
}

// **************************************************************************
// Generator: JsonGenerator
// Target: class Status
// **************************************************************************

/// Mapper for Status
abstract class StatusMapper {
  /// Converts an instance of Status to Map.
  static Map<String, dynamic> map(Status object) {
    if (object == null) return null;
    return (new _owl_json.MapBuilder(ordered: false)
          ..put('success', object.success)
          ..put('message', object.message))
        .toMap();
  }

  /// Converts a Map to an instance of Status.
  static Status parse(Map<String, dynamic> map) {
    if (map == null) return null;
    final Status object = new Status();
    object.success = map['success'];
    object.message = map['message'];
    return object;
  }

  /// Converts a JSON string to an instance of Status.
  static Status fromJson(String json) {
    if (json == null || json.isEmpty) return null;
    final Map<String, dynamic> map = JSON.decoder.convert(json);
    return parse(map);
  }

  /// Converts an instance of Status to JSON string.
  static String toJson(Status object) {
    if (object == null) return null;
    return JSON.encoder.convert(map(object));
  }
}
