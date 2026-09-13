import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers.dart';
import '../services/dictionary_service.dart';
import '../theme.dart';

class DictionarySelection {
  final String term;
  final List<DictionarySense> senses;
  const DictionarySelection(this.term, this.senses);

  String get suggestedPartOfSpeech {
    final parts = senses.map((sense) => sense.partOfSpeechLabel).toSet();
    return parts.length == 1 ? parts.single : '';
  }
}

class DictionaryLookupButton extends StatelessWidget {
  final String term;
  final List<String> Function() meanings;
  final Future<void> Function(DictionarySelection) onSelected;

  const DictionaryLookupButton({
    super.key,
    required this.term,
    required this.meanings,
    required this.onSelected,
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
                builder: (_) =>
                    _DictionaryDialog(term: term.trim(), meanings: meanings()),
              );
              if (selected == null || !context.mounted) return;
              try {
                await onSelected(selected);
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('뜻을 추가하지 못했어요. 다시 시도해 주세요.')),
                  );
                }
              }
            },
      icon: const Icon(Icons.menu_book_outlined, size: 18),
      label: const Text('사전 뜻 보기'),
    ),
  );
}

class _DictionaryDialog extends ConsumerStatefulWidget {
  final String term;
  final List<String> meanings;
  const _DictionaryDialog({required this.term, required this.meanings});

  @override
  ConsumerState<_DictionaryDialog> createState() => _DictionaryDialogState();
}

class _DictionaryDialogState extends ConsumerState<_DictionaryDialog> {
  late Future<DictionaryResult> _lookup;
  DictionaryResult? _result;
  final _selected = <int>{};

  @override
  void initState() {
    super.initState();
    _lookup = ref.read(dictionaryServiceProvider).lookup(widget.term);
  }

  void _retry() => setState(() {
    _selected.clear();
    _result = null;
    _lookup = ref.read(dictionaryServiceProvider).lookup(widget.term);
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
                '${widget.term} · 사전 뜻',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              const Text(
                '한국어 뜻이 없는 항목은 영어 풀이로 표시해요.',
                style: TextStyle(color: AppColors.sub, fontSize: 12),
              ),
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
                                  : '사전 뜻을 불러오지 못했어요.',
                            ),
                            TextButton(
                              onPressed: _retry,
                              child: const Text('다시 시도'),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      );
                    }
                    final result = snapshot.requireData;
                    _result = result;
                    if (result.senses.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          '사전에 등록된 뜻을 찾지 못했어요.\n철자를 확인하거나 다른 사전에서 찾아보세요.',
                        ),
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
                                  sense.partOfSpeechLabel,
                                  if (saved) '추가됨',
                                ].where((s) => s.isNotEmpty).join(' · '),
                                style: const TextStyle(
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
                          subtitle: sense.korean.isEmpty
                              ? null
                              : Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: Text(
                                    sense.definition,
                                    style: const TextStyle(
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
                    child: const Text('닫기'),
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
                      child: Text('선택한 뜻 추가 ($count)'),
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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('사전 링크를 열지 못했어요.')));
        }
      },
      child: Text(label),
    );
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final term in terms.toSet())
          link(
            'Wiktionary · $term',
            Uri(
              scheme: 'https',
              host: 'en.wiktionary.org',
              pathSegments: ['wiki', term],
            ),
          ),
        link('FreeDictionaryAPI.com', Uri.https('freedictionaryapi.com')),
        link(
          'CC BY-SA 4.0',
          Uri.https('creativecommons.org', '/licenses/by-sa/4.0/'),
        ),
      ],
    );
  }
}
