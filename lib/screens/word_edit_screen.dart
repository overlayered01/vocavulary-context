import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/l10n.dart';
import '../models/word.dart';
import '../models/translation_language.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/panel.dart' show exampleSourceLabel;
import '../widgets/word_form_section.dart';
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
  bool _fetchingExamples = false;
  bool _pendingExamples = false;
  bool _acceptPendingExamples = true;
  bool _examplesChanged = false;
  bool _saving = false;
  late List<_EditableExample> _examples;
  late TranslationLanguage _translationLanguage;

  @override
  void initState() {
    super.initState();
    final w = widget.existing ?? widget.initialDraft;
    _translationLanguage = w == null
        ? ref.read(settingsProvider).translationLanguage
        : TranslationLanguage.fromCode(w.translationLanguage);
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

  void _removeExample(int index) {
    _examplesChanged = true;
    final example = _examples[index];
    _examples.removeAt(index);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      example.s.dispose();
      example.t.dispose();
    });
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
      for (final term in selection.sourceTerms) {
        if (!_dictionarySourceTerms.contains(term)) {
          _dictionarySourceTerms.add(term);
        }
      }
      if (_pos.text.isEmpty) _pos.text = selection.suggestedPartOfSpeech;
    });
  }

  Future<void> _fetchExternalExamples() async {
    final term = _term.text.trim();
    if (term.isEmpty) {
      _termFocus.requestFocus();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.wordEditTermRequired)),
      );
      return;
    }
    if (_fetchingExamples) return;

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _fetchingExamples = true);
    try {
      final fetched = await ref
          .read(exampleSourceServiceProvider)
          .fetchExamples(term, translationLanguage: _translationLanguage);
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
                  ? context.l10n.wordEditNoExamplesFound(term)
                  : context.l10n.wordEditExamplesAlreadyAdded,
            ),
          ),
        );
        return;
      }

      final selected = await showDialog<List<Example>>(
        context: context,
        builder: (context) => _ExamplePickerDialog(
          term: term,
          examples: candidates,
          language: _translationLanguage,
        ),
      );
      if (selected == null || selected.isEmpty || !mounted) return;
      _appendExamples(selected);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.wordEditExamplesAdded(selected.length)),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.wordEditExamplesFetchFailed('$error')),
        ),
      );
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

  Future<void> _addManualExample() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final example = await showDialog<Example>(
      context: context,
      builder: (_) => _ManualExampleDialog(language: _translationLanguage),
    );
    if (!mounted || example == null || _saving) return;
    _acceptPendingExamples = false;
    _pendingExamples = false;
    _appendExamples([example]);
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.wordEditTermAndMeaningRequired)),
      );
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
            translationLanguage: _translationLanguage.code,
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
          SnackBar(content: Text(context.l10n.wordEditSaveFailed)),
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
        title: Text(
          widget.existing == null
              ? context.l10n.wordAddWord
              : context.l10n.wordEditWord,
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: Text(
              context.l10n.commonSave,
              style: TextStyle(
                color: AppColors.accentDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
                if (widget.wordbookTitle.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.book_outlined, size: 16, color: AppColors.sub),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          widget.wordbookTitle,
                          style: TextStyle(color: AppColors.sub, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                if (widget.draftNotice?.isNotEmpty ?? false) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.accentSoft,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      widget.draftNotice!,
                      style: const TextStyle(fontSize: 12, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                WordFormSection(
                  icon: Icons.text_fields_rounded,
                  title: context.l10n.wordEditSectionTerm,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [_termField(savedWords)],
                  ),
                ),
                const SizedBox(height: 16),
                WordFormSection(
                  icon: Icons.translate_rounded,
                  title: context.l10n.wordEditSectionMeaning,
                  trailing: Text(
                    context.l10n.language(_translationLanguage),
                    style: TextStyle(color: AppColors.sub, fontSize: 12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      MeaningFields(
                        controllers: _meanings,
                        onAdd: () => setState(
                          () => _meanings.add(TextEditingController()),
                        ),
                        onRemove: (i) {
                          final removed = _meanings[i];
                          setState(() => _meanings.removeAt(i));
                          WidgetsBinding.instance.addPostFrameCallback(
                            (_) => removed.dispose(),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _partOfSpeechField()),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _field(
                              _phonetic,
                              context.l10n.wordEditPhonetic,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _term,
                        builder: (_, value, _) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DictionaryLookupButton(
                              term: value.text,
                              translationLanguage: _translationLanguage,
                              meanings: () =>
                                  _meanings.map((c) => c.text).toList(),
                              onSelected: _addDictionaryMeanings,
                            ),
                            DictionaryAttribution(
                              terms: _dictionarySourceTerms,
                            ),
                            DictionaryLinks(
                              term: value.text,
                              language: _translationLanguage,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                WordFormSection(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: context.l10n.wordExamples,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: _fetchingExamples || _pendingExamples
                                ? null
                                : _fetchExternalExamples,
                            icon: _fetchingExamples || _pendingExamples
                                ? const SizedBox.square(
                                    dimension: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.travel_explore_rounded,
                                    size: 18,
                                  ),
                            label: Text(
                              _fetchingExamples || _pendingExamples
                                  ? context.l10n.wordEditSearching
                                  : context.l10n.wordEditFetchExamples,
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: _saving ? null : _addManualExample,
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: Text(context.l10n.wordEditAddManually),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      for (final entry in _examples.asMap().entries)
                        _exampleCard(entry.key, entry.value),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _exampleCard(int index, _EditableExample example) => Container(
    key: ObjectKey(example),
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.bg,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.line),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                context.l10n.wordEditExampleNumber(index + 1),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              tooltip: context.l10n.wordEditDeleteExample,
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.close, size: 18),
              onPressed: () => setState(() => _removeExample(index)),
            ),
          ],
        ),
        TextField(
          controller: example.s,
          minLines: 1,
          maxLines: 4,
          decoration: InputDecoration(labelText: context.l10n.wordEditSentence),
        ),
        // 영어(영영)는 해석 칸을 두지 않는다. 이미 있는 해석은 계속 편집할 수 있다.
        if (_translationLanguage.hasTranslations ||
            example.t.text.isNotEmpty) ...[
          const SizedBox(height: 10),
          TextField(
            controller: example.t,
            minLines: 1,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: context.l10n.wordEditTranslationLabel(
                context.l10n.language(_translationLanguage),
              ),
            ),
          ),
        ],
        if (example.source.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            context.l10n.wordExampleSource(
              exampleSourceLabel(
                context,
                Example(
                  sentence: example.s.text,
                  source: example.source,
                  license: example.license,
                ),
              ),
            ),
            style: TextStyle(color: AppColors.sub, fontSize: 11),
          ),
        ],
      ],
    ),
  );

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
                      word.translationLanguage == _translationLanguage.code &&
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
          decoration: InputDecoration(
            labelText: context.l10n.wordEditTermLabel,
            suffixIcon: Tooltip(
              message: context.l10n.wordEditTermHint,
              child: const Icon(Icons.auto_awesome_outlined, size: 20),
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
      decoration: InputDecoration(labelText: context.l10n.wordEditPartOfSpeech),
      items: [
        DropdownMenuItem(
          value: '',
          child: Text(context.l10n.wordEditPartOfSpeechNone),
        ),
        for (final part in _partsOfSpeech)
          DropdownMenuItem(
            value: part,
            child: Text(context.l10n.partOfSpeech(part)),
          ),
        if (_pos.text.isNotEmpty && !_partsOfSpeech.contains(_pos.text))
          DropdownMenuItem(value: _pos.text, child: Text(_pos.text)),
      ],
      onChanged: (value) => setState(() => _pos.text = value ?? ''),
    ),
  );

  Widget _field(TextEditingController c, String label) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: c,
      decoration: InputDecoration(labelText: label),
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

class _ManualExampleDialog extends StatefulWidget {
  final TranslationLanguage language;
  const _ManualExampleDialog({required this.language});

  @override
  State<_ManualExampleDialog> createState() => _ManualExampleDialogState();
}

class _ManualExampleDialogState extends State<_ManualExampleDialog> {
  final _sentence = TextEditingController();
  final _translation = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _sentence.dispose();
    _translation.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      Example(
        sentence: _sentence.text.trim(),
        translation: _translation.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
    title: Text(context.l10n.wordEditManualExampleTitle),
    scrollable: true,
    content: SizedBox(
      width: 480,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _sentence,
              autofocus: true,
              minLines: 3,
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: context.l10n.wordEditSentenceRequiredLabel,
              ),
              validator: (value) => (value ?? '').trim().isEmpty
                  ? context.l10n.wordEditSentenceRequired
                  : null,
            ),
            if (widget.language.hasTranslations) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _translation,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: context.l10n.wordEditTranslationLabel(
                    context.l10n.language(widget.language),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    ),
    actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(context.l10n.commonCancel),
      ),
      ElevatedButton(onPressed: _submit, child: Text(context.l10n.commonAdd)),
    ],
  );
}

class _ExamplePickerDialog extends StatefulWidget {
  final String term;
  final List<Example> examples;
  final TranslationLanguage language;

  const _ExamplePickerDialog({
    required this.term,
    required this.examples,
    required this.language,
  });

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
                context.l10n.wordEditPickerTitle(widget.term),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(
                context.l10n.wordEditPickerDescription,
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
                          ? !widget.language.hasTranslations
                                ? null
                                : Text(
                                    context.l10n.wordEditNoTranslation(
                                      context.l10n.language(widget.language),
                                    ),
                                    style: const TextStyle(fontSize: 12),
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
              Text(
                context.l10n.wordEditPickerAttribution,
                style: TextStyle(color: AppColors.sub, fontSize: 11),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(context.l10n.commonCancel),
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
                      child: Text(
                        context.l10n.wordEditAddSelectedExamples(
                          _selected.length,
                        ),
                      ),
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
