import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/srs.dart';
import '../models/word.dart';
import '../models/wordbook.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/word_image.dart';
import 'review_screen.dart';
import 'word_detail_screen.dart';
import 'word_edit_screen.dart';

typedef _WordDestination = ({Wordbook book, String group});
typedef _PreviewGroup = ({String bookId, String group});

const _allPreviewGroups = (bookId: '', group: '');

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  _PreviewGroup _selectedPreviewGroup = _allPreviewGroups;

  @override
  Widget build(BuildContext context) {
    final wordsAsync = ref.watch(allWordsProvider);
    final books =
        ref.watch(wordbooksProvider).asData?.value ?? const <Wordbook>[];
    final settings = ref.watch(settingsProvider);
    final isCloud = ref.watch(repositoryProvider).isCloud;

    return Scaffold(
      appBar: AppBar(
        title: const Text('WordCloud'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                isCloud ? '동기화' : '로컬',
                style: const TextStyle(color: AppColors.sub, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
      body: wordsAsync.when(
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
          final previewGroups = _previewGroups(words, books);
          final selectedGroup = previewGroups.contains(_selectedPreviewGroup)
              ? _selectedPreviewGroup
              : _allPreviewGroups;
          final previewWords = selectedGroup == _allPreviewGroups
              ? words
              : words
                    .where(
                      (word) =>
                          word.wordbookId == selectedGroup.bookId &&
                          word.group == selectedGroup.group,
                    )
                    .toList();
          final preview = _previewWord(previewWords);

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '안녕하세요',
                          style: TextStyle(color: AppColors.sub, fontSize: 14),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '오늘도 외워볼까요?',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => _addWord(context),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('단어 추가'),
                  ),
                ],
              ),
              if (preview != null) ...[
                const SizedBox(height: 28),
                _WordPreviewHeader(
                  groups: previewGroups,
                  selected: selectedGroup,
                  books: books,
                  words: words,
                  onSelected: (group) =>
                      setState(() => _selectedPreviewGroup = group),
                ),
                _WordPreviewCard(
                  word: preview,
                  onSpeakWord: () => ref
                      .read(ttsServiceProvider)
                      .speak(preview.term, locale: settings.ttsLocale),
                  onSpeakExample: preview.examples.isEmpty
                      ? null
                      : () => ref
                            .read(ttsServiceProvider)
                            .speak(
                              preview.examples.first.sentence,
                              locale: settings.ttsLocale,
                            ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) {
                        final book = books
                            .where((book) => book.id == preview.wordbookId)
                            .firstOrNull;
                        return WordDetailScreen(
                          word: preview,
                          wordbookTitle: book?.title ?? '',
                          groups: book?.groups ?? const [],
                        );
                      },
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 28),

              // 오늘의 복습 카드
              _ReviewCard(
                due: due,
                mixExtra: mixExtra,
                onStart: () => _startReview(context),
              ),
              const SizedBox(height: 32),

              const _SectionLabel('학습 현황'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  child: Row(
                    children: [
                      _Stat(n: '${words.length}', label: '전체 단어'),
                      _Stat(n: '$completed', label: '완료'),
                      _Stat(n: '$accuracy%', label: '정답률'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              const _SectionLabel('빠른 시작'),
              _QuickItem(
                icon: Icons.edit_note,
                label: '예문 보고 단어 맞추기',
                onTap: () => _startReview(context),
              ),
              _QuickItem(
                icon: Icons.menu_book,
                label: '단어장 둘러보기',
                onTap: () => ref.read(homeTabProvider.notifier).set(1),
              ),
            ],
          );
        },
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

  List<_PreviewGroup> _previewGroups(List<Word> words, List<Wordbook> books) {
    final groups = words
        .map((word) => (bookId: word.wordbookId, group: word.group))
        .toSet()
        .toList();
    final titles = {for (final book in books) book.id: book.title};
    groups.sort((a, b) {
      final byBook = (titles[a.bookId] ?? '').compareTo(titles[b.bookId] ?? '');
      return byBook != 0 ? byBook : a.group.compareTo(b.group);
    });
    return [_allPreviewGroups, ...groups];
  }

  Future<void> _addWord(BuildContext context) async {
    final books = await ref.read(wordbooksProvider.future);
    if (!context.mounted) return;
    if (books.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('먼저 단어장을 만들어 주세요.')));
      return;
    }

    final destination = await showModalBottomSheet<_WordDestination>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _DestinationSheet(books: books),
    );
    if (destination == null || !context.mounted) return;

    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => WordEditScreen(
          wordbookId: destination.book.id,
          wordbookTitle: destination.book.title,
          groups: destination.book.groups,
          initialGroup: destination.group,
        ),
      ),
    );
    if (saved == true) {
      ref.invalidate(wordsProvider(destination.book.id));
      invalidateData(ref);
    }
  }

  void _startReview(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ReviewScreen()));
  }
}

class _WordPreviewHeader extends StatelessWidget {
  final List<_PreviewGroup> groups;
  final _PreviewGroup selected;
  final List<Wordbook> books;
  final List<Word> words;
  final ValueChanged<_PreviewGroup> onSelected;

  const _WordPreviewHeader({
    required this.groups,
    required this.selected,
    required this.books,
    required this.words,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final titles = {for (final book in books) book.id: book.title};
    final selectedLabel = selected == _allPreviewGroups
        ? '전체 그룹'
        : selected.group.isEmpty
        ? '그룹 없음'
        : selected.group;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              '오늘의 단어',
              style: TextStyle(
                color: AppColors.sub,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          PopupMenuButton<_PreviewGroup>(
            tooltip: '프리뷰 그룹 선택',
            onSelected: onSelected,
            itemBuilder: (context) => [
              _groupMenuItem(
                group: _allPreviewGroups,
                label: '전체 그룹',
                count: words.length,
              ),
              const PopupMenuDivider(),
              for (final group in groups.skip(1))
                _groupMenuItem(
                  group: group,
                  label:
                      '${titles[group.bookId] ?? '단어장'} · ${group.group.isEmpty ? '그룹 없음' : group.group}',
                  count: words
                      .where(
                        (word) =>
                            word.wordbookId == group.bookId &&
                            word.group == group.group,
                      )
                      .length,
                ),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.chip,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.folder_outlined, size: 15),
                  const SizedBox(width: 6),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 120),
                    child: Text(
                      selectedLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 3),
                  const Icon(Icons.keyboard_arrow_down, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<_PreviewGroup> _groupMenuItem({
    required _PreviewGroup group,
    required String label,
    required int count,
  }) {
    return PopupMenuItem(
      value: group,
      child: SizedBox(
        width: 250,
        child: Row(
          children: [
            Icon(
              group == selected ? Icons.check : Icons.folder_outlined,
              size: 17,
              color: group == selected ? AppColors.ink : AppColors.sub,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(label, overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 10),
            Text(
              '$count개',
              style: const TextStyle(color: AppColors.sub, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _DestinationSheet extends StatelessWidget {
  final List<Wordbook> books;

  const _DestinationSheet({required this.books});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * .72,
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          children: [
            const Text(
              '저장할 그룹 선택',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              '단어장과 그룹을 선택하면 입력 화면으로 이동합니다.',
              style: TextStyle(color: AppColors.sub, fontSize: 13),
            ),
            const SizedBox(height: 18),
            for (final book in books) ...[
              Text(
                book.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.inbox_outlined, size: 16),
                    label: const Text('그룹 없음'),
                    onPressed: () =>
                        Navigator.pop(context, (book: book, group: '')),
                  ),
                  for (final group in book.groups)
                    if (group.isNotEmpty)
                      ActionChip(
                        avatar: const Icon(Icons.folder_outlined, size: 16),
                        label: Text(group),
                        onPressed: () =>
                            Navigator.pop(context, (book: book, group: group)),
                      ),
                ],
              ),
              const SizedBox(height: 22),
            ],
          ],
        ),
      ),
    );
  }
}

class _WordPreviewCard extends StatelessWidget {
  final Word word;
  final VoidCallback onTap;
  final VoidCallback onSpeakWord;
  final VoidCallback? onSpeakExample;

  const _WordPreviewCard({
    required this.word,
    required this.onTap,
    required this.onSpeakWord,
    this.onSpeakExample,
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
              AspectRatio(
                aspectRatio: 16 / 9,
                child: WordImage(
                  source: word.imageUrl,
                  width: double.infinity,
                  height: double.infinity,
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
                      IconButton.filledTonal(
                        tooltip: '단어 발음 듣기',
                        icon: const Icon(Icons.volume_up_outlined, size: 21),
                        onPressed: onSpeakWord,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    word.meaning,
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
                          IconButton(
                            tooltip: '예문 듣기',
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(
                              Icons.volume_up_outlined,
                              size: 20,
                              color: AppColors.ink,
                            ),
                            onPressed: onSpeakExample,
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
  final VoidCallback onStart;
  const _ReviewCard({
    required this.due,
    required this.mixExtra,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${due + mixExtra}',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 6),
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  '개',
                  style: TextStyle(color: AppColors.sub, fontSize: 15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '오늘의 복습 · 신규/복습 $due + 섞기 $mixExtra',
            style: const TextStyle(color: AppColors.sub, fontSize: 13),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onStart,
              child: const Text('예문 복습 시작'),
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

class _Stat extends StatelessWidget {
  final String n;
  final String label;
  const _Stat({required this.n, required this.label});
  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(
          n,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(color: AppColors.sub, fontSize: 11)),
      ],
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
    padding: const EdgeInsets.only(bottom: 10),
    child: Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(14),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Icon(icon, color: AppColors.ink),
        title: Text(label, style: const TextStyle(fontSize: 14)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.sub),
        onTap: onTap,
      ),
    ),
  );
}
