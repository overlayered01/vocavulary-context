import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import '../theme.dart';
import 'login_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final notifications = ref.read(notificationServiceProvider);
    final cloudAvailable = ref.watch(cloudAvailableProvider);
    final user = ref.watch(authUserProvider).asData?.value;

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
                    activeColor: AppColors.ink,
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
                  activeThumbColor: AppColors.ink,
                  onChanged: (v) async {
                    await notifier.setReminderEnabled(v);
                    if (v) {
                      await notifications.requestPermissions();
                      await notifications.scheduleDailyReminder(
                        hour: settings.reminderHour,
                        minute: settings.reminderMinute,
                      );
                    } else {
                      await notifications.cancelDailyReminder();
                    }
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('알림 시간'),
                  trailing: Text(
                    '${settings.reminderHour.toString().padLeft(2, '0')}:${settings.reminderMinute.toString().padLeft(2, '0')}',
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
                      if (settings.reminderEnabled) {
                        await notifications.scheduleDailyReminder(
                          hour: picked.hour,
                          minute: picked.minute,
                        );
                      }
                    }
                  },
                ),
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
          const SizedBox(height: 18),

          // 계정·동기화
          const _SectionLabel('계정 · 동기화'),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('클라우드 동기화'),
                  trailing: Text(
                    user != null ? '켜짐' : '꺼짐',
                    style: TextStyle(
                      color: user != null ? AppColors.ink : AppColors.sub,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                const Divider(height: 1),
                if (user != null)
                  ListTile(
                    title: Text(user.email ?? user.id),
                    trailing: const Text(
                      '로그아웃',
                      style: TextStyle(color: AppColors.sub),
                    ),
                    onTap: () => ref.read(authServiceProvider).signOut(),
                  )
                else
                  ListTile(
                    leading: const Icon(Icons.login, color: AppColors.ink),
                    title: Text(
                      cloudAvailable
                          ? '로그인하고 기기 간 동기화'
                          : 'Supabase 미설정 — 로컬 모드',
                    ),
                    subtitle: cloudAvailable
                        ? null
                        : const Text(
                            'SUPABASE_설정가이드.md 참고',
                            style: TextStyle(fontSize: 11),
                          ),
                    enabled: cloudAvailable,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: cloudAvailable
                        ? () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          )
                        : null,
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
        ],
      ),
    );
  }
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
