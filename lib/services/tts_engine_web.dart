import 'dart:js_interop';

@JS('speechSynthesis')
external _SpeechSynthesis get _speechSynthesis;

@JS()
extension type _SpeechSynthesis._(JSObject _) implements JSObject {
  external void cancel();

  external JSArray<_SpeechSynthesisVoice> getVoices();

  external void speak(_SpeechSynthesisUtterance utterance);
}

@JS('SpeechSynthesisUtterance')
extension type _SpeechSynthesisUtterance._(JSObject _) implements JSObject {
  external _SpeechSynthesisUtterance();

  external String lang;
  external double pitch;
  external double rate;
  external String text;
  external _SpeechSynthesisVoice? voice;
}

@JS()
extension type _SpeechSynthesisVoice._(JSObject _) implements JSObject {
  external String get lang;
  external String get name;
}

/// 웹에서는 브라우저의 Web Speech API를 사용자 클릭 시점에 직접 호출한다.
///
/// flutter_tts의 웹 구현처럼 재생 전에 비동기 플랫폼 채널을 여러 번
/// 왕복하면 Chrome에서 음성 재생이 거부되거나 취소될 수 있다.
class TtsEngine {
  Future<void> speak(
    String text, {
    required String locale,
    required bool isSentence,
    String voice = '',
    double speed = 1,
  }) {
    final utterance = _SpeechSynthesisUtterance()
      ..text = text
      ..lang = locale
      // Web Speech API의 기본 속도는 1.0이다. 기존 0.45는 지나치게 느려
      // 문장 억양이 끊겨 들리므로 예문은 실제 회화에 가까운 속도로 읽는다.
      ..rate = (isSentence ? 0.92 : 0.78) * speed
      ..pitch = 1.0;

    final normalizedLocale = _normalizeLocale(locale);
    final voices = _speechSynthesis.getVoices().toDart;
    _SpeechSynthesisVoice? preferredVoice;
    var preferredScore = -1;
    for (final candidate in voices) {
      final voiceLocale = _normalizeLocale(candidate.lang);
      if (!voiceLocale.startsWith(normalizedLocale.split('-').first)) continue;

      var score = voiceLocale == normalizedLocale ? 100 : 50;
      // 사용자가 고른 목소리가 있으면 그것을 쓴다.
      if (voice.isNotEmpty && candidate.name == voice) score += 1000;
      final name = candidate.name.toLowerCase();
      if (name.contains('natural') || name.contains('neural')) score += 40;
      if (name.contains('premium') || name.contains('enhanced')) score += 30;
      if (name.contains('google') || name.contains('microsoft')) score += 20;
      if (score > preferredScore) {
        preferredVoice = candidate;
        preferredScore = score;
      }
    }
    if (preferredVoice != null) {
      utterance
        ..voice = preferredVoice
        ..lang = preferredVoice.lang;
    }

    // 같은 버튼을 연속으로 눌러도 이전 발음을 끊고 즉시 다시 읽는다.
    _speechSynthesis.cancel();
    _speechSynthesis.speak(utterance);
    return Future<void>.value();
  }

  /// 브라우저가 가진 [locale] 언어 목소리 이름.
  Future<List<String>> voices(String locale) {
    final language = locale.split('-').first.toLowerCase();
    final names = <String>{
      for (final voice in _speechSynthesis.getVoices().toDart)
        if (_normalizeLocale(voice.lang).startsWith(language)) voice.name,
    };
    return Future.value(names.toList()..sort());
  }

  Future<void> stop() {
    _speechSynthesis.cancel();
    return Future<void>.value();
  }

  String _normalizeLocale(String locale) =>
      locale.replaceAll('_', '-').toLowerCase();
}
