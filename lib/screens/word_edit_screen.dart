import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/word.dart';
import '../providers.dart';
import '../services/word_image_picker.dart';
import '../theme.dart';
import '../widgets/word_image.dart';
import '../widgets/meaning_fields.dart';
import '../widgets/dictionary_links.dart';
import '../widgets/dictionary_lookup.dart';

/// 단어 추가/편집. 단어·뜻·품사·발음기호 + 예문(문장/해석) 여러 개.
class WordEditScreen extends ConsumerStatefulWidget {
  final String wordbookId;
  final String wordbookTitle;
  final Word? existing;
  final Word? initialDraft;
  final String? draftNotice;
  final Future<List<Example>>? pendingExamples;
  const WordEditScreen({
    super.key,
    required this.wordbookId,
    this.wordbookTitle = '',
    this.existing,
    this.initialDraft,
    this.draftNotice,
    this.pendingExamples,
  }) : assert(existing == null || initialDraft == null);

  @override
  ConsumerState<WordEditScreen> createState() => _WordEditScreenState();
}

class _WordEditScreenState extends ConsumerState<WordEditScreen> {
  static const _partsOfSpeech = [
    '명사',
    '동사',
    '형용사',
    '부사',
    '대명사',
    '전치사',
    '접속사',
    '감탄사',
    '관사',
    '한정사',
    '구동사',
    '숙어',
  ];

  late final TextEditingController _term;
  late List<TextEditingController> _meanings;
  late List<String> _dictionarySourceTerms;
  late final TextEditingController _pos;
  late final TextEditingController _phonetic;
  late final FocusNode _termFocus;
  late String _imageUrl;
  bool _pickingImage = false;
  bool _fetchingExamples = false;
  bool _pendingExamples = false;
  bool _acceptPendingExamples = true;
  bool _examplesChanged = false;
  bool _saving = false;
  late List<_EditableExample> _examples;

  @override
  void initState() {
    super.initState();
    final w = widget.existing ?? widget.initialDraft;
    _term = TextEditingController(text: w?.term ?? '');
    _term.addListener(() {
      if (_term.text.trim() != widget.initialDraft?.term.trim()) {
        _acceptPendingExamples = false;
        if (_pendingExamples && mounted) {
          setState(() => _pendingExamples = false);
        }
      }
    });
    _dictionarySourceTerms = [...?w?.dictionarySourceTerms];
    _meanings = [
      for (final value in w == null || w.meanings.isEmpty ? [''] : w.meanings)
        TextEditingController(text: value),
    ];
    _pos = TextEditingController(text: w?.partOfSpeech ?? '');
    _phonetic = TextEditingController(text: w?.phonetic ?? '');
    _termFocus = FocusNode();
    _imageUrl = w?.imageUrl ?? '';
    _examples = (w?.examples ?? const <Example>[])
        .map(_EditableExample.fromExample)
        .toList();
    if (_examples.isEmpty) _addExample();
    if (widget.pendingExamples != null) {
      _pendingExamples = true;
      _finishPendingExamples();
    }
  }

  Future<void> _finishPendingExamples() async {
    try {
      final examples = await widget.pendingExamples!;
      if (!mounted ||
          !_acceptPendingExamples ||
          _saving ||
          _examplesChanged ||
          _examples.any((example) => example.edited) ||
          _term.text.trim() != widget.initialDraft?.term.trim() ||
          examples.isEmpty) {
        return;
      }
      final previous = _examples;
      setState(
        () => _examples = examples.map(_EditableExample.fromExample).toList(),
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        for (final example in previous) {
          example.s.dispose();
          example.t.dispose();
        }
      });
    } catch (_) {
      // The dictionary draft remains usable when the example source fails.
    } finally {
      if (mounted) setState(() => _pendingExamples = false);
    }
  }

  void _addExample() {
    _examples.add(_EditableExample());
  }

  void _removeExample(int index) {
    _examplesChanged = true;
    final example = _examples[index];
    if (_examples.length == 1) {
      example.s.clear();
      example.t.clear();
      return;
    }
    example.s.dispose();
    example.t.dispose();
    _examples.removeAt(index);
  }

  void _applySuggestion(Word word) {
    _acceptPendingExamples = false;
    _pendingExamples = false;
    _term.text = word.term;
    _dictionarySourceTerms = [...word.dictionarySourceTerms];
    final previous = _meanings;
    _meanings = [
      for (final value in word.meanings.isEmpty ? [''] : word.meanings)
        TextEditingController(text: value),
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final controller in previous) {
        controller.dispose();
      }
    });
    _pos.text = word.partOfSpeech;
    _phonetic.text = word.phonetic;
    _imageUrl = word.imageUrl;

    for (final example in _examples) {
      example.s.dispose();
      example.t.dispose();
    }
    _examples = word.examples.map(_EditableExample.fromExample).toList();
    if (_examples.isEmpty) _addExample();
    setState(() {});
  }

  Future<void> _addDictionaryMeanings(DictionarySelection selection) async {
    final existing = _meanings.map((c) => c.text.trim()).toSet();
    final added = <String>[];
    for (final sense in selection.senses) {
      if (existing.add(sense.meaning)) added.add(sense.meaning);
    }
    if (added.isEmpty) return;
    setState(() {
      for (final meaning in added) {
        final blank = _meanings.where((c) => c.text.trim().isEmpty).firstOrNull;
        if (blank != null) {
          blank.text = meaning;
        } else {
          _meanings.add(TextEditingController(text: meaning));
        }
      }
      if (!_dictionarySourceTerms.contains(selection.term)) {
        _dictionarySourceTerms.add(selection.term);
      }
      if (_pos.text.isEmpty) _pos.text = selection.suggestedPartOfSpeech;
    });
  }

  Future<void> _fetchExternalExamples() async {
    final term = _term.text.trim();
    if (term.isEmpty) {
      _termFocus.requestFocus();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('먼저 영어 단어를 입력해 주세요.')));
      return;
    }
    if (_fetchingExamples) return;

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _fetchingExamples = true);
    try {
      final fetched = await ref
          .read(exampleSourceServiceProvider)
          .fetchExamples(term);
      if (!mounted) return;

      final existing = {
        for (final example in _examples)
          if (example.s.text.trim().isNotEmpty)
            example.s.text.trim().toLowerCase(),
      };
      final candidates = fetched
          .where(
            (example) => !existing.contains(example.sentence.toLowerCase()),
          )
          .toList();
      if (candidates.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              fetched.isEmpty
                  ? "'$term'에 사용할 예문을 찾지 못했습니다."
                  : '가져온 예문이 모두 이미 추가되어 있습니다.',
            ),
          ),
        );
        return;
      }

      final selected = await showDialog<List<Example>>(
        context: context,
        builder: (context) =>
            _ExamplePickerDialog(term: term, examples: candidates),
      );
      if (selected == null || selected.isEmpty || !mounted) return;
      _appendExamples(selected);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('예문 ${selected.length}개를 추가했습니다.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('예문을 가져오지 못했습니다: $error')));
    } finally {
      if (mounted) setState(() => _fetchingExamples = false);
    }
  }

  void _appendExamples(List<Example> examples) {
    _examplesChanged = true;
    setState(() {
      for (final example in examples) {
        final blankIndex = _examples.indexWhere(
          (editable) => editable.s.text.trim().isEmpty,
        );
        if (blankIndex >= 0) {
          final editable = _examples[blankIndex];
          editable
            ..s.text = example.sentence
            ..t.text = example.translation
            ..source = example.source
            ..sourceId = example.sourceId
            ..license = example.license;
        } else {
          _examples.add(_EditableExample.fromExample(example));
        }
      }
    });
  }

  Future<void> _pickImage() async {
    if (_pickingImage) return;
    setState(() => _pickingImage = true);
    try {
      final source = await pickWordImage();
      if (mounted && source != null) setState(() => _imageUrl = source);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error is FormatException
                ? error.message
                : '이미지를 불러오지 못했습니다: $error',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _pickingImage = false);
    }
  }

  @override
  void dispose() {
    _term.dispose();
    for (final controller in _meanings) {
      controller.dispose();
    }
    _pos.dispose();
    _phonetic.dispose();
    _termFocus.dispose();
    for (final e in _examples) {
      e.s.dispose();
      e.t.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    final meanings = Word.normalizeMeanings(_meanings.map((c) => c.text));
    if (_term.text.trim().isEmpty || meanings.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('단어와 뜻을 하나 이상 입력해 주세요.')));
      return;
    }
    _acceptPendingExamples = false;
    setState(() => _saving = true);
    final examples = _examples
        .where((e) => e.s.text.trim().isNotEmpty)
        .map(
          (e) => Example(
            sentence: e.s.text.trim(),
            translation: e.t.text.trim(),
            source: e.source,
            sourceId: e.sourceId,
            license: e.license,
          ),
        )
        .toList();

    final base = widget.existing;
    final now = DateTime.now();
    final word = base == null
        ? Word(
            id: '',
            wordbookId: widget.wordbookId,
            term: _term.text.trim(),
            meanings: meanings,
            dictionarySourceTerms: _dictionarySourceTerms,
            partOfSpeech: _pos.text.trim(),
            phonetic: _phonetic.text.trim(),
            imageUrl: _imageUrl,
            examples: examples,
            createdAt: now,
            updatedAt: now,
          )
        : base.copyWith(
            term: _term.text.trim(),
            meanings: meanings,
            dictionarySourceTerms: _dictionarySourceTerms,
            partOfSpeech: _pos.text.trim(),
            phonetic: _phonetic.text.trim(),
            imageUrl: _imageUrl,
            examples: examples,
            updatedAt: now,
          );

    try {
      await ref.read(repositoryProvider).upsertWord(word);
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('저장하지 못했습니다. 다시 시도해 주세요.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final savedWords =
        ref.watch(allWordsProvider).asData?.value ?? const <Word>[];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? '단어 추가' : '단어 편집'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: const Text(
              '저장',
              style: TextStyle(
                color: AppColors.accentDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (widget.wordbookTitle.isNotEmpty) ...[
            Text(
              widget.wordbookTitle,
              style: const TextStyle(color: AppColors.sub, fontSize: 13),
            ),
            const SizedBox(height: 20),
          ],
          if (widget.draftNotice != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                widget.draftNotice!,
                style: const TextStyle(color: AppColors.sub, fontSize: 13),
              ),
            ),
          _termField(savedWords),
          MeaningFields(
            controllers: _meanings,
            onAdd: () => setState(() => _meanings.add(TextEditingController())),
            onRemove: (i) {
              final removed = _meanings[i];
              setState(() => _meanings.removeAt(i));
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => removed.dispose(),
              );
            },
          ),
          const SizedBox(height: 8),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _term,
            builder: (_, value, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DictionaryLookupButton(
                  term: value.text,
                  meanings: () => _meanings.map((c) => c.text).toList(),
                  onSelected: _addDictionaryMeanings,
                ),
                DictionaryAttribution(terms: _dictionarySourceTerms),
                DictionaryLinks(term: value.text),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _partOfSpeechField()),
              const SizedBox(width: 10),
              Expanded(child: _field(_phonetic, '발음기호', '/ˈhæpi/')),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '대표 이미지',
            style: TextStyle(color: AppColors.sub, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _imageEditor(),
          const SizedBox(height: 8),
          Row(
            children: [
              const Expanded(
                child: Text(
                  '예문',
                  style: TextStyle(
                    color: AppColors.sub,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _fetchingExamples || _pendingExamples
                    ? null
                    : _fetchExternalExamples,
                icon: _fetchingExamples || _pendingExamples
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.travel_explore_rounded, size: 18),
                label: Text(
                  _fetchingExamples || _pendingExamples ? '검색 중' : '예문 가져오기',
                ),
              ),
              TextButton.icon(
                onPressed: () => setState(() {
                  _examplesChanged = true;
                  _addExample();
                }),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('직접 추가'),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              '예문을 2개 이상 저장하면 복습할 때마다 자동으로 바뀌어요.',
              style: TextStyle(color: AppColors.sub, fontSize: 12),
            ),
          ),
          ..._examples.asMap().entries.map((entry) {
            final i = entry.key;
            final e = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '예문 ${i + 1}',
                            style: const TextStyle(
                              color: AppColors.sub,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: '예문 삭제',
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => setState(() => _removeExample(i)),
                        ),
                      ],
                    ),
                    TextField(
                      controller: e.s,
                      decoration: InputDecoration(
                        labelText: '영어 문장',
                        hintText: 'I am happy today.',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: e.t,
                      decoration: const InputDecoration(
                        labelText: '해석 (한글)',
                        hintText: '오늘은 행복해요.',
                      ),
                    ),
                    if (e.source.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '출처: ${e.source}${e.license.isEmpty ? '' : ' · ${e.license}'}',
                          style: const TextStyle(
                            color: AppColors.sub,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _imageEditor() {
    if (_imageUrl.isEmpty) {
      return OutlinedButton.icon(
        onPressed: _pickingImage ? null : _pickImage,
        icon: _pickingImage
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.add_photo_alternate_outlined),
        label: Text(_pickingImage ? '이미지 불러오는 중…' : '이미지 추가'),
      );
    }

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: WordImage(
              source: _imageUrl,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickingImage ? null : _pickImage,
                icon: const Icon(Icons.swap_horiz),
                label: const Text('이미지 변경'),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.outlined(
              tooltip: '이미지 삭제',
              onPressed: () => setState(() => _imageUrl = ''),
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ],
    );
  }

  Widget _termField(List<Word> savedWords) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: RawAutocomplete<Word>(
      textEditingController: _term,
      focusNode: _termFocus,
      displayStringForOption: (word) => word.term,
      optionsBuilder: (value) {
        final query = value.text.trim().toLowerCase();
        if (query.isEmpty) return const Iterable<Word>.empty();

        final matches =
            savedWords
                .where(
                  (word) =>
                      word.id != widget.existing?.id &&
                      word.term.toLowerCase().startsWith(query),
                )
                .toList()
              ..sort((a, b) {
                final aExact = a.term.toLowerCase() == query;
                final bExact = b.term.toLowerCase() == query;
                if (aExact != bExact) return aExact ? -1 : 1;
                return a.term.compareTo(b.term);
              });

        final unique = <String, Word>{};
        for (final word in matches) {
          unique.putIfAbsent(word.term.toLowerCase(), () => word);
          if (unique.length == 6) break;
        }
        return unique.values;
      },
      onSelected: _applySuggestion,
      fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => onSubmitted(),
          decoration: const InputDecoration(
            labelText: '단어 *',
            hintText: 'happy',
            suffixIcon: Tooltip(
              message: '저장된 단어를 선택하면 뜻과 예문을 자동으로 채웁니다.',
              child: Icon(Icons.auto_awesome_outlined, size: 20),
            ),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        final items = options.toList();
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(12),
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              width: (MediaQuery.sizeOf(context).width - 32).clamp(240, 560),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 280),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final word = items[index];
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.history, size: 19),
                      title: Text(word.term),
                      subtitle: Text(
                        word.meaning,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => onSelected(word),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    ),
  );

  Widget _partOfSpeechField() => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: DropdownButtonFormField<String>(
      key: ValueKey(_pos.text),
      initialValue: _pos.text,
      isExpanded: true,
      decoration: const InputDecoration(labelText: '품사'),
      items: [
        const DropdownMenuItem(value: '', child: Text('선택 안 함')),
        for (final part in _partsOfSpeech)
          DropdownMenuItem(value: part, child: Text(part)),
        if (_pos.text.isNotEmpty && !_partsOfSpeech.contains(_pos.text))
          DropdownMenuItem(value: _pos.text, child: Text(_pos.text)),
      ],
      onChanged: (value) => setState(() => _pos.text = value ?? ''),
    ),
  );

  Widget _field(TextEditingController c, String label, String hint) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: c,
      decoration: InputDecoration(labelText: label, hintText: hint),
    ),
  );
}

class _EditableExample {
  final TextEditingController s;
  final TextEditingController t;
  String source;
  String sourceId;
  String license;
  bool edited = false;

  _EditableExample({
    String sentence = '',
    String translation = '',
    this.source = '',
    this.sourceId = '',
    this.license = '',
  }) : s = TextEditingController(text: sentence),
       t = TextEditingController(text: translation) {
    s.addListener(() => edited = true);
    t.addListener(() => edited = true);
  }

  factory _EditableExample.fromExample(Example example) => _EditableExample(
    sentence: example.sentence,
    translation: example.translation,
    source: example.source,
    sourceId: example.sourceId,
    license: example.license,
  );
}

class _ExamplePickerDialog extends StatefulWidget {
  final String term;
  final List<Example> examples;

  const _ExamplePickerDialog({required this.term, required this.examples});

  @override
  State<_ExamplePickerDialog> createState() => _ExamplePickerDialogState();
}

class _ExamplePickerDialogState extends State<_ExamplePickerDialog> {
  late final Set<int> _selected = {
    for (var i = 0; i < widget.examples.length; i++) i,
  };

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.76;
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 560, maxHeight: maxHeight),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "'${widget.term}' 예문",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              const Text(
                '추가할 예문을 선택하세요. 번역이 없는 문장은 직접 입력할 수 있어요.',
                style: TextStyle(color: AppColors.sub, fontSize: 12),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: widget.examples.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final example = widget.examples[index];
                    return CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      value: _selected.contains(index),
                      title: Text(
                        example.sentence,
                        style: const TextStyle(fontSize: 14),
                      ),
                      subtitle: example.translation.isEmpty
                          ? const Text(
                              '한국어 번역 없음',
                              style: TextStyle(fontSize: 12),
                            )
                          : Text(
                              example.translation,
                              style: const TextStyle(fontSize: 12),
                            ),
                      onChanged: (checked) => setState(() {
                        if (checked ?? false) {
                          _selected.add(index);
                        } else {
                          _selected.remove(index);
                        }
                      }),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                '예문 출처: Tatoeba · CC BY 2.0 FR',
                style: TextStyle(color: AppColors.sub, fontSize: 11),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('취소'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selected.isEmpty
                          ? null
                          : () => Navigator.pop(context, [
                              for (var i = 0; i < widget.examples.length; i++)
                                if (_selected.contains(i)) widget.examples[i],
                            ]),
                      child: Text('선택한 예문 추가 (${_selected.length})'),
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
