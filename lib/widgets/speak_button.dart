import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import '../theme.dart';

/// 발음 듣기 버튼. 화면마다 다르던 스피커 아이콘 스타일을 하나로 통일한다.
/// [prominent]가 true면 카드 헤더용 강조형(filledTonal), 아니면 컴팩트 아이콘형.
class SpeakButton extends ConsumerWidget {
  final String text;
  final bool prominent;
  final String tooltip;

  const SpeakButton({
    super.key,
    required this.text,
    this.prominent = false,
    this.tooltip = '발음 듣기',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void speak() => ref
        .read(ttsServiceProvider)
        .speak(text, locale: ref.read(settingsProvider).ttsLocale);

    if (prominent) {
      return IconButton.filledTonal(
        tooltip: tooltip,
        icon: const Icon(Icons.volume_up_outlined, size: 21),
        onPressed: speak,
      );
    }
    return IconButton(
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      icon: const Icon(
        Icons.volume_up_outlined,
        size: 20,
        color: AppColors.ink,
      ),
      onPressed: speak,
    );
  }
}
