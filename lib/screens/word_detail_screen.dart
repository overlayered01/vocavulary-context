import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/l10n.dart';
import '../models/translation_language.dart';
import '../models/word.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/speak_button.dart';
import '../widgets/meaning_fields.dart';
import '../widgets/panel.dart';
import '../widgets/dictionary_links.dart';
import '../widgets/dictionary_lookup.dart';
import 'word_edit_screen.dart';

/// 단어 상세: 뜻·예문·발음(TTS)·사전 딥링크.
class WordDetailScreen extends ConsumerStatefulWidget {
  final Word word;
  final String wordbookTitle;
  const WordDetailScreen({
    super.key,
    required this.word,
    this.wordbookTitle = '',
  });

  @override
  ConsumerState<WordDetailScreen> createState() => _WordDetailScreenState();
}

class _WordDetailScreenState extends ConsumerState<WordDetailScreen> {
  late Word _word;

  @override
  void initState() {
    super.initState();
    _word = widget.word;
  }

  Future<void> _edit() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => WordEditScreen(
          wordbookId: _word.wordbookId,
          wordbookTitle: widget.wordbookTitle,
          existing: _word,
        ),
      ),
    );
    if (saved != true || !mounted) return;

    final words = await ref.read(repositoryProvider).getWords(_word.wordbookId);
    if (!mounted) return;
    for (final word in words) {
      if (word.id == _word.id) {
        setState(() => _word = word);
        break;
      }
    }
  }

  /// 다시 찾은 예문을 카드에 넣는다.
  Future<void> _addFoundExample(Example example) async {
    final updated = await ref
        .read(repositoryProvider)
        .upsertWord(
          _word.copyWith(
            examples: [..._word.examples, example],
            updatedAt: DateTime.now(),
          ),
        );
    if (!mounted) return;
    setState(() => _word = updated);
    ref.invalidate(wordsProvider(updated.wordbookId));
    invalidateData(ref);
  }

  Future<void> _toggleFavorite() async {
    final updated = await ref
        .read(repositoryProvider)
        .upsertWord(
          _word.copyWith(favorite: !_word.favorite, updatedAt: DateTime.now()),
        );
    if (!mounted) return;
    setState(() => _word = updated);
    invalidateData(ref);
  }

  Future<void> _addDictionaryMeanings(DictionarySelection selection) async {
    final repo = ref.read(repositoryProvider);
    final words = await repo.getWords(_word.wordbookId);
    final latest = words.where((word) => word.id == _word.id).firstOrNull;
    if (latest == null || latest.term.trim() != selection.term) {
      throw StateError('Word changed or was deleted');
    }
    final meanings = Word.normalizeMeanings([
      ...latest.meanings,
      ...selection.senses.map((sense) => sense.meaning),
    ]);
    if (meanings.length == latest.meanings.length) return;
    final updated = await repo.upsertWord(
      latest.copyWith(
        meanings: meanings,
        dictionarySourceTerms: {
          ...latest.dictionarySourceTerms,
          ...selection.sourceTerms,
        }.toList(),
        partOfSpeech: latest.partOfSpeech.isEmpty
            ? selection.suggestedPartOfSpeech
            : latest.partOfSpeech,
        updatedAt: DateTime.now(),
      ),
    );
    if (!mounted) return;
    setState(() => _word = updated);
    ref.invalidate(wordsProvider(updated.wordbookId));
    invalidateData(ref);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.wordDetailDictionaryMeaningsAdded)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final word = _word;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.panel,
      body: PanelPage(
        header: ContentWidth(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    BackButton(color: AppColors.ink),
                    const Spacer(),
                    IconButton(
                      tooltip: word.favorite
                          ? l10n.wordDetailUnfavorite
                          : l10n.wordDetailFavorite,
                      icon: Icon(
                        word.favorite
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: AppColors.ink,
                      ),
                      onPressed: _toggleFavorite,
                    ),
                    IconButton(
                      tooltip: l10n.wordEditWord,
                      icon: Icon(Icons.edit_outlined, color: AppColors.ink),
                      onPressed: _edit,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 4, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              word.term,
                              style: TextStyle(
                                fontSize: 42,
                                height: 1.1,
                                fontWeight: FontWeight.w300,
                                letterSpacing: -0.8,
                                color: AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                PosChip(word.partOfSpeech, filled: true),
                                if (word.phonetic.isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    word.phonetic,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.sub,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      SpeakButton(text: word.term, prominent: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bodyPadding: EdgeInsets.zero,
        body: ContentWidth(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
            children: [
              PanelLabel(l10n.wordDetailMyMeanings),
              WhiteBlock(
                onTap: _edit,
                padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: MeaningList(
                        meanings: word.meanings,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    Icon(Icons.edit_outlined, size: 18, color: AppColors.sub),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              PanelLabel(l10n.wordExamples),
              for (final e in word.examples) ...[
                WhiteBlock(
                  padding: const EdgeInsets.fromLTRB(18, 14, 8, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ExampleSentence(
                              sentence: e.sentence,
                              term: word.term,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                                height: 1.45,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                          SpeakButton(
                            text: e.sentence,
                            isSentence: true,
                            tooltip: l10n.wordDetailListenExample,
                          ),
                        ],
                      ),
                      if (e.translation.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Text(
                            e.translation,
                            style: TextStyle(
                              color: AppColors.sub,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                      if (e.source.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: e.source == 'Tatoeba' && e.sourceId.isNotEmpty
                              ? () => _open(
                                  'https://tatoeba.org/en/sentences/show/${e.sourceId}',
                                )
                              : null,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                l10n.wordExampleSource(
                                  exampleSourceLabel(context, e),
                                ),
                                style: TextStyle(
                                  color: AppColors.sub,
                                  fontSize: 11,
                                ),
                              ),
                              if (e.source == 'Tatoeba' &&
                                  e.sourceId.isNotEmpty) ...[
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.open_in_new_rounded,
                                  color: AppColors.sub,
                                  size: 13,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
              if (word.examples.isEmpty)
                for (final e
                    in ref
                            .watch(exampleSuggestionsProvider)
                            .asData
                            ?.value[word.id] ??
                        const <Example>[]) ...[
                  WhiteBlock(
                    key: ValueKey('found-${e.sourceId}'),
                    color: AppColors.panelHigh,
                    padding: const EdgeInsets.fromLTRB(18, 14, 8, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.wordFoundExample,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.point,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ExampleSentence(
                          sentence: e.sentence,
                          term: word.term,
                          highlight: AppColors.onPanel.withValues(alpha: 0.18),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                            height: 1.45,
                            color: AppColors.onPanel,
                          ),
                        ),
                        if (e.translation.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            e.translation,
                            style: TextStyle(
                              color: AppColors.onPanelSub,
                              fontSize: 13,
                            ),
                          ),
                        ],
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () => _addFoundExample(e),
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: Text(l10n.wordAddFoundExample),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.point,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              const SizedBox(height: 8),
              WhiteBlock(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DictionaryLookupButton(
                      term: word.term,
                      meanings: () => word.meanings,
                      onSelected: _addDictionaryMeanings,
                    ),
                    DictionaryAttribution(terms: word.dictionarySourceTerms),
                    const SizedBox(height: 8),
                    DictionaryLinks(
                      term: word.term,
                      language: TranslationLanguage.fromCode(
                        word.translationLanguage,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _open(
                        'https://translate.google.com/?sl=en&tl=ko&text=${Uri.encodeComponent(word.term)}',
                      ),
                      icon: const Icon(Icons.open_in_new, size: 15),
                      label: Text(l10n.wordDetailGoogleTranslate),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
