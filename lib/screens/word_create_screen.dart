import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/wordbook.dart';
import '../providers.dart';
import '../theme.dart';
import 'word_edit_screen.dart';

class WordCreateScreen extends ConsumerStatefulWidget {
  final String? wordbookId;
  const WordCreateScreen({super.key, this.wordbookId});

  @override
  ConsumerState<WordCreateScreen> createState() => _WordCreateScreenState();
}

class _WordCreateScreenState extends ConsumerState<WordCreateScreen> {
  final _term = TextEditingController();
  String? _selectedBookId;
  bool _loading = false;
  String? _error;

  Wordbook? _selectedBook(List<Wordbook> books) =>
      books
          .where((book) => book.id == (_selectedBookId ?? widget.wordbookId))
          .firstOrNull ??
      books.firstOrNull;

  @override
  void dispose() {
    _term.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final term = _term.text.trim();
    final book = _selectedBook(ref.read(wordbooksProvider).asData?.value ?? []);
    if (term.isEmpty || book == null || _loading) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final service = ref.read(wordDraftServiceProvider);
      final savedWords = await ref.read(repositoryProvider).getAllWords();
      if (!mounted) return;
      final draft = await service.create(
        term: term,
        wordbookId: book.id,
        savedWords: savedWords,
      );
      if (!mounted) return;
      final saved = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => WordEditScreen(
            wordbookId: book.id,
            wordbookTitle: book.title,
            initialDraft: draft.word,
            draftNotice: draft.notice,
            pendingExamples: draft.pendingExamples,
          ),
        ),
      );
      if (saved == true && mounted) {
        ref.invalidate(wordsProvider(book.id));
        invalidateData(ref);
        Navigator.pop(context, true);
      }
    } catch (_) {
      if (mounted) setState(() => _error = '불러오지 못했습니다. 다시 시도해 주세요.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final booksAsync = ref.watch(wordbooksProvider);
    final books = booksAsync.asData?.value ?? const <Wordbook>[];
    final selectedBook = _selectedBook(books);
    return Scaffold(
      appBar: AppBar(title: const Text('단어 추가')),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              children: [
                const Text(
                  '단어 입력',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 24),
                DropdownButtonFormField<String>(
                  key: ValueKey(selectedBook?.id),
                  initialValue: selectedBook?.id,
                  isExpanded: true,
                  menuMaxHeight: 300,
                  decoration: const InputDecoration(labelText: '단어장'),
                  hint: Text(booksAsync.isLoading ? '불러오는 중' : '단어장 없음'),
                  items: [
                    for (final book in books)
                      DropdownMenuItem(
                        value: book.id,
                        child: Text(
                          book.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: _loading
                      ? null
                      : (value) => setState(() => _selectedBookId = value),
                ),
                if (booksAsync.hasError)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => ref.invalidate(wordbooksProvider),
                      child: const Text('단어장 다시 불러오기'),
                    ),
                  ),
                const SizedBox(height: 16),
                TextField(
                  controller: _term,
                  autofocus: true,
                  readOnly: _loading,
                  autocorrect: false,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _create(),
                  decoration: const InputDecoration(
                    labelText: '단어',
                    hintText: 'happy',
                  ),
                ),
                const SizedBox(height: 20),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _term,
                  builder: (_, value, _) => ElevatedButton.icon(
                    onPressed:
                        _loading ||
                            selectedBook == null ||
                            value.text.trim().isEmpty
                        ? null
                        : _create,
                    icon: _loading
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check_rounded, size: 21),
                    label: Text(_loading ? '불러오는 중' : '완료'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                    ),
                  ),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: AppColors.sub),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
