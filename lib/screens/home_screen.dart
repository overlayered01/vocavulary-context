import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/srs.dart';
import '../models/word.dart';
import '../models/wordbook.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/add_word_button.dart';
import '../widgets/speak_button.dart';
import '../widgets/word_image.dart';
import '../widgets/meaning_fields.dart';
import 'review_screen.dart';
import 'word_detail_screen.dart';
import 'word_edit_screen.dart';
import 'word_create_screen.dart';
import 'word_image_editor.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final wordsAsync = ref.watch(allWordsProvider);
    final books =
        ref.watch(wordbooksProvider).asData?.value ?? const <Wordbook>[];
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: wordsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('오류: $e')),
          data: (words) {
            final now = DateTime.now();
            // 실제 복습 세션과 동일하게 구성해 카운트가 어긋나지 않도록 한다.
            final session = Srs.buildSession(
              words,
              now,
              mixRatio: settings.reviewMixRatio,
              sessionSize: settings.sessionSize,
            );
            final mixExtra = session
                .where((w) => w.status == LearnStatus.completed)
                .length;
            final due = session.length - mixExtra;
            final completed = words
                .where((w) => w.status == LearnStatus.completed)
                .length;
            final accuracy = _accuracy(words);
            final todayCount =
                ref.watch(todayStudyLogsProvider).asData?.value.length ?? 0;
            final preview = _previewWord(words);

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'WORDCLOUD',
                          style: TextStyle(
                            color: AppColors.sub,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.4,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          '오늘도 외워볼까요?',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    AddWordButton(onPressed: () => _addWord(context)),
                    const SizedBox(height: 20),

                    _ReviewCard(
                      due: due,
                      mixExtra: mixExtra,
                      totalWords: words.length,
                      completed: completed,
                      onStart: () => _startReview(context),
                    ),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: _MetricCard(
                            icon: Icons.local_fire_department_outlined,
                            value: '$todayCount',
                            label: '오늘 학습',
                            caption: '전체 ${words.length}개',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MetricCard(
                            icon: Icons.track_changes_rounded,
                            value: '$accuracy%',
                            label: '정답률',
                            caption: '완료 $completed개',
                          ),
                        ),
                      ],
                    ),

                    if (preview != null) ...[
                      const SizedBox(height: 30),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Text(
                          '오늘의 단어',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      _WordPreviewCard(
                        word: preview,
                        onEdit: () => _editWord(preview, books),
                        onImageEdit: () => editWordImage(context, ref, preview),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) {
                              final book = books
                                  .where(
                                    (book) => book.id == preview.wordbookId,
                                  )
                                  .firstOrNull;
                              return WordDetailScreen(
                                word: preview,
                                wordbookTitle: book?.title ?? '',
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 30),

                    const _SectionLabel('빠른 시작'),
                    _QuickItem(
                      icon: Icons.edit_note_rounded,
                      label: '예문 보고 단어 맞추기',
                      onTap: () => _startReview(context),
                    ),
                    _QuickItem(
                      icon: Icons.checklist_rounded,
                      label: '예문 빈칸 채우기',
                      onTap: () =>
                          _startReview(context, mode: ReviewMode.choice),
                    ),
                    _QuickItem(
                      icon: Icons.menu_book_rounded,
                      label: '단어장 둘러보기',
                      onTap: () => ref.read(homeTabProvider.notifier).set(1),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  int _accuracy(List<Word> words) {
    final c = words.fold<int>(0, (s, w) => s + w.timesCorrect);
    final t = words.fold<int>(0, (s, w) => s + w.timesCorrect + w.timesWrong);
    if (t == 0) return 0;
    return (c * 100 / t).round();
  }

  /// '오늘의 단어'. 이미지 있는 단어 > 예문 있는 단어 > 아무 단어 순으로
  /// 후보를 고르고, 날짜 기준으로 회전시켜 매일 다른 단어를 보여준다.
  Word? _previewWord(List<Word> words) {
    if (words.isEmpty) return null;
    var candidates = words.where((w) => w.imageUrl.isNotEmpty).toList();
    if (candidates.isEmpty) {
      candidates = words.where((w) => w.examples.isNotEmpty).toList();
    }
    if (candidates.isEmpty) candidates = words;

    final today = DateTime.now();
    final dayNumber =
        DateTime(today.year, today.month, today.day).millisecondsSinceEpoch ~/
        Duration.millisecondsPerDay;
    return candidates[dayNumber % candidates.length];
  }

  Future<void> _editWord(Word word, List<Wordbook> books) async {
    final title =
        books.where((book) => book.id == word.wordbookId).firstOrNull?.title ??
        '';
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => WordEditScreen(
          wordbookId: word.wordbookId,
          wordbookTitle: title,
          existing: word,
        ),
      ),
    );
    if (mounted && saved == true) {
      ref.invalidate(wordsProvider(word.wordbookId));
      invalidateData(ref);
    }
  }

  Future<void> _addWord(BuildContext context) async {
    final books = await ref.read(wordbooksProvider.future);
    if (!context.mounted) return;
    if (books.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('먼저 단어장을 만들어 주세요.')));
      ref.read(homeTabProvider.notifier).set(1);
      return;
    }

    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => WordCreateScreen(wordbookId: books.first.id),
      ),
    );
    if (mounted && saved == true) {
      invalidateData(ref);
    }
  }

  void _startReview(
    BuildContext context, {
    ReviewMode mode = ReviewMode.input,
  }) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ReviewScreen(mode: mode)));
  }
}

class _WordPreviewCard extends StatelessWidget {
  final Word word;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onImageEdit;

  const _WordPreviewCard({
    required this.word,
    required this.onTap,
    required this.onEdit,
    required this.onImageEdit,
  });

  @override
  Widget build(BuildContext context) {
    final example = word.examples.firstOrNull;
    final hasImage = word.imageUrl.isNotEmpty;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasImage)
              Tooltip(
                message: '대표 이미지 편집',
                child: InkWell(
                  onTap: onImageEdit,
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: WordImage(
                      source: word.imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, hasImage ? 18 : 20, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              word.term,
                              style: const TextStyle(
                                fontSize: 27,
                                fontWeight: FontWeight.w700,
                                height: 1.1,
                              ),
                            ),
                            if (word.phonetic.isNotEmpty ||
                                word.partOfSpeech.isNotEmpty) ...[
                              const SizedBox(height: 5),
                              Text(
                                [word.phonetic, word.partOfSpeech]
                                    .where((value) => value.isNotEmpty)
                                    .join(' · '),
                                style: const TextStyle(
                                  color: AppColors.sub,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        tooltip: '단어 편집',
                        onPressed: onEdit,
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: AppColors.sub,
                        ),
                      ),
                      SpeakButton(
                        text: word.term,
                        prominent: true,
                        tooltip: '단어 발음 듣기',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  MeaningList(
                    meanings: word.meanings,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (example != null) ...[
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
                      decoration: BoxDecoration(
                        color: AppColors.bg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  example.sentence,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    height: 1.5,
                                  ),
                                ),
                                if (example.translation.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    example.translation,
                                    style: const TextStyle(
                                      color: AppColors.sub,
                                      fontSize: 12,
                                      height: 1.45,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          SpeakButton(
                            text: example.sentence,
                            isSentence: true,
                            tooltip: '예문 듣기',
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '자세히 보기',
                        style: TextStyle(color: AppColors.sub, fontSize: 12),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 17, color: AppColors.sub),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final int due;
  final int mixExtra;
  final int totalWords;
  final int completed;
  final VoidCallback onStart;
  const _ReviewCard({
    required this.due,
    required this.mixExtra,
    required this.totalWords,
    required this.completed,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final reviewCount = due + mixExtra;
    final progress = totalWords == 0 ? 0.0 : completed / totalWords;

    return Material(
      color: AppColors.accent,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onStart,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.bolt_rounded, size: 18),
                            SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                'DAILY REVIEW',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          reviewCount == 0
                              ? '오늘 복습을\n모두 마쳤어요!'
                              : '$reviewCount개의 단어가\n기다리고 있어요',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            height: 1.18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox.square(
                    dimension: 78,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox.square(
                          dimension: 72,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 8,
                            strokeCap: StrokeCap.round,
                            backgroundColor: Colors.white.withValues(
                              alpha: .72,
                            ),
                            valueColor: const AlwaysStoppedAnimation(
                              AppColors.ink,
                            ),
                          ),
                        ),
                        Text(
                          '$completed\n완료',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            height: 1.15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '신규/복습 $due · 섞기 $mixExtra',
                      style: TextStyle(
                        color: AppColors.ink.withValues(alpha: .68),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.ink,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '시작하기',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 15,
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
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final String caption;

  const _MetricCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.accentSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: AppColors.accentDark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 5,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        value,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                    ),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.sub,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.sub, fontSize: 11),
                ),
              ],
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

class _QuickItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(20),
      child: ListTile(
        minVerticalPadding: 12,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        leading: Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: AppColors.accentSoft,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.accentDark, size: 20),
        ),
        title: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.arrow_forward_rounded, color: AppColors.sub),
        onTap: onTap,
      ),
    ),
  );
}
