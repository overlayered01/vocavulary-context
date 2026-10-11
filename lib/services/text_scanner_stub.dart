/// 글자 읽기를 지원하지 않는 플랫폼(웹).
bool get textScanSupported => false;

Future<String> recognizeText(String imagePath) =>
    throw UnsupportedError('text recognition');
