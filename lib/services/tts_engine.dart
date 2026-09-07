import 'package:flutter_tts/flutter_tts.dart';

/// Android/iOS/데스크톱용 기기 내장 TTS 구현.
class TtsEngine {
  final FlutterTts _tts = FlutterTts();
  bool _ready = false;

  Future<void> _ensure(String locale, {required bool isSentence}) async {
    if (!_ready) {
      await _tts.awaitSpeakCompletion(true);
      _ready = true;
    }
    await _tts.setLanguage(locale);
    // 문장은 단어보다 조금 빠르게 읽어야 억양과 문장 리듬이 자연스럽다.
    await _tts.setSpeechRate(isSentence ? 0.50 : 0.43);
    await _tts.setPitch(1.0);
  }

  Future<void> speak(
    String text, {
    required String locale,
    required bool isSentence,
  }) async {
    await _ensure(locale, isSentence: isSentence);
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stop() => _tts.stop();
}
