import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/review_examples.dart';
import '../data/srs.dart';
import '../l10n/l10n.dart';
import '../models/study_log.dart';
import '../models/word.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/panel.dart';
import '../widgets/speak_button.dart';

/// 복습 방식.
enum ReviewMode {
  /// 예문 보고 단어 직접 입력. 예문이 있는 카드만.
  input,

  /// 예문 빈칸 채우기 — 4개 보기 중 고르는 객관식. 예문이 있는 카드만.
  choice,

  /// 뜻 보고 단어 맞추기. 예문 없이 모든 카드. 답 방식은 설정을 따른다.
  meaning,

  /// 홈의 시작: 예문이 있으면 빈칸, 없으면 뜻을 보고 맞춘다. 답 방식은 설정을 따른다.
  mixed;

  /// 예문이 있는 카드만 내는 방식.
  bool get examplesOnly => this == input || this == choice;

  /// 보기 4개 중 고르는지. [input]·[choice]는 정해져 있고 나머지는 설정
  /// ([answerByChoice])을 따른다. 기본은 직접 쓰기.
  bool usesChoices({bool answerByChoice = false}) => switch (this) {
    input => false,
    choice => true,
    meaning || mixed => answerByChoice,
  };
}

/// 예문 중심 복습 화면. 정답을 확인하면 같은 카드 위에서 단어가 채워지고,
/// 사용자가 카드를 남기거나 버린다.
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
  List<int> _exampleIndexes = [];
  int _index = 0;
  int _remaining = 0;
  bool _loading = true;
  bool _revealed = false;
  bool _busy = false;

  /// 객관식에서 방금 누른 보기. 정답 공개 전 잠깐 색으로 표시한다.
  String? _picked;
  bool _pickedCorrect = false;

  /// 정답 공개 시 SRS를 반영한 단어. 버리기에서 마저 저장한다.
  Word? _graded;
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
    final mode = widget.mode;
    final session = Srs.buildSession(
      mode.examplesOnly
          ? [
              for (final w in all)
                if (w.examples.isNotEmpty) w,
            ]
          : all,
      DateTime.now(),
      mixRatio: settings.reviewMixRatio,
      sessionSize: settings.sessionSize,
    );
    if (!mounted) return;
    setState(() {
      _session = session;
      _remaining = all.where((w) => w.status != LearnStatus.completed).length;
      _exampleIndexes = [
        for (final word in session)
          mode == ReviewMode.meaning ? -1 : ReviewExamples.initialIndex(word),
      ];
      if (_useChoices) {
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

  /// 이번 복습에서 보기 중 고르는지 (설정의 문제 방식 반영).
  late final bool _useChoices = widget.mode.usesChoices(
    answerByChoice: ref.read(settingsProvider).answerByChoice,
  );

  Word get _current => _session[_index];

  Example? get _currentExample {
    final exampleIndex = _exampleIndexes[_index];
    if (exampleIndex < 0) return null;
    return _current.examples[exampleIndex];
  }

  Future<void> _pick(String option) async {
    if (_busy || _revealed) return;
    final ok = Srs.checkAnswer(option, _current.term);
    setState(() {
      _busy = true;
      _picked = option;
      _pickedCorrect = ok;
    });
    await Future<void>.delayed(const Duration(milliseconds: 260));
    if (!mounted) return;
    await _reveal(ok);
  }

  Future<void> _reveal(bool ok) async {
    if (_revealed) return;
    setState(() => _busy = true);
    final repo = ref.read(repositoryProvider);
    final now = DateTime.now();
    final graded = ok
        ? Srs.applyCorrect(_current, now)
        : Srs.applyWrong(_current, now);
    // 버릴지는 사용자가 정하므로, 마지막 단계에 닿아도 여기서는 덱에 남긴다.
    final kept = Srs.keep(graded);
    await repo.upsertWord(kept);
    await repo.addStudyLog(
      StudyLog(id: '', wordId: _current.id, correct: ok, studiedAt: now),
    );
    invalidateData(ref);
    if (!mounted) return;
    setState(() {
      _graded = kept;
      _revealed = true;
      _busy = false;
    });
  }

  Future<void> _decide({required bool discard}) async {
    final graded = _graded;
    if (graded == null || _busy) return;
    setState(() => _busy = true);
    final wasInDeck = _current.status != LearnStatus.completed;
    if (discard) {
      await ref
          .read(repositoryProvider)
          .upsertWord(Srs.discard(graded, DateTime.now()));
      invalidateData(ref);
    }
    if (!mounted) return;
    setState(() {
      if (discard && wasInDeck) {
        _remaining--;
      } else if (!discard && !wasInDeck) {
        _remaining++;
      }
      _busy = false;
      _revealed = false;
      _picked = null;
      _graded = null;
      _input.clear();
      _index++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.panel,
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_session.isEmpty || _index >= _session.length) {
      return _DoneView(
        empty: _session.isEmpty,
        total: _session.length,
        remaining: _remaining,
      );
    }

    final w = _current;
    final example = _currentExample;
    return Scaffold(
      backgroundColor: AppColors.panel,
      body: SafeArea(
        child: ContentWidth(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    IconButton(
                      tooltip: l10n.commonClose,
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close_rounded, color: AppColors.onPanel),
                    ),
                    const Spacer(),
                    Text(
                      '${_two(_index + 1)} / ${_two(_session.length)} · '
                      '${l10n.reviewRemaining(_remaining)}',
                      key: const ValueKey('review-progress'),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onPanelSub,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: (_index + (_revealed ? 1 : 0)) / _session.length,
                      minHeight: 3,
                      color: AppColors.point,
                      backgroundColor: AppColors.panelLine,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _QuizCard(
                          key: ValueKey('card-$_index'),
                          word: w,
                          example: example,
                          revealed: _revealed,
                        ),
                        const SizedBox(height: 18),
                        if (!_revealed && _useChoices)
                          _ChoiceGrid(
                            options: _choices[_index],
                            picked: _picked,
                            pickedCorrect: _pickedCorrect,
                            onPick: _pick,
                          ),
                        if (!_revealed && !_useChoices)
                          _AnswerInput(
                            controller: _input,
                            onSubmit: () =>
                                _reveal(Srs.checkAnswer(_input.text, w.term)),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  layoutBuilder: (current, previous) => Stack(
                    fit: StackFit.passthrough,
                    alignment: Alignment.bottomCenter,
                    children: [...previous, ?current],
                  ),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween(
                        begin: const Offset(0, 0.3),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: _revealed
                      ? Row(
                          key: const ValueKey('decide'),
                          children: [
                            Expanded(
                              child: PanelOutlineButton(
                                label: l10n.reviewKeep,
                                onPressed: () => _decide(discard: false),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: PointButton(
                                key: const ValueKey('review-discard'),
                                label: l10n.reviewDiscard,
                                onPressed: () => _decide(discard: true),
                              ),
                            ),
                          ],
                        )
                      : _useChoices
                      ? PanelOutlineButton(
                          key: const ValueKey('dont-know'),
                          label: l10n.reviewDontKnow,
                          height: 52,
                          onPressed: _busy ? null : () => _reveal(false),
                        )
                      : Row(
                          key: const ValueKey('input-actions'),
                          children: [
                            Expanded(
                              child: PanelOutlineButton(
                                label: l10n.reviewDontKnow,
                                onPressed: _busy ? null : () => _reveal(false),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: PointButton(
                                label: l10n.reviewCheckAnswer,
                                onPressed: _busy
                                    ? null
                                    : () => _reveal(
                                        Srs.checkAnswer(_input.text, w.term),
                                      ),
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _two(int n) => n.toString().padLeft(2, '0');
}

/// 예문 카드. [revealed]가 되면 빈칸이 채워지고 단어·뜻이 아래로 펼쳐진다.
class _QuizCard extends StatelessWidget {
  final Word word;
  final Example? example;
  final bool revealed;
  const _QuizCard({
    super.key,
    required this.word,
    required this.example,
    required this.revealed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final example = this.example;
    final sentenceStyle = TextStyle(
      fontSize: 25,
      fontWeight: FontWeight.w300,
      height: 1.45,
      color: AppColors.ink,
    );
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 16,
          right: 16,
          top: -10,
          height: 40,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.tab,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(22),
              ),
            ),
          ),
        ),
        Material(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(26),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 14, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    PosChip(word.partOfSpeech),
                    const Spacer(),
                    SpeakButton(
                      text: example?.sentence ?? word.term,
                      isSentence: example != null,
                      tooltip: l10n.speakListenExample,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: example == null
                      ? Text(
                          word.meanings.join(', '),
                          key: const ValueKey('meanings-prompt'),
                          style: sentenceStyle.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      : TweenAnimationBuilder<double>(
                          key: ValueKey('sentence-$revealed'),
                          tween: Tween(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 380),
                          builder: (context, t, _) => ExampleSentence(
                            sentence: example.sentence,
                            term: word.term,
                            blank: !revealed,
                            highlight: AppColors.point.withValues(
                              alpha: revealed ? t : 1,
                            ),
                            style: sentenceStyle,
                          ),
                        ),
                ),
                if (example != null && example.translation.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ExampleTranslation(
                      key: const ValueKey('quiz-translation'),
                      translation: example.translation,
                      meanings: word.meanings,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: AppColors.sub,
                      ),
                    ),
                  ),
                ],
                AnimatedSize(
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.topCenter,
                  child: !revealed
                      ? const SizedBox(width: double.infinity)
                      : Padding(
                          padding: const EdgeInsets.only(top: 20, right: 10),
                          child: Container(
                            padding: const EdgeInsets.only(top: 16),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(color: AppColors.chip),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        word.term,
                                        key: const ValueKey('answer-term'),
                                        style: TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.w300,
                                          letterSpacing: -0.5,
                                          color: AppColors.ink,
                                        ),
                                      ),
                                      if (word.phonetic.isNotEmpty)
                                        Text(
                                          word.phonetic,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.sub,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Flexible(
                                  child: Text(
                                    word.meanings.join(', '),
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ChoiceGrid extends StatelessWidget {
  final List<String> options;
  final String? picked;
  final bool pickedCorrect;
  final ValueChanged<String> onPick;
  const _ChoiceGrid({
    required this.options,
    required this.picked,
    required this.pickedCorrect,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 8) / 2;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in options)
              SizedBox(
                width: width,
                height: 58,
                child: _ChoiceButton(
                  label: option,
                  state: picked != option ? null : pickedCorrect,
                  onTap: () => onPick(option),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  final String label;

  /// null: 기본, true: 정답으로 고름, false: 오답으로 고름.
  final bool? state;
  final VoidCallback onTap;
  const _ChoiceButton({
    required this.label,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = switch (state) {
      true => AppColors.point,
      false => AppColors.ink,
      null => AppColors.panelHigh,
    };
    final fg = state == true ? AppColors.onPoint : AppColors.onPanel;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                  color: fg,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnswerInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;
  const _AnswerInput({required this.controller, required this.onSubmit});

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    autofocus: true,
    textAlign: TextAlign.center,
    textInputAction: TextInputAction.done,
    style: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w300,
      color: AppColors.ink,
    ),
    decoration: InputDecoration(
      fillColor: AppColors.card,
      hintText: context.l10n.reviewInputHint,
      hintStyle: TextStyle(color: AppColors.sub, fontSize: 16),
    ),
    onSubmitted: (_) => onSubmit(),
  );
}

/// 세션을 마쳤거나 꺼낼 카드가 없을 때. 남은 카드 수만 크게 보여 준다.
class _DoneView extends StatelessWidget {
  final bool empty;
  final int total;
  final int remaining;
  const _DoneView({
    required this.empty,
    required this.total,
    required this.remaining,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.panel,
      body: SafeArea(
        child: ContentWidth(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(26, 24, 26, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                Text(
                  empty ? l10n.reviewEmpty : l10n.reviewDoneTitle(total),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onPanelSub,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.homeRemainingCards,
                  style: TextStyle(fontSize: 13, color: AppColors.onPanelSub),
                ),
                Text(
                  '$remaining',
                  key: const ValueKey('done-remaining'),
                  style: TextStyle(
                    fontSize: 96,
                    height: 1,
                    fontWeight: FontWeight.w200,
                    letterSpacing: -4,
                    color: AppColors.point,
                  ),
                ),
                const Spacer(flex: 2),
                PointButton(
                  label: l10n.reviewGoHome,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
