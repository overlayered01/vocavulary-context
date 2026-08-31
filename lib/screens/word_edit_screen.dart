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
  late String _group;
  late List<({TextEditingController s, TextEditingController t})> _examples;

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
        .map(
          (e) => (
            s: TextEditingController(text: e.sentence),
            t: TextEditingController(text: e.translation),
          ),
        )
        .toList();
    if (_examples.isEmpty) _addExample();
  }

  void _addExample() {
    _examples.add((s: TextEditingController(), t: TextEditingController()));
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
    _examples = word.examples
        .map(
          (example) => (
            s: TextEditingController(text: example.sentence),
            t: TextEditingController(text: example.translation),
          ),
        )
        .toList();
    if (_examples.isEmpty) _addExample();
    setState(() {});
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
          (e) =>
              Example(sentence: e.s.text.trim(), translation: e.t.text.trim()),
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
                color: AppColors.accent,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '예문',
                style: TextStyle(
                  color: AppColors.sub,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton.icon(
                onPressed: () => setState(_addExample),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('예문 추가'),
              ),
            ],
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
            helperText: '저장된 단어를 선택하면 뜻과 예문을 자동으로 채웁니다.',
            suffixIcon: Icon(Icons.auto_awesome_outlined, size: 20),
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
