import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;

import 'tts_engine.dart' if (dart.library.js_interop) 'tts_engine_web.dart';

/// 기기 또는 브라우저의 TTS로 단어·예문 발음을 재생한다.
///
/// 단어는 설정에 따라 Wikimedia Commons의 사람 녹음(CC BY-SA)을 먼저 찾고,
/// 녹음이 없으면 TTS로 읽는다.
class TtsService {
  final TtsEngine _engine = TtsEngine();
  final http.Client _client;
  AudioPlayer? _player;

  /// 단어별 녹음 주소. 녹음이 없으면 null로 기억해 다시 묻지 않는다.
  final _recordings = <String, String?>{};

  TtsService({http.Client? client}) : _client = client ?? http.Client();

  static double speedFactor(String speed) => switch (speed) {
    'slow' => 0.8,
    'fast' => 1.2,
    _ => 1.0,
  };

  Future<void> speak(
    String text, {
    String locale = 'en-US',
    bool isSentence = false,
    String voice = '',
    String speed = 'normal',
    bool recordedFirst = false,
  }) async {
    final normalized = text.trim();
    if (normalized.isEmpty) return;
    if (!isSentence && recordedFirst && !normalized.contains(' ')) {
      final url = await _recordingUrl(normalized, locale);
      if (url != null) {
        try {
          await _engine.stop();
          final player = _player ??= AudioPlayer();
          await player.stop();
          await player.play(UrlSource(url));
          return;
        } catch (_) {
          // 재생할 수 없으면 TTS로 읽는다.
        }
      }
    }
    await _engine.speak(
      normalized,
      locale: locale,
      isSentence: isSentence,
      voice: voice,
      speed: speedFactor(speed),
    );
  }

  Future<List<String>> voices(String locale) async {
    try {
      return await _engine.voices(locale);
    } catch (_) {
      return const [];
    }
  }

  Future<void> stop() async {
    await _player?.stop();
    await _engine.stop();
  }

  /// Commons의 `En-us-<word>.ogg` 같은 녹음 파일을 mp3 변환본 주소로 돌려준다.
  Future<String?> _recordingUrl(String word, String locale) async {
    final key = '$locale/${word.toLowerCase()}';
    if (_recordings.containsKey(key)) return _recordings[key];
    final lower = word.toLowerCase();
    final names = locale == 'en-GB'
        ? ['En-uk-$lower.ogg', 'En-gb-$lower.ogg', 'En-us-$lower.ogg']
        : ['En-us-$lower.ogg', 'En-uk-$lower.ogg', 'En-au-$lower.ogg'];
    String? found;
    try {
      final uri = Uri.https('commons.wikimedia.org', '/w/api.php', {
        'action': 'query',
        'titles': names.map((n) => 'File:$n').join('|'),
        'prop': 'imageinfo',
        'iiprop': 'url',
        'format': 'json',
        'origin': '*',
      });
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final pages = (data['query']?['pages'] as Map?)?.values ?? const [];
        final urls = <String, String>{};
        for (final page in pages.whereType<Map>()) {
          final info = page['imageinfo'];
          if (info is List && info.isNotEmpty && info.first is Map) {
            final url = (info.first as Map)['url'];
            final title = '${page['title'] ?? ''}'.replaceFirst('File:', '');
            if (url is String) urls[title.toLowerCase()] = url;
          }
        }
        for (final name in names) {
          final url = urls[name.toLowerCase()];
          if (url != null) {
            found = mp3Url(url);
            break;
          }
        }
      }
    } catch (_) {
      return null; // 연결 문제는 기억하지 않고 다음에 다시 시도한다.
    }
    _recordings[key] = found;
    return found;
  }

  /// iOS 사파리 등에서도 재생되도록 Commons의 mp3 변환본을 쓴다.
  static String mp3Url(String original) {
    final uri = Uri.parse(original);
    final segments = uri.pathSegments;
    final index = segments.indexOf('commons');
    if (index < 0 || segments.length < index + 4) return original;
    final file = segments.last;
    return Uri.https(uri.host, [
      ...segments.sublist(0, index + 1),
      'transcoded',
      ...segments.sublist(index + 1),
      '$file.mp3',
    ].join('/')).toString();
  }
}
