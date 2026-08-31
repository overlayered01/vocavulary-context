import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../theme.dart';

/// 단어 대표 이미지. data URL과 일반 HTTP(S) URL을 모두 표시한다.
class WordImage extends StatelessWidget {
  final String source;
  final BoxFit fit;
  final double? width;
  final double? height;

  const WordImage({
    super.key,
    required this.source,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final bytes = _dataUrlBytes(source);
    if (bytes != null) {
      return Image.memory(
        bytes,
        width: width,
        height: height,
        fit: fit,
        gaplessPlayback: true,
        errorBuilder: _errorBuilder,
      );
    }

    return Image.network(
      source,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: _errorBuilder,
    );
  }

  Uint8List? _dataUrlBytes(String value) {
    if (!value.startsWith('data:image/')) return null;
    final comma = value.indexOf(',');
    if (comma < 0) return null;
    try {
      return base64Decode(value.substring(comma + 1));
    } on FormatException {
      return null;
    }
  }

  Widget _errorBuilder(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
    return Container(
      width: width,
      height: height,
      color: AppColors.chip,
      alignment: Alignment.center,
      child: const Icon(Icons.broken_image_outlined, color: AppColors.sub),
    );
  }
}
