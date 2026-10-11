import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/l10n.dart';
import '../models/app_settings.dart';
import '../models/translation_language.dart';
import '../providers.dart';

/// 뜻·예문 번역 언어 선택. '자동'은 기기 언어·국가에 따라 정한다.
class TranslationLanguageDropdown extends ConsumerWidget {
  final bool enabled;
  const TranslationLanguageDropdown({super.key, this.enabled = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(
      settingsProvider.select((s) => s.translationLanguageOverride),
    );
    final l10n = context.l10n;
    final device = AppSettings.deviceTranslationLanguage;
    // DropdownButton ignores a null selection, so "auto" needs its own value.
    const auto = 'auto';
    return DropdownButtonFormField<String>(
      key: ValueKey(selected),
      initialValue: selected?.code ?? auto,
      isExpanded: true,
      decoration: InputDecoration(labelText: l10n.translationLanguageLabel),
      items: [
        DropdownMenuItem(
          value: auto,
          child: Text(l10n.translationLanguageAuto(l10n.language(device))),
        ),
        for (final language in TranslationLanguage.values)
          DropdownMenuItem(
            value: language.code,
            child: Text(l10n.language(language)),
          ),
      ],
      onChanged: enabled
          ? (code) {
              ref
                  .read(settingsProvider.notifier)
                  .setTranslationLanguage(
                    code == auto ? null : TranslationLanguage.fromCode(code),
                  );
              // 화면 언어가 바뀌므로 알림 문구도 새 언어로 다시 예약한다.
              // 이 위젯은 언어가 바뀌면 다시 만들어지므로 ref는 지금 바로 쓴다.
              rescheduleReminders(ref);
            }
          : null,
    );
  }
}
