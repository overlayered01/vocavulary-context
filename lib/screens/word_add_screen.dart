import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../l10n/l10n.dart';
import '../models/word.dart';
import '../models/wordbook.dart';
import '../providers.dart';
import '../services/sentence_extractor.dart';
import '../services/text_scanner.dart';
import '../services/word_draft_service.dart';
import '../theme.dart';
import '../widgets/panel.dart';
import '../widgets/speak_button.dart';
import '../widgets/translation_language_dropdown.dart';

/// 단어 추가를 연다. 단어장이 없으면 단어장 탭으로 보낸다. 저장했으면 true.
Future<bool> openWordAdd(
  BuildContext context,
  WidgetRef ref, {
  String? wordbookId,
}) async {
  final books = await ref.read(wordbooksProvider.future);
  if (!context.mounted) return false;
  if (books.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.homeCreateWordbookFirst)),
    );
    ref.read(homeTabProvider.notifier).set(1);
    return false;
  }
  final saved = await Navigator.of(context).push<bool>(
    MaterialPageRoute(
      builder: (_) => WordAddScreen(wordbookId: wordbookId ?? books.first.id),
    ),
  );
  if (saved == true) invalidateData(ref);
  return saved == true;
}

/// 단어 추가: 단어를 쓰고, 한 품사의 뜻과 그 품사의 예문을 한 화면에서 골라 등록한다.
/// 품사를 모르거나 예문이 없으면 비워 둔 채로 등록할 수 있다.
class WordAddScreen extends ConsumerStatefulWidget {
  final String wordbookId;
  const WordAddScreen({super.key, required this.wordbookId});

  @override
  ConsumerState<WordAddScreen> createState() => _WordAddScreenState();
}

/// 사용자가 고르고 있는 한 품사 카드와 그 품사의 예문 후보.
class _GroupChoice {
  final String partOfSpeech;
  final List<String> meanings;
  final Set<String> checked;
  final SenseGroup? source;
  final List<Example> examples = [];
  final Set<int> picked = {};
  bool examplesRequested = false;
  bool loadingExamples = false;
  _GroupChoice({
    required this.partOfSpeech,
    required this.meanings,
    required this.checked,
    this.source,
  });

  /// 사전에서 오지 않은(직접 쓴) 뜻.
  List<String> get manualMeanings => [
    for (final m in meanings)
      if (source == null || !source!.meanings.contains(m)) m,
  ];
}

class _WordAddScreenState extends ConsumerState<WordAddScreen> {
  static const _manualParts = ['명사', '동사', '형용사', '부사', ''];
  static const _maxExamples = 8;

  late String _bookId = widget.wordbookId;
  final _term = TextEditingController();
  Timer? _debounce;
  WordLookup? _lookup;
  bool _loading = false;
  int _lookupSerial = 0;
  final List<_GroupChoice> _groups = [];
  int _selected = 0;
  bool _saving = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _term.dispose();
    super.dispose();
  }

  void _onTermChanged(String _) {
    _debounce?.cancel();
    setState(() {});
    _debounce = Timer(const Duration(milliseconds: 600), _runLookup);
  }

  Future<void> _runLookup() async {
    _debounce?.cancel();
    final term = _term.text.trim();
    final serial = ++_lookupSerial;
    if (term.isEmpty || !ref.read(settingsProvider).autoMeanings) {
      setState(() {
        _lookup = term.isEmpty ? null : WordLookup(term: term);
        _loading = false;
        _resetGroups(const []);
      });
      _loadExamples();
      return;
    }
    setState(() => _loading = true);
    final result = await ref.read(wordDraftServiceProvider).lookup(term);
    if (!mounted || serial != _lookupSerial) return;
    setState(() {
      _lookup = result;
      _loading = false;
      _resetGroups(result.groups);
    });
    _loadExamples();
  }

  /// 사전 결과로 품사 카드를 새로 만든다. 직접 쓴 뜻은 같은 품사 카드에 다시 넣는다.
  void _resetGroups(List<SenseGroup> groups) {
    final manual = [
      for (final g in _groups)
        if (g.manualMeanings.isNotEmpty) (g.partOfSpeech, g.manualMeanings),
    ];
    _groups
      ..clear()
      ..addAll([
        for (final group in groups)
          _GroupChoice(
            partOfSpeech: group.partOfSpeech,
            meanings: [...group.meanings],
            checked: group.meanings.take(2).toSet(),
            source: group,
          ),
      ]);
    for (final (part, meanings) in manual) {
      final group = _groups.where((g) => g.partOfSpeech == part).firstOrNull;
      if (group == null) {
        _groups.insert(
          0,
          _GroupChoice(
            partOfSpeech: part,
            meanings: [...meanings],
            checked: meanings.toSet(),
          ),
        );
      } else {
        for (final m in meanings.reversed) {
          if (!group.meanings.contains(m)) group.meanings.insert(0, m);
          group.checked.add(m);
        }
      }
    }
    _selected = _firstFreeGroup();
  }

  int _firstFreeGroup() {
    for (var i = 0; i < _groups.length; i++) {
      if (!_alreadySaved(_groups[i].partOfSpeech)) return i;
    }
    return 0;
  }

  List<Word> get _bookWords =>
      ref.read(wordsProvider(_bookId)).asData?.value ?? const [];

  bool _alreadySaved(String partOfSpeech) {
    final term = _term.text.trim().toLowerCase();
    if (term.isEmpty) return false;
    return _bookWords.any(
      (w) =>
          w.term.trim().toLowerCase() == term && w.partOfSpeech == partOfSpeech,
    );
  }

  _GroupChoice? get _current =>
      _groups.isEmpty ? null : _groups[_selected.clamp(0, _groups.length - 1)];

  void _select(int index) {
    setState(() => _selected = index);
    _loadExamples();
  }

  /// 고른 품사 카드의 예문 후보를 처음 한 번 채운다: 사전 예문 다음에 Tatoeba.
  Future<void> _loadExamples() async {
    final group = _current;
    final term = _term.text.trim();
    if (group == null || term.isEmpty || group.examplesRequested) return;
    group.examplesRequested = true;
    final settings = ref.read(settingsProvider);
    if (!settings.autoExamples) return;
    setState(() {
      _addExamples(group, group.source?.examples ?? const []);
      group.loadingExamples = true;
    });
    try {
      final more = await ref
          .read(wordDraftServiceProvider)
          .tatoebaExamples(
            term,
            group.partOfSpeech,
            withTranslations: settings.autoExampleTranslations,
          )
          .timeout(const Duration(seconds: 12));
      if (!mounted || term != _term.text.trim()) return;
      setState(() => _addExamples(group, more));
    } catch (_) {
      // 예문 없이도 등록할 수 있다.
    } finally {
      if (mounted) setState(() => group.loadingExamples = false);
    }
  }

  /// 중복을 빼고 최대 [_maxExamples]개까지 넣는다. 처음 두 개는 미리 고른다.
  void _addExamples(_GroupChoice group, List<Example> examples) {
    final seen = {for (final e in group.examples) e.sentence.toLowerCase()};
    for (final example in examples) {
      if (group.examples.length >= _maxExamples) break;
      if (seen.add(example.sentence.toLowerCase())) {
        group.examples.add(example);
        if (group.picked.length < 2) {
          group.picked.add(group.examples.length - 1);
        }
      }
    }
  }

  /// 뜻을 직접 쓴다. 품사도 고르거나 모르면 비워 둔다.
  Future<void> _addManualMeaning() async {
    final l10n = context.l10n;
    final controller = TextEditingController();
    var part = _current?.partOfSpeech ?? '';
    final value = await showDialog<(String, String)>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          title: Text(l10n.wordAddManualInput),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                key: const ValueKey('manual-meaning'),
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l10n.wordAddMeaningLabel,
                ),
                onSubmitted: (v) => Navigator.pop(ctx, (v, part)),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.wordAddPosLabel,
                style: TextStyle(fontSize: 12, color: AppColors.sub),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final p in _manualParts)
                    ChoiceChip(
                      key: ValueKey('manual-pos-$p'),
                      label: Text(
                        p.isEmpty
                            ? l10n.wordAddPosUnknown
                            : partOfSpeechLabel(ctx, p),
                      ),
                      selected: part == p,
                      showCheckmark: false,
                      onSelected: (_) => setDialog(() => part = p),
                    ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.commonCancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, (controller.text, part)),
              child: Text(l10n.commonAdd),
            ),
          ],
        ),
      ),
    );
    final meaning = value?.$1.trim() ?? '';
    if (value == null || meaning.isEmpty || !mounted) return;
    final chosen = value.$2;
    setState(() {
      var index = _groups.indexWhere((g) => g.partOfSpeech == chosen);
      if (index < 0) {
        _groups.insert(
          0,
          _GroupChoice(partOfSpeech: chosen, meanings: [], checked: {}),
        );
        index = 0;
      }
      final group = _groups[index];
      if (!group.meanings.contains(meaning)) group.meanings.insert(0, meaning);
      group.checked.add(meaning);
      _selected = index;
    });
    _loadExamples();
  }

  Future<void> _writeExample() async {
    final group = _current;
    if (group == null) return;
    final l10n = context.l10n;
    final language = ref.read(settingsProvider).translationLanguage;
    final sentence = TextEditingController();
    final translation = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.wordAddWriteExample),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: sentence,
              autofocus: true,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(labelText: l10n.wordEditSentence),
            ),
            if (language.hasTranslations) ...[
              const SizedBox(height: 8),
              TextField(
                controller: translation,
                minLines: 1,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n.wordEditTranslationLabel(
                    l10n.language(language),
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.commonAdd),
          ),
        ],
      ),
    );
    if (saved != true || sentence.text.trim().isEmpty || !mounted) return;
    setState(() {
      group.examples.insert(
        0,
        Example(
          sentence: sentence.text.trim(),
          translation: translation.text.trim(),
        ),
      );
      final shifted = {for (final i in group.picked) i + 1};
      group.picked
        ..clear()
        ..addAll(shifted)
        ..add(0);
    });
  }

  /// 책·프린트를 찍거나 앨범 사진을 골라, 이 단어가 들어간 문장을 예문으로 가져온다.
  Future<void> _scanExamples() async {
    final group = _current;
    final term = _term.text.trim();
    if (group == null || term.isEmpty) return;
    final l10n = context.l10n;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l10n.wordScanCamera),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.wordScanGallery),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;
    List<String> sentences;
    try {
      final image = await ImagePicker().pickImage(
        source: source,
        maxWidth: 2400,
        maxHeight: 2400,
      );
      if (image == null || !mounted) return;
      setState(() => group.loadingExamples = true);
      sentences = sentencesWithTerm(await recognizeText(image.path), term);
    } catch (_) {
      if (mounted) {
        setState(() => group.loadingExamples = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.wordScanFailed)));
      }
      return;
    }
    if (!mounted) return;
    setState(() => group.loadingExamples = false);
    if (sentences.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.wordScanNoSentence(term))));
      return;
    }
    final chosen = {for (var i = 0; i < sentences.length && i < 3; i++) i};
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          title: Text(l10n.wordScanPick),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final (i, sentence) in sentences.indexed)
                  CheckboxListTile(
                    value: chosen.contains(i),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(sentence),
                    onChanged: (_) => setDialog(() {
                      if (!chosen.remove(i)) chosen.add(i);
                    }),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.commonCancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.commonAdd),
            ),
          ],
        ),
      ),
    );
    if (ok != true || !mounted) return;
    setState(() {
      final added = [
        for (final (i, sentence) in sentences.indexed)
          if (chosen.contains(i))
            Example(sentence: sentence, source: Example.photoSource),
      ];
      group.examples.insertAll(0, added);
      final shifted = {for (final i in group.picked) i + added.length};
      group.picked
        ..clear()
        ..addAll(shifted)
        ..addAll([for (var i = 0; i < added.length; i++) i]);
    });
  }

  Future<void> _save() async {
    final group = _current;
    final term = _term.text.trim();
    if (_saving || group == null || term.isEmpty) return;
    final meanings = [
      for (final m in group.meanings)
        if (group.checked.contains(m)) m,
    ];
    if (meanings.isEmpty) return;
    setState(() => _saving = true);
    final settings = ref.read(settingsProvider);
    final word = ref
        .read(wordDraftServiceProvider)
        .buildWord(
          wordbookId: _bookId,
          term: term,
          partOfSpeech: group.partOfSpeech,
          meanings: meanings,
          phonetic: _lookup?.phonetic ?? '',
          sourceTerms: [
            for (final m in meanings)
              if (group.source?.sourceTerms[m] != null)
                group.source!.sourceTerms[m]!,
          ],
          examples: [
            for (final (i, e) in group.examples.indexed)
              if (group.picked.contains(i)) e,
          ],
          withTranslations: settings.autoExampleTranslations,
        );
    try {
      await ref.read(repositoryProvider).upsertWord(word);
      ref.invalidate(wordsProvider(_bookId));
      invalidateData(ref);
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.wordEditSaveFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final books =
        ref.watch(wordbooksProvider).asData?.value ?? const <Wordbook>[];
    ref.watch(wordsProvider(_bookId));
    final settings = ref.watch(settingsProvider);
    final term = _term.text.trim();
    final current = _current;
    final canSave =
        !_saving &&
        term.isNotEmpty &&
        current != null &&
        current.checked.isNotEmpty &&
        !_alreadySaved(current.partOfSpeech);
    final lookup = _lookup;

    return Scaffold(
      backgroundColor: AppColors.panel,
      body: PanelPage(
        header: ContentWidth(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      tooltip: l10n.commonClose,
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close_rounded, color: AppColors.ink),
                    ),
                    const Spacer(),
                    _BookPicker(
                      books: books,
                      value: _bookId,
                      onChanged: (id) => setState(() => _bookId = id),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 0, 0),
                  child: TextField(
                    key: const ValueKey('word-add-term'),
                    controller: _term,
                    autofocus: true,
                    textInputAction: TextInputAction.search,
                    onChanged: _onTermChanged,
                    onSubmitted: (_) => _runLookup(),
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w300,
                      letterSpacing: -0.8,
                      color: AppColors.ink,
                    ),
                    cursorColor: AppColors.point,
                    cursorWidth: 2.5,
                    decoration: InputDecoration(
                      filled: false,
                      isDense: true,
                      contentPadding: const EdgeInsets.only(bottom: 6),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.ink, width: 2),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.ink, width: 2),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.ink, width: 2),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 36,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Row(
                      children: [
                        if ((lookup?.phonetic ?? '').isNotEmpty)
                          Text(
                            lookup!.phonetic,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.sub,
                            ),
                          ),
                        if (term.isNotEmpty) SpeakButton(text: term),
                        if (_loading)
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.sub,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bodyPadding: EdgeInsets.zero,
        body: ContentWidth(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            children: [
              if (term.isNotEmpty) ...[
                PanelLabel(
                  l10n.wordAddMeaningSelect,
                  trailing: lookup == null || _loading
                      ? null
                      : lookup.failed
                      ? Text(l10n.wordAddLookupFailed)
                      : _groups.every((g) => g.source == null) &&
                            settings.autoMeanings
                      ? Text(l10n.wordAddNoResults)
                      : null,
                ),
                _AddAction(
                  key: const ValueKey('word-add-manual'),
                  label: l10n.wordAddManualInput,
                  onTap: _addManualMeaning,
                ),
                const SizedBox(height: 10),
                for (final (index, group) in _groups.indexed) ...[
                  _GroupCard(
                    group: group,
                    selected: index == _selected,
                    saved: _alreadySaved(group.partOfSpeech),
                    onSelect: () => _select(index),
                    onToggle: (meaning) {
                      setState(() {
                        if (!group.checked.remove(meaning)) {
                          group.checked.add(meaning);
                        }
                      });
                      if (index != _selected) _select(index);
                    },
                  ),
                  const SizedBox(height: 10),
                ],
                if (current != null) ...[
                  const SizedBox(height: 12),
                  PanelLabel(
                    current.partOfSpeech.isEmpty
                        ? l10n.wordExamples
                        : l10n.wordAddExamplesOf(
                            partOfSpeechLabel(context, current.partOfSpeech),
                          ),
                    trailing: Text(
                      l10n.wordAddSelectedCount(current.picked.length),
                    ),
                  ),
                  for (final (i, example) in current.examples.indexed) ...[
                    _ExampleOption(
                      example: example,
                      term: term,
                      checked: current.picked.contains(i),
                      onTap: () => setState(() {
                        if (!current.picked.remove(i)) current.picked.add(i);
                      }),
                    ),
                    const SizedBox(height: 10),
                  ],
                  if (current.loadingExamples)
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (current.examples.isEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 4, 8, 14),
                      child: Text(
                        l10n.wordAddNoExamples,
                        style: TextStyle(color: AppColors.onPanelSub),
                      ),
                    ),
                  _AddAction(
                    key: const ValueKey('word-add-write-example'),
                    label: l10n.wordAddWriteExample,
                    onTap: _writeExample,
                  ),
                  if (textScanSupported) ...[
                    const SizedBox(height: 10),
                    _AddAction(
                      key: const ValueKey('word-add-scan-example'),
                      label: l10n.wordAddScanExample,
                      icon: Icons.photo_camera_outlined,
                      onTap: _scanExamples,
                    ),
                  ],
                ],
              ],
            ],
          ),
        ),
        bottom: ContentWidth(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              12 + MediaQuery.paddingOf(context).bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InkWell(
                  onTap: () => showAutoInputSheet(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _autoStatus(context),
                            key: const ValueKey('auto-status'),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.onPanelSub,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.tune_rounded,
                          size: 18,
                          color: AppColors.onPanelSub,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                PointButton(
                  key: const ValueKey('word-add-save'),
                  label: l10n.wordAddSave,
                  onPressed: canSave ? _save : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _autoStatus(BuildContext context) {
    final l10n = context.l10n;
    final s = ref.watch(settingsProvider);
    if (!s.autoMeanings && !s.autoExamples) return l10n.wordAddAutoOff;
    return [
      l10n.wordAddAutoInput,
      l10n.language(s.translationLanguage),
      if (s.autoExamples &&
          s.autoExampleTranslations &&
          s.translationLanguage.hasTranslations)
        l10n.wordAddExampleTranslation,
    ].join(' · ');
  }
}

class _BookPicker extends StatelessWidget {
  final List<Wordbook> books;
  final String value;
  final ValueChanged<String> onChanged;
  const _BookPicker({
    required this.books,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final title =
        books.where((b) => b.id == value).firstOrNull?.title ??
        context.l10n.wordCreateNoWordbook;
    return PopupMenuButton<String>(
      tooltip: context.l10n.wordCreateWordbook,
      onSelected: onChanged,
      itemBuilder: (_) => [
        for (final book in books)
          PopupMenuItem(value: book.id, child: Text(book.title)),
      ],
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.chip,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 160),
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.ink,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.expand_more_rounded, size: 18, color: AppColors.ink),
          ],
        ),
      ),
    );
  }
}

/// 한 품사의 뜻 카드. 고른 카드는 흰 바탕과 포인트 테두리, 나머지는 흐리게.
class _GroupCard extends StatelessWidget {
  final _GroupChoice group;
  final bool selected;
  final bool saved;
  final VoidCallback onSelect;
  final ValueChanged<String> onToggle;
  const _GroupCard({
    required this.group,
    required this.selected,
    required this.saved,
    required this.onSelect,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pos = group.partOfSpeech.isEmpty
        ? l10n.wordAddPosUnknown
        : partOfSpeechLabel(context, group.partOfSpeech);
    final header = Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: selected ? AppColors.point : AppColors.panel,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            pos,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
              color: selected ? AppColors.onPoint : AppColors.onPanel,
            ),
          ),
        ),
        const Spacer(),
        if (saved)
          Text(
            l10n.wordAddAlreadyInDeck,
            style: TextStyle(
              fontSize: 11,
              color: selected ? AppColors.sub : AppColors.onPanelSub,
            ),
          )
        else if (selected)
          Text(
            '${group.checked.length} / ${group.meanings.length}',
            style: TextStyle(fontSize: 11, color: AppColors.sub),
          ),
      ],
    );

    if (!selected) {
      return WhiteBlock(
        color: AppColors.panelHigh,
        radius: 22,
        onTap: saved ? null : onSelect,
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        child: Opacity(
          opacity: saved ? 0.55 : 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              const SizedBox(height: 8),
              Text(
                group.meanings.join(', '),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 15, color: AppColors.onPanel),
              ),
            ],
          ),
        ),
      );
    }

    return WhiteBlock(
      radius: 22,
      outline: AppColors.point,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          const SizedBox(height: 6),
          for (final meaning in group.meanings)
            InkWell(
              onTap: saved ? null : () => onToggle(meaning),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 42),
                child: Row(
                  children: [
                    _CheckBox(checked: group.checked.contains(meaning)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        meaning,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: group.checked.contains(meaning)
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: group.checked.contains(meaning)
                              ? AppColors.ink
                              : AppColors.sub,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CheckBox extends StatelessWidget {
  final bool checked;
  final bool onPanel;
  const _CheckBox({required this.checked, this.onPanel = false});

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 140),
    width: 22,
    height: 22,
    decoration: BoxDecoration(
      color: checked ? AppColors.point : Colors.transparent,
      borderRadius: BorderRadius.circular(7),
      border: Border.all(
        color: checked
            ? AppColors.point
            : onPanel
            ? AppColors.onPanelSub
            : AppColors.line,
        width: 1.5,
      ),
    ),
    child: checked
        ? Icon(Icons.check_rounded, size: 15, color: AppColors.onPoint)
        : null,
  );
}

/// 직접 입력 버튼. 짙은 패널 위에서 눈에 띄도록 채운 블록에 포인트 색 아이콘.
class _AddAction extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData icon;
  const _AddAction({
    super.key,
    required this.label,
    required this.onTap,
    this.icon = Icons.edit_rounded,
  });

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.panelHigh,
    borderRadius: BorderRadius.circular(18),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.point, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.point,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: AppColors.onPoint),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.onPanel,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// 자동 입력 설정 시트. 설정 화면의 같은 항목과 연결된다.
Future<void> showAutoInputSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const _AutoInputSheet(),
  );
}

class _AutoInputSheet extends ConsumerWidget {
  const _AutoInputSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final s = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.wordAddAutoInput,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            BlockRow(
              title: l10n.wordCreateAutoMeanings,
              trailing: Switch(
                value: s.autoMeanings,
                onChanged: (v) => notifier.setAutoInput(meanings: v),
              ),
            ),
            BlockRow(
              title: l10n.wordCreateAutoExamples,
              trailing: Switch(
                value: s.autoExamples,
                onChanged: (v) => notifier.setAutoInput(examples: v),
              ),
            ),
            BlockRow(
              title: l10n.wordCreateExampleTranslations,
              indent: 14,
              trailing: Switch(
                value: s.autoExampleTranslations,
                onChanged:
                    s.autoExamples && s.translationLanguage.hasTranslations
                    ? (v) => notifier.setAutoInput(exampleTranslations: v)
                    : null,
              ),
            ),
            const SizedBox(height: 14),
            const TranslationLanguageDropdown(),
          ],
        ),
      ),
    );
  }
}

class _ExampleOption extends StatelessWidget {
  final Example example;
  final String term;
  final bool checked;
  final VoidCallback onTap;
  const _ExampleOption({
    required this.example,
    required this.term,
    required this.checked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg = checked ? AppColors.ink : AppColors.onPanel;
    return WhiteBlock(
      color: checked ? AppColors.card : AppColors.panelHigh,
      outline: checked ? AppColors.point : null,
      radius: 22,
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(16, 16, 18, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: _CheckBox(checked: checked, onPanel: !checked),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExampleSentence(
                  sentence: example.sentence,
                  term: term,
                  highlight: checked
                      ? AppColors.point
                      : AppColors.onPanel.withValues(alpha: 0.18),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                    height: 1.45,
                    color: fg,
                  ),
                ),
                if (example.translation.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    example.translation,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: checked ? AppColors.sub : AppColors.onPanelSub,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
