import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../models/word.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/word_image.dart';

/// 단어 추가/편집. 단어·뜻·품사·발음기호 + 예문(문장/해석) 여러 개.
class WordEditScreen extends ConsumerStatefulWidget {
  final String wordbookId;
  final String wordbookTitle;
  final List<String> groups;
  final String initialGroup;
  final Word? existing;
  const WordEditScreen({
    super.key,
    required this.wordbookId,
    this.wordbookTitle = '',
    this.groups = const [],
    this.initialGroup = '',
    this.existing,
  });

  @override
  ConsumerState<WordEditScreen> createState() => _WordEditScreenState();
}

class _WordEditScreenState extends ConsumerState<WordEditScreen> {
  static const _maxImageBytes = 2 * 1024 * 1024;

  late final TextEditingController _term;
  late final TextEditingController _meaning;
  late final TextEditingController _pos;
  late final TextEditingController _phonetic;
  late final FocusNode _termFocus;
  late String _imageUrl;
  bool _pickingImage = false;
  bool _fetchingExamples = false;
  late String _group;
  late List<_EditableExample> _examples;

  @override
  void initState() {
    super.initState();
    final w = widget.existing;
    _term = TextEditingController(text: w?.term ?? '');
    _meaning = TextEditingController(text: w?.meaning ?? '');
    _pos = TextEditingController(text: w?.partOfSpeech ?? '');
    _phonetic = TextEditingController(text: w?.phonetic ?? '');
    _termFocus = FocusNode();
    _imageUrl = w?.imageUrl ?? '';
    _group = w?.group ?? widget.initialGroup;
    _examples = (w?.examples ?? const <Example>[])
        .map(_EditableExample.fromExample)
        .toList();
    if (_examples.isEmpty) _addExample();
  }

  void _addExample() {
    _examples.add(_EditableExample());
  }

  void _removeExample(int index) {
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
    _term.text = word.term;
    _meaning.text = word.meaning;
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
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1400,
        imageQuality: 82,
      );
      if (file == null) return;

      final bytes = await file.readAsBytes();
      if (!mounted) return;
      if (bytes.length > _maxImageBytes) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('이미지는 2MB 이하로 선택해 주세요.')));
        return;
      }

      final mimeType = file.mimeType ?? _mimeTypeFor(file.name);
      setState(() {
        _imageUrl = 'data:$mimeType;base64,${base64Encode(bytes)}';
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('이미지를 불러오지 못했습니다: $error')));
    } finally {
      if (mounted) setState(() => _pickingImage = false);
    }
  }

  String _mimeTypeFor(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }

  @override
  void dispose() {
    _term.dispose();
    _meaning.dispose();
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
    if (_term.text.trim().isEmpty || _meaning.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('단어와 뜻은 필수입니다.')));
      return;
    }
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
            group: _group,
            term: _term.text.trim(),
            meaning: _meaning.text.trim(),
            partOfSpeech: _pos.text.trim(),
            phonetic: _phonetic.text.trim(),
            imageUrl: _imageUrl,
            examples: examples,
            createdAt: now,
            updatedAt: now,
          )
        : base.copyWith(
            group: _group,
            term: _term.text.trim(),
            meaning: _meaning.text.trim(),
            partOfSpeech: _pos.text.trim(),
            phonetic: _phonetic.text.trim(),
            imageUrl: _imageUrl,
            examples: examples,
            updatedAt: now,
          );

    await ref.read(repositoryProvider).upsertWord(word);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final savedWords =
        ref.watch(allWordsProvider).asData?.value ?? const <Word>[];
    final groups = <String>[''];
    for (final group in widget.groups) {
      if (group.isNotEmpty && !groups.contains(group)) groups.add(group);
    }
    if (_group.isNotEmpty && !groups.contains(_group)) groups.add(_group);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? '단어 추가' : '단어 편집'),
        actions: [
          TextButton(
            onPressed: _save,
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
          const Text(
            '저장 위치',
            style: TextStyle(color: AppColors.sub, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _group,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.folder_outlined),
              labelText: widget.wordbookTitle.isEmpty
                  ? '저장할 그룹'
                  : '${widget.wordbookTitle} · 저장할 그룹',
            ),
            items: [
              for (final group in groups)
                DropdownMenuItem(
                  value: group,
                  child: Text(group.isEmpty ? '그룹 없음' : group),
                ),
            ],
            onChanged: (group) => setState(() => _group = group ?? ''),
          ),
          const SizedBox(height: 20),
          const Text(
            '대표 이미지',
            style: TextStyle(color: AppColors.sub, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _imageEditor(),
          const SizedBox(height: 20),
          _termField(savedWords),
          _field(_meaning, '뜻 *', 'e.g. 중대한, 결정적인'),
          Row(
            children: [
              Expanded(child: _field(_pos, '품사', '형용사')),
              const SizedBox(width: 10),
              Expanded(child: _field(_phonetic, '발음기호', '/ˈkruːʃl/')),
            ],
          ),
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
                onPressed: _fetchingExamples ? null : _fetchExternalExamples,
                icon: _fetchingExamples
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.travel_explore_rounded, size: 18),
                label: Text(_fetchingExamples ? '검색 중' : '예문 가져오기'),
              ),
              TextButton.icon(
                onPressed: () => setState(_addExample),
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
                        hintText: 'This is a crucial decision.',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: e.t,
                      decoration: const InputDecoration(
                        labelText: '해석 (한글)',
                        hintText: '이것은 중대한 결정이다.',
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
            hintText: 'e.g. crucial',
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

  _EditableExample({
    String sentence = '',
    String translation = '',
    this.source = '',
    this.sourceId = '',
    this.license = '',
  }) : s = TextEditingController(text: sentence),
       t = TextEditingController(text: translation);

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
