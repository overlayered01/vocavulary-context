import 'package:flutter/material.dart';
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
    final controller = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('새 단어장'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '단어장 이름'),
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
    if (title == null || title.isEmpty) return;
    final repo = ref.read(repositoryProvider);
    await repo.createWordbook(
      Wordbook(
        id: '',
        ownerId: repo.isCloud ? 'cloud' : 'local',
        title: title,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    invalidateData(ref);
  }
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
                      Text(
                        book.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
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
                  if (v == 'delete') _delete(context, ref, count);
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'rename', child: Text('이름 변경')),
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
    final controller = TextEditingController(text: book.title);
    final title = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('단어장 이름 변경'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '단어장 이름'),
          onSubmitted: (_) => Navigator.pop(ctx, controller.text.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('저장'),
          ),
        ],
      ),
    );
    if (title == null || title.isEmpty || title == book.title) return;
    await ref
        .read(repositoryProvider)
        .updateWordbook(book.copyWith(title: title));
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
