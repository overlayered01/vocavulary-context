import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/l10n.dart';
import '../providers.dart';
import '../models/translation_language.dart';
import '../services/dictionary_service.dart';
import '../theme.dart';

class DictionarySelection {
  final String term;
  final List<DictionarySense> senses;
  const DictionarySelection(this.term, this.senses);

  /// 고른 뜻의 출처. 내장 언어판 사전 뜻은 'ko:take' 형식으로 남는다.
  List<String> get sourceTerms =>
      {for (final sense in senses) sense.sourceTerm(term)}.toList();

  String get suggestedPartOfSpeech {
    final parts = senses.map((sense) => sense.partOfSpeechLabel).toSet();
    return parts.length == 1 ? parts.single : '';
  }
}

class DictionaryLookupButton extends StatelessWidget {
  final String term;
  final List<String> Function() meanings;
  final Future<void> Function(DictionarySelection) onSelected;
  final TranslationLanguage? translationLanguage;

  const DictionaryLookupButton({
    super.key,
    required this.term,
    required this.meanings,
    required this.onSelected,
    this.translationLanguage,
  });

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: TextButton.icon(
      onPressed: term.trim().isEmpty
          ? null
          : () async {
              FocusManager.instance.primaryFocus?.unfocus();
              final selected = await showDialog<DictionarySelection>(
                context: context,
                builder: (_) => _DictionaryDialog(
                  term: term.trim(),
                  meanings: meanings(),
                  language: translationLanguage,
                ),
              );
              if (selected == null || !context.mounted) return;
              try {
                await onSelected(selected);
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.l10n.dictLookupAddFailed)),
                  );
                }
              }
            },
      icon: const Icon(Icons.menu_book_outlined, size: 18),
      label: Text(context.l10n.dictLookupButton),
    ),
  );
}

class _DictionaryDialog extends ConsumerStatefulWidget {
  final String term;
  final List<String> meanings;
  final TranslationLanguage? language;
  const _DictionaryDialog({
    required this.term,
    required this.meanings,
    this.language,
  });

  @override
  ConsumerState<_DictionaryDialog> createState() => _DictionaryDialogState();
}

class _DictionaryDialogState extends ConsumerState<_DictionaryDialog> {
  late Future<DictionaryResult> _lookup;
  DictionaryResult? _result;
  final _selected = <int>{};
  late final TranslationLanguage _language;

  @override
  void initState() {
    super.initState();
    _language =
        widget.language ?? ref.read(settingsProvider).translationLanguage;
    _lookup = ref
        .read(dictionaryServiceProvider)
        .lookup(widget.term, translationLanguage: _language);
  }

  void _retry() => setState(() {
    _selected.clear();
    _result = null;
    _lookup = ref
        .read(dictionaryServiceProvider)
        .lookup(widget.term, translationLanguage: _language);
  });

  @override
  Widget build(BuildContext context) {
    final selected = [
      if (_result != null)
        for (var i = 0; i < _result!.senses.length; i++)
          if (_selected.contains(i)) _result!.senses[i],
    ];
    final count = selected.map((sense) => sense.meaning).toSet().length;
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 560,
          maxHeight: MediaQuery.sizeOf(context).height * .85,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.dictLookupTitle(widget.term),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (_language.hasTranslations) ...[
                const SizedBox(height: 6),
                Text(
                  context.l10n.dictLookupFallbackNotice(
                    context.l10n.language(_language),
                  ),
                  style: TextStyle(color: AppColors.sub, fontSize: 12),
                ),
              ],
              const SizedBox(height: 12),
              Flexible(
                child: FutureBuilder<DictionaryResult>(
                  future: _lookup,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const SizedBox(
                        height: 140,
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      final error = snapshot.error;
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            Text(
                              error is DictionaryLookupException
                                  ? error.message
                                  : context.l10n.dictLookupLoadFailed,
                            ),
                            TextButton(
                              onPressed: _retry,
                              child: Text(context.l10n.commonRetry),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      );
                    }
                    final result = snapshot.requireData;
                    _result = result;
                    if (result.senses.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text(context.l10n.dictLookupNoResults),
                      );
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: result.senses.length,
                      separatorBuilder: (_, _) => const Divider(height: 16),
                      itemBuilder: (context, index) {
                        final sense = result.senses[index];
                        final saved = widget.meanings.any(
                          (m) => m.trim() == sense.meaning,
                        );
                        return CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          isThreeLine: false,
                          value: saved || _selected.contains(index),
                          onChanged: saved
                              ? null
                              : (checked) => setState(() {
                                  if (checked == true) {
                                    _selected.add(index);
                                  } else {
                                    _selected.remove(index);
                                  }
                                }),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                [
                                  context.l10n.partOfSpeech(
                                    sense.partOfSpeechLabel,
                                  ),
                                  if (saved)
                                    context.l10n.dictLookupAlreadyAdded,
                                ].where((s) => s.isNotEmpty).join(' · '),
                                style: TextStyle(
                                  color: AppColors.sub,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                sense.meaning,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          // 내장 사전 뜻은 영어 풀이가 없다.
                          subtitle:
                              sense.translations.isEmpty ||
                                  sense.definition.isEmpty
                              ? null
                              : Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: Text(
                                    sense.definition,
                                    style: TextStyle(
                                      color: AppColors.sub,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              DictionaryAttribution(terms: [widget.term]),
              const SizedBox(height: 12),
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(context.l10n.commonClose),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: selected.isEmpty
                          ? null
                          : () => Navigator.pop(
                              context,
                              DictionarySelection(widget.term, selected),
                            ),
                      child: Text(context.l10n.dictLookupAddSelected(count)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Keep attribution visible for saved/imported dictionary definitions too.
class DictionaryAttribution extends StatelessWidget {
  final List<String> terms;
  const DictionaryAttribution({super.key, required this.terms});

  @override
  Widget build(BuildContext context) {
    if (terms.isEmpty) return const SizedBox.shrink();
    Widget link(String label, Uri uri) => TextButton(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.sub,
        textStyle: const TextStyle(fontSize: 11),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        minimumSize: const Size(0, 32),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: () async {
        try {
          final opened = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
            webOnlyWindowName: '_blank',
          );
          if (opened) return;
        } catch (_) {
          /* Show the same message for unsupported launchers. */
        }
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.dictLookupLinkFailed)),
          );
        }
      },
      child: Text(label),
    );
    // 'ko:take'는 한국어판 Wiktionary(내장 사전), 'take'는 영어판(온라인 사전).
    final sources = [
      for (final term in terms.toSet())
        switch (RegExp(r'^([a-z]{2}):(.+)$').firstMatch(term)) {
          final m? => (edition: m.group(1)!, term: m.group(2)!),
          null => (edition: 'en', term: term),
        },
    ];
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final source in sources)
          link(
            source.edition == 'en'
                ? 'Wiktionary · ${source.term}'
                : 'Wiktionary (${source.edition}) · ${source.term}',
            Uri(
              scheme: 'https',
              host: '${source.edition}.wiktionary.org',
              pathSegments: ['wiki', source.term],
            ),
          ),
        if (sources.any((s) => s.edition == 'en'))
          link('FreeDictionaryAPI.com', Uri.https('freedictionaryapi.com')),
        if (sources.any((s) => s.edition != 'en'))
          link('Kaikki.org', Uri.https('kaikki.org')),
        link(
          'CC BY-SA 4.0',
          Uri.https('creativecommons.org', '/licenses/by-sa/4.0/'),
        ),
      ],
    );
  }
}
