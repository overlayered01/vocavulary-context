import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:vocabulary/models/translation_language.dart';
import 'package:vocabulary/services/pack_store.dart';
import 'package:vocabulary/services/translation_packs.dart';

class _MemoryStore extends PackStore {
  final files = <String, (String, String)>{};

  @override
  Future<(String, String)?> read(String name) async => files[name];

  @override
  Future<void> write(String name, String tag, String body) async =>
      files[name] = (tag, body);

  @override
  Future<void> delete(String name) async => files.remove(name);
}

void main() {
  final body = jsonEncode({
    'lang': 'ko',
    'human': {'1': '안녕.'},
    'machine': {'2': '기계 번역'},
  });
  String manifest(String tag, {String? hash}) => jsonEncode({
    'examples': {
      'version': 1,
      'tag': tag,
      'files': {
        'ko': {
          'path': 'examples/ko.json',
          'bytes': body.length,
          'sha256': hash ?? sha256.convert(utf8.encode(body)).toString(),
        },
      },
    },
  });

  test('목록의 버전으로 언어 파일을 받아 저장하고, 같은 버전이면 다시 받지 않는다', () async {
    final store = _MemoryStore();
    final requested = <String>[];
    http.Client client(String tag) => MockClient((request) async {
      requested.add(request.url.toString());
      if (request.url == TranslationPacks.manifestUrl) {
        return http.Response(manifest(tag), 200);
      }
      return http.Response.bytes(utf8.encode(body), 200);
    });

    final first = TranslationPacks(client: client('examples-v1'), store: store);
    expect(await first.examples(TranslationLanguage.korean), {'1': '안녕.'});
    expect(
      requested.last,
      'https://cdn.jsdelivr.net/gh/${TranslationPacks.repo}@examples-v1/examples/ko.json',
    );
    expect(store.files['examples-ko']!.$1, 'examples-v1');
    expect(
      first.status.value[TranslationLanguage.korean]!.state,
      PackState.ready,
    );

    requested.clear();
    final again = TranslationPacks(client: client('examples-v1'), store: store);
    expect(await again.examples(TranslationLanguage.korean), {'1': '안녕.'});
    expect(requested, [TranslationPacks.manifestUrl.toString()]);

    // 영어는 해석이 없다.
    expect(await again.examples(TranslationLanguage.english), isEmpty);
  });

  test('받지 못하면 저장한 예전 버전을 쓰고, 그것도 없으면 빈 해석', () async {
    final store = _MemoryStore()..files['examples-ko'] = ('examples-v1', body);
    final broken = TranslationPacks(
      client: MockClient((request) async {
        if (request.url == TranslationPacks.manifestUrl) {
          return http.Response(manifest('examples-v2', hash: 'bad'), 200);
        }
        return http.Response.bytes(utf8.encode(body), 200);
      }),
      store: store,
    );
    expect(await broken.examples(TranslationLanguage.korean), {'1': '안녕.'});

    final offline = TranslationPacks(
      client: MockClient((_) async => throw Exception('offline')),
      store: _MemoryStore(),
    );
    expect(await offline.examples(TranslationLanguage.korean), isEmpty);
    expect(
      offline.status.value[TranslationLanguage.korean]!.state,
      PackState.failed,
    );
  });

  test('업데이트 확인은 목록을 다시 받아 새 버전을 받고, 끄면 모두 지운다', () async {
    final store = _MemoryStore();
    var tag = 'examples-v1';
    final packs = TranslationPacks(
      client: MockClient((request) async {
        if (request.url == TranslationPacks.manifestUrl) {
          return http.Response(manifest(tag), 200);
        }
        return http.Response.bytes(utf8.encode(body), 200);
      }),
      store: store,
    );
    await packs.examples(TranslationLanguage.korean);
    expect(packs.status.value[TranslationLanguage.korean]!.version, 1);

    var status = await packs.checkUpdate(TranslationLanguage.korean);
    expect(status.version, 1);

    tag = 'examples-v2';
    status = await packs.checkUpdate(TranslationLanguage.korean);
    expect(status.state, PackState.ready);
    expect(status.version, 2);
    expect(store.files['examples-ko']!.$1, 'examples-v2');

    await packs.removeAll();
    expect(store.files, isEmpty);
    expect(packs.status.value, isEmpty);
  });
}
