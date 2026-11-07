import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/l10n.dart';
import '../models/app_settings.dart';
import '../models/reminder_schedule.dart';
import '../models/translation_language.dart';
import '../providers.dart';
import '../services/translation_packs.dart';
import '../services/reminder_planner.dart';
import '../theme.dart';
import '../widgets/panel.dart';
import '../widgets/reminder_schedule_editor.dart';
import '../widgets/theme_picker.dart';
import '../widgets/translation_language_dropdown.dart';
import 'about_screen.dart';

/// 개인정보처리방침 공개 페이지 (overlayered01.github.io 레포).
final kPrivacyPolicyUrl = Uri.parse(
  'https://overlayered01.github.io/vocabexamples/privacy/',
);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final notifications = ref.read(notificationServiceProvider);
    final mixed = (settings.sessionSize * settings.reviewMixRatio / 100)
        .round();

    return PanelPage(
      header: ContentWidth(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(26, 22, 26, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HeaderEyebrow('SETTINGS'),
              const SizedBox(height: 18),
              Text(
                l10n.settingsTitle,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.5,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
      bodyPadding: EdgeInsets.zero,
      body: ContentWidth(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
          children: [
            PanelLabel(l10n.settingsTheme),
            WhiteBlock(
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
              child: const ThemeSwatches(),
            ),
            const SizedBox(height: 18),

            PanelLabel(l10n.settingsLanguageSection),
            WhiteBlock(
              child: BlockRow(
                key: const ValueKey('settings-language'),
                title: l10n.settingsLanguageRow,
                subtitle: settings.translationLanguageOverride == null
                    ? l10n.settingsFollowDevice
                    : null,
                divider: false,
                minHeight: 64,
                trailing: ChevronValue(
                  l10n.language(settings.translationLanguage),
                ),
                onTap: () => _languageSheet(context),
              ),
            ),
            const SizedBox(height: 18),

            PanelLabel(l10n.settingsExampleDataSection),
            const WhiteBlock(child: _ExampleDataRows()),
            const SizedBox(height: 18),

            PanelLabel(l10n.settingsReviewSection),
            WhiteBlock(
              child: Column(
                children: [
                  BlockRow(
                    key: const ValueKey('settings-answer-style'),
                    title: l10n.settingsAnswerStyle,
                    subtitle: l10n.settingsAnswerHelp,
                    minHeight: 64,
                    trailing: ChevronValue(
                      settings.answerByChoice
                          ? l10n.settingsAnswerChoice
                          : l10n.settingsAnswerInput,
                    ),
                    onTap: () => _answerStyleSheet(context, ref),
                  ),
                  BlockRow(
                    title: l10n.settingsSessionSize,
                    minHeight: 60,
                    trailing: StepperControl(
                      value: '${settings.sessionSize}',
                      onMinus: settings.sessionSize <= 5
                          ? null
                          : () => notifier.setSessionSize(
                              settings.sessionSize - 5,
                            ),
                      onPlus: settings.sessionSize >= 50
                          ? null
                          : () => notifier.setSessionSize(
                              settings.sessionSize + 5,
                            ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 14, bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.settingsMixLabel,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.ink,
                                ),
                              ),
                            ),
                            Text(
                              '${settings.reviewMixRatio}%',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: AppColors.ink,
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value: settings.reviewMixRatio.toDouble(),
                          min: 0,
                          max: 100,
                          divisions: 20,
                          label: '${settings.reviewMixRatio}%',
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          onChanged: (v) => notifier.setMixRatio(v.round()),
                        ),
                        Text(
                          l10n.settingsMixExample(settings.sessionSize, mixed),
                          style: TextStyle(fontSize: 12, color: AppColors.sub),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            PanelLabel(l10n.settingsWordAddSection),
            WhiteBlock(
              child: Column(
                children: [
                  BlockRow(
                    title: l10n.wordCreateAutoMeanings,
                    trailing: Switch(
                      value: settings.autoMeanings,
                      onChanged: (v) => notifier.setAutoInput(meanings: v),
                    ),
                  ),
                  BlockRow(
                    title: l10n.wordCreateAutoExamples,
                    trailing: Switch(
                      value: settings.autoExamples,
                      onChanged: (v) => notifier.setAutoInput(examples: v),
                    ),
                  ),
                  BlockRow(
                    title: l10n.wordCreateExampleTranslations,
                    indent: 14,
                    divider: false,
                    trailing: Switch(
                      value: settings.autoExampleTranslations,
                      onChanged:
                          settings.autoExamples &&
                              settings.translationLanguage.hasTranslations
                          ? (v) => notifier.setAutoInput(exampleTranslations: v)
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            PanelLabel(l10n.settingsNotificationsSection),
            WhiteBlock(
              child: Column(
                children: [
                  BlockRow(
                    title: l10n.settingsReminderMaster,
                    trailing: Switch(
                      value: settings.reminderEnabled,
                      onChanged: (v) async {
                        await notifier.setReminderEnabled(v);
                        if (v) {
                          await notifications.requestPermissions();
                          await rescheduleReminders(ref);
                        } else {
                          await notifications.cancelReminder();
                        }
                      },
                    ),
                  ),
                  for (final schedule in settings.reminderSchedules)
                    _ReminderScheduleRow(
                      schedule: schedule,
                      onTap: () => _editSchedule(context, ref, schedule),
                      onToggle: (v) async {
                        await notifier.saveReminderSchedule(
                          schedule.copyWith(enabled: v),
                        );
                        await rescheduleReminders(ref);
                      },
                    ),
                  InkWell(
                    onTap: () => _editSchedule(context, ref, null),
                    child: SizedBox(
                      height: 54,
                      child: Row(
                        children: [
                          Icon(
                            Icons.add_rounded,
                            size: 18,
                            color: AppColors.ink,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              l10n.settingsAddSlot,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Text(
                _reminderSummary(l10n, settings),
                style: TextStyle(fontSize: 12, color: AppColors.onPanelSub),
              ),
            ),
            const SizedBox(height: 18),

            PanelLabel(l10n.settingsPronunciationSection),
            WhiteBlock(
              child: Column(
                children: [
                  BlockRow(
                    title: l10n.settingsAccent,
                    minHeight: 60,
                    trailing: Segmented<String>(
                      options: [
                        ('en-US', l10n.settingsTtsUs),
                        ('en-GB', l10n.settingsTtsUk),
                      ],
                      value: settings.ttsLocale,
                      onChanged: notifier.setTtsLocale,
                    ),
                  ),
                  BlockRow(
                    title: l10n.settingsVoice,
                    trailing: ChevronValue(
                      settings.ttsVoice.isEmpty
                          ? l10n.settingsVoiceDefault
                          : settings.ttsVoice,
                    ),
                    onTap: () => _voiceSheet(context, ref),
                  ),
                  BlockRow(
                    title: l10n.settingsSpeed,
                    minHeight: 60,
                    trailing: Segmented<String>(
                      options: [
                        ('slow', l10n.settingsSpeedSlow),
                        ('normal', l10n.settingsSpeedNormal),
                        ('fast', l10n.settingsSpeedFast),
                      ],
                      value: settings.ttsSpeed,
                      onChanged: notifier.setTtsSpeed,
                    ),
                  ),
                  BlockRow(
                    title: l10n.settingsRecorded,
                    subtitle: l10n.settingsRecordedHelp,
                    minHeight: 64,
                    divider: false,
                    trailing: Switch(
                      value: settings.recordedPronunciation,
                      onChanged: notifier.setRecordedPronunciation,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            WhiteBlock(
              color: AppColors.panelHigh,
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const AboutScreen())),
              child: SizedBox(
                height: 56,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.settingsAbout,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.onPanel,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.onPanelSub,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            WhiteBlock(
              color: AppColors.panelHigh,
              onTap: () => launchUrl(
                kPrivacyPolicyUrl,
                mode: LaunchMode.externalApplication,
              ),
              child: SizedBox(
                height: 56,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.settingsPrivacy,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.onPanel,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.open_in_new_rounded,
                      size: 18,
                      color: AppColors.onPanelSub,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _answerStyleSheet(BuildContext context, WidgetRef ref) {
    return showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => Consumer(
        builder: (ctx, ref, _) {
          final choice = ref.watch(
            settingsProvider.select((s) => s.answerByChoice),
          );
          Widget option(bool value, String label) => ListTile(
            key: ValueKey('answer-style-$value'),
            title: Text(label),
            trailing: choice == value
                ? Icon(Icons.check_rounded, color: AppColors.ink)
                : null,
            onTap: () {
              ref.read(settingsProvider.notifier).setAnswerByChoice(value);
              Navigator.pop(ctx);
            },
          );
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                option(false, ctx.l10n.settingsAnswerInput),
                option(true, ctx.l10n.settingsAnswerChoice),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _languageSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                ctx.l10n.settingsLanguageRow,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 16),
              const TranslationLanguageDropdown(),
              const SizedBox(height: 12),
              Text(
                ctx.l10n.settingsAppLanguageNote,
                style: TextStyle(fontSize: 12, color: AppColors.sub),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _voiceSheet(BuildContext context, WidgetRef ref) async {
    final settings = ref.read(settingsProvider);
    final voices = await ref
        .read(ttsServiceProvider)
        .voices(settings.ttsLocale);
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Consumer(
        builder: (ctx, ref, _) {
          final selected = ref.watch(
            settingsProvider.select((s) => s.ttsVoice),
          );
          final notifier = ref.read(settingsProvider.notifier);
          Widget option(String value, String label) => ListTile(
            title: Text(label),
            trailing: selected == value
                ? Icon(Icons.check_rounded, color: AppColors.ink)
                : null,
            onTap: () {
              notifier.setTtsVoice(value);
              ref
                  .read(ttsServiceProvider)
                  .speak(
                    'Hello',
                    locale: settings.ttsLocale,
                    voice: value,
                    speed: settings.ttsSpeed,
                  );
            },
          );
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(ctx).height * 0.7,
            ),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.only(bottom: 20),
              children: [
                option('', ctx.l10n.settingsVoiceDefault),
                for (final voice in voices) option(voice, voice),
              ],
            ),
          );
        },
      ),
    );
  }
}

String _reminderSummary(AppLocalizations l10n, AppSettings settings) {
  final count = weeklyReminderCount(settings);
  if (!settings.reminderEnabled) return l10n.settingsReminderOff;
  if (count == 0) return l10n.settingsReminderNoActive;
  return [
    l10n.settingsWeeklyCount(count),
    if (requiredNotificationCount(settings) > maxPlannedReminders)
      l10n.settingsReminderCapped(maxPlannedReminders),
  ].join(' ');
}

Future<void> _editSchedule(
  BuildContext context,
  WidgetRef ref,
  ReminderSchedule? existing,
) async {
  final result = await showReminderScheduleEditor(context, existing: existing);
  if (result == null) return;
  final notifier = ref.read(settingsProvider.notifier);
  final schedule = result.schedule;
  if (schedule == null) {
    await notifier.removeReminderSchedule(existing!.id);
  } else {
    await notifier.saveReminderSchedule(schedule);
  }
  await rescheduleReminders(ref);
}

/// 알림 구간 한 줄. 시간을 크게, 요일·간격·장수는 작게.
class _ReminderScheduleRow extends StatelessWidget {
  final ReminderSchedule schedule;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggle;
  const _ReminderScheduleRow({
    required this.schedule,
    required this.onTap,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final start = ReminderSchedule.formatMinutes(schedule.startMinutes);
    final end = ReminderSchedule.formatMinutes(schedule.endMinutes);
    final slots = schedule.slotMinutes.length;
    return InkWell(
      onTap: onTap,
      child: Opacity(
        opacity: schedule.enabled ? 1 : 0.55,
        child: Container(
          constraints: const BoxConstraints(minHeight: 72),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.chip)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      start == end ? start : '$start – $end',
                      style: TextStyle(
                        fontSize: 24,
                        height: 1.1,
                        fontWeight: FontWeight.w300,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [
                        schedule.weekdaysLabel(l10n),
                        if (slots > 1)
                          ReminderSchedule.intervalLabel(
                            l10n,
                            schedule.intervalMinutes,
                          ),
                        l10n.reminderCardCount(schedule.wordCount),
                      ].join(' · '),
                      style: TextStyle(fontSize: 12, color: AppColors.sub2),
                    ),
                  ],
                ),
              ),
              Switch(value: schedule.enabled, onChanged: onToggle),
            ],
          ),
        ),
      ),
    );
  }
}

/// 고른 번역 언어의 예문 해석 파일을 받았는지 보여 준다.
/// 예문 해석 데이터: 받기 스위치·받은 버전·업데이트 확인.
class _ExampleDataRows extends ConsumerStatefulWidget {
  const _ExampleDataRows();

  @override
  ConsumerState<_ExampleDataRows> createState() => _ExampleDataRowsState();
}

class _ExampleDataRowsState extends ConsumerState<_ExampleDataRows> {
  bool _checking = false;

  Future<void> _setEnabled(bool value, TranslationLanguage language) async {
    final packs = ref.read(translationPacksProvider);
    await ref.read(settingsProvider.notifier).setExampleData(value);
    if (value) {
      packs.prefetch(language);
    } else {
      await packs.removeAll();
    }
  }

  Future<void> _checkUpdate(TranslationLanguage language) async {
    final packs = ref.read(translationPacksProvider);
    final before = packs.status.value[language]?.version;
    setState(() => _checking = true);
    final status = await packs.checkUpdate(language);
    if (!mounted) return;
    setState(() => _checking = false);
    final l10n = context.l10n;
    final version = status.version;
    final message = status.state == PackState.failed || version == null
        ? l10n.settingsPackFailed
        : version == before
        ? l10n.settingsPackUpToDate(version)
        : l10n.settingsPackUpdated(version);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (language, enabled) = ref.watch(
      settingsProvider.select(
        (s) => (s.translationLanguage, s.exampleData == true),
      ),
    );
    final packs = ref.watch(translationPacksProvider);
    return ValueListenableBuilder(
      valueListenable: packs.status,
      builder: (context, statuses, _) {
        final status = statuses[language];
        final size = '${((status?.bytes ?? 0) / 1e6).toStringAsFixed(1)}MB';
        final String subtitle;
        if (!language.hasTranslations) {
          subtitle = l10n.settingsPackNotNeeded;
        } else if (!enabled || status == null) {
          subtitle = l10n.settingsPackNone;
        } else {
          subtitle = switch (status.state) {
            PackState.none => l10n.settingsPackNone,
            PackState.downloading => l10n.settingsPackDownloading(size),
            PackState.failed => l10n.settingsPackFailed,
            PackState.ready =>
              status.version == null
                  ? l10n.settingsPackReady(size)
                  : l10n.settingsPackVersion(status.version!, size),
          };
        }
        final canUpdate = enabled && language.hasTranslations;
        return Column(
          children: [
            BlockRow(
              key: const ValueKey('settings-example-data'),
              title: l10n.settingsExampleData,
              subtitle: subtitle,
              divider: canUpdate,
              minHeight: 64,
              trailing: Switch(
                value: enabled,
                onChanged: language.hasTranslations
                    ? (v) => _setEnabled(v, language)
                    : null,
              ),
            ),
            if (canUpdate)
              BlockRow(
                key: const ValueKey('settings-example-update'),
                title: status?.state == PackState.failed
                    ? l10n.settingsPackRetry
                    : l10n.settingsPackUpdate,
                divider: false,
                trailing: _checking || status?.state == PackState.downloading
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const ChevronValue(''),
                onTap: _checking ? null : () => _checkUpdate(language),
              ),
          ],
        );
      },
    );
  }
}
