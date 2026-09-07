import 'tts_engine.dart' if (dart.library.js_interop) 'tts_engine_web.dart';

/// 기기 또는 브라우저의 TTS로 단어·예문 발음을 재생한다.
class TtsService {
  final TtsEngine _engine = TtsEngine();

  Future<void> speak(
    String text, {
    String locale = 'en-US',
    bool isSentence = false,
  }) {
    final normalized = text.trim();
    if (normalized.isEmpty) return Future<void>.value();
    return _engine.speak(normalized, locale: locale, isSentence: isSentence);
  }

  Future<void> stop() => _engine.stop();
}
