import 'package:flutter/material.dart' hide Visibility;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/l10n.dart';
import '../models/word.dart';
import '../models/wordbook.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/panel.dart';
import 'wordbook_detail_screen.dart';

class WordbooksScreen extends ConsumerWidget {
  const WordbooksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(wordbooksProvider);
    final words = ref.watch(allWordsProvider).asData?.value ?? const <Word>[];
    final remaining = words
        .where((w) => w.status != LearnStatus.completed)
        .length;
    final l10n = context.l10n;

    return PanelPage(
      header: ContentWidth(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(26, 18, 22, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeaderEyebrow(
                'WORDBOOKS',
                trailing: TextButton.icon(
                  onPressed: () => _createDialog(context, ref),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.point,
                    foregroundColor: AppColors.onPoint,
                    minimumSize: const Size(0, 34),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: Text(l10n.wordbooksNew),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      l10n.navWordbooks,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.5,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text.rich(
                      TextSpan(
                        text: '${l10n.homeRemainingCards} ',
                        children: [
                          TextSpan(
                            text: '$remaining',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                      style: TextStyle(fontSize: 12, color: AppColors.sub2),
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
        child: booksAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(l10n.wordbookError('$e'))),
          data: (books) {
            if (books.isEmpty) {
              return Center(
                child: Text(
                  l10n.wordbooksEmpty,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.onPanelSub),
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 24),
              itemCount: books.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, i) =>
                  _WordbookCard(book: books[i], highlighted: i == 0),
            );
          },
        ),
      ),
    );
  }

  Future<void> _createDialog(BuildContext context, WidgetRef ref) async {
    final result = await showWordbookDialog(
      context,
      dialogTitle: context.l10n.wordbooksNew,
      confirmLabel: context.l10n.wordbooksCreate,
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
  final l10n = context.l10n;

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
            decoration: InputDecoration(labelText: l10n.wordbooksNameLabel),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: tagsCtrl,
            decoration: InputDecoration(
              labelText: l10n.wordbooksTagsLabel,
              hintText: l10n.wordbooksTagsHint,
            ),
            onSubmitted: (_) => Navigator.pop(ctx, collect()),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(l10n.commonCancel),
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

  /// 맨 위 단어장은 흰 카드, 나머지는 패널 톤으로 구분한다.
  final bool highlighted;
  const _WordbookCard({required this.book, this.highlighted = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final words = ref.watch(wordsProvider(book.id)).asData?.value ?? const [];
    final count = words.length;
    final left = words.where((w) => w.status != LearnStatus.completed).length;
    final l10n = context.l10n;
    final fg = highlighted ? AppColors.ink : AppColors.onPanel;
    final track = highlighted ? AppColors.chip : AppColors.panel;
    final bar = highlighted ? AppColors.ink : AppColors.point;

    return Material(
      color: highlighted ? AppColors.card : AppColors.panelHigh,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => WordbookDetailScreen(book: book)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 6, 18),
          child: DefaultTextStyle.merge(
            style: TextStyle(color: fg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        book.title,
                        overflow: TextOverflow.ellipsis,
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
                        size: 14,
                        color: fg.withValues(alpha: 0.6),
                      ),
                    ],
                    const Spacer(),
                    PopupMenuButton<String>(
                      tooltip: l10n.wordbooksMenu,
                      icon: Icon(
                        Icons.more_vert,
                        size: 20,
                        color: fg.withValues(alpha: 0.6),
                      ),
                      onSelected: (v) {
                        if (v == 'rename') _rename(context, ref);
                        if (v == 'share') _shareSettings(context, ref);
                        if (v == 'delete') _delete(context, ref, count);
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: 'rename',
                          child: Text(l10n.wordbooksMenuRename),
                        ),
                        // 공유는 클라우드 모드 전용. 로컬 모드에서는 로그인 경로가
                        // 없으므로 메뉴 자체를 숨긴다.
                        if (ref.read(repositoryProvider).isCloud)
                          PopupMenuItem(
                            value: 'share',
                            child: Text(l10n.wordbooksShareSettings),
                          ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(l10n.wordbooksMenuDelete),
                        ),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$left',
                        style: const TextStyle(
                          fontSize: 40,
                          height: 1,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          l10n.wordbooksCardsLeft(count),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: fg.withValues(alpha: 0.65),
                          ),
                        ),
                      ),
                      for (final tag in book.tags.take(2))
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: _Tag(
                            tag,
                            background: highlighted
                                ? AppColors.chip
                                : AppColors.panel,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: count == 0 ? 0 : left / count,
                      minHeight: 4,
                      color: bar,
                      backgroundColor: track,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _rename(BuildContext context, WidgetRef ref) async {
    final result = await showWordbookDialog(
      context,
      dialogTitle: context.l10n.wordbooksEditTitle,
      confirmLabel: context.l10n.commonSave,
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
    final l10n = context.l10n;
    if (!ref.read(repositoryProvider).isCloud) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.wordbooksShareLoginRequired)));
      return;
    }

    var selected = book.visibility;
    final saved = await showDialog<Visibility>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(l10n.wordbooksShareSettings),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SegmentedButton<Visibility>(
                expandedInsets: EdgeInsets.zero,
                segments: [
                  ButtonSegment(
                    value: Visibility.private,
                    label: Text(l10n.wordbooksVisibilityPrivate),
                  ),
                  ButtonSegment(
                    value: Visibility.shared,
                    label: Text(l10n.wordbooksVisibilityShared),
                  ),
                  ButtonSegment(
                    value: Visibility.public,
                    label: Text(l10n.wordbooksVisibilityPublic),
                  ),
                ],
                selected: {selected},
                onSelectionChanged: (s) =>
                    setDialogState(() => selected = s.first),
              ),
              const SizedBox(height: 12),
              Text(switch (selected) {
                Visibility.private => l10n.wordbooksVisibilityPrivateDesc,
                Visibility.shared => l10n.wordbooksVisibilitySharedDesc,
                Visibility.public => l10n.wordbooksVisibilityPublicDesc,
              }, style: TextStyle(color: AppColors.sub, fontSize: 12)),
              if (selected != Visibility.private) ...[
                const SizedBox(height: 14),
                Text(
                  l10n.wordbookShareCode,
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
                        tooltip: l10n.wordbooksCopyCode,
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.copy, size: 17),
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: book.id));
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(content: Text(l10n.wordbooksCodeCopied)),
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
              child: Text(l10n.commonCancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, selected),
              child: Text(l10n.commonSave),
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
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.wordbookDeleteTitle(book.title)),
        content: Text(
          count > 0
              ? l10n.wordbooksDeleteWithWords(count)
              : l10n.wordbooksDeleteEmpty,
        ),
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
    if (ok != true) return;
    await ref.read(repositoryProvider).deleteWordbook(book.id);
    ref.invalidate(wordsProvider(book.id));
    invalidateData(ref);
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final Color background;
  const _Tag(this.text, {required this.background});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(text, style: const TextStyle(fontSize: 11)),
  );
}
