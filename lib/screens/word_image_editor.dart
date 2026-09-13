import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/word.dart';
import '../providers.dart';
import '../services/word_image_picker.dart';
import '../theme.dart';
import '../widgets/word_image.dart';

/// 취소는 null, 이미지 삭제는 빈 문자열로 반환한다.
Future<String?> showWordImageEditor(BuildContext context, String source) {
  return showDialog<String>(
    context: context,
    builder: (_) => WordImageEditor(source: source),
  );
}

/// 저장된 단어의 이미지 필드만 변경하고 관련 화면을 갱신한다.
Future<Word?> editWordImage(
  BuildContext context,
  WidgetRef ref,
  Word word,
) async {
  final source = await showWordImageEditor(context, word.imageUrl);
  if (!context.mounted || source == null || source == word.imageUrl) {
    return null;
  }

  try {
    final repo = ref.read(repositoryProvider);
    final words = await repo.getWords(word.wordbookId);
    final latest = words
        .where((candidate) => candidate.id == word.id)
        .firstOrNull;
    if (!context.mounted) return null;
    if (latest == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('삭제된 단어입니다.')));
      return null;
    }
    final saved = await repo.upsertWord(
      latest.copyWith(imageUrl: source, updatedAt: DateTime.now()),
    );
    if (context.mounted) {
      ref.invalidate(wordsProvider(word.wordbookId));
      invalidateData(ref);
    }
    return saved;
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('이미지를 저장하지 못했습니다: $error')));
    }
    return null;
  }
}

class WordImageEditor extends StatefulWidget {
  final String source;

  const WordImageEditor({super.key, required this.source});

  @override
  State<WordImageEditor> createState() => _WordImageEditorState();
}

class _WordImageEditorState extends State<WordImageEditor> {
  late String _source = widget.source;
  bool _picking = false;
  String? _error;

  Future<void> _pick() async {
    setState(() {
      _picking = true;
      _error = null;
    });
    try {
      final source = await pickWordImage();
      if (mounted && source != null) setState(() => _source = source);
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error is FormatException
              ? error.message
              : '이미지를 불러오지 못했습니다.';
        });
      }
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 480,
          maxHeight: MediaQuery.sizeOf(context).height * .85,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '대표 이미지',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: ColoredBox(
                    color: AppColors.bg,
                    child: _source.isEmpty
                        ? const Center(
                            child: Icon(
                              Icons.image_outlined,
                              size: 40,
                              color: AppColors.sub,
                            ),
                          )
                        : InteractiveViewer(
                            child: WordImage(
                              source: _source,
                              fit: BoxFit.contain,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _picking ? null : _pick,
                      icon: _picking
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.add_photo_alternate_outlined),
                      label: Text(_source.isEmpty ? '이미지 추가' : '이미지 변경'),
                    ),
                  ),
                  if (_source.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    IconButton.outlined(
                      tooltip: '이미지 삭제',
                      onPressed: _picking
                          ? null
                          : () => setState(() {
                              _source = '';
                              _error = null;
                            }),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: const TextStyle(color: AppColors.sub)),
              ],
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('취소'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _picking
                        ? null
                        : () => Navigator.pop(context, _source),
                    child: const Text('저장'),
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
