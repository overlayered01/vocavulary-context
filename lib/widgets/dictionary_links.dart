import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/l10n.dart';
import '../models/translation_language.dart';
import '../theme.dart';

enum DictionarySource {
  naver,
  weblio,
  youdao,
  spanishDict,
  wordReferenceFr,
  wordReferencePt,
  leo,
  longdo,
  merriamWebster,
  cambridge,
  oxford;

  /// 번역 언어별 링크: 현지 대표 사전, 그 언어의 Cambridge, Oxford(영영) 순.
  static List<DictionarySource> forLanguage(TranslationLanguage language) => [
    ?switch (language) {
      TranslationLanguage.korean => naver,
      TranslationLanguage.english => merriamWebster,
      TranslationLanguage.japanese => weblio,
      TranslationLanguage.chinese => youdao,
      TranslationLanguage.spanish => spanishDict,
      TranslationLanguage.french => wordReferenceFr,
      TranslationLanguage.portuguese => wordReferencePt,
      TranslationLanguage.german => leo,
      TranslationLanguage.thai => longdo,
      // 대표적인 무료 영어 사전을 확인하지 못한 언어는 Cambridge·Oxford만 둔다.
      TranslationLanguage.vietnamese || TranslationLanguage.indonesian => null,
    },
    cambridge,
    oxford,
  ];

  String label(AppLocalizations l10n) => switch (this) {
    naver => l10n.dictLinksNaver,
    weblio => 'Weblio',
    youdao => '有道词典',
    spanishDict => 'SpanishDict',
    wordReferenceFr || wordReferencePt => 'WordReference',
    leo => 'LEO',
    longdo => 'Longdo Dict',
    merriamWebster => 'Merriam-Webster',
    cambridge => 'Cambridge',
    oxford => l10n.dictLinksOxford,
  };

  Uri searchUri(
    String term, [
    TranslationLanguage language = TranslationLanguage.korean,
  ]) {
    final query = term.trim();
    final path = Uri.encodeComponent(query);
    return switch (this) {
      naver => Uri.https(
        'en.dict.naver.com',
      ).replace(fragment: '/search?query=$path'),
      weblio => Uri.parse('https://ejje.weblio.jp/content/$path'),
      youdao => Uri.https('dict.youdao.com', '/result', {
        'word': query,
        'lang': 'en',
      }),
      spanishDict => Uri.parse('https://www.spanishdict.com/translate/$path'),
      wordReferenceFr => Uri.parse('https://www.wordreference.com/enfr/$path'),
      wordReferencePt => Uri.parse('https://www.wordreference.com/enpt/$path'),
      leo => Uri.parse('https://dict.leo.org/englisch-deutsch/$path'),
      longdo => Uri.parse('https://dict.longdo.com/search/$path'),
      merriamWebster => Uri.parse(
        'https://www.merriam-webster.com/dictionary/$path',
      ),
      cambridge => Uri.https(
        'dictionary.cambridge.org',
        '/search/${_cambridgeDataset(language)}/direct/',
        {'q': query},
      ),
      oxford => Uri.https(
        'www.oxfordlearnersdictionaries.com',
        '/search/english/',
        {'q': query},
      ),
    };
  }

  static String _cambridgeDataset(TranslationLanguage language) =>
      switch (language) {
        TranslationLanguage.english => 'english',
        TranslationLanguage.chinese => 'english-chinese-simplified',
        _ => 'english-${language.name}',
      };
}

class DictionaryLinks extends StatelessWidget {
  final String term;

  /// 뜻·예문 번역 언어. 이 언어에 맞는 사전을 보여준다.
  final TranslationLanguage language;
  const DictionaryLinks({
    super.key,
    required this.term,
    this.language = TranslationLanguage.korean,
  });

  Future<void> _open(BuildContext context, DictionarySource source) async {
    try {
      final opened = await launchUrl(
        source.searchUri(term, language),
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: '_blank',
      );
      if (opened || !context.mounted) return;
    } catch (_) {
      if (!context.mounted) return;
    }
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.dictLinksOpenFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.dictLinksTitle,
          style: TextStyle(color: AppColors.sub, fontSize: 13),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            for (final source in DictionarySource.forLanguage(language))
              TextButton.icon(
                onPressed: term.trim().isEmpty
                    ? null
                    : () => _open(context, source),
                icon: const Icon(Icons.open_in_new, size: 15),
                label: Text(source.label(context.l10n)),
              ),
          ],
        ),
      ],
    );
  }
}
