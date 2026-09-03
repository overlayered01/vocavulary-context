import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/srs.dart';
import '../models/study_log.dart';
import '../models/word.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/speak_button.dart';

/// 복습 방식.
enum ReviewMode {
  /// 예문 보고 단어 직접 입력 (MVP 기본).
  input,

  /// 예문 빈칸 채우기 — 4개 보기 중 고르는 객관식.
  choice,
}

/// 예문 중심 복습 화면. [mode]에 따라 직접 입력 또는 객관식으로 출제한다.
class ReviewScreen extends ConsumerStatefulWidget {
  final ReviewMode mode;
  const ReviewScreen({super.key, this.mode = ReviewMode.input});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  List<Word> _session = [];

  /// 객관식 모드: 문제별 보기 목록 (정답 포함, 섞인 순서 고정).
  List<List<String>> _choices = [];
  int _index = 0;
  int _correct = 0;
  bool _loading = true;
  bool _revealed = false;
  bool _wasCorrect = false;
  final _input = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(repositoryProvider);
    final settings = ref.read(settingsProvider);
    final all = await repo.getAllWords();
    final session = Srs.buildSession(
      all,
      DateTime.now(),
      mixRatio: settings.reviewMixRatio,
      sessionSize: settings.sessionSize,
    );
    setState(() {
      _session = session;
      if (widget.mode == ReviewMode.choice) {
        _choices = _buildChoices(session, all);
      }
      _loading = false;
    });
  }

  /// 문제별로 정답 + 다른 단어에서 뽑은 오답 최대 3개를 섞어 보기를 만든다.
  List<List<String>> _buildChoices(List<Word> session, List<Word> all) {
    final rng = Random();
    final seen = <String>{};
    final pool = <String>[
      for (final w in all)
        if (seen.add(w.term.toLowerCase())) w.term,
    ];
    return [
      for (final w in session)
        ([
          w.term,
          ...(pool
                  .where((t) => t.toLowerCase() != w.term.toLowerCase())
                  .toList()
                ..shuffle(rng))
              .take(3),
        ]..shuffle(rng)),
    ];
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Word get _current => _session[_index];

  /// 예문에서 정답 단어를 빈칸으로 가린 문자열.
  ///
  /// 단어 경계에서 시작하는 변형형까지 가린다 (run → running, runs).
  /// 반대로 다른 단어 속 부분 일치는 가리지 않는다 (art ↛ part).
  String _clozeSentence(Word w) {
    if (w.examples.isEmpty) return '(예문이 없습니다 — 뜻을 보고 단어를 입력하세요)';
    final s = w.examples.first.sentence;
    final pattern = RegExp(
      '\\b${RegExp.escape(w.term)}\\w*',
      caseSensitive: false,
    );
    return s.replaceAll(pattern, '______');
  }

  /// 입력을 채점해 공개한다.
  Future<void> _check() => _reveal(Srs.checkAnswer(_input.text, _current.term));

  /// '잘 모르겠어요' — 입력과 무관하게 오답 처리 후 정답을 공개한다.
  Future<void> _giveUp() => _reveal(false);

  Future<void> _reveal(bool ok) async {
    final repo = ref.read(repositoryProvider);
    final now = DateTime.now();
    final updated = ok
        ? Srs.applyCorrect(_current, now)
        : Srs.applyWrong(_current, now);
    await repo.upsertWord(updated);
    await repo.addStudyLog(
      StudyLog(id: '', wordId: _current.id, correct: ok, studiedAt: now),
    );
    // 매 문제마다 갱신해 두면 중간에 나가도 홈 통계가 어긋나지 않는다.
    invalidateData(ref);

    setState(() {
      _revealed = true;
      _wasCorrect = ok;
      if (ok) _correct++;
    });
  }

  void _next() {
    if (_index + 1 >= _session.length) {
      setState(() => _index = _session.length); // 완료 상태로
      return;
    }
    setState(() {
      _index++;
      _revealed = false;
      _input.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_session.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('예문 복습')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Text(
              '지금 복습할 단어가 없어요.\n단어를 추가하거나 나중에 다시 오세요.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.sub, fontSize: 15),
            ),
          ),
        ),
      );
    }
    if (_index >= _session.length) {
      return _SummaryView(
        correct: _correct,
        total: _session.length,
        onClose: () => Navigator.pop(context),
      );
    }

    final w = _current;
    final progress = (_index) / _session.length;
    final isMixed = w.status == LearnStatus.completed;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.mode == ReviewMode.choice ? '빈칸 채우기' : '예문 복습'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${_index + 1} / ${_session.length}',
                style: const TextStyle(color: AppColors.sub, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.line,
              color: AppColors.ink,
              minHeight: 4,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.mode == ReviewMode.choice
                      ? '예문과 뜻을 보고 알맞은 단어를 고르세요'
                      : '예문과 뜻을 보고 단어를 입력하세요',
                  style: const TextStyle(color: AppColors.sub, fontSize: 13),
                ),
                SpeakButton(
                  text: w.examples.isNotEmpty
                      ? w.examples.first.sentence
                      : w.term,
                  tooltip: '예문 듣기',
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 빈칸 예문 카드
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _clozeSentence(w),
                    style: const TextStyle(fontSize: 16, height: 1.6),
                  ),
                  const Divider(height: 20),
                  Text(
                    '${w.meaning}${w.partOfSpeech.isNotEmpty ? " · ${w.partOfSpeech}" : ""}${w.phonetic.isNotEmpty ? " ${w.phonetic}" : ""}',
                    style: const TextStyle(color: AppColors.sub, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (!_revealed && widget.mode == ReviewMode.choice) ...[
              for (final option in _choices[_index])
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _reveal(Srs.checkAnswer(option, w.term)),
                      child: Text(option, style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
              Center(
                child: TextButton(
                  onPressed: _giveUp,
                  child: const Text(
                    '잘 모르겠어요',
                    style: TextStyle(color: AppColors.sub),
                  ),
                ),
              ),
            ] else if (!_revealed) ...[
              TextField(
                controller: _input,
                autofocus: true,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink,
                ),
                decoration: const InputDecoration(hintText: '단어 입력'),
                onSubmitted: (_) => _check(),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  '힌트: ${w.inputHint}',
                  style: const TextStyle(color: AppColors.sub, fontSize: 12),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _giveUp,
                      child: const Text('잘 모르겠어요'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _check,
                      child: const Text('정답 확인'),
                    ),
                  ),
                ],
              ),
            ] else
              _FeedbackBlock(
                word: w,
                wasCorrect: _wasCorrect,
                isMixed: isMixed,
                onNext: _next,
              ),
          ],
        ),
      ),
    );
  }
}

class _FeedbackBlock extends StatelessWidget {
  final Word word;
  final bool wasCorrect;
  final bool isMixed;
  final VoidCallback onNext;
  const _FeedbackBlock({
    required this.word,
    required this.wasCorrect,
    required this.isMixed,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: wasCorrect ? AppColors.card : AppColors.bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: wasCorrect ? AppColors.line : AppColors.ink,
              width: wasCorrect ? 1 : 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                wasCorrect ? Icons.check_circle_outline : Icons.highlight_off,
                color: AppColors.ink,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wasCorrect ? '정답입니다' : '아쉬워요. 정답은',
                      style: const TextStyle(
                        color: AppColors.sub,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          word.term,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        SpeakButton(text: word.term),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (word.examples.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            word.examples.first.sentence,
            style: const TextStyle(fontSize: 14),
          ),
          if (word.examples.first.translation.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                word.examples.first.translation,
                style: const TextStyle(color: AppColors.sub, fontSize: 13),
              ),
            ),
        ],
        if (isMixed) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '복습 섞기로 다시 나온 단어예요 (학습완료)',
              style: TextStyle(color: AppColors.sub, fontSize: 12),
            ),
          ),
        ],
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(onPressed: onNext, child: const Text('다음')),
        ),
      ],
    );
  }
}

class _SummaryView extends StatelessWidget {
  final int correct;
  final int total;
  final VoidCallback onClose;
  const _SummaryView({
    required this.correct,
    required this.total,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0 : (correct * 100 / total).round();
    return Scaffold(
      appBar: AppBar(title: const Text('복습 완료')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$pct%',
                style: const TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '복습을 완료했어요',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                '$total문제 중 $correct개 정답',
                style: const TextStyle(color: AppColors.sub),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onClose,
                  child: const Text('홈으로'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
