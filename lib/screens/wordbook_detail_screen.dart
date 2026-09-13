import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../models/word.dart';
import '../models/wordbook.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/add_word_button.dart';
import '../widgets/speak_button.dart';
import '../widgets/word_image.dart';
import '../widgets/meaning_fields.dart';
import 'word_detail_screen.dart';
import 'word_edit_screen.dart';
import 'word_create_screen.dart';
import 'word_image_editor.dart';

class WordbookDetailScreen extends ConsumerStatefulWidget {
  final Wordbook book;
  const WordbookDetailScreen({super.key, required this.book});

  @override
  ConsumerState<WordbookDetailScreen> createState() =>
      _WordbookDetailScreenState();
}

class _WordbookDetailScreenState extends ConsumerState<WordbookDetailScreen> {
  /// 스와이프로 삭제된 단어는 실행취소할 때까지 목록에서 숨긴다.
  final Set<String> _pendingDelete = {};

  String get _bookId => widget.book.id;

  void _refresh() {
    ref.invalidate(wordsProvider(_bookId));
    invalidateData(ref);
  }

  @override
  Widget build(BuildContext context) {
    final wordsAsync = ref.watch(wordsProvider(_bookId));

    return Scaffold(
      appBar: AppBar(title: Text(widget.book.title)),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: Align(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: AddWordButton(onPressed: () => _openEditor(null)),
          ),
        ),
      ),
      body: wordsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
        data: (all) {
          final words = all
              .where((w) => !_pendingDelete.contains(w.id))
              .toList();

          if (words.isEmpty) {
            return const Center(
              child: Text(
                '단어가 없습니다.\n단어 추가 버튼을 눌러보세요.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.sub),
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: words.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (_, index) {
              final word = words[index];
              return _WordRow(
                key: ValueKey(word.id),
                word: word,
                onTap: () => _openDetail(word),
                onEdit: () => _openEditor(word),
                onImageEdit: () => editWordImage(context, ref, word),
                onMeaningSaved: (meaning) => _saveMeaning(word, meaning),
                onToggleFavorite: () => _toggleFavorite(word),
                onDismissed: () => _deleteWord(word),
              );
            },
          );
        },
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

  Future<void> _openEditor(Word? word) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => word == null
            ? WordCreateScreen(wordbookId: _bookId)
            : WordEditScreen(
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

  Future<void> _deleteWord(Word w) async {
    setState(() => _pendingDelete.add(w.id));
    await ref.read(repositoryProvider).deleteWord(_bookId, w.id);
    _refresh();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text("'${w.term}' 삭제됨"),
          action: SnackBarAction(
            label: '실행취소',
            textColor: Colors.white,
            onPressed: () async {
              await ref.read(repositoryProvider).upsertWord(w);
              if (mounted) setState(() => _pendingDelete.remove(w.id));
              _refresh();
            },
          ),
        ),
      );
  }
}

/// 단어 한 줄. 개별 뜻 수정 + 왼쪽 스와이프 삭제(임계점 자동 삭제) 지원.
class _WordRow extends ConsumerStatefulWidget {
  final Word word;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onImageEdit;
  final ValueChanged<List<String>> onMeaningSaved;
  final VoidCallback onToggleFavorite;
  final VoidCallback onDismissed;
  const _WordRow({
    super.key,
    required this.word,
    required this.onTap,
    required this.onEdit,
    required this.onImageEdit,
    required this.onMeaningSaved,
    required this.onToggleFavorite,
    required this.onDismissed,
  });

  @override
  ConsumerState<_WordRow> createState() => _WordRowState();
}

class _WordRowState extends ConsumerState<_WordRow> {
  /// 자동 삭제 임계점 (항목 너비의 55%).
  static const _threshold = 0.55;

  Future<void> _startEdit() async {
    final values = await showMeaningEditor(context, widget.word.meanings);
    if (mounted && values != null) widget.onMeaningSaved(values);
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.word;
    // 왼쪽 스와이프:
    //  - 임계점(55%) 미만에서 손을 떼면 부분 열림 상태로 남고,
    //    노출된 삭제 버튼을 누르면 확인 다이얼로그 후 삭제.
    //  - 임계점 이상이면 배경이 잉크색으로 바뀌고(햅틱), 놓으면 자동 삭제.
    return Slidable(
      key: ValueKey('slide_${w.id}'),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.26,
        dismissible: DismissiblePane(
          dismissThreshold: _threshold,
          closeOnCancel: true,
          onDismissed: widget.onDismissed,
        ),
        children: [
          _DeletePaneAction(
            threshold: _threshold,
            term: w.term,
            onConfirmedDelete: widget.onDismissed,
          ),
        ],
      ),
      child: _content(w),
    );
  }

  Widget _content(Word w) {
    return Material(
      color: AppColors.card,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (w.imageUrl.trim().isNotEmpty) ...[
                Tooltip(
                  message: '대표 이미지 편집',
                  child: InkWell(
                    onTap: widget.onImageEdit,
                    borderRadius: BorderRadius.circular(12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: WordImage(
                        source: w.imageUrl,
                        width: 56,
                        height: 56,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Tooltip(
                            message: '단어 전체 편집',
                            child: GestureDetector(
                              onTap: widget.onEdit,
                              behavior: HitTestBehavior.opaque,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      w.term,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  if (w.favorite) ...[
                                    const SizedBox(width: 5),
                                    const Icon(
                                      Icons.star,
                                      size: 14,
                                      color: AppColors.ink,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (w.phonetic.isNotEmpty)
                          Text(
                            w.phonetic,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.sub,
                              fontSize: 12,
                            ),
                          ),
                        _StatusBadge(status: w.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    _meaningText(w),
                  ],
                ),
              ),
              IconButton(
                tooltip: '단어 편집',
                visualDensity: VisualDensity.compact,
                onPressed: widget.onEdit,
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: AppColors.sub,
                ),
              ),
              SpeakButton(text: w.term),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: AppColors.sub),
                onSelected: (v) {
                  if (v == 'favorite') widget.onToggleFavorite();
                  if (v == 'edit') widget.onEdit();
                  if (v == 'image') widget.onImageEdit();
                  if (v == 'meaning') _startEdit();
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'favorite',
                    child: Text(w.favorite ? '즐겨찾기 해제' : '즐겨찾기'),
                  ),
                  const PopupMenuItem(value: 'meaning', child: Text('뜻 수정')),
                  const PopupMenuItem(value: 'edit', child: Text('전체 편집')),
                  PopupMenuItem(
                    value: 'image',
                    child: Text(w.imageUrl.isEmpty ? '이미지 추가' : '이미지 편집'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _meaningText(Word w) => GestureDetector(
    onTap: _startEdit,
    behavior: HitTestBehavior.opaque,
    child: SizedBox(
      width: double.infinity,
      child: MeaningList(
        meanings: w.meanings,
        style: const TextStyle(color: AppColors.sub),
      ),
    ),
  );
}

/// 학습 상태(미학습/학습중/완료) 뱃지. 모노크롬 톤으로 위계만 구분한다.
class _StatusBadge extends StatelessWidget {
  final LearnStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      LearnStatus.fresh => ('미학습', AppColors.chip, AppColors.sub),
      LearnStatus.learning => ('학습중', AppColors.bg, AppColors.ink),
      LearnStatus.completed => ('완료', AppColors.ink, Colors.white),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: status == LearnStatus.learning
            ? Border.all(color: AppColors.line)
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// 스와이프 삭제 팬 액션.
/// 임계점 미만 부분 열림 시 노출되는 '확인 후 삭제' 버튼이며,
/// 드래그가 임계점을 넘으면 배경이 잉크색으로 전환되고 햅틱을 울린다.
class _DeletePaneAction extends StatefulWidget {
  final double threshold;
  final String term;
  final VoidCallback onConfirmedDelete;
  const _DeletePaneAction({
    required this.threshold,
    required this.term,
    required this.onConfirmedDelete,
  });

  @override
  State<_DeletePaneAction> createState() => _DeletePaneActionState();
}

class _DeletePaneActionState extends State<_DeletePaneAction> {
  SlidableController? _controller;
  bool _past = false;

  void _onAnimation() {
    final past = (_controller?.animation.value ?? 0) >= widget.threshold;
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

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("'${widget.term}' 삭제"),
        content: const Text('이 단어를 삭제할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (ok == true) widget.onConfirmedDelete();
  }

  @override
  Widget build(BuildContext context) {
    return CustomSlidableAction(
      onPressed: (_) => _confirmDelete(),
      backgroundColor: _past ? AppColors.ink : AppColors.chip,
      foregroundColor: _past ? Colors.white : AppColors.sub,
      borderRadius: BorderRadius.zero,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_past)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Text(
                '놓으면 삭제',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          const Icon(Icons.delete_outline),
        ],
      ),
    );
  }
}
