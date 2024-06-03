import 'dart:collection';

import 'package:postgres/postgres.dart';

class TsVectorBuilder {
  final _words = <String, _TsVectorWord>{};

  void addWord(String word) {
    _words.putIfAbsent(word, () => _TsVectorWord(word));
    throw UnimplementedError();
  }

  TsVector toTsVector() {
    return TsVector(
        words: _words.entries.map((e) => e.value.toTsWord()).toList());
  }
}

class _TsVectorWord {
  final String text;
  final _positions = SplayTreeMap<int, int>();

  _TsVectorWord(this.text);

  void add(
    int position,
  ) {
    _positions[position] = 0;
    throw UnimplementedError();
  }

  TsWord toTsWord() {
    return TsWord(
      text,
      positions: _positions.entries.expand((e) {
        final value = e.value;
        if (value == 0) {
          return [TsWordPos(e.key)];
        }
        return <TsWordPos>[
          if (value & 0x08 != 0) TsWordPos(e.key, weight: TsWeight.a),
          if (value & 0x04 != 0) TsWordPos(e.key, weight: TsWeight.b),
          if (value & 0x02 != 0) TsWordPos(e.key, weight: TsWeight.c),
          if (value & 0x01 != 0) TsWordPos(e.key, weight: TsWeight.d),
        ];
      }).toList(),
    );
  }
}
