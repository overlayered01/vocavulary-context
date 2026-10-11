import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/migration.dart';
import '../data/supabase_repository.dart';
import '../l10n/l10n.dart';
import '../models/wordbook.dart' hide Visibility;
import '../providers.dart';
import '../theme.dart';
import 'login_screen.dart';

/// 공유·탐색 탭. 공유 코드로 단어장을 가져오거나 공개 단어장을 둘러보고 복제한다.
/// 클라우드 로그인 상태에서만 동작한다 (로컬 모드에서는 안내만 표시).
class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final _code = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _importByCode(SupabaseRepository repo) async {
    final code = _code.text.trim();
    if (code.isEmpty || _busy) return;
    setState(() => _busy = true);
    try {
      final book = await repo.getSharedWordbook(code);
      if (!mounted) return;
      if (book == null) {
        _snack(context.l10n.exploreCodeNotFound);
        return;
      }
      final done = await _importBook(repo, book);
      if (done && mounted) _code.clear();
    } catch (_) {
      if (mounted) _snack(context.l10n.exploreImportFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// 단어 수 확인 다이얼로그를 거쳐 [book]을 내 단어장으로 복제한다.
  Future<bool> _importBook(SupabaseRepository repo, Wordbook book) async {
    final words = await repo.getSharedWords(book.id);
    if (!mounted) return false;

    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.exploreCopyTitle(book.title)),
        content: Text(l10n.exploreCopyConfirm(words.length)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.exploreCopy),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return false;

    await importSharedWordbook(repo, book, words);
    invalidateData(ref);
    if (mounted) _snack(context.l10n.exploreImported(book.title));
    return true;
  }

  void _snack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(repositoryProvider);
    final cloudAvailable = ref.watch(cloudAvailableProvider);
    final l10n = context.l10n;

    if (repo is! SupabaseRepository) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.exploreTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Card(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.accentSoft,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.travel_explore_rounded,
                          size: 30,
                          color: AppColors.accentDark,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        l10n.exploreLoggedOutHeadline,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        l10n.exploreLoginRequired,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.sub,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                      if (cloudAvailable) ...[
                        const SizedBox(height: 22),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            ),
                            child: Text(l10n.exploreGoToLogin),
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 12),
                        Text(
                          l10n.exploreSupabaseRequired,
                          style: TextStyle(
                            color: AppColors.sub,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    final publicBooks = ref.watch(publicWordbooksProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.exploreTitle)),
      body: RefreshIndicator(
        color: AppColors.accentDark,
        onRefresh: () => ref.refresh(publicWordbooksProvider.future),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            _SectionLabel(l10n.exploreImportByCode),
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _code,
                            decoration: InputDecoration(
                              labelText: l10n.wordbookShareCode,
                              hintText: l10n.exploreCodeHint,
                            ),
                            onSubmitted: (_) => _importByCode(repo),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _busy ? null : () => _importByCode(repo),
                          child: _busy
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(l10n.exploreImport),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.exploreCodeHelp,
                      style: TextStyle(
                        color: AppColors.sub,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            _SectionLabel(l10n.explorePublicWordbooks),
            publicBooks.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.explorePublicLoadFailed,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.sub),
                ),
              ),
              data: (books) {
                if (books.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      l10n.explorePublicEmpty,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.sub),
                    ),
                  );
                }
                return Column(
                  children: [
                    for (final book in books)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _PublicBookCard(
                          book: book,
                          onImport: () => _importBook(repo, book),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PublicBookCard extends StatelessWidget {
  final Wordbook book;
  final VoidCallback onImport;
  const _PublicBookCard({required this.book, required this.onImport});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 12, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (book.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      book.description,
                      style: TextStyle(
                        color: AppColors.sub,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  if (book.tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final tag in book.tags)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.chip,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                color: AppColors.sub,
                                fontSize: 11,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: onImport,
              child: Text(context.l10n.exploreCopy),
            ),
          ],
        ),
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
      style: TextStyle(
        color: AppColors.sub,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
