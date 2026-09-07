import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers.dart';
import '../theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final notifications = ref.read(notificationServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          // 복습 섞기 비율
          const _SectionLabel('복습 섞기 비율'),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('이미 외운 단어 다시 섞기'),
                      Text(
                        '${settings.reviewMixRatio}%',
                        style: const TextStyle(
                          color: AppColors.ink,
                          fontWeight: FontWeight.bold,
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
                    activeColor: AppColors.accentDark,
                    onChanged: (v) => notifier.setMixRatio(v.round()),
                  ),
                  Text(
                    "복습 세트에 '학습완료' 단어를 이 비율만큼 섞어 출제해 장기 기억을 강화해요. "
                    '(예: ${settings.sessionSize}문제 중 ${(settings.sessionSize * settings.reviewMixRatio / 100).round()}문제)',
                    style: const TextStyle(color: AppColors.sub, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),

          // 알람·복습
          const _SectionLabel('알람 · 복습'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('복습 알림 받기'),
                  value: settings.reminderEnabled,
                  activeThumbColor: AppColors.accentDark,
                  activeTrackColor: AppColors.accentSoft,
                  onChanged: (v) async {
                    await notifier.setReminderEnabled(v);
                    if (v) {
                      await notifications.requestPermissions();
                      await _reschedule(ref);
                    } else {
                      await notifications.cancelReminder();
                    }
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('알림 시간'),
                  trailing: Text(
                    _formatTime(settings.reminderHour, settings.reminderMinute),
                    style: const TextStyle(color: AppColors.sub),
                  ),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                        hour: settings.reminderHour,
                        minute: settings.reminderMinute,
                      ),
                    );
                    if (picked != null) {
                      await notifier.setReminderTime(
                        picked.hour,
                        picked.minute,
                      );
                      await _reschedule(ref);
                    }
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('알림 간격'),
                  subtitle: const Text(
                    '선택한 시각을 기준으로 반복해요.',
                    style: TextStyle(fontSize: 11),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _reminderIntervalLabel(settings.reminderIntervalDays),
                        style: const TextStyle(color: AppColors.sub),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.sub,
                      ),
                    ],
                  ),
                  onTap: () async {
                    final days = await _pickReminderInterval(
                      context,
                      settings.reminderIntervalDays,
                    );
                    if (days != null) {
                      await notifier.setReminderIntervalDays(days);
                      await _reschedule(ref);
                    }
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('방해금지 시간'),
                  subtitle: const Text(
                    '이 시간대와 겹치면 알림을 구간이 끝난 뒤로 미뤄요.',
                    style: TextStyle(fontSize: 11),
                  ),
                  value: settings.quietEnabled,
                  activeThumbColor: AppColors.accentDark,
                  activeTrackColor: AppColors.accentSoft,
                  onChanged: (v) async {
                    await notifier.setQuietEnabled(v);
                    await _reschedule(ref);
                  },
                ),
                if (settings.quietEnabled) ...[
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('방해금지 시작'),
                    trailing: Text(
                      _formatTime(
                        settings.quietStartHour,
                        settings.quietStartMinute,
                      ),
                      style: const TextStyle(color: AppColors.sub),
                    ),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(
                          hour: settings.quietStartHour,
                          minute: settings.quietStartMinute,
                        ),
                      );
                      if (picked != null) {
                        await notifier.setQuietStart(
                          picked.hour,
                          picked.minute,
                        );
                        await _reschedule(ref);
                      }
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('방해금지 끝'),
                    trailing: Text(
                      _formatTime(
                        settings.quietEndHour,
                        settings.quietEndMinute,
                      ),
                      style: const TextStyle(color: AppColors.sub),
                    ),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(
                          hour: settings.quietEndHour,
                          minute: settings.quietEndMinute,
                        ),
                      );
                      if (picked != null) {
                        await notifier.setQuietEnd(picked.hour, picked.minute);
                        await _reschedule(ref);
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),

          // 발음·TTS
          const _SectionLabel('발음 · TTS'),
          Card(
            child: Column(
              children: [
                const ListTile(
                  title: Text('기본 발음'),
                  subtitle: Text('단어와 예문을 읽을 기본 억양을 선택하세요.'),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: SegmentedButton<String>(
                    expandedInsets: EdgeInsets.zero,
                    segments: const [
                      ButtonSegment(value: 'en-US', label: Text('미국식')),
                      ButtonSegment(value: 'en-GB', label: Text('영국식')),
                    ],
                    selected: {settings.ttsLocale},
                    onSelectionChanged: (selection) {
                      notifier.setTtsLocale(selection.first);
                    },
                  ),
                ),
                const Divider(height: 1),
                const ListTile(
                  title: Text('음질'),
                  trailing: Text(
                    '기기 TTS(무료)',
                    style: TextStyle(color: AppColors.sub),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text(
              'WordCloud 단어장 · MVP v0.1',
              style: TextStyle(color: AppColors.sub, fontSize: 12),
            ),
          ),
          Center(
            child: TextButton(
              onPressed: () => launchUrl(
                Uri.parse('https://tatoeba.org'),
                mode: LaunchMode.externalApplication,
              ),
              child: const Text(
                '외부 예문: Tatoeba · CC BY 2.0 FR',
                style: TextStyle(color: AppColors.sub, fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatTime(int hour, int minute) =>
    '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

String _reminderIntervalLabel(int days) => switch (days) {
  1 => '매일',
  2 => '2일마다',
  3 => '3일마다',
  7 => '1주마다',
  14 => '2주마다',
  _ => '$days일마다',
};

Future<int?> _pickReminderInterval(BuildContext context, int selected) {
  const options = [1, 2, 3, 7, 14];
  return showDialog<int>(
    context: context,
    builder: (context) => SimpleDialog(
      title: const Text('알림 간격'),
      children: [
        for (final days in options)
          ListTile(
            title: Text(_reminderIntervalLabel(days)),
            trailing: days == selected
                ? const Icon(Icons.check_rounded, color: AppColors.accentDark)
                : null,
            onTap: () => Navigator.pop(context, days),
          ),
      ],
    ),
  );
}

/// 최신 설정값으로 복습 알림을 다시 예약한다. (꺼져 있으면 아무것도 안 함)
Future<void> _reschedule(WidgetRef ref) async {
  final s = ref.read(settingsProvider);
  if (!s.reminderEnabled) return;
  await ref
      .read(notificationServiceProvider)
      .scheduleReminder(
        hour: s.reminderHour,
        minute: s.reminderMinute,
        intervalDays: s.reminderIntervalDays,
        quiet: s.quietWindow,
      );
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        color: AppColors.sub,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
