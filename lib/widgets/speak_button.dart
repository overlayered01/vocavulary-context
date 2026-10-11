import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/l10n.dart';
import '../providers.dart';
import '../theme.dart';

/// 발음 듣기 버튼. 화면마다 다르던 스피커 아이콘 스타일을 하나로 통일한다.
/// [prominent]가 true면 카드 헤더용 강조형(filledTonal), 아니면 컴팩트 아이콘형.
class SpeakButton extends ConsumerWidget {
  final String text;
  final bool prominent;
  final bool isSentence;

  /// 생략하면 화면 언어의 기본 문구('발음 듣기')를 쓴다.
  final String? tooltip;

  const SpeakButton({
    super.key,
    required this.text,
    this.prominent = false,
    this.isSentence = false,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tooltip = this.tooltip ?? context.l10n.speakListen;
    void speak() {
      final settings = ref.read(settingsProvider);
      ref
          .read(ttsServiceProvider)
          .speak(
            text,
            locale: settings.ttsLocale,
            isSentence: isSentence,
            voice: settings.ttsVoice,
            speed: settings.ttsSpeed,
            recordedFirst: settings.recordedPronunciation,
          );
    }

    if (prominent) {
      return IconButton.filledTonal(
        tooltip: tooltip,
        style: IconButton.styleFrom(
          backgroundColor: AppColors.chip,
          foregroundColor: AppColors.ink,
        ),
        icon: const Icon(Icons.volume_up_outlined, size: 21),
        onPressed: speak,
      );
    }
    return IconButton(
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      icon: Icon(
        Icons.volume_up_outlined,
        size: 20,
        color: AppColors.ink,
      ),
      onPressed: speak,
    );
  }
}
