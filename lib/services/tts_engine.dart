import 'package:flutter_tts/flutter_tts.dart';

/// Android/iOS/데스크톱용 기기 내장 TTS 구현.
class TtsEngine {
  final FlutterTts _tts = FlutterTts();
  bool _ready = false;

  Future<void> _ensure(
    String locale, {
    required bool isSentence,
    required String voice,
    required double speed,
  }) async {
    if (!_ready) {
      await _tts.awaitSpeakCompletion(true);
      _ready = true;
    }
    await _tts.setLanguage(locale);
    if (voice.isNotEmpty) {
      await _tts.setVoice({'name': voice, 'locale': locale});
    }
    // 문장은 단어보다 조금 빠르게 읽어야 억양과 문장 리듬이 자연스럽다.
    await _tts.setSpeechRate((isSentence ? 0.50 : 0.43) * speed);
    await _tts.setPitch(1.0);
  }

  Future<void> speak(
    String text, {
    required String locale,
    required bool isSentence,
    String voice = '',
    double speed = 1,
  }) async {
    await _ensure(locale, isSentence: isSentence, voice: voice, speed: speed);
    await _tts.stop();
    await _tts.speak(text);
  }

  /// [locale] 언어(en)로 읽을 수 있는 기기 목소리 이름.
  Future<List<String>> voices(String locale) async {
    final language = locale.split('-').first.toLowerCase();
    final raw = await _tts.getVoices;
    if (raw is! List) return const [];
    final names = <String>{};
    for (final voice in raw.whereType<Map>()) {
      final name = voice['name'];
      final voiceLocale = '${voice['locale'] ?? ''}'.toLowerCase();
      if (name is String &&
          voiceLocale.replaceAll('_', '-').startsWith(language)) {
        names.add(name);
      }
    }
    return names.toList()..sort();
  }

  Future<void> stop() => _tts.stop();
}
