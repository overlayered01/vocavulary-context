import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../models/word.dart';
import '../theme.dart';

/// 옅은 바탕색 머리 영역 아래에 위가 둥근 짙은 패널이 깔리는 기본 화면 틀.
/// 머리 영역을 흰색으로 두면 패널 속 흰 카드가 스크롤로 올라올 때
/// 머리 영역과 이어져 보이므로 바탕색을 옅게 깐다.
class PanelPage extends StatelessWidget {
  final Widget header;
  final Widget body;

  /// 패널 바닥에 고정되는 버튼 줄 등.
  final Widget? bottom;
  final EdgeInsetsGeometry bodyPadding;

  const PanelPage({
    super.key,
    required this.header,
    required this.body,
    this.bottom,
    this.bodyPadding = const EdgeInsets.fromLTRB(16, 20, 16, 0),
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.header,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SafeArea(bottom: false, child: header),
          Expanded(
            child: Material(
              color: AppColors.panel,
              clipBehavior: Clip.antiAlias,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Padding(padding: bodyPadding, child: body),
                  ),
                  ?bottom,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 화면 폭이 넓을 때 내용 폭을 휴대폰처럼 제한한다.
class ContentWidth extends StatelessWidget {
  final Widget child;
  const ContentWidth({super.key, required this.child});

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    heightFactor: 1,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560),
      child: SizedBox(width: double.infinity, child: child),
    ),
  );
}

/// 머리 영역 맨 위 작은 영문 표시와 오른쪽 보조 요소.
class HeaderEyebrow extends StatelessWidget {
  final String text;
  final Widget? trailing;
  const HeaderEyebrow(this.text, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.3,
            color: AppColors.sub,
          ),
        ),
      ),
      ?trailing,
    ],
  );
}

/// 패널 위 그룹 제목.
class PanelLabel extends StatelessWidget {
  final String text;
  final Widget? trailing;
  const PanelLabel(this.text, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
    child: Row(
      children: [
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.onPanelSub,
            ),
          ),
        ),
        if (trailing != null)
          DefaultTextStyle.merge(
            style: TextStyle(fontSize: 12, color: AppColors.onPanelSub),
            child: trailing!,
          ),
      ],
    ),
  );
}

/// 패널 위의 흰 카드 블록.
class WhiteBlock extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? color;
  final Color? outline;
  final VoidCallback? onTap;

  const WhiteBlock({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 18),
    this.radius = 20,
    this.color,
    this.outline,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: outline == null
          ? BorderSide.none
          : BorderSide(color: outline!, width: 2),
    );
    return Material(
      color: color ?? AppColors.card,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// 품사 칩 (verb, noun ...).
class PosChip extends StatelessWidget {
  final String partOfSpeech;
  final bool filled;
  const PosChip(this.partOfSpeech, {super.key, this.filled = false});

  @override
  Widget build(BuildContext context) {
    final label = partOfSpeechLabel(context, partOfSpeech);
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: filled ? AppColors.point : AppColors.chip,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: kDisplayFont,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
          color: filled ? AppColors.onPoint : AppColors.sub2,
        ),
      ),
    );
  }
}

/// 예문 속 단어를 형광펜으로 칠하거나 빈칸으로 가린다.
///
/// 단어 경계에서 시작하는 변형형까지 찾는다 (run → running, runs).
class ExampleSentence extends StatelessWidget {
  final String sentence;
  final String term;
  final TextStyle style;
  final bool blank;
  final Color? highlight;
  final TextAlign textAlign;

  const ExampleSentence({
    super.key,
    required this.sentence,
    required this.term,
    required this.style,
    this.blank = false,
    this.highlight,
    this.textAlign = TextAlign.start,
  });

  static RegExp patternFor(String term) =>
      RegExp('\\b${RegExp.escape(term.trim())}\\w*', caseSensitive: false);

  @override
  Widget build(BuildContext context) {
    final spans = <InlineSpan>[];
    var last = 0;
    final mark = highlight ?? AppColors.point;
    if (term.trim().isNotEmpty) {
      for (final match in patternFor(term).allMatches(sentence)) {
        spans.add(TextSpan(text: sentence.substring(last, match.start)));
        if (blank) {
          spans.add(
            TextSpan(
              text: ' ' * (match.end - match.start + 2),
              style: TextStyle(
                decoration: TextDecoration.underline,
                decorationColor: style.color ?? AppColors.ink,
                decorationThickness: 2,
              ),
            ),
          );
        } else {
          spans.add(
            TextSpan(
              text: match.group(0),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                background: Paint()..color = mark,
              ),
            ),
          );
        }
        last = match.end;
      }
    }
    spans.add(TextSpan(text: sentence.substring(last)));
    return Text.rich(
      TextSpan(style: style, children: spans),
      textAlign: textAlign,
    );
  }
}

/// 예문 해석. 카드의 뜻에 해당하는 부분을 굵게 보여 줘서
/// 빈칸이 해석의 어디에 해당하는지 알 수 있게 한다.
class ExampleTranslation extends StatelessWidget {
  final String translation;
  final List<String> meanings;
  final TextStyle style;
  final Color? focusColor;

  const ExampleTranslation({
    super.key,
    required this.translation,
    required this.meanings,
    required this.style,
    this.focusColor,
  });

  static final _boundary = RegExp('[\\s.,!?;:"\'“”‘’()\\[\\]…。、！？「」]');
  static final _latin = RegExp(r'^[a-zà-ÿ\s-]+$');

  /// 해석에서 뜻에 해당하는 [start, end). 못 찾으면 null.
  ///
  /// 뜻은 활용형으로 바뀌어 나오므로("기소하다" → "기소되었다") 뜻의 앞부분을
  /// 점점 줄여 가며 찾는다. 가장 길게 맞은 곳을 고르고(어절 첫머리 우선),
  /// 띄어 쓰는 언어면 그 어절 끝까지 굵게 한다.
  static (int, int)? focusOf(String translation, List<String> meanings) {
    final text = translation.toLowerCase();
    final candidates = <String>{};
    for (final meaning in meanings) {
      final cleaned = meaning
          .replaceAll(RegExp(r'\([^)]*\)|\[[^\]]*\]|[~…]'), ' ')
          .toLowerCase();
      for (final part in cleaned.split(RegExp(r'[,;/·]'))) {
        final phrase = part.trim().replaceAll(RegExp(r'\s+'), ' ');
        if (phrase.isEmpty) continue;
        candidates.add(phrase);
        for (final word in phrase.split(' ')) {
          if (word.length >= 2) candidates.add(word);
        }
      }
    }
    bool wordStart(int i) => i == 0 || _boundary.hasMatch(text[i - 1]);
    (int, int)? best;
    var bestLength = 0;
    var bestAtStart = false;
    for (final candidate in candidates) {
      // 라틴 문자는 4글자, 한글·한자 등은 2글자까지 줄여 본다.
      final shortest = _latin.hasMatch(candidate) ? 4 : 2;
      final minLength = candidate.length < shortest
          ? candidate.length
          : shortest;
      for (var length = candidate.length; length >= minLength; length--) {
        if (length < bestLength) break;
        final prefix = candidate.substring(0, length);
        var found = -1;
        var atStart = false;
        for (
          var i = text.indexOf(prefix);
          i >= 0;
          i = text.indexOf(prefix, i + 1)
        ) {
          if (wordStart(i)) {
            found = i;
            atStart = true;
            break;
          }
          if (found < 0) found = i;
        }
        // 한 글자는 어절 첫머리에서만 인정한다.
        if (found < 0 || (length == 1 && !atStart)) continue;
        if (length > bestLength || (atStart && !bestAtStart)) {
          best = (found, found + length);
          bestLength = length;
          bestAtStart = atStart;
        }
        break;
      }
    }
    if (best == null) return null;
    var (start, end) = best;
    if (text.contains(' ')) {
      while (end < text.length && !_boundary.hasMatch(text[end])) {
        end++;
      }
    }
    return (start, end);
  }

  @override
  Widget build(BuildContext context) {
    final focus = focusOf(translation, meanings);
    if (focus == null) return Text(translation, style: style);
    final (start, end) = focus;
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(text: translation.substring(0, start)),
          TextSpan(
            text: translation.substring(start, end),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: focusColor ?? AppColors.ink,
            ),
          ),
          TextSpan(text: translation.substring(end)),
        ],
      ),
    );
  }
}

/// 짙은 패널 위의 테두리 버튼.
class PanelOutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double height;
  const PanelOutlineButton({
    super.key,
    required this.label,
    this.onPressed,
    this.height = 58,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.onPanel,
        side: BorderSide(color: AppColors.panelLine, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      child: Text(label),
    ),
  );
}

/// 포인트색으로 채운 주 버튼. [trailingArrow]면 오른쪽에 화살표를 붙인다.
class PointButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool trailingArrow;
  final IconData? leadingIcon;
  final double height;
  const PointButton({
    super.key,
    required this.label,
    this.onPressed,
    this.trailingArrow = false,
    this.leadingIcon,
    this.height = 58,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 22),
      ),
      child: Row(
        mainAxisAlignment: trailingArrow
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.center,
        children: [
          if (leadingIcon != null) ...[
            Icon(leadingIcon, size: 20),
            const SizedBox(width: 8),
          ],
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
          if (trailingArrow) const Icon(Icons.arrow_forward_rounded, size: 20),
        ],
      ),
    ),
  );
}

/// 패널 위의 흐린 채움 버튼.
class PanelTonalButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;
  const PanelTonalButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: AppColors.panelHigh,
        foregroundColor: AppColors.onPanel,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
        ],
      ),
    ),
  );
}

/// − 값 + 조절기.
class StepperControl extends StatelessWidget {
  final String value;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;
  final String? minusLabel;
  final String? plusLabel;
  const StepperControl({
    super.key,
    required this.value,
    this.onMinus,
    this.onPlus,
    this.minusLabel,
    this.plusLabel,
  });

  @override
  Widget build(BuildContext context) {
    Widget button(IconData icon, VoidCallback? onTap, String? tooltip) =>
        Material(
          color: AppColors.chip,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onTap,
            child: Tooltip(
              message: tooltip ?? '',
              child: SizedBox(
                width: 36,
                height: 36,
                child: Icon(
                  icon,
                  size: 16,
                  color: onTap == null ? AppColors.line : AppColors.ink,
                ),
              ),
            ),
          ),
        );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        button(Icons.remove_rounded, onMinus, minusLabel),
        SizedBox(
          width: 52,
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.ink,
            ),
          ),
        ),
        button(Icons.add_rounded, onPlus, plusLabel),
      ],
    );
  }
}

/// 두세 개 중 하나를 고르는 둥근 분할 버튼.
class Segmented<T> extends StatelessWidget {
  final List<(T, String)> options;
  final T value;
  final ValueChanged<T> onChanged;
  const Segmented({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(
      color: AppColors.chip,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (option, label) in options)
          GestureDetector(
            onTap: () => onChanged(option),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: option == value ? AppColors.ink : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: option == value ? Colors.white : AppColors.sub2,
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

/// 흰 블록 안의 한 줄 설정 항목.
class BlockRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool divider;
  final double minHeight;
  final double indent;
  const BlockRow({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.divider = true,
    this.minHeight = 56,
    this.indent = 0,
  });

  @override
  Widget build(BuildContext context) {
    final row = Container(
      constraints: BoxConstraints(minHeight: minHeight),
      padding: EdgeInsets.only(left: indent, top: 8, bottom: 8),
      decoration: BoxDecoration(
        border: divider
            ? Border(bottom: BorderSide(color: AppColors.chip))
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.ink,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle!,
                    style: TextStyle(fontSize: 12, color: AppColors.sub),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 12),
            // 언어에 따라 길어지는 분할 버튼은 줄어들어 한 줄에 맞춘다.
            Flexible(
              child: Align(
                alignment: Alignment.centerRight,
                child: FittedBox(fit: BoxFit.scaleDown, child: trailing),
              ),
            ),
          ],
        ],
      ),
    );
    if (onTap == null) return row;
    return InkWell(onTap: onTap, child: row);
  }
}

/// 오른쪽 값 + 꺾쇠.
class ChevronValue extends StatelessWidget {
  final String value;
  const ChevronValue(this.value, {super.key});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Flexible(
        child: Text(
          value,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
      ),
      const SizedBox(width: 4),
      Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.sub),
    ],
  );
}

/// 예문 출처 표기. 사진에서 가져온 예문은 "내 사진"처럼 화면 언어로.
String exampleSourceLabel(BuildContext context, Example example) {
  final source = example.source == Example.photoSource
      ? context.l10n.exampleSourcePhoto
      : example.source;
  return example.license.isEmpty ? source : '$source · ${example.license}';
}

/// 품사를 영어와 화면 언어로 함께 쓴다 (예: "adj · 형용사").
/// 화면이 영어거나 알 수 없는 품사면 영어만. 품사가 비어 있으면 빈 문자열.
String partOfSpeechLabel(BuildContext context, String value) {
  final english = englishPartOfSpeech(value);
  final l10n = context.l10n;
  if (english.isEmpty || l10n.localeName.startsWith('en')) return english;
  final local = l10n.partOfSpeech(value.trim());
  // 모르는 품사는 저장 값 그대로 돌아온다.
  return local == english ? english : '$english · $local';
}

/// 저장된 품사 값(한국어 품사명 또는 영어)을 짧은 영어 표기로 바꾼다.
String englishPartOfSpeech(String value) {
  const labels = {
    '명사': 'noun',
    '동사': 'verb',
    '형용사': 'adj',
    '부사': 'adv',
    '대명사': 'pron',
    '전치사': 'prep',
    '접속사': 'conj',
    '감탄사': 'interj',
    '관사': 'article',
    '한정사': 'det',
    '구동사': 'phrasal verb',
    '숙어': 'idiom',
    '관용구': 'idiom',
    '구': 'phrase',
    'adjective': 'adj',
    'adverb': 'adv',
    'pronoun': 'pron',
    'preposition': 'prep',
    'conjunction': 'conj',
    'interjection': 'interj',
    'determiner': 'det',
  };
  final trimmed = value.trim();
  return labels[trimmed] ?? trimmed;
}
