import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:vocabulary/data/review_examples.dart';
import 'package:vocabulary/data/srs.dart';
import 'package:vocabulary/l10n/l10n.dart';
import 'package:vocabulary/models/app_settings.dart';
import 'package:vocabulary/models/reminder_schedule.dart';
import 'package:vocabulary/models/word.dart';
import 'package:vocabulary/services/example_source_service.dart';
import 'package:vocabulary/services/reminder_planner.dart';

final ko = lookupAppLocalizations(const Locale('ko'));

void main() {
  test('동시에 요청한 예문과 최근 조회 결과를 재사용한다', () async {
    var requests = 0;
    final pending = Completer<http.Response>();
    final service = ExampleSourceService(
      client: MockClient((_) {
        requests++;
        return pending.future;
      }),
    );
    addTearDown(service.dispose);
    final first = service.fetchExamples(' happy ', limit: 2);
    final second = service.fetchExamples('happy', limit: 2);
    pending.complete(
      http.Response(
        jsonEncode({
          'data': [
            {'text': 'A happy day.'},
            {'text': 'I am happy.'},
          ],
        }),
        200,
      ),
    );
    expect(await first, hasLength(2));
    expect(await second, hasLength(2));
    expect(await service.fetchExamples('happy', limit: 2), hasLength(2));
    expect(requests, 1);
  });

  test('영어 예문 추가 조회가 실패해도 먼저 받은 한국어 예문은 유지한다', () async {
    final service = ExampleSourceService(
      client: MockClient((request) async {
        if (!request.url.queryParameters.containsKey('trans:lang')) {
          return http.Response('', 503);
        }
        return http.Response(
          jsonEncode({
            'data': [
              {
                'text': 'A happy day.',
                'translations': [
                  {'lang': 'kor', 'text': '행복한 하루.'},
                ],
              },
            ],
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );
    addTearDown(service.dispose);
    expect(
      (await service.fetchExamples('happy', limit: 2)).single.translation,
      '행복한 하루.',
    );
  });

  group('Srs', () {
    Word makeWord({LearnStatus status = LearnStatus.fresh}) {
      final now = DateTime(2026, 1, 1);
      return Word(
        id: 'w1',
        wordbookId: 'b1',
        term: 'crucial',
        meaning: '중대한',
        status: status,
        createdAt: now,
        updatedAt: now,
      );
    }

    test('정답 처리 시 단계가 오른다', () {
      final w = makeWord();
      final updated = Srs.applyCorrect(w, DateTime(2026, 1, 1));
      expect(updated.srsStage, 1);
      expect(updated.timesCorrect, 1);
    });

    test('오답 처리 시 단계가 0으로 초기화된다', () {
      final w = makeWord().copyWith(srsStage: 3);
      final updated = Srs.applyWrong(w, DateTime(2026, 1, 1));
      expect(updated.srsStage, 0);
      expect(updated.timesWrong, 1);
    });

    test('채점은 공백/대소문자를 무시한다', () {
      expect(Srs.checkAnswer('  Crucial ', 'crucial'), isTrue);
      expect(Srs.checkAnswer('wrong', 'crucial'), isFalse);
    });

    test('복습 섞기 비율만큼 완료 단어가 포함된다', () {
      final now = DateTime(2026, 1, 1);
      final due = List.generate(
        20,
        (i) => Word(
          id: 'due$i',
          wordbookId: 'b1',
          term: 'word$i',
          meaning: 'm',
          status: LearnStatus.fresh,
          createdAt: now,
          updatedAt: now,
        ),
      );
      final done = List.generate(
        10,
        (i) => Word(
          id: 'done$i',
          wordbookId: 'b1',
          term: 'done$i',
          meaning: 'm',
          status: LearnStatus.completed,
          completedAt: now,
          createdAt: now,
          updatedAt: now,
        ),
      );
      final session = Srs.buildSession(
        [...due, ...done],
        now,
        mixRatio: 20,
        sessionSize: 15,
      );
      final mixed = session
          .where((w) => w.status == LearnStatus.completed)
          .length;
      expect(session.length, 15);
      expect(mixed, 3); // 15 * 20% = 3
    });
  });

  test('단어 대표 이미지를 직렬화하고 복원한다', () {
    final now = DateTime(2026, 1, 1);
    final word = Word(
      id: 'image-word',
      wordbookId: 'b1',
      term: 'apple',
      meaning: '사과',
      imageUrl: 'data:image/png;base64,dGVzdA==',
      createdAt: now,
      updatedAt: now,
    );

    final restored = Word.fromMap(word.toMap());

    expect(restored.imageUrl, word.imageUrl);
  });

  group('알람 구간', () {
    Word word(String term, {LearnStatus status = LearnStatus.learning}) => Word(
      id: term,
      wordbookId: 'b',
      term: term,
      meaning: '$term 뜻',
      status: status,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

    test('이전 버전의 단일 알림 시각을 한 번짜리 구간으로 옮긴다', () {
      final restored = AppSettings.fromMap(const {
        'reminderEnabled': true,
        'reminderHour': 18,
        'reminderMinute': 30,
        'reminderIntervalDays': 7,
      });
      final schedule = restored.reminderSchedules.single;
      expect(schedule.startMinutes, 18 * 60 + 30);
      expect(schedule.slotMinutes, [18 * 60 + 30]);
    });

    test('구간 목록을 직렬화하고 복원한다', () {
      const settings = AppSettings(
        reminderSchedules: [
          ReminderSchedule(
            id: 'a',
            startMinutes: 8 * 60,
            endMinutes: 10 * 60,
            intervalMinutes: 30,
            wordCount: 5,
          ),
          ReminderSchedule(
            id: 'b',
            enabled: false,
            startMinutes: 22 * 60,
            endMinutes: 60,
            intervalMinutes: 90,
          ),
        ],
      );
      final restored = AppSettings.fromMap(
        jsonDecode(jsonEncode(settings.toMap())) as Map<String, dynamic>,
      );
      expect(restored.reminderSchedules.map((s) => s.toMap()).toList(), [
        for (final s in settings.reminderSchedules) s.toMap(),
      ]);
      expect(restored.reminderSchedules.first.slotMinutes, [
        480,
        510,
        540,
        570,
        600,
      ]);
      // 자정을 넘는 구간: 22:00, 23:30, 01:00
      expect(restored.reminderSchedules.last.slotMinutes, [1320, 1410, 60]);
    });

    test('알림을 시각 순으로 만들고 단어 수·중복을 반영한다', () {
      const settings = AppSettings(
        reminderSchedules: [
          ReminderSchedule(
            id: 'a',
            startMinutes: 11 * 60,
            endMinutes: 13 * 60,
            intervalMinutes: 60,
            wordCount: 2,
          ),
          ReminderSchedule(
            id: 'b',
            startMinutes: 13 * 60,
            endMinutes: 13 * 60,
            wordCount: 3,
          ),
          ReminderSchedule(
            id: 'off',
            enabled: false,
            startMinutes: 6 * 60,
            endMinutes: 6 * 60,
          ),
        ],
      );
      final words = [
        word('done', status: LearnStatus.completed),
        word('a'),
        word('b'),
        word('c'),
      ];
      final plan = planReminders(settings, words);
      expect(plan.map((r) => r.minutes), [11 * 60, 12 * 60, 13 * 60]);
      expect(plan.every((r) => r.daily), isTrue);
      expect(plan[0].words.map((w) => w.term), ['a', 'b']);
      expect(plan[1].words.map((w) => w.term), ['c', 'done']);
      expect(plan[2].words.map((w) => w.term), ['a', 'b', 'c']);
      expect(plan[0].body(ko), 'a — a 뜻\nb — b 뜻');
      expect(weeklyReminderCount(settings), 21);
      expect(
        planReminders(settings.copyWith(reminderEnabled: false), words),
        isEmpty,
      );
    });

    test('체크한 요일에만 보내고 자정을 넘긴 시각은 다음 요일로 옮긴다', () {
      const settings = AppSettings(
        reminderSchedules: [
          ReminderSchedule(
            id: 'mwf',
            startMinutes: 9 * 60,
            endMinutes: 9 * 60,
            weekdays: [1, 3, 5],
          ),
          ReminderSchedule(
            id: 'fri-night',
            startMinutes: 23 * 60,
            endMinutes: 30,
            intervalMinutes: 90,
            weekdays: [5],
          ),
        ],
      );
      final plan = planReminders(settings, const []);
      expect(plan.map((r) => '${r.minutes}@${r.weekdays.join(',')}'), [
        '30@6',
        '540@1,3,5',
        '1380@5',
      ]);
      expect(requiredNotificationCount(settings), 5);
      expect(weeklyReminderCount(settings), 5);
      expect(settings.reminderSchedules.first.weekdaysLabel(ko), '월·수·금');
      expect(
        ReminderSchedule.fromMap(
          settings.reminderSchedules.first.toMap(),
        ).weekdays,
        [1, 3, 5],
      );
      expect(
        const ReminderSchedule(
          id: 'x',
          startMinutes: 0,
          endMinutes: 0,
          weekdays: [1, 2, 3, 4, 5],
        ).weekdaysLabel(ko),
        '평일',
      );
    });

    test('예약 알림 수는 기기 제한 안으로 자른다', () {
      const settings = AppSettings(
        reminderSchedules: [
          ReminderSchedule(
            id: 'a',
            startMinutes: 0,
            endMinutes: 23 * 60 + 45,
            intervalMinutes: 15,
          ),
        ],
      );
      expect(requiredNotificationCount(settings), 96);
      expect(planReminders(settings, const []), hasLength(maxPlannedReminders));
    });
  });

  group('복습 예문 순환', () {
    Word makeWord({List<Example> examples = const [], int reviewed = 0}) {
      final now = DateTime(2026, 1, 1);
      return Word(
        id: 'rotation-word',
        wordbookId: 'b1',
        term: 'crucial',
        meaning: '중대한',
        examples: examples,
        timesCorrect: reviewed,
        createdAt: now,
        updatedAt: now,
      );
    }

    test('이전 복습 횟수 다음 예문부터 보여 준다', () {
      final word = makeWord(
        reviewed: 5,
        examples: const [
          Example(sentence: 'First crucial example.'),
          Example(sentence: 'Second crucial example.'),
          Example(sentence: 'Third crucial example.'),
        ],
      );

      expect(ReviewExamples.initialIndex(word), 2);
      expect(ReviewExamples.nextIndex(2, word.examples.length), 0);
    });

    test('예문이 없으면 선택하지 않는다', () {
      expect(ReviewExamples.initialIndex(makeWord()), -1);
      expect(ReviewExamples.nextIndex(-1, 0), -1);
    });
  });

  test('Tatoeba 예문과 한국어 번역을 가져오고 출처를 보존한다', () async {
    final client = MockClient((request) async {
      final requiresKorean = request.url.queryParameters.containsKey(
        'trans:lang',
      );
      final data = requiresKorean
          ? [
              {
                'id': 101,
                'text': 'I read this book.',
                'license': 'CC BY 2.0 FR',
                'translations': [
                  {'lang': 'kor', 'text': '나는 이 책을 읽었다.'},
                ],
              },
            ]
          : [
              {
                'id': 101,
                'text': 'I read this book.',
                'license': 'CC BY 2.0 FR',
                'translations': const [],
              },
              {
                'id': 102,
                'text': 'This book is useful.',
                'license': 'CC BY 2.0 FR',
                'translations': const [],
              },
              {
                'id': 103,
                'text': 'Please open the book.',
                'license': 'CC BY 2.0 FR',
                'translations': const [],
              },
            ];
      return http.Response(
        jsonEncode({'data': data}),
        200,
        headers: const {'content-type': 'application/json; charset=utf-8'},
      );
    });
    final service = ExampleSourceService(client: client);

    final examples = await service.fetchExamples('book', limit: 3);
    service.dispose();

    expect(examples, hasLength(3));
    expect(examples.first.translation, '나는 이 책을 읽었다.');
    expect(examples.first.source, 'Tatoeba');
    expect(examples.first.sourceId, '101');

    final restored = Example.fromMap(examples.first.toMap());
    expect(restored.source, 'Tatoeba');
    expect(restored.license, 'CC BY 2.0 FR');
  });
}
