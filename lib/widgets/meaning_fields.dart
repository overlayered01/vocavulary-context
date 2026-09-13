import 'package:flutter/material.dart';

import '../models/word.dart';
import '../theme.dart';

class MeaningList extends StatelessWidget {
  final List<String> meanings;
  final TextStyle? style;
  const MeaningList({super.key, required this.meanings, this.style});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (var i = 0; i < meanings.length; i++)
        Padding(
          padding: EdgeInsets.only(top: i == 0 ? 0 : 4),
          child: Text(
            '${meanings.length > 1 ? '${i + 1}. ' : ''}${meanings[i]}',
            style: style,
          ),
        ),
    ],
  );
}

class MeaningFields extends StatelessWidget {
  final List<TextEditingController> controllers;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  const MeaningFields({
    super.key,
    required this.controllers,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < controllers.length; i++)
          Padding(
            key: ObjectKey(controllers[i]),
            padding: const EdgeInsets.only(bottom: 12),
            child: TextField(
              controller: controllers[i],
              minLines: 1,
              maxLines: 3,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: controllers.length == 1 ? '뜻 *' : '뜻 ${i + 1}',
                hintText: '뜻을 하나씩 입력하세요',
                suffixIcon: controllers.length > 1
                    ? IconButton(
                        tooltip: '뜻 ${i + 1} 삭제',
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => onRemove(i),
                      )
                    : null,
              ),
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('뜻 추가'),
          ),
        ),
      ],
    );
  }
}

Future<List<String>?> showMeaningEditor(
  BuildContext context,
  List<String> meanings,
) {
  return showDialog<List<String>>(
    context: context,
    builder: (_) => _MeaningDialog(meanings: meanings),
  );
}

class _MeaningDialog extends StatefulWidget {
  final List<String> meanings;
  const _MeaningDialog({required this.meanings});

  @override
  State<_MeaningDialog> createState() => _MeaningDialogState();
}

class _MeaningDialogState extends State<_MeaningDialog> {
  late final List<TextEditingController> _controllers = [
    for (final value in widget.meanings.isEmpty ? [''] : widget.meanings)
      TextEditingController(text: value),
  ];
  String? _error;

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _save() {
    final values = Word.normalizeMeanings(_controllers.map((c) => c.text));
    if (values.isEmpty) {
      setState(() => _error = '뜻을 하나 이상 입력해 주세요.');
      return;
    }
    Navigator.pop(context, values);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('뜻 수정'),
      scrollable: true,
      content: SizedBox(
        width: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MeaningFields(
              controllers: _controllers,
              onAdd: () =>
                  setState(() => _controllers.add(TextEditingController())),
              onRemove: (i) {
                final removed = _controllers[i];
                setState(() => _controllers.removeAt(i));
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => removed.dispose(),
                );
              },
            ),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: AppColors.sub)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(onPressed: _save, child: const Text('저장')),
      ],
    );
  }
}
