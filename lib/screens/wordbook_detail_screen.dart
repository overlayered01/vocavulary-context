import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../data/srs.dart';
import '../l10n/l10n.dart';
import '../models/word.dart';
import '../models/wordbook.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/meaning_fields.dart';
import '../widgets/panel.dart';
import '../widgets/speak_button.dart';
import 'word_add_screen.dart';
import 'word_detail_screen.dart';
import 'word_edit_screen.dart';

/// 단어장 안의 남은 카드 목록. 오른쪽으로 밀면 카드를 버린다.
class WordbookDetailScreen extends ConsumerStatefulWidget {
  final Wordbook book;
  const WordbookDetailScreen({super.key, required this.book});

  @override
  ConsumerState<WordbookDetailScreen> createState() =>
      _WordbookDetailScreenState();
}

class _WordbookDetailScreenState extends ConsumerState<WordbookDetailScreen> {
  /// 버리거나 삭제한 카드는 실행취소할 때까지 목록에서 바로 숨긴다.
  final Set<String> _hidden = {};

  String get _bookId => widget.book.id;

  void _refresh() {
    ref.invalidate(wordsProvider(_bookId));
    invalidateData(ref);
  }

  @override
  Widget build(BuildContext context) {
    final wordsAsync = ref.watch(wordsProvider(_bookId));
    final l10n = context.l10n;
    final all = wordsAsync.asData?.value ?? const <Word>[];
    final words = [
      for (final w in all)
        if (w.status != LearnStatus.completed && !_hidden.contains(w.id)) w,
    ];

    return Scaffold(
      backgroundColor: AppColors.panel,
      body: PanelPage(
        header: ContentWidth(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    BackButton(color: AppColors.ink),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          widget.book.title,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.4,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '${words.length}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink,
                              ),
                            ),
                            TextSpan(text: ' ${l10n.wordbookCardsLeftSuffix}'),
                          ],
                        ),
                        key: const ValueKey('wordbook-left'),
                        style: TextStyle(fontSize: 12, color: AppColors.sub2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bodyPadding: EdgeInsets.zero,
        body: ContentWidth(
          child: wordsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(l10n.wordbookError('$e'))),
            data: (_) {
              if (words.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      all.isEmpty
                          ? l10n.wordbookDetailEmpty
                          : l10n.wordbookDetailAllDiscarded,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.onPanelSub),
                    ),
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
                itemCount: words.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, index) {
                  final word = words[index];
                  return _WordCard(
                    key: ValueKey(word.id),
                    word: word,
                    found:
                        ref
                            .watch(exampleSuggestionsProvider)
                            .asData
                            ?.value[word.id]
                            ?.length ??
                        0,
                    onTap: () => _openDetail(word),
                    onEdit: () => _openEditor(word),
                    onMeaningSaved: (meaning) => _saveMeaning(word, meaning),
                    onToggleFavorite: () => _toggleFavorite(word),
                    onDiscard: () => _discard(word),
                    onDelete: () => _delete(word),
                  );
                },
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: ColoredBox(
        color: AppColors.panel,
        child: ContentWidth(
          child: Container(
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              12 + MediaQuery.paddingOf(context).bottom,
            ),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.panelHigh)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: PanelTonalButton(
                    key: const ValueKey('open-discarded'),
                    label: l10n.discardedTitle,
                    icon: Icons.inventory_2_outlined,
                    onPressed: _openDiscarded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: PointButton(
                    label: l10n.wordbookAddWordShort,
                    leadingIcon: Icons.add_rounded,
                    height: 56,
                    onPressed: () async {
                      final saved = await openWordAdd(
                        context,
                        ref,
                        wordbookId: _bookId,
                      );
                      if (mounted && saved) _refresh();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---- 단어 동작 ----

  Future<void> _openDetail(Word w) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            WordDetailScreen(word: w, wordbookTitle: widget.book.title),
      ),
    );
    if (mounted) _refresh();
  }

  Future<void> _openDiscarded() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DiscardedScreen(book: widget.book)),
    );
    if (mounted) _refresh();
  }

  Future<void> _openEditor(Word word) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => WordEditScreen(
          wordbookId: _bookId,
          wordbookTitle: widget.book.title,
          existing: word,
        ),
      ),
    );
    if (mounted && result == true) _refresh();
  }

  Future<void> _saveMeaning(Word w, List<String> meanings) async {
    final values = Word.normalizeMeanings(meanings);
    if (values.isEmpty || listEquals(values, w.meanings)) return;
    final repo = ref.read(repositoryProvider);
    final words = await repo.getWords(_bookId);
    final latest = words.where((word) => word.id == w.id).firstOrNull;
    if (latest == null) return;
    await repo.upsertWord(
      latest.copyWith(meanings: values, updatedAt: DateTime.now()),
    );
    if (mounted) _refresh();
  }

  Future<void> _toggleFavorite(Word w) async {
    await ref
        .read(repositoryProvider)
        .upsertWord(
          w.copyWith(favorite: !w.favorite, updatedAt: DateTime.now()),
        );
    _refresh();
  }

  Future<void> _discard(Word w) async {
    final message = context.l10n.wordbookDetailDiscarded(w.term);
    setState(() => _hidden.add(w.id));
    await ref
        .read(repositoryProvider)
        .upsertWord(Srs.discard(w, DateTime.now()));
    _refresh();
    _showUndo(message, w);
  }

  Future<void> _delete(Word w) async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.wordbookDeleteTitle(w.term)),
        content: Text(l10n.wordbookDetailDeleteWordConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _hidden.add(w.id));
    await ref.read(repositoryProvider).deleteWord(_bookId, w.id);
    _refresh();
    if (mounted) _showUndo(l10n.wordbookDetailWordDeleted(w.term), w);
  }

  void _showUndo(String message, Word original) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          action: SnackBarAction(
            label: context.l10n.wordbookDetailUndo,
            textColor: AppColors.point,
            onPressed: () async {
              await ref.read(repositoryProvider).upsertWord(original);
              if (mounted) setState(() => _hidden.remove(original.id));
              _refresh();
            },
          ),
        ),
      );
  }
}

/// 남은 카드 한 장. 뜻 아래에 예문을 기본으로 보여 준다.
class _WordCard extends StatelessWidget {
  final Word word;

  /// 예문이 없을 때 내장 예문에서 다시 찾은 예문 수.
  final int found;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final ValueChanged<List<String>> onMeaningSaved;
  final VoidCallback onToggleFavorite;
  final VoidCallback onDiscard;
  final VoidCallback onDelete;
  const _WordCard({
    super.key,
    required this.word,
    this.found = 0,
    required this.onTap,
    required this.onEdit,
    required this.onMeaningSaved,
    required this.onToggleFavorite,
    required this.onDiscard,
    required this.onDelete,
  });

  /// 이 너비 비율 넘게 밀었다 놓으면 버린다.
  static const _threshold = 0.4;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: ColoredBox(
        color: AppColors.point,
        child: Slidable(
          key: ValueKey('slide_${word.id}'),
          startActionPane: ActionPane(
            motion: const BehindMotion(),
            extentRatio: 0.32,
            dismissible: DismissiblePane(
              dismissThreshold: _threshold,
              closeOnCancel: true,
              onDismissed: onDiscard,
            ),
            children: [_DiscardPaneAction(onDiscard: onDiscard)],
          ),
          child: _content(context),
        ),
      ),
    );
  }

  Widget _content(BuildContext context) {
    final l10n = context.l10n;
    final w = word;
    final example = w.examples.firstOrNull;
    return Material(
      color: AppColors.card,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 4, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Flexible(
                          child: Text(
                            w.term,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.w300,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          partOfSpeechLabel(context, w.partOfSpeech),
                          style: TextStyle(fontSize: 11, color: AppColors.sub),
                        ),
                        if (w.favorite) ...[
                          const SizedBox(width: 6),
                          Icon(
                            Icons.star_rounded,
                            size: 15,
                            color: AppColors.ink,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _menu(context),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _editMeanings(context),
                        child: MeaningList(
                          meanings: w.meanings,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (example == null && found > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Container(
                    key: ValueKey('found-${w.id}'),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.point,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      l10n.wordbookFoundExamples(found),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onPoint,
                      ),
                    ),
                  ),
                ),
              if (example != null) ...[
                Container(
                  margin: const EdgeInsets.only(top: 12, right: 14),
                  height: 1,
                  color: AppColors.chip,
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ExampleSentence(
                            sentence: example.sentence,
                            term: w.term,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w300,
                              height: 1.45,
                              color: AppColors.ink,
                            ),
                          ),
                          if (example.translation.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              example.translation,
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.5,
                                color: AppColors.sub,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SpeakButton(
                      text: example.sentence,
                      isSentence: true,
                      tooltip: l10n.speakListenExample,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editMeanings(BuildContext context) async {
    final values = await showMeaningEditor(context, word.meanings);
    if (values != null) onMeaningSaved(values);
  }

  Widget _menu(BuildContext context) {
    final l10n = context.l10n;
    return PopupMenuButton<String>(
      tooltip: l10n.wordbooksMenu,
      icon: Icon(Icons.more_vert, size: 20, color: AppColors.sub),
      onSelected: (v) {
        if (v == 'favorite') onToggleFavorite();
        if (v == 'edit') onEdit();
        if (v == 'meaning') _editMeanings(context);
        if (v == 'discard') onDiscard();
        if (v == 'delete') onDelete();
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'favorite',
          child: Text(
            word.favorite
                ? l10n.wordbookDetailUnfavorite
                : l10n.wordbookDetailFavorite,
          ),
        ),
        PopupMenuItem(
          value: 'meaning',
          child: Text(l10n.wordbookDetailEditMeaning),
        ),
        PopupMenuItem(value: 'edit', child: Text(l10n.wordbookDetailEditAll)),
        PopupMenuItem(value: 'discard', child: Text(l10n.reviewDiscard)),
        PopupMenuItem(value: 'delete', child: Text(l10n.commonDelete)),
      ],
    );
  }
}

/// 밀었을 때 왼쪽에 드러나는 '버리기' 영역. 임계점을 넘으면 햅틱과 함께
/// '놓으면 버림'으로 바뀐다.
class _DiscardPaneAction extends StatefulWidget {
  final VoidCallback onDiscard;
  const _DiscardPaneAction({required this.onDiscard});

  @override
  State<_DiscardPaneAction> createState() => _DiscardPaneActionState();
}

class _DiscardPaneActionState extends State<_DiscardPaneAction> {
  SlidableController? _controller;
  bool _past = false;

  void _onAnimation() {
    final past = (_controller?.animation.value ?? 0) >= _WordCard._threshold;
    if (past != _past) {
      setState(() => _past = past);
      if (past) HapticFeedback.mediumImpact();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = Slidable.of(context);
    if (!identical(controller, _controller)) {
      _controller?.animation.removeListener(_onAnimation);
      _controller = controller;
      _controller?.animation.addListener(_onAnimation);
    }
  }

  @override
  void dispose() {
    _controller?.animation.removeListener(_onAnimation);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomSlidableAction(
      onPressed: (_) => widget.onDiscard(),
      backgroundColor: AppColors.point,
      foregroundColor: AppColors.onPoint,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.arrow_forward_rounded),
          const SizedBox(height: 6),
          Text(
            _past
                ? context.l10n.wordbookDetailReleaseToDiscard
                : context.l10n.reviewDiscard,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

/// 버린 카드 목록. 다시 넣으면 남은 카드로 돌아간다.
class DiscardedScreen extends ConsumerWidget {
  final Wordbook book;
  const DiscardedScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final wordsAsync = ref.watch(wordsProvider(book.id));
    final gone =
        [
          for (final w in wordsAsync.asData?.value ?? const <Word>[])
            if (w.status == LearnStatus.completed) w,
        ]..sort(
          (a, b) => (b.completedAt ?? b.updatedAt).compareTo(
            a.completedAt ?? a.updatedAt,
          ),
        );

    return Scaffold(
      backgroundColor: AppColors.panel,
      body: PanelPage(
        header: ContentWidth(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BackButton(color: AppColors.ink),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.discardedTitle,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        book.title,
                        style: TextStyle(fontSize: 12, color: AppColors.sub),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bodyPadding: EdgeInsets.zero,
        body: ContentWidth(
          child: gone.isEmpty
              ? Center(
                  child: Text(
                    l10n.discardedEmpty,
                    style: TextStyle(color: AppColors.onPanelSub),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(22, 10, 22, 24),
                  itemCount: gone.length,
                  itemBuilder: (_, i) {
                    final w = gone[i];
                    return Container(
                      constraints: const BoxConstraints(minHeight: 62),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: AppColors.panelHigh),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => WordDetailScreen(
                                    word: w,
                                    wordbookTitle: book.title,
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      w.term,
                                      style: TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.w300,
                                        color: AppColors.onPanel,
                                      ),
                                    ),
                                    Text(
                                      w.meanings.join(', '),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.onPanelSub,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton(
                            key: ValueKey('restore-${w.id}'),
                            onPressed: () async {
                              await ref
                                  .read(repositoryProvider)
                                  .upsertWord(Srs.restore(w, DateTime.now()));
                              ref.invalidate(wordsProvider(book.id));
                              invalidateData(ref);
                            },
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 34),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              foregroundColor: AppColors.onPanel,
                              side: BorderSide(
                                color: AppColors.panelLine,
                                width: 1.5,
                              ),
                              shape: const StadiumBorder(),
                              textStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            child: Text(l10n.discardedRestore),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
