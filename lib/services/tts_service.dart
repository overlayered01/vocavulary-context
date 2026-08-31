import 'package:flutter_tts/flutter_tts.dart';

/// 기기 내장 TTS로 단어·예문 발음을 재생한다. (MVP: 무료·오프라인)
class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _ready = false;

  Future<void> _ensure(String locale) async {
    if (!_ready) {
      await _tts.awaitSpeakCompletion(true);
      _ready = true;
    }
    await _tts.setLanguage(locale);
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);
  }

  Future<void> speak(String text, {String locale = 'en-US'}) async {
    if (text.trim().isEmpty) return;
    await _ensure(locale);
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stop() => _tts.stop();
}
