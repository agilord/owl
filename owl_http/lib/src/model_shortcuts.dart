void normalizeModel(Map<String, dynamic> model) {
  final origEndpoints = model['endpoints'];
  if (origEndpoints is Map<String, dynamic>) {
    model['endpoints'] = origEndpoints.entries
        .map((e) {
          final map = e.value as Map<String, dynamic> ?? <String, dynamic>{};
          return map.entries.map((m) {
            final mm = m.value as Map<String, dynamic> ?? <String, dynamic>{};
            mm['path'] ??= e.key;
            mm['method'] ??= m.key;
            return mm;
          }).toList();
        })
        .expand((a) => a)
        .toList();
  }
  for (final v in model['endpoints'] ?? []) {
    if (v is Map<String, dynamic>) {
      _normalizeEndpoint(v);
    }
  }
  final messages = model['messages'];
  if (messages is Map<String, dynamic>) {
    model['messages'] = messages.entries.map((e) {
      final map = e.value as Map<String, dynamic> ?? <String, dynamic>{};
      map['name'] ??= e.key;
      return map;
    }).toList();
  }
  for (final v in model['messages'] ?? []) {
    if (v is Map<String, dynamic>) {
      _normalizeMessage(v);
    }
  }
}

void _normalizeEndpoint(Map<String, dynamic> endpoint) {
  final query = endpoint['query'];
  if (query is Map<String, dynamic>) {
    endpoint['query'] = query.entries.map((e) {
      Map<String, dynamic> map;
      if (e.value is String) {
        map = <String, dynamic>{};
        map['type'] = e.value;
      } else {
        map = e.value as Map<String, dynamic> ?? <String, dynamic>{};
      }
      map['name'] ??= e.key;
      return map;
    }).toList();
  }
  _normalizeHeadersField(endpoint);
  final responses = endpoint['responses'];
  if (responses is Map<String, dynamic>) {
    endpoint['responses'] = responses.entries.map((e) {
      Map<String, dynamic> map;
      if (e.value is String) {
        map = <String, dynamic>{};
        map['body'] = e.value;
      } else {
        map = e.value as Map<String, dynamic> ?? <String, dynamic>{};
        if (map.containsKey('fields')) {
          map = <String, dynamic>{'body': map};
        }
      }
      map['status'] ??= int.parse(e.key);
      return map;
    }).toList();
  }
  for (final r in endpoint['responses'] ?? []) {
    if (r is Map<String, dynamic>) {
      _normalizeHeadersField(r);
      _normalizeBodyField(r);
    }
  }
  _normalizeBodyField(endpoint);
}

_normalizeHeadersField(Map<String, dynamic> endpoint) {
  final headers = endpoint['headers'];
  if (headers is Map<String, dynamic>) {
    endpoint['headers'] = headers.entries.map((e) {
      Map<String, dynamic> map;
      if (e.value is String) {
        map = <String, dynamic>{};
        map['type'] = e.value;
      } else {
        map = e.value as Map<String, dynamic> ?? <String, dynamic>{};
      }
      map['name'] ??= e.key;
      return map;
    }).toList();
  }
}

void _normalizeMessage(Map<String, dynamic> msg) {
  final fields = msg['fields'];
  if (fields is Map<String, dynamic>) {
    msg['fields'] = fields.entries.map((e) {
      Map<String, dynamic> map;
      if (e.value is String) {
        map = <String, dynamic>{};
        map['type'] = e.value;
      } else {
        map = e.value as Map<String, dynamic> ?? <String, dynamic>{};
      }
      map['name'] ??= e.key;
      return map;
    }).toList();
  }
}

void _normalizeBodyField(Map<String, dynamic> spec) {
  if (spec == null) return;
  final v = spec['body'];
  if (v is String) {
    spec['body'] = <String, dynamic>{'ref': v};
  } else if (v is Map) {
    if (v.containsKey('ref') || v.containsKey('inline')) {
      // nothing to do
    } else {
      _normalizeMessage(v as Map<String, dynamic>);
      spec['body'] = <String, dynamic>{
        'inline': v,
      };
    }
  }
}
