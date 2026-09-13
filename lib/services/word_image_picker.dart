import 'dart:convert';

import 'package:image_picker/image_picker.dart';

Future<String?> pickWordImage() async {
  final file = await ImagePicker().pickImage(
    source: ImageSource.gallery,
    maxWidth: 1400,
    imageQuality: 82,
  );
  if (file == null) return null;

  final bytes = await file.readAsBytes();
  if (bytes.length > 2 * 1024 * 1024) {
    throw const FormatException('이미지는 2MB 이하로 선택해 주세요.');
  }

  final name = file.name.toLowerCase();
  final mimeType =
      file.mimeType ??
      (name.endsWith('.png')
          ? 'image/png'
          : name.endsWith('.webp')
          ? 'image/webp'
          : name.endsWith('.gif')
          ? 'image/gif'
          : 'image/jpeg');
  return 'data:$mimeType;base64,${base64Encode(bytes)}';
}
