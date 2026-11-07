import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../l10n/l10n.dart';
import '../models/translation_language.dart';
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

  /// 사용자가 직접 쓰거나 사진에서 가져온 예문. 지울 수 있다.
  final Set<Example> userExamples = {};
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
  static const _manualParts = ['명사', '동사', '형용사', '부사', '구동사', '숙어', '구', ''];
  static const _maxExamples = 8;

  late String _bookId = widget.wordbookId;
  final _term = TextEditingController();
  Timer? _debounce;
  WordLookup? _lookup;
  bool _loading = false;
  int _lookupSerial = 0;

  /// 마지막으로 시작한(진행 중이거나 끝난) 조회의 단어·설정.
  /// 같은 조건이면 다시 찾지 않아 고른 예문·직접 쓴 예문을 지킨다.
  String _lookupTerm = '';
  bool? _lookupAuto;
  TranslationLanguage? _lookupLanguage;
  final List<_GroupChoice> _groups = [];
  int _selected = 0;
  bool _saving = false;

  /// 화면 안에서 바로 쓰는 뜻·예문 입력칸.
  final _meaningInput = TextEditingController();
  final _sentenceInput = TextEditingController();
  final _translationInput = TextEditingController();
  bool _writingMeaning = false;
  bool _writingExample = false;
  bool _scanOpen = false;
  String _meaningPart = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _term.dispose();
    _meaningInput.dispose();
    _sentenceInput.dispose();
    _translationInput.dispose();
    super.dispose();
  }

  void _onTermChanged(String _) {
    _debounce?.cancel();
    setState(() {});
    _debounce = Timer(const Duration(milliseconds: 600), _runLookup);
  }

  /// [force]면 같은 단어라도 다시 찾는다(번역 언어가 바뀐 때).
  Future<void> _runLookup({bool force = false}) async {
    _debounce?.cancel();
    final term = _term.text.trim();
    final settings = ref.read(settingsProvider);
    final auto = settings.autoMeanings;
    final language = settings.translationLanguage;
    // 같은 단어를 다시 찾으면(엔터, 끝 공백 넣었다 지우기) 고른 예문이 사라진다.
    if (!force &&
        term == _lookupTerm &&
        (term.isEmpty ||
            (auto == _lookupAuto && language == _lookupLanguage))) {
      return;
    }
    final serial = ++_lookupSerial;
    _lookupTerm = term;
    _lookupAuto = auto;
    _lookupLanguage = language;
    if (term.isEmpty || !auto) {
      setState(() {
        _lookup = term.isEmpty ? null : WordLookup(term: term);
        _loading = false;
        _resetGroups(const []);
      });
      _loadExamples();
      return;
    }
    // 조회 전에 있던 직접 쓴 예문은 이전 단어(또는 이전 언어)의 것이다.
    final before = {for (final g in _groups) ...g.userExamples};
    setState(() => _loading = true);
    final result = await ref.read(wordDraftServiceProvider).lookup(term);
    if (!mounted || serial != _lookupSerial) return;
    setState(() {
      _lookup = result;
      _loading = false;
      _resetGroups(result.groups, before: before);
    });
    _loadExamples();
  }

  /// 사전 결과로 품사 카드를 새로 만든다. 직접 쓴 뜻은 같은 품사 카드에 다시 넣는다.
  /// 조회하는 동안 직접 쓰거나 사진에서 가져온 예문([before]에 없는 것)도 다시 넣는다.
  void _resetGroups(List<SenseGroup> groups, {Set<Example> before = const {}}) {
    final manual = [
      for (final g in _groups)
        if (g.manualMeanings.isNotEmpty) (g.partOfSpeech, g.manualMeanings),
    ];
    final kept = [
      for (final g in _groups)
        for (final e in g.examples)
          if (g.userExamples.contains(e) && !before.contains(e))
            (g.partOfSpeech, e),
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
    for (final (part, example) in kept.reversed) {
      final group =
          _groups.where((g) => g.partOfSpeech == part).firstOrNull ??
          _groups.firstOrNull;
      if (group != null) _insertExamples(group, [example]);
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

  /// 직접 쓴 뜻을 넣는다. 같은 품사 카드가 있으면 그 카드에, 없으면 새 카드를 맨 위에.
  void _commitMeaning() {
    final meaning = _meaningInput.text.trim();
    if (meaning.isEmpty) return;
    final part = _meaningPart;
    setState(() {
      var index = _groups.indexWhere((g) => g.partOfSpeech == part);
      if (index < 0) {
        _groups.insert(
          0,
          _GroupChoice(partOfSpeech: part, meanings: [], checked: {}),
        );
        index = 0;
      }
      final group = _groups[index];
      if (!group.meanings.contains(meaning)) group.meanings.insert(0, meaning);
      group.checked.add(meaning);
      _selected = index;
      _meaningInput.clear();
      _writingMeaning = false;
    });
    _loadExamples();
  }

  /// 직접 쓴 뜻을 지운다. 뜻이 하나도 남지 않은 직접 만든 카드는 없앤다.
  void _deleteMeaning(int index, String meaning) {
    final selected = _current;
    setState(() {
      final group = _groups[index];
      group.meanings.remove(meaning);
      group.checked.remove(meaning);
      if (group.meanings.isEmpty && group.source == null) {
        _groups.removeAt(index);
        final keep = selected == null ? -1 : _groups.indexOf(selected);
        _selected = keep >= 0 ? keep : _firstFreeGroup();
      }
    });
    _loadExamples();
  }

  /// 직접 쓴 예문을 고른 품사의 후보 맨 위에 넣고 고른다.
  void _commitExample() {
    final group = _current;
    final sentence = _sentenceInput.text.trim();
    if (group == null || sentence.isEmpty) return;
    setState(() {
      _insertExamples(group, [
        Example(sentence: sentence, translation: _translationInput.text.trim()),
      ]);
      _sentenceInput.clear();
      _translationInput.clear();
      _writingExample = false;
    });
  }

  /// [examples]를 후보 맨 위에 넣고 고른 상태로 둔다. 직접 쓴 것이라 지울 수 있다.
  void _insertExamples(_GroupChoice group, List<Example> examples) {
    group.examples.insertAll(0, examples);
    group.userExamples.addAll(examples);
    final shifted = {for (final i in group.picked) i + examples.length};
    group.picked
      ..clear()
      ..addAll(shifted)
      ..addAll([for (var i = 0; i < examples.length; i++) i]);
  }

  void _deleteExample(_GroupChoice group, int index) {
    setState(() {
      group.userExamples.remove(group.examples.removeAt(index));
      final picked = {
        for (final i in group.picked)
          if (i != index) i > index ? i - 1 : i,
      };
      group.picked
        ..clear()
        ..addAll(picked);
    });
  }

  /// 책·프린트를 찍거나 앨범 사진을 골라, 이 단어가 들어간 문장을 예문 후보로 넣는다.
  Future<void> _scanExamples(ImageSource source) async {
    final group = _current;
    final term = _term.text.trim();
    if (group == null || term.isEmpty) return;
    final l10n = context.l10n;
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
    setState(() {
      group.loadingExamples = false;
      _scanOpen = false;
      if (sentences.isNotEmpty) {
        _insertExamples(group, [
          for (final sentence in sentences)
            Example(sentence: sentence, source: Example.photoSource),
        ]);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          sentences.isEmpty
              ? l10n.wordScanNoSentence(term)
              : l10n.wordScanAdded(sentences.length),
        ),
      ),
    );
  }

  /// 뜻 직접 입력: 화면 안에서 바로 쓰고 품사를 고른다.
  Widget _meaningEditor() {
    final l10n = context.l10n;
    return WhiteBlock(
      key: const ValueKey('manual-editor'),
      radius: 22,
      outline: AppColors.point,
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            key: const ValueKey('manual-meaning'),
            controller: _meaningInput,
            autofocus: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _commitMeaning(),
            decoration: InputDecoration(labelText: l10n.wordAddMeaningLabel),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.wordAddPosLabel,
            style: TextStyle(fontSize: 12, color: AppColors.sub),
          ),
          const SizedBox(height: 6),
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
                        : partOfSpeechLabel(context, p),
                  ),
                  selected: _meaningPart == p,
                  showCheckmark: false,
                  onSelected: (_) => setState(() => _meaningPart = p),
                ),
            ],
          ),
          _editorButtons(
            onCancel: () => setState(() {
              _meaningInput.clear();
              _writingMeaning = false;
            }),
            onAdd: _commitMeaning,
            addKey: const ValueKey('manual-add'),
          ),
        ],
      ),
    );
  }

  /// 예문 직접 쓰기: 화면 안에서 문장과 해석을 바로 쓴다.
  Widget _exampleEditor() {
    final l10n = context.l10n;
    final language = ref.read(settingsProvider).translationLanguage;
    return WhiteBlock(
      key: const ValueKey('example-editor'),
      radius: 22,
      outline: AppColors.point,
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            key: const ValueKey('example-sentence'),
            controller: _sentenceInput,
            autofocus: true,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(labelText: l10n.wordEditSentence),
          ),
          if (language.hasTranslations) ...[
            const SizedBox(height: 8),
            TextField(
              key: const ValueKey('example-translation'),
              controller: _translationInput,
              minLines: 1,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l10n.wordEditTranslationLabel(
                  l10n.language(language),
                ),
              ),
            ),
          ],
          _editorButtons(
            onCancel: () => setState(() {
              _sentenceInput.clear();
              _translationInput.clear();
              _writingExample = false;
            }),
            onAdd: _commitExample,
            addKey: const ValueKey('example-add'),
          ),
        ],
      ),
    );
  }

  Widget _editorButtons({
    required VoidCallback onCancel,
    required VoidCallback onAdd,
    required Key addKey,
  }) {
    final l10n = context.l10n;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(onPressed: onCancel, child: Text(l10n.commonCancel)),
        const SizedBox(width: 4),
        FilledButton(
          key: addKey,
          onPressed: onAdd,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.ink,
            foregroundColor: AppColors.card,
          ),
          child: Text(l10n.commonAdd),
        ),
      ],
    );
  }

  /// 사진 가져오기: 카메라·앨범 버튼을 그 자리에 펼친다.
  Widget _scanButtons() {
    final l10n = context.l10n;
    Widget button(IconData icon, String label, ImageSource source) => Expanded(
      child: OutlinedButton.icon(
        onPressed: () => _scanExamples(source),
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.onPanel,
          side: BorderSide(color: AppColors.point, width: 1.5),
          minimumSize: const Size(0, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
    return Row(
      children: [
        button(
          Icons.photo_camera_outlined,
          l10n.wordScanCamera,
          ImageSource.camera,
        ),
        const SizedBox(width: 8),
        button(
          Icons.photo_library_outlined,
          l10n.wordScanGallery,
          ImageSource.gallery,
        ),
      ],
    );
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
    // 자동 입력 시트에서 번역 언어를 바꾸면 그 언어의 뜻·예문으로 다시 찾는다.
    ref.listen(settingsProvider.select((s) => s.translationLanguage), (
      previous,
      next,
    ) {
      if (previous != next && _term.text.trim().isNotEmpty) {
        _runLookup(force: true);
      }
    });
    final term = _term.text.trim();
    final current = _current;
    // 바뀐 단어를 찾기 전(입력 대기·조회 중)에는 이전 단어의 발음·예문이 남아 있다.
    final canSave =
        !_saving &&
        !_loading &&
        term == _lookupTerm &&
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
                _SectionHeader(
                  step: 1,
                  title: l10n.wordAddMeaningSelect,
                  trailing: lookup == null || _loading
                      ? null
                      : lookup.failed
                      ? l10n.wordAddLookupFailed
                      : _groups.every((g) => g.source == null) &&
                            settings.autoMeanings
                      ? l10n.wordAddNoResults
                      : null,
                ),
                if (_writingMeaning)
                  _meaningEditor()
                else
                  _AddAction(
                    key: const ValueKey('word-add-manual'),
                    label: l10n.wordAddManualInput,
                    onTap: () => setState(() {
                      _meaningPart = _current?.partOfSpeech ?? '';
                      _writingMeaning = true;
                    }),
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
                    onDelete: (meaning) => _deleteMeaning(index, meaning),
                  ),
                  const SizedBox(height: 10),
                ],
                if (current != null) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 18, 4, 22),
                    child: Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.panelLine,
                    ),
                  ),
                  _SectionHeader(
                    step: 2,
                    title: current.partOfSpeech.isEmpty
                        ? l10n.wordExamples
                        : l10n.wordAddExamplesOf(
                            partOfSpeechLabel(context, current.partOfSpeech),
                          ),
                    trailing: l10n.wordAddSelectedCount(current.picked.length),
                  ),
                  if (_writingExample)
                    _exampleEditor()
                  else
                    _AddAction(
                      key: const ValueKey('word-add-write-example'),
                      label: l10n.wordAddWriteExample,
                      onTap: () => setState(() => _writingExample = true),
                    ),
                  if (textScanSupported) ...[
                    const SizedBox(height: 10),
                    if (_scanOpen)
                      _scanButtons()
                    else
                      _AddAction(
                        key: const ValueKey('word-add-scan-example'),
                        label: l10n.wordAddScanExample,
                        icon: Icons.photo_camera_outlined,
                        onTap: () => setState(() => _scanOpen = true),
                      ),
                  ],
                  const SizedBox(height: 10),
                  for (final (i, example) in current.examples.indexed) ...[
                    _ExampleOption(
                      example: example,
                      term: term,
                      checked: current.picked.contains(i),
                      onTap: () => setState(() {
                        if (!current.picked.remove(i)) current.picked.add(i);
                      }),
                      onDelete: current.userExamples.contains(example)
                          ? () => _deleteExample(current, i)
                          : null,
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

/// 단어 추가의 구간 제목. 번호 원과 굵은 제목으로 뜻·예문 구간을 나눈다.
class _SectionHeader extends StatelessWidget {
  final int step;
  final String title;
  final String? trailing;
  const _SectionHeader({
    required this.step,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
    child: Row(
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.point,
            shape: BoxShape.circle,
          ),
          child: Text(
            '$step',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.onPoint,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.onPanel,
            ),
          ),
        ),
        if (trailing != null)
          Text(
            trailing!,
            style: TextStyle(fontSize: 12, color: AppColors.onPanelSub),
          ),
      ],
    ),
  );
}

/// 한 품사의 뜻 카드. 고른 카드는 흰 바탕과 포인트 테두리, 나머지는 흐리게.
class _GroupCard extends StatelessWidget {
  final _GroupChoice group;
  final bool selected;
  final bool saved;
  final VoidCallback onSelect;
  final ValueChanged<String> onToggle;

  /// 직접 쓴 뜻 지우기.
  final ValueChanged<String> onDelete;
  const _GroupCard({
    required this.group,
    required this.selected,
    required this.saved,
    required this.onSelect,
    required this.onToggle,
    required this.onDelete,
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
                    if (group.manualMeanings.contains(meaning))
                      IconButton(
                        key: ValueKey('delete-meaning-$meaning'),
                        tooltip: context.l10n.commonDelete,
                        visualDensity: VisualDensity.compact,
                        onPressed: () => onDelete(meaning),
                        icon: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: AppColors.sub,
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

  /// 직접 쓰거나 사진에서 가져온 예문이면 지우기. 아니면 null.
  final VoidCallback? onDelete;
  const _ExampleOption({
    required this.example,
    required this.term,
    required this.checked,
    required this.onTap,
    this.onDelete,
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
          if (onDelete != null)
            IconButton(
              key: ValueKey('delete-example-${example.sentence}'),
              tooltip: context.l10n.commonDelete,
              visualDensity: VisualDensity.compact,
              onPressed: onDelete,
              icon: Icon(
                Icons.close_rounded,
                size: 18,
                color: checked ? AppColors.sub : AppColors.onPanelSub,
              ),
            ),
        ],
      ),
    );
  }
}
