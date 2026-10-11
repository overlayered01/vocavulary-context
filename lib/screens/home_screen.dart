import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/review_examples.dart';
import '../data/srs.dart';
import '../l10n/l10n.dart';
import '../models/word.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/panel.dart';
import '../widgets/speak_button.dart';
import 'review_screen.dart';
import 'word_add_screen.dart';

/// 홈: 남은 카드 수와 다음 카드의 예문을 먼저 보여 주고 복습을 시작한다.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordsAsync = ref.watch(allWordsProvider);
    final settings = ref.watch(settingsProvider);
    final l10n = context.l10n;

    return wordsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(l10n.homeError(e.toString()))),
      data: (words) {
        final session = Srs.buildSession(
          words,
          DateTime.now(),
          mixRatio: settings.reviewMixRatio,
          sessionSize: settings.sessionSize,
        );
        final remaining = words
            .where((w) => w.status != LearnStatus.completed)
            .length;
        final fresh = session.where((w) => w.status == LearnStatus.fresh);
        final next = session.firstOrNull;

        return PanelPage(
          header: ContentWidth(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(26, 18, 18, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HeaderEyebrow(
                    l10n.appTitle.toUpperCase(),
                    trailing: FilledButton.icon(
                      key: const ValueKey('home-add-word'),
                      onPressed: () => openWordAdd(context, ref),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: Text(l10n.wordAddWord),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.ink,
                        foregroundColor: AppColors.card,
                        minimumSize: const Size(0, 40),
                        padding: const EdgeInsets.fromLTRB(12, 0, 16, 0),
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.homeRemainingCards,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.sub2,
                              ),
                            ),
                            Text(
                              '$remaining',
                              key: const ValueKey('home-remaining'),
                              style: TextStyle(
                                fontSize: 92,
                                height: 1,
                                fontWeight: FontWeight.w200,
                                letterSpacing: -4,
                                color: AppColors.ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8, right: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.point,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                l10n.homeTodayCards(session.length),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onPoint,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              l10n.homeNewReviewBreakdown(
                                fresh.length,
                                session.length - fresh.length,
                              ),
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.sub,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          bodyPadding: EdgeInsets.zero,
          body: ContentWidth(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 16),
              children: [
                _DeckPreview(
                  word: next,
                  position: next == null ? 0 : 1,
                  total: session.length,
                  onTap: next == null
                      ? null
                      : () => _startReview(context, ReviewMode.mixed),
                ),
                const SizedBox(height: 14),
                if (words.isEmpty)
                  PointButton(
                    label: l10n.wordAddWord,
                    leadingIcon: Icons.add_rounded,
                    onPressed: () => openWordAdd(context, ref),
                  )
                else
                  PointButton(
                    key: const ValueKey('home-start'),
                    label: l10n.homeStartButton,
                    trailingArrow: true,
                    onPressed: session.isEmpty
                        ? null
                        : () => _startReview(context, ReviewMode.mixed),
                  ),
                const SizedBox(height: 20),
                _QuickRow(
                  label: l10n.homeQuickGuessWord,
                  onTap: () => _startReview(context, ReviewMode.input),
                ),
                _QuickRow(
                  label: l10n.homeQuickFillBlank,
                  onTap: () => _startReview(context, ReviewMode.choice),
                ),
                _QuickRow(
                  label: l10n.homeQuickGuessFromMeaning,
                  onTap: () => _startReview(context, ReviewMode.meaning),
                ),
                _QuickRow(
                  label: l10n.homeQuickBrowseWordbooks,
                  onTap: () => ref.read(homeTabProvider.notifier).set(1),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _startReview(BuildContext context, ReviewMode mode) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ReviewScreen(mode: mode)));
  }
}

/// 덱 맨 위 카드: 다음에 나올 카드의 예문을 빈칸으로 보여 준다.
class _DeckPreview extends StatelessWidget {
  final Word? word;
  final int position;
  final int total;
  final VoidCallback? onTap;
  const _DeckPreview({
    required this.word,
    required this.position,
    required this.total,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final w = word;
    final exampleIndex = w == null ? -1 : ReviewExamples.initialIndex(w);
    final example = exampleIndex < 0 ? null : w!.examples[exampleIndex];

    return SizedBox(
      height: 252,
      child: Stack(
        children: [
          Positioned(
            left: 28,
            right: 28,
            top: 0,
            height: 200,
            child: _Layer(
              color: Color.lerp(AppColors.panel, AppColors.tab, 0.45)!,
            ),
          ),
          Positioned(
            left: 14,
            right: 14,
            top: 10,
            height: 200,
            child: _Layer(color: AppColors.tab),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 22,
            bottom: 0,
            child: WhiteBlock(
              radius: 22,
              onTap: onTap,
              padding: const EdgeInsets.fromLTRB(20, 18, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'NEXT',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.1,
                            color: AppColors.sub,
                          ),
                        ),
                      ),
                      if (total > 0)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Text(
                            '${_two(position)} / ${_two(total)}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.1,
                              color: AppColors.sub,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: w == null
                        ? Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              l10n.homeNoCardsToday,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w300,
                                color: AppColors.sub2,
                              ),
                            ),
                          )
                        : example == null
                        ? Text(
                            w.meanings.join(', '),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                              color: AppColors.ink,
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                child: ExampleSentence(
                                  sentence: example.sentence,
                                  term: w.term,
                                  blank: true,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w300,
                                    height: 1.45,
                                    color: AppColors.ink,
                                  ),
                                ),
                              ),
                              if (example.translation.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  example.translation,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 1.5,
                                    color: AppColors.sub,
                                  ),
                                ),
                              ],
                            ],
                          ),
                  ),
                  if (w != null)
                    Row(
                      children: [
                        PosChip(w.partOfSpeech),
                        const SizedBox(width: 8),
                        const Spacer(),
                        if (example != null)
                          SpeakButton(
                            text: example.sentence,
                            isSentence: true,
                            tooltip: l10n.speakListenExample,
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _two(int n) => n.toString().padLeft(2, '0');
}

class _Layer extends StatelessWidget {
  final Color color;
  const _Layer({required this.color});

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(22),
    ),
  );
}

class _QuickRow extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _QuickRow({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Container(
      height: 50,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.panelLine)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.onPanel,
              ),
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: AppColors.onPanelSub,
          ),
        ],
      ),
    ),
  );
}
