import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/translation_language.dart';
import 'pack_store.dart' if (dart.library.js_interop) 'pack_store_web.dart';

enum PackState { none, downloading, ready, failed }

class PackStatus {
  final PackState state;

  /// 파일 크기(바이트). 목록을 아직 못 받았으면 0.
  final int bytes;

  /// 기기에 있는 데이터 버전. 없으면 null.
  final int? version;
  const PackStatus(this.state, [this.bytes = 0, this.version]);
}

/// 목록(manifest)이 가리키는 언어별 파일.
typedef PackInfo = ({String tag, String path, int bytes, String sha256});

/// 'examples-v3' → 3.
int? packVersion(String? tag) =>
    int.tryParse(RegExp(r'-v(\d+)$').firstMatch(tag ?? '')?.group(1) ?? '');

/// 내장 영어 예문의 언어별 해석. 용량이 커서 앱에 넣지 않고,
/// 번역 언어의 파일 하나만 GitHub 데이터 저장소에서 받아 기기에 둔다.
///
/// `tool/publish_packs.py`가 올린다. 목록(manifest)이 가리키는 버전(tag)이
/// 저장한 것과 다를 때만 다시 받는다. 받지 못하면 저장해 둔 것을 쓰고,
/// 그것도 없으면 해석 없이 예문만 보인다.
class TranslationPacks {
  static const repo = 'overlayered01/vocabulary-data';
  static final manifestUrl = Uri.parse(
    'https://raw.githubusercontent.com/$repo/main/manifest.json',
  );
  static Uri fileUrl(String tag, String path) =>
      Uri.parse('https://cdn.jsdelivr.net/gh/$repo@$tag/$path');

  final http.Client _client;
  final PackStore _store;
  Future<Map<String, dynamic>?>? _manifest;
  final _loaded = <TranslationLanguage, Future<Map<String, String>>>{};

  /// 언어별 받기 상태. 설정 화면이 보여 준다.
  final status = ValueNotifier<Map<TranslationLanguage, PackStatus>>({});

  TranslationPacks({http.Client? client, PackStore? store})
    : _client = client ?? http.Client(),
      _store = store ?? PackStore();

  /// 영어 문장 id → [language] 해석. 사람 번역만 쓴다.
  Future<Map<String, String>> examples(TranslationLanguage language) {
    if (!language.hasTranslations) return Future.value(const {});
    return _loaded[language] ??= _load(language).then((value) {
      // 받지 못했으면 다음에 다시 시도한다.
      if (value.isEmpty) _loaded.remove(language);
      return value;
    });
  }

  /// 언어를 고르면 미리 받아 둔다.
  void prefetch(TranslationLanguage language) {
    examples(language).ignore();
  }

  /// 목록을 다시 받아 새 버전이 있으면 받는다. 받은 뒤의 상태를 돌려준다.
  Future<PackStatus> checkUpdate(TranslationLanguage language) async {
    final pending = _loaded[language];
    if (pending != null) await pending;
    _manifest = null;
    _loaded.remove(language);
    await examples(language);
    return status.value[language] ?? const PackStatus(PackState.none);
  }

  /// 받은 해석을 모두 지운다 (예문 데이터를 끌 때).
  Future<void> removeAll() async {
    _loaded.clear();
    for (final language in TranslationLanguage.values) {
      if (language.hasTranslations) {
        await _store.delete('examples-${language.code}');
      }
    }
    status.value = {};
  }

  /// 처음 물어볼 때 보여 줄 크기를 위해 목록만 본다.
  Future<PackInfo?> info(TranslationLanguage language) => _fileInfo(language);

  void _setStatus(TranslationLanguage language, PackStatus value) {
    status.value = {...status.value, language: value};
  }

  Future<Map<String, String>> _load(TranslationLanguage language) async {
    final name = 'examples-${language.code}';
    final stored = await _store.read(name);
    final info = await _fileInfo(language);
    if (stored != null && (info == null || info.tag == stored.$1)) {
      final parsed = _parse(stored.$2);
      if (parsed != null) {
        _setStatus(
          language,
          PackStatus(
            PackState.ready,
            info?.bytes ?? stored.$2.length,
            packVersion(stored.$1),
          ),
        );
        return parsed;
      }
    }
    if (info == null) {
      _setStatus(language, const PackStatus(PackState.failed));
      return const {};
    }
    _setStatus(language, PackStatus(PackState.downloading, info.bytes));
    try {
      final response = await _client
          .get(fileUrl(info.tag, info.path))
          .timeout(const Duration(seconds: 60));
      if (response.statusCode != 200) {
        throw http.ClientException('HTTP ${response.statusCode}');
      }
      if (info.sha256.isNotEmpty &&
          sha256.convert(response.bodyBytes).toString() != info.sha256) {
        throw const FormatException('checksum');
      }
      final body = utf8.decode(response.bodyBytes);
      final parsed = _parse(body);
      if (parsed == null) throw const FormatException('pack');
      await _store.write(name, info.tag, body);
      _setStatus(
        language,
        PackStatus(PackState.ready, info.bytes, packVersion(info.tag)),
      );
      return parsed;
    } catch (_) {
      // 예전 버전이라도 있으면 그것을 쓴다.
      final fallback = stored == null ? null : _parse(stored.$2);
      _setStatus(
        language,
        PackStatus(
          fallback == null ? PackState.failed : PackState.ready,
          info.bytes,
          fallback == null ? null : packVersion(stored!.$1),
        ),
      );
      return fallback ?? const {};
    }
  }

  Future<PackInfo?> _fileInfo(
    TranslationLanguage language,
  ) async {
    final manifest = await (_manifest ??= _fetchManifest());
    final examples = manifest?['examples'];
    if (examples is! Map) return null;
    final file = (examples['files'] as Map?)?[language.code];
    final tag = examples['tag'];
    if (file is! Map || tag is! String || file['path'] is! String) return null;
    return (
      tag: tag,
      path: file['path'] as String,
      bytes: (file['bytes'] as num?)?.toInt() ?? 0,
      sha256: (file['sha256'] ?? '') as String,
    );
  }

  Future<Map<String, dynamic>?> _fetchManifest() async {
    try {
      final response = await _client
          .get(manifestUrl)
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) throw http.ClientException('manifest');
      return (jsonDecode(utf8.decode(response.bodyBytes)) as Map)
          .cast<String, dynamic>();
    } catch (_) {
      _manifest = null; // 다음 조회에서 다시 시도
      return null;
    }
  }

  /// 기계 번역(`machine`)은 앱에서 표시할 수 있게 되면 함께 쓴다.
  static Map<String, String>? _parse(String body) {
    try {
      final data = jsonDecode(body) as Map;
      return (data['human'] as Map).cast<String, String>();
    } catch (_) {
      return null;
    }
  }

  void dispose() {
    _client.close();
    status.dispose();
  }
}
