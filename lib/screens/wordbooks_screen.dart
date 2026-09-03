import 'package:flutter/material.dart' hide Visibility;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/wordbook.dart';
import '../providers.dart';
import '../theme.dart';
import 'wordbook_detail_screen.dart';

class WordbooksScreen extends ConsumerWidget {
  const WordbooksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(wordbooksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('내 단어장'),
        actions: [
          IconButton(
            tooltip: '새 단어장',
            icon: const Icon(Icons.add),
            onPressed: () => _createDialog(context, ref),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: booksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
        data: (books) {
          if (books.isEmpty) {
            return const Center(
              child: Text(
                '단어장이 없습니다.\n+ 버튼으로 추가하세요.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.sub),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            itemCount: books.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _WordbookCard(book: books[i]),
          );
        },
      ),
    );
  }

  Future<void> _createDialog(BuildContext context, WidgetRef ref) async {
    final result = await showWordbookDialog(
      context,
      dialogTitle: '새 단어장',
      confirmLabel: '만들기',
    );
    if (result == null || result.title.isEmpty) return;
    final repo = ref.read(repositoryProvider);
    await repo.createWordbook(
      Wordbook(
        id: '',
        ownerId: repo.isCloud ? 'cloud' : 'local',
        title: result.title,
        tags: result.tags,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    invalidateData(ref);
  }
}

/// 단어장 이름·태그 입력 다이얼로그. 확인 시 (title, tags), 취소 시 null.
Future<({String title, List<String> tags})?> showWordbookDialog(
  BuildContext context, {
  required String dialogTitle,
  required String confirmLabel,
  String initialTitle = '',
  List<String> initialTags = const [],
}) {
  final titleCtrl = TextEditingController(text: initialTitle);
  final tagsCtrl = TextEditingController(text: initialTags.join(', '));

  ({String title, List<String> tags}) collect() {
    final seen = <String>{};
    final tags = [
      for (final tag in tagsCtrl.text.split(','))
        if (tag.trim().isNotEmpty && seen.add(tag.trim())) tag.trim(),
    ];
    return (title: titleCtrl.text.trim(), tags: tags);
  }

  return showDialog<({String title, List<String> tags})>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(dialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleCtrl,
            autofocus: true,
            decoration: const InputDecoration(labelText: '단어장 이름'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: tagsCtrl,
            decoration: const InputDecoration(
              labelText: '태그',
              hintText: '토익, 일상회화 (쉼표로 구분)',
            ),
            onSubmitted: (_) => Navigator.pop(ctx, collect()),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, collect()),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
}

class _WordbookCard extends ConsumerWidget {
  final Wordbook book;
  const _WordbookCard({required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordsAsync = ref.watch(wordsProvider(book.id));
    final count = wordsAsync.asData?.value.length ?? 0;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => WordbookDetailScreen(book: book)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 8, 18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              book.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (book.visibility != Visibility.private) ...[
                            const SizedBox(width: 6),
                            Icon(
                              book.visibility == Visibility.public
                                  ? Icons.public
                                  : Icons.link,
                              size: 15,
                              color: AppColors.sub,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '단어 $count개',
                        style: const TextStyle(
                          color: AppColors.sub,
                          fontSize: 13,
                        ),
                      ),
                      if (book.tags.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: book.tags.map((t) => _Tag(t)).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              PopupMenuButton<String>(
                tooltip: '단어장 메뉴',
                icon: const Icon(Icons.more_vert, color: AppColors.sub),
                onSelected: (v) {
                  if (v == 'rename') _rename(context, ref);
                  if (v == 'share') _shareSettings(context, ref);
                  if (v == 'delete') _delete(context, ref, count);
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'rename', child: Text('이름·태그 편집')),
                  PopupMenuItem(value: 'share', child: Text('공유·공개 설정')),
                  PopupMenuItem(value: 'delete', child: Text('단어장 삭제')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _rename(BuildContext context, WidgetRef ref) async {
    final result = await showWordbookDialog(
      context,
      dialogTitle: '단어장 편집',
      confirmLabel: '저장',
      initialTitle: book.title,
      initialTags: book.tags,
    );
    if (result == null || result.title.isEmpty) return;
    await ref
        .read(repositoryProvider)
        .updateWordbook(book.copyWith(title: result.title, tags: result.tags));
    invalidateData(ref);
  }

  /// 공개 범위(비공개/코드 공유/공개) 설정 + 공유 코드 복사. 클라우드 모드 전용.
  Future<void> _shareSettings(BuildContext context, WidgetRef ref) async {
    if (!ref.read(repositoryProvider).isCloud) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('공유·공개는 로그인 후 사용할 수 있어요.')));
      return;
    }

    var selected = book.visibility;
    final saved = await showDialog<Visibility>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('공유·공개 설정'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SegmentedButton<Visibility>(
                expandedInsets: EdgeInsets.zero,
                segments: const [
                  ButtonSegment(value: Visibility.private, label: Text('비공개')),
                  ButtonSegment(value: Visibility.shared, label: Text('코드 공유')),
                  ButtonSegment(value: Visibility.public, label: Text('공개')),
                ],
                selected: {selected},
                onSelectionChanged: (s) =>
                    setDialogState(() => selected = s.first),
              ),
              const SizedBox(height: 12),
              Text(switch (selected) {
                Visibility.private => '나만 볼 수 있어요.',
                Visibility.shared => '공유 코드를 아는 사람이 이 단어장을 복제할 수 있어요.',
                Visibility.public => '탐색 탭의 공개 목록에 올라가고 누구나 복제할 수 있어요.',
              }, style: const TextStyle(color: AppColors.sub, fontSize: 12)),
              if (selected != Visibility.private) ...[
                const SizedBox(height: 14),
                const Text(
                  '공유 코드',
                  style: TextStyle(color: AppColors.sub, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
                  decoration: BoxDecoration(
                    color: AppColors.chip,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          book.id,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        tooltip: '코드 복사',
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.copy, size: 17),
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: book.id));
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              const SnackBar(content: Text('공유 코드를 복사했어요.')),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, selected),
              child: const Text('저장'),
            ),
          ],
        ),
      ),
    );
    if (saved == null || saved == book.visibility) return;
    await ref
        .read(repositoryProvider)
        .updateWordbook(book.copyWith(visibility: saved));
    invalidateData(ref);
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, int count) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("'${book.title}' 삭제"),
        content: Text(
          count > 0
              ? '단어장에 든 단어 $count개도 함께 삭제됩니다.\n삭제한 단어장은 되돌릴 수 없어요.'
              : '삭제한 단어장은 되돌릴 수 없어요.',
        ),
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
    await ref.read(repositoryProvider).deleteWordbook(book.id);
    ref.invalidate(wordsProvider(book.id));
    invalidateData(ref);
  }
}

class _Tag extends StatelessWidget {
  final String text;
  const _Tag(this.text);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: AppColors.chip,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: const TextStyle(color: AppColors.sub, fontSize: 11),
    ),
  );
}
