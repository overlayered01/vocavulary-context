import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../models/word.dart';
import '../models/wordbook.dart';
import '../providers.dart';
import '../theme.dart';
import 'word_detail_screen.dart';
import 'word_edit_screen.dart';

/// 그룹명 빈 문자열의 화면 표기.
const _kNoGroupLabel = '그룹 없음';

class WordbookDetailScreen extends ConsumerStatefulWidget {
  final Wordbook book;
  const WordbookDetailScreen({super.key, required this.book});

  @override
  ConsumerState<WordbookDetailScreen> createState() =>
      _WordbookDetailScreenState();
}

class _WordbookDetailScreenState extends ConsumerState<WordbookDetailScreen> {
  /// null = 전체, 그 외에는 선택된 그룹명('' = 그룹 없음).
  String? _filter;

  /// 스와이프로 막 삭제되어 화면에서 즉시 제거할 단어 id(Undo 시 복원).
  final Set<String> _pendingDelete = {};

  /// 단어장에 저장된 그룹 목록(빈 그룹 포함, 표시 순서 유지).
  late List<String> _groups;

  String get _bookId => widget.book.id;

  @override
  void initState() {
    super.initState();
    _groups = List.of(widget.book.groups);
  }

  void _refresh() {
    ref.invalidate(wordsProvider(_bookId));
    invalidateData(ref);
  }

  Future<void> _persistGroups() async {
    await ref
        .read(repositoryProvider)
        .updateWordbook(widget.book.copyWith(groups: List.of(_groups)));
    invalidateData(ref);
  }

  /// 표시할 그룹 순서 = 저장된 그룹 + (단어에만 있는 그룹을 뒤에 보강).
  List<String> _displayGroups(List<Word> words) {
    final order = <String>[];
    for (final g in _groups) {
      if (g.isNotEmpty && !order.contains(g)) order.add(g);
    }
    for (final w in words) {
      if (w.group.isNotEmpty && !order.contains(w.group)) order.add(w.group);
    }
    return order;
  }

  @override
  Widget build(BuildContext context) {
    final wordsAsync = ref.watch(wordsProvider(_bookId));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.title),
        actions: [
          IconButton(
            tooltip: '그룹 추가',
            icon: const Icon(Icons.create_new_folder_outlined),
            onPressed: _createGroup,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.ink,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('단어 추가'),
        onPressed: () => _openEditor(null),
      ),
      body: wordsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
        data: (all) {
          final words = all
              .where((w) => !_pendingDelete.contains(w.id))
              .toList();

          final byGroup = <String, List<Word>>{};
          for (final w in words) {
            byGroup.putIfAbsent(w.group, () => []).add(w);
          }
          final order = _displayGroups(words);
          final hasUngrouped = byGroup.containsKey('');

          if (words.isEmpty && order.isEmpty) {
            return const Center(
              child: Text(
                '단어가 없습니다.\n단어 추가 버튼을 눌러보세요.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.sub),
              ),
            );
          }

          // 더 이상 표시되지 않는 그룹을 가리키면 전체로 되돌린다.
          final filter = _filter == null
              ? null
              : (_filter == '' ? hasUngrouped : order.contains(_filter))
              ? _filter
              : null;

          // 표시할 (그룹명, 단어목록) 섹션 목록.
          final sections = <MapEntry<String, List<Word>>>[];
          for (final g in order) {
            sections.add(MapEntry(g, byGroup[g] ?? const []));
          }
          if (hasUngrouped) {
            sections.add(MapEntry('', byGroup['']!));
          }
          final visible = filter == null
              ? sections
              : sections.where((s) => s.key == filter);

          return Column(
            children: [
              _GroupFilterBar(
                groups: order,
                hasUngrouped: hasUngrouped,
                selected: filter,
                onSelected: (g) => setState(() => _filter = g),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 96),
                  children: [
                    for (final entry in visible) ...[
                      _GroupHeader(
                        name: entry.key,
                        count: entry.value.length,
                        onRename: entry.key.isEmpty
                            ? null
                            : () => _renameGroup(entry.key),
                        onDelete: entry.key.isEmpty
                            ? null
                            : () => _deleteGroup(entry.key),
                      ),
                      if (entry.value.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 6, left: 2),
                          child: Text(
                            '이 그룹에 단어가 없어요',
                            style: TextStyle(
                              color: AppColors.sub,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      for (final w in entry.value) ...[
                        _WordRow(
                          key: ValueKey(w.id),
                          word: w,
                          onTap: () => _openDetail(w),
                          onEdit: () => _openEditor(w),
                          onMoveGroup: () => _moveGroup(w),
                          onMeaningSaved: (m) => _saveMeaning(w, m),
                          onToggleFavorite: () => _toggleFavorite(w),
                          onDismissed: () => _deleteWord(w),
                        ),
                        const SizedBox(height: 10),
                      ],
                      const SizedBox(height: 14),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ---- 단어 동작 ----

  Future<void> _openDetail(Word w) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WordDetailScreen(
          word: w,
          wordbookTitle: widget.book.title,
          groups: _groups,
        ),
      ),
    );
    if (mounted) _refresh();
  }

  Future<void> _openEditor(Word? word) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => WordEditScreen(
          wordbookId: _bookId,
          wordbookTitle: widget.book.title,
          groups: _groups,
          initialGroup: _filter ?? '',
          existing: word,
        ),
      ),
    );
    if (result == true) _refresh();
  }

  Future<void> _saveMeaning(Word w, String meaning) async {
    final trimmed = meaning.trim();
    if (trimmed.isEmpty || trimmed == w.meaning) return;
    await ref
        .read(repositoryProvider)
        .upsertWord(w.copyWith(meaning: trimmed, updatedAt: DateTime.now()));
    _refresh();
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

  // ---- 그룹 동작 ----

  Future<void> _createGroup() async {
    final name = await _promptGroupName(title: '새 그룹');
    if (name == null || name.isEmpty) return;
    if (!_groups.contains(name)) {
      setState(() {
        _groups.add(name);
        _filter = name;
      });
      await _persistGroups();
    } else {
      setState(() => _filter = name);
    }
  }

  Future<void> _moveGroup(Word w) async {
    final words = ref.read(wordsProvider(_bookId)).value ?? [];
    final target = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) =>
          _GroupPickerSheet(groups: _displayGroups(words), current: w.group),
    );
    if (target == null || target == w.group) return;
    if (target.isNotEmpty && !_groups.contains(target)) {
      _groups.add(target);
      await _persistGroups();
    }
    await ref
        .read(repositoryProvider)
        .upsertWord(w.copyWith(group: target, updatedAt: DateTime.now()));
    _refresh();
  }

  Future<void> _renameGroup(String oldName) async {
    final newName = await _promptGroupName(title: '그룹 이름 변경', initial: oldName);
    if (newName == null || newName.isEmpty || newName == oldName) return;
    final repo = ref.read(repositoryProvider);
    final words = ref.read(wordsProvider(_bookId)).value ?? [];
    for (final w in words.where((w) => w.group == oldName)) {
      await repo.upsertWord(
        w.copyWith(group: newName, updatedAt: DateTime.now()),
      );
    }
    setState(() {
      final i = _groups.indexOf(oldName);
      if (i >= 0) {
        _groups[i] = newName;
      } else if (!_groups.contains(newName)) {
        _groups.add(newName);
      }
      if (_filter == oldName) _filter = newName;
    });
    await _persistGroups();
    _refresh();
  }

  Future<void> _deleteGroup(String name) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("그룹 '$name' 삭제"),
        content: const Text("그룹만 삭제되고 단어는 '그룹 없음'으로 이동합니다."),
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
    if (ok != true) return;
    final repo = ref.read(repositoryProvider);
    final words = ref.read(wordsProvider(_bookId)).value ?? [];
    for (final w in words.where((w) => w.group == name)) {
      await repo.upsertWord(w.copyWith(group: '', updatedAt: DateTime.now()));
    }
    setState(() {
      _groups.remove(name);
      if (_filter == name) _filter = null;
    });
    await _persistGroups();
    _refresh();
  }

  Future<String?> _promptGroupName({required String title, String? initial}) {
    final controller = TextEditingController(text: initial ?? '');
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '그룹 이름'),
          onSubmitted: (_) => Navigator.pop(ctx, controller.text.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}

/// 상단 그룹 필터 칩 바.
class _GroupFilterBar extends StatelessWidget {
  final List<String> groups;
  final bool hasUngrouped;
  final String? selected;
  final ValueChanged<String?> onSelected;
  const _GroupFilterBar({
    required this.groups,
    required this.hasUngrouped,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty && !hasUngrouped) return const SizedBox(height: 8);
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          _chip('전체', selected == null, () => onSelected(null)),
          for (final g in groups) _chip(g, selected == g, () => onSelected(g)),
          if (hasUngrouped)
            _chip(_kNoGroupLabel, selected == '', () => onSelected('')),
        ],
      ),
    );
  }

  Widget _chip(String label, bool active, VoidCallback onTap) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: active ? AppColors.ink : AppColors.chip,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : AppColors.sub,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
  );
}

/// 그룹 섹션 헤더 (이름·개수 + 이름변경/삭제 메뉴).
class _GroupHeader extends StatelessWidget {
  final String name;
  final int count;
  final VoidCallback? onRename;
  final VoidCallback? onDelete;
  const _GroupHeader({
    required this.name,
    required this.count,
    this.onRename,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 8, left: 2),
      child: Row(
        children: [
          Text(
            name.isEmpty ? _kNoGroupLabel : name,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$count',
            style: const TextStyle(color: AppColors.sub, fontSize: 12),
          ),
          const Spacer(),
          if (onRename != null || onDelete != null)
            SizedBox(
              height: 28,
              width: 28,
              child: PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.more_horiz,
                  size: 18,
                  color: AppColors.sub,
                ),
                onSelected: (v) {
                  if (v == 'rename') onRename?.call();
                  if (v == 'delete') onDelete?.call();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'rename', child: Text('이름 변경')),
                  PopupMenuItem(value: 'delete', child: Text('그룹 삭제')),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// 단어 한 줄. 인라인 뜻 수정 + 왼쪽 스와이프 삭제(임계점 자동 삭제) 지원.
class _WordRow extends ConsumerStatefulWidget {
  final Word word;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onMoveGroup;
  final ValueChanged<String> onMeaningSaved;
  final VoidCallback onToggleFavorite;
  final VoidCallback onDismissed;
  const _WordRow({
    super.key,
    required this.word,
    required this.onTap,
    required this.onEdit,
    required this.onMoveGroup,
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

  bool _editing = false;
  late final TextEditingController _meaningCtrl;
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _meaningCtrl = TextEditingController(text: widget.word.meaning);
    _focus = FocusNode()
      ..addListener(() {
        if (!_focus.hasFocus && _editing) _commitMeaning();
      });
  }

  @override
  void dispose() {
    _meaningCtrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _startEdit() {
    _meaningCtrl.text = widget.word.meaning;
    setState(() => _editing = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focus.requestFocus();
        _meaningCtrl.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _meaningCtrl.text.length,
        );
      }
    });
  }

  void _commitMeaning() {
    if (!_editing) return;
    setState(() => _editing = false);
    widget.onMeaningSaved(_meaningCtrl.text);
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
      child: _card(w),
    );
  }

  Widget _card(Word w) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
                                  if (w.phonetic.isNotEmpty) ...[
                                    const SizedBox(width: 6),
                                    Text(
                                      w.phonetic,
                                      style: const TextStyle(
                                        color: AppColors.sub,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _StatusBadge(status: w.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    _editing ? _meaningField() : _meaningText(w),
                  ],
                ),
              ),
              IconButton(
                tooltip: '단어 편집',
                visualDensity: VisualDensity.compact,
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: AppColors.sub,
                ),
                onPressed: widget.onEdit,
              ),
              IconButton(
                tooltip: '발음 듣기',
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.volume_up, color: AppColors.ink),
                onPressed: () => ref
                    .read(ttsServiceProvider)
                    .speak(
                      w.term,
                      locale: ref.read(settingsProvider).ttsLocale,
                    ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: AppColors.sub),
                onSelected: (v) {
                  if (v == 'favorite') widget.onToggleFavorite();
                  if (v == 'move') widget.onMoveGroup();
                  if (v == 'edit') widget.onEdit();
                  if (v == 'meaning') _startEdit();
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'favorite',
                    child: Text(w.favorite ? '즐겨찾기 해제' : '즐겨찾기'),
                  ),
                  const PopupMenuItem(value: 'meaning', child: Text('뜻 수정')),
                  const PopupMenuItem(value: 'move', child: Text('그룹 이동')),
                  const PopupMenuItem(value: 'edit', child: Text('전체 편집')),
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
      child: Text(
        '${w.partOfSpeech.isNotEmpty ? "${w.partOfSpeech}. " : ""}${w.meaning}',
        style: const TextStyle(color: AppColors.sub),
      ),
    ),
  );

  Widget _meaningField() => TextField(
    controller: _meaningCtrl,
    focusNode: _focus,
    autofocus: true,
    style: const TextStyle(fontSize: 14),
    decoration: const InputDecoration(isDense: true, hintText: '뜻 입력'),
    onSubmitted: (_) => _commitMeaning(),
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
      borderRadius: BorderRadius.circular(16),
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

/// 그룹 선택/생성 바텀시트. 선택한 그룹명('' = 그룹 없음)을 pop, 취소 시 null.
class _GroupPickerSheet extends StatelessWidget {
  final List<String> groups;
  final String current;
  const _GroupPickerSheet({required this.groups, required this.current});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 18, 20, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '그룹 이동',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.block, color: AppColors.sub),
            title: const Text(_kNoGroupLabel),
            trailing: current.isEmpty
                ? const Icon(Icons.check, color: AppColors.ink)
                : null,
            onTap: () => Navigator.pop(context, ''),
          ),
          for (final g in groups)
            ListTile(
              leading: const Icon(Icons.folder_outlined, color: AppColors.ink),
              title: Text(g),
              trailing: current == g
                  ? const Icon(Icons.check, color: AppColors.ink)
                  : null,
              onTap: () => Navigator.pop(context, g),
            ),
          ListTile(
            leading: const Icon(Icons.add, color: AppColors.ink),
            title: const Text('새 그룹 만들기'),
            onTap: () async {
              final name = await _promptNewGroup(context);
              if (name != null && name.isNotEmpty && context.mounted) {
                Navigator.pop(context, name);
              }
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Future<String?> _promptNewGroup(BuildContext context) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('새 그룹'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '그룹 이름'),
          onSubmitted: (_) => Navigator.pop(ctx, controller.text.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('만들기'),
          ),
        ],
      ),
    );
  }
}
