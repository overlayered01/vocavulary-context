import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/migration.dart';
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
                      await _reschedule(ref);
                    } else {
                      await notifications.cancelDailyReminder();
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
                SwitchListTile(
                  title: const Text('방해금지 시간'),
                  subtitle: const Text(
                    '이 시간대와 겹치면 알림을 구간이 끝난 뒤로 미뤄요.',
                    style: TextStyle(fontSize: 11),
                  ),
                  value: settings.quietEnabled,
                  activeThumbColor: AppColors.ink,
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
                if (user != null) ...[
                  ListTile(
                    title: Text(user.email ?? user.id),
                    trailing: const Text(
                      '로그아웃',
                      style: TextStyle(color: AppColors.sub),
                    ),
                    onTap: () => ref.read(authServiceProvider).signOut(),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.cloud_upload_outlined,
                      color: AppColors.ink,
                    ),
                    title: const Text('이 기기의 단어장 가져오기'),
                    subtitle: const Text(
                      '로컬 모드에서 만든 단어장을 클라우드로 복사해요.',
                      style: TextStyle(fontSize: 11),
                    ),
                    onTap: () => _importLocal(context, ref),
                  ),
                ] else
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

/// 로컬 단어장을 클라우드로 이관한다. (로그인 상태에서만 노출되는 진입점)
Future<void> _importLocal(BuildContext context, WidgetRef ref) async {
  final repo = ref.read(repositoryProvider);
  if (!repo.isCloud) return;
  final local = ref.read(localRepositoryProvider);
  final books = await local.getWordbooks();
  if (!context.mounted) return;

  if (books.isEmpty) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('가져올 로컬 단어장이 없어요.')));
    return;
  }

  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('로컬 단어장 가져오기'),
      content: Text(
        '이 기기에서 만든 단어장 ${books.length}개를 클라우드로 복사할까요?\n'
        '이미 클라우드에 있는 단어장은 건너뜁니다.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('가져오기'),
        ),
      ],
    ),
  );
  if (ok != true || !context.mounted) return;

  final migrated = await migrateLocalToCloud(local, repo);
  invalidateData(ref);
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        migrated > 0 ? '단어장 $migrated개를 가져왔어요.' : '모든 단어장이 이미 클라우드에 있어요.',
      ),
    ),
  );
}

String _formatTime(int hour, int minute) =>
    '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

/// 최신 설정값으로 복습 알림을 다시 예약한다. (꺼져 있으면 아무것도 안 함)
Future<void> _reschedule(WidgetRef ref) async {
  final s = ref.read(settingsProvider);
  if (!s.reminderEnabled) return;
  await ref
      .read(notificationServiceProvider)
      .scheduleDailyReminder(
        hour: s.reminderHour,
        minute: s.reminderMinute,
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
