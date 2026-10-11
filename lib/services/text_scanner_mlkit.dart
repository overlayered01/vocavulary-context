import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// ML Kit 글자 인식은 Android·iOS만 지원한다.
bool get textScanSupported => Platform.isAndroid || Platform.isIOS;

/// 사진에서 영어(라틴 문자) 글을 읽는다. 사진은 기기 밖으로 나가지 않는다.
Future<String> recognizeText(String imagePath) async {
  final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
  try {
    final result = await recognizer.processImage(
      InputImage.fromFilePath(imagePath),
    );
    return result.text;
  } finally {
    await recognizer.close();
  }
}
