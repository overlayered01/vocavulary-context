import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../models/reminder_schedule.dart';
import '../theme.dart';
import 'panel.dart';

/// 편집 결과. [schedule]이 null이면 삭제를 뜻한다.
class ReminderScheduleEdit {
  final ReminderSchedule? schedule;
  const ReminderScheduleEdit(this.schedule);
}

/// 알림 구간 추가·편집 시트. [existing]이 없으면 새 구간을 만든다.
Future<ReminderScheduleEdit?> showReminderScheduleEditor(
  BuildContext context, {
  ReminderSchedule? existing,
}) => showModalBottomSheet<ReminderScheduleEdit>(
  context: context,
  isScrollControlled: true,
  builder: (_) => _ReminderScheduleSheet(existing: existing),
);

class _ReminderScheduleSheet extends StatefulWidget {
  final ReminderSchedule? existing;
  const _ReminderScheduleSheet({this.existing});

  @override
  State<_ReminderScheduleSheet> createState() => _ReminderScheduleSheetState();
}

class _ReminderScheduleSheetState extends State<_ReminderScheduleSheet> {
  late ReminderSchedule _schedule =
      widget.existing ??
      ReminderSchedule(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        startMinutes: 9 * 60,
        endMinutes: 21 * 60,
        intervalMinutes: 180,
      );

  Future<void> _pickTime({required bool start}) async {
    final current = start ? _schedule.startMinutes : _schedule.endMinutes;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current ~/ 60, minute: current % 60),
    );
    if (picked == null || !mounted) return;
    final minutes = picked.hour * 60 + picked.minute;
    setState(
      () => _schedule = start
          ? _schedule.copyWith(startMinutes: minutes)
          : _schedule.copyWith(endMinutes: minutes),
    );
  }

  Widget _timeTile(String label, int minutes, {required bool start}) =>
      Expanded(
        child: Material(
          color: AppColors.chip,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => _pickTime(start: start),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 11, color: AppColors.sub),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    ReminderSchedule.formatMinutes(minutes),
                    style: TextStyle(
                      fontSize: 28,
                      height: 1.1,
                      fontWeight: FontWeight.w300,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 8),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.sub2,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final slots = _schedule.slotMinutes;
    final crossesMidnight = _schedule.endMinutes < _schedule.startMinutes;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.existing == null
                        ? l10n.reminderAddSchedule
                        : l10n.reminderEditSchedule,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                if (widget.existing != null)
                  TextButton(
                    onPressed: () => Navigator.pop(
                      context,
                      const ReminderScheduleEdit(null),
                    ),
                    child: Text(
                      l10n.commonDelete,
                      style: TextStyle(color: AppColors.sub),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _timeTile(
                  l10n.reminderStart,
                  _schedule.startMinutes,
                  start: true,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: AppColors.sub,
                  ),
                ),
                _timeTile(
                  l10n.reminderEnd,
                  _schedule.endMinutes,
                  start: false,
                ),
              ],
            ),
            if (crossesMidnight)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  l10n.reminderCrossesMidnight,
                  style: TextStyle(fontSize: 11, color: AppColors.sub),
                ),
              ),
            _label(l10n.reminderWeekdaysTitle),
            Row(
              children: [
                for (final day in ReminderSchedule.allWeekdays)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: _WeekdayToggle(
                        label: l10n.weekday(day),
                        selected: _schedule.weekdays.contains(day),
                        onTap: () => setState(
                          () => _schedule = _schedule.copyWith(
                            weekdays: _schedule.weekdays.contains(day)
                                ? [
                                    for (final d in _schedule.weekdays)
                                      if (d != day) d,
                                  ]
                                : [..._schedule.weekdays, day],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            if (_schedule.weekdays.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  l10n.reminderWeekdaysRequired,
                  style: const TextStyle(fontSize: 11, color: AppColors.warn),
                ),
              ),
            _label(l10n.reminderInterval),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final minutes in {
                  ...ReminderSchedule.intervalOptions,
                  _schedule.intervalMinutes,
                })
                  ChoiceChip(
                    key: ValueKey('interval-$minutes'),
                    label: Text(ReminderSchedule.intervalLabel(l10n, minutes)),
                    selected: _schedule.intervalMinutes == minutes,
                    showCheckmark: false,
                    selectedColor: AppColors.ink,
                    labelStyle: TextStyle(
                      fontSize: 13,
                      color: _schedule.intervalMinutes == minutes
                          ? Colors.white
                          : AppColors.sub2,
                    ),
                    onSelected: (_) => setState(
                      () => _schedule = _schedule.copyWith(
                        intervalMinutes: minutes,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.reminderWordsPerAlert,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.sub2,
                    ),
                  ),
                ),
                StepperControl(
                  value: l10n.reminderCardCount(_schedule.wordCount),
                  minusLabel: l10n.reminderDecreaseWords,
                  plusLabel: l10n.reminderIncreaseWords,
                  onMinus: _schedule.wordCount <= 1
                      ? null
                      : () => setState(
                          () => _schedule = _schedule.copyWith(
                            wordCount: _schedule.wordCount - 1,
                          ),
                        ),
                  onPlus: _schedule.wordCount >= ReminderSchedule.maxWordCount
                      ? null
                      : () => setState(
                          () => _schedule = _schedule.copyWith(
                            wordCount: _schedule.wordCount + 1,
                          ),
                        ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: BoxDecoration(
                color: AppColors.panel,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.reminderPerDayTotal(
                      slots.length,
                      slots.length * _schedule.wordCount,
                    ),
                    key: const ValueKey('reminder-preview'),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.onPanelSub,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final m in slots.take(12))
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.panelHigh,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            ReminderSchedule.formatMinutes(m),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                              color: AppColors.onPanel,
                            ),
                          ),
                        ),
                      if (slots.length > 12)
                        Text(
                          '\u2026',
                          style: TextStyle(color: AppColors.onPanel),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                key: const ValueKey('reminder-save'),
                onPressed: _schedule.weekdays.isEmpty
                    ? null
                    : () => Navigator.pop(
                        context,
                        ReminderScheduleEdit(_schedule),
                      ),
                child: Text(l10n.commonSave),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekdayToggle extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _WeekdayToggle({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.point : AppColors.chip,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: selected ? AppColors.onPoint : AppColors.sub,
          ),
        ),
      ),
    ),
  );
}
