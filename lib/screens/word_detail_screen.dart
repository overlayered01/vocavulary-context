import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/word.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/word_image.dart';
import 'word_edit_screen.dart';

/// 단어 상세: 뜻·예문·발음(TTS)·사전 딥링크.
class WordDetailScreen extends ConsumerStatefulWidget {
  final Word word;
  final String wordbookTitle;
  final List<String> groups;
  const WordDetailScreen({
    super.key,
    required this.word,
    this.wordbookTitle = '',
    this.groups = const [],
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
          groups: widget.groups,
          initialGroup: _word.group,
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

  @override
  Widget build(BuildContext context) {
    final word = _word;
    final settings = ref.watch(settingsProvider);
    final tts = ref.read(ttsServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('단어 상세'),
        actions: [
          IconButton(
            tooltip: word.favorite ? '즐겨찾기 해제' : '즐겨찾기',
            icon: Icon(word.favorite ? Icons.star : Icons.star_border),
            onPressed: _toggleFavorite,
          ),
          IconButton(
            tooltip: '단어 편집',
            icon: const Icon(Icons.edit_outlined),
            onPressed: _edit,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Tooltip(
                      message: '단어 편집',
                      child: InkWell(
                        onTap: _edit,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            word.term,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (word.phonetic.isNotEmpty ||
                        word.partOfSpeech.isNotEmpty)
                      Text(
                        [
                          word.phonetic,
                          word.partOfSpeech,
                        ].where((value) => value.isNotEmpty).join(' · '),
                        style: const TextStyle(color: AppColors.sub),
                      ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                icon: const Icon(Icons.volume_up),
                onPressed: () =>
                    tts.speak(word.term, locale: settings.ttsLocale),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            expandedInsets: EdgeInsets.zero,
            segments: const [
              ButtonSegment(
                value: 'en-US',
                icon: Icon(Icons.record_voice_over_outlined, size: 17),
                label: Text('미국식'),
              ),
              ButtonSegment(
                value: 'en-GB',
                icon: Icon(Icons.record_voice_over_outlined, size: 17),
                label: Text('영국식'),
              ),
            ],
            selected: {settings.ttsLocale},
            onSelectionChanged: (selection) {
              final locale = selection.first;
              ref.read(settingsProvider.notifier).setTtsLocale(locale);
              tts.speak(word.term, locale: locale);
            },
          ),
          const SizedBox(height: 12),
          Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: _edit,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '뜻',
                            style: TextStyle(color: AppColors.sub),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            word.meaning,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: AppColors.sub,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _imageSection(word),
          const SizedBox(height: 18),
          const _Label('예문'),
          ...word.examples.map(
            (e) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            e.sentence,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        InkWell(
                          onTap: () =>
                              tts.speak(e.sentence, locale: settings.ttsLocale),
                          child: const Icon(
                            Icons.volume_up,
                            size: 20,
                            color: AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                    if (e.translation.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        e.translation,
                        style: const TextStyle(
                          color: AppColors.sub,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const _Label('사전에서 더 보기'),
          _LinkTile(
            text: '네이버 사전 — 원어민 발음·예문',
            onTap: () => _open(
              'https://dict.naver.com/dict.search?query=${Uri.encodeComponent(word.term)}',
            ),
          ),
          _LinkTile(
            text: '구글 번역',
            onTap: () => _open(
              'https://translate.google.com/?sl=en&tl=ko&text=${Uri.encodeComponent(word.term)}',
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageSection(Word word) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                '대표 이미지',
                style: TextStyle(
                  color: AppColors.sub,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (word.imageUrl.isNotEmpty)
              TextButton.icon(
                onPressed: _edit,
                icon: const Icon(Icons.edit_outlined, size: 17),
                label: const Text('변경'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (word.imageUrl.isNotEmpty)
          Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: _edit,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: WordImage(
                  source: word.imageUrl,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          )
        else
          SizedBox(
            width: double.infinity,
            height: 112,
            child: OutlinedButton.icon(
              onPressed: _edit,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: const Text('대표 이미지 추가'),
            ),
          ),
      ],
    );
  }

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8, top: 4),
    child: Text(
      text,
      style: const TextStyle(
        color: AppColors.sub,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class _LinkTile extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _LinkTile({required this.text, required this.onTap});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(14),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(text, style: const TextStyle(fontSize: 14)),
        trailing: const Icon(Icons.open_in_new, size: 18, color: AppColors.sub),
        onTap: onTap,
      ),
    ),
  );
}
